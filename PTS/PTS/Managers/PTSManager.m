//
//  PTSManager.m
//  PTS
//
//  Created by Shweta Sawant on 20/02/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "PTSManager.h"
#import "ApiRequestData.h"
#import <UIKit/UIKit.h>
#import "WebApiManager.h"
#import "User+CoreDataClass.h"
#import "PTSSubTask+CoreDataProperties.h"
#import "RedCap+CoreDataProperties.h"
#import "RedCapSubtask+CoreDataProperties.h"
#import "PTSItem+CoreDataClass.h"
#import "LoginManager.h"

@implementation PTSManager

static PTSManager *sharedInstance;

+(instancetype) sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PTSManager alloc] init];
    });
    return sharedInstance;
}

-(void) fetchPTSListFromDB:(User*)user completionHandler:(void(^)(NSArray *ptsTasks, NSError *error))fetchPTSCompletionHandler{
    
        NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PTSItem"];
        NSError *error;
        NSArray *ptsArray = [moc executeFetchRequest:fetchRequest error:&error];
        
        NSMutableArray *finalPTSList = [[NSMutableArray alloc] init];
        if (ptsArray.count > 0) {
            [finalPTSList addObjectsFromArray:ptsArray];
        }
        
        fetchPTSCompletionHandler(finalPTSList, nil);
}

-(void) fetchAndDeletePTSFromDB:(NSArray*)ptsToDelete{
    
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PTSItem"];
    NSError *error;
    NSArray *ptsArray = [moc executeFetchRequest:fetchRequest error:&error];
    
    for (PTSItem *ptsItem in ptsArray) {
        if ([ptsToDelete containsObject:[NSNumber numberWithInt:ptsItem.flightId] ]){
            [moc deleteObject:ptsItem];
            [moc save:&error];
        }
    }
    
}


-(void) fetchPTSListForUser:(User*)user completionHandler:(void(^)(BOOL fetchComplete, NSArray *ptsTasks, NSError *error))fetchPTSCompletionHandler{
    
    [[WebApiManager sharedInstance] initiatePost:[self getRequestDataToFetchPTSList:user] completionHandler:^(BOOL requestSuccessfull, id responseData) {
        NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PTSItem"];
        NSError *error;
        NSArray *ptsArray = [moc executeFetchRequest:fetchRequest error:&error];
        NSArray *ptsIdsDBArray = [ptsArray valueForKey:@"flightId"];
        
        NSMutableArray *finalPTSList = [[NSMutableArray alloc] init];
        if (ptsArray.count > 0) {
            [finalPTSList addObjectsFromArray:ptsArray];
        }
        
        if (requestSuccessfull) {
                        
                NSArray *ptsList = [responseData objectForKey:@"flight_pts_info"];
                [self parsePTSListForMasterRedCap:ptsList existingPTSData:ptsIdsDBArray originalResponseData:responseData didParse:^(BOOL didParse, NSArray *parsedList, NSArray *fetchedPTSIDs) {
                    
                    NSMutableArray *mutableExistingPTSIDs = [NSMutableArray arrayWithArray:ptsIdsDBArray];
                    [mutableExistingPTSIDs removeObjectsInArray:fetchedPTSIDs];
                    if (mutableExistingPTSIDs.count > 0) {
                        NSMutableArray *itemsToDelete = [[NSMutableArray alloc] init];
                        for (PTSItem *itemToDelete in finalPTSList) {
                            if ([mutableExistingPTSIDs containsObject:[NSNumber numberWithInt:itemToDelete.flightId]]) {
                                [itemsToDelete addObject:itemToDelete];
                            }
                        }
                        
                        [finalPTSList removeObjectsInArray:itemsToDelete];
                        [self fetchAndDeletePTSFromDB:mutableExistingPTSIDs];

                    }
                    
                    if (parsedList.count > 0) {
                        [finalPTSList addObjectsFromArray:parsedList];
                    }
                    fetchPTSCompletionHandler(requestSuccessfull, finalPTSList, nil);
                }];
            
        }else{
            fetchPTSCompletionHandler(requestSuccessfull, finalPTSList, nil);
        }
    }];
    
}

-(ApiRequestData *) getRequestDataToFetchPTSList:(User *)user{
    ApiRequestData *requestData = [[ApiRequestData alloc] init];

    requestData.baseURL = [NSString stringWithFormat:@"%@getmyappdata.php?cmd=", SERVICE_API_URL];
    requestData.postData = [self getDataRequest:user];
    
    return requestData;
}

-(NSDictionary *) getDataRequest:(User *)user{
    NSMutableDictionary *getListData = [[NSMutableDictionary alloc] init];
    
    UIDevice *device = [UIDevice currentDevice];
    NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
    [getListData setObject:currentDeviceId forKey:@"deviceid"];
    [getListData setObject:[NSNumber numberWithDouble:user.userId] forKey:@"userid"];
    [getListData setObject:[NSNumber numberWithDouble:user.empType] forKey:@"emp_type"];
    [getListData setObject:[NSNumber numberWithDouble:user.airportId] forKey:@"tbl_airport_id"];
    
    return getListData;
}

-(NSString *) getDateString:(NSString *)dateWithLmiter{
    if (![dateWithLmiter isKindOfClass:[NSNull class]]) {
        NSArray *partsOfStartDate = [dateWithLmiter componentsSeparatedByString:@"@@"];
        if (partsOfStartDate.count > 1) {
            return [partsOfStartDate objectAtIndex:1];
        }
    }
    
    return nil;
}

#pragma mark PTS For Master Redcap
-(void) parsePTSListForMasterRedCap:(NSArray *)ptsList existingPTSData:(NSArray *)ptsTaskIds originalResponseData:(NSDictionary *)responseData didParse:(void (^)(BOOL didParse, NSArray *parsedList, NSArray *fetchedIds))completionHandler{
    
    NSMutableArray *ptsListToReturn = [[NSMutableArray alloc] init];
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    NSEntityDescription *ptsEntity = [NSEntityDescription entityForName:NSStringFromClass([PTSItem class]) inManagedObjectContext:moc];
   
    int countForList = 0;
    NSMutableArray *fetchedPTSIDs = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *ptsItem in ptsList) {
        
        NSNumber *ptsId = [NSNumber numberWithInt:[[ptsItem objectForKey:@"id"] intValue]];
        
        [fetchedPTSIDs addObject:ptsId];
        
        if (![ptsTaskIds containsObject:ptsId]) {
            PTSItem *pts = (PTSItem*)[[NSManagedObject alloc] initWithEntity:ptsEntity insertIntoManagedObjectContext:moc];
            
            NSError *jsonError;
            NSString *originalString = [ptsItem objectForKey:@"json_data"];
            NSData *data = [[NSData alloc] initWithBase64EncodedString:originalString options:0];//[NSData dataFromBase64String:originalString];
            NSDictionary *jsonForPTSItem;
            if (data != nil) {
                jsonForPTSItem = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];
            }
            
            [self parsePTSFlightDetails:ptsItem storeIn:pts];
            
            NSDictionary *ptsTasksDictionary = [[responseData objectForKey:@"pts"] valueForKey:[NSString stringWithFormat:@"%d",pts.ptsSubTaskId]];
            [self parseRedCapData:[ptsItem objectForKey:@"redcaps"] forPTS:pts fromPTSData:ptsItem tasksDictionary:ptsTasksDictionary];
            
            if (jsonForPTSItem != nil) {
                [self parseJsonForPTSRedCap:jsonForPTSItem storeIn:pts completionHandler:^(PTSItem *pts) {
                    NSError *error;
                    [moc save:&error];
                    if (!error) {
                        [ptsListToReturn addObject:pts];
                    }
                    
                    if (ptsListToReturn.count == ptsList.count) {
                        completionHandler(TRUE, ptsListToReturn, fetchedPTSIDs);

                    }
                }];
            }else{
//                NSDictionary *ptsTasksDictionary = [[responseData objectForKey:@"pts"] valueForKey:[NSString stringWithFormat:@"%d",pts.ptsSubTaskId]];
//                [self parseRedCapData:[ptsItem objectForKey:@"redcaps"] forPTS:pts fromPTSData:ptsItem tasksDictionary:ptsTasksDictionary];
                NSError *error;
                [moc save:&error];
                if (!error) {
                    [ptsListToReturn addObject:pts];
                }
                if (ptsListToReturn.count == ptsList.count) {
                    completionHandler(TRUE, ptsListToReturn, fetchedPTSIDs);
                }
            }
            
        }else{
            countForList++;
        }
        
    }
    
    if (countForList == ptsList.count) {
        completionHandler(TRUE, ptsListToReturn, fetchedPTSIDs);
    }
    

}

-(void) parsePTSFlightDetailsFromJson:(NSDictionary *)ptsJson storeIn:(PTSItem *)pts{
    
//    "device_id" = "DB95E33D-27DC-4693-A1BF-42E8504FC347";
//    "user_name" = "Shweta Sawant";
//    "user_type" = 3;
//    userid = 25;

    pts.redCapId = [[ptsJson objectForKey:@"redcap_id"] intValue];
    pts.redCapName = [ptsJson objectForKey:@"redcap_name"];
    pts.flightDate = [ptsJson objectForKey:@"flight_date"];
    pts.flightNo = [ptsJson objectForKey:@"flight_num"];
    pts.airlineName = [ptsJson objectForKey:@"airline_name"];
    pts.remarks = [ptsJson objectForKey:@"remarks"];
    pts.ptsName = [ptsJson objectForKey:@"pts_name"];
    pts.ptsSubTaskId = [[ptsJson objectForKey:@"m_pts_id"] intValue];
    pts.flightId = [[ptsJson objectForKey:@"flight_id"] intValue];//pts id
    pts.flightType = [[ptsJson objectForKey:@"flight_type"] intValue];
    pts.timeWindow = [[ptsJson objectForKey:@"pts_time"] intValue];
    pts.flightTime = [ptsJson objectForKey:@"arr_dep_type"];
    pts.isRunning = [[ptsJson objectForKey:@"is_running"] intValue];
    pts.masterRedCap = [[ptsJson objectForKey:@"master_redcap"] boolValue];
    pts.coment = [ptsJson objectForKey:@"comment"];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];

    NSString *startTime = [ptsJson objectForKey:@"pts_start_time"];
    if (![startTime isEqualToString:@"0"]) {
        pts.ptsStartTime = [dateFormatter dateFromString:startTime];
    }
    
    NSString *endTime = [ptsJson objectForKey:@"pts_end_time"];
    if (![endTime isEqualToString:@"0"]) {
        pts.ptsEndTime = [dateFormatter dateFromString:endTime];
    }
    
    NSString *currentTime = [ptsJson objectForKey:@"current_time"];
    if (![currentTime isEqualToString:@"0"]) {
        pts.currentTime = [dateFormatter dateFromString:currentTime];
    }
    
    NSString *timerStopTime = [ptsJson objectForKey:@"timer_stop_time"];
    if (currentTime.length != 0) {
        pts.timerStopTime = [dateFormatter dateFromString:timerStopTime];
    }
    
    pts.executionTime = [ptsJson objectForKey:@"execute_time"]; //Change to date
    
    // comment = "";
    //"device_id" = "";
    
}

-(void) parsePTSFlightDetails:(NSDictionary *)ptsJson storeIn:(PTSItem *)pts{
    
    pts.dutyManagerId = [[ptsJson objectForKey:@"duty_manager_id"] intValue];
    pts.dutyManagerName = [ptsJson objectForKey:@"dutymanager_name"];
    pts.supervisorId = [[ptsJson objectForKey:@"supervisor_id"] intValue];
    pts.supervisorName = [ptsJson objectForKey:@"supervisor_name"];
    pts.redCapId = [[ptsJson objectForKey:@"redcap_id"] intValue];
    pts.redCapName = [ptsJson objectForKey:@"redcap_name"];
    pts.flightDate = [ptsJson objectForKey:@"flight_date"];
    pts.flightNo = [ptsJson objectForKey:@"flight_no"];
    if (pts.flightNo.length == 0) {
        pts.flightNo = [ptsJson objectForKey:@"flight_num"];
    }
    pts.airlineName = [ptsJson objectForKey:@"airline_name"];
    pts.remarks = [ptsJson objectForKey:@"remarks"];
    pts.ptsName = [ptsJson objectForKey:@"pts_name"];
    pts.ptsSubTaskId = [[ptsJson objectForKey:@"m_pts_id"] intValue];
    pts.flightId = [[ptsJson objectForKey:@"id"] intValue];//pts id
    pts.flightType = [[ptsJson objectForKey:@"type"] intValue];
    pts.timeWindow = [[ptsJson objectForKey:@"time_window"] intValue];
    pts.flightTime = [ptsJson objectForKey:@"flight_time"];
    pts.isRunning = [[ptsJson objectForKey:@"is_running"] intValue];
    pts.masterRedCap = [[ptsJson objectForKey:@"master_redcap"] boolValue];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *startTime = [ptsJson objectForKey:@"pts_start_time"];
    if (startTime != nil && ![startTime isEqualToString:@"0"]) {
        pts.ptsStartTime = [dateFormatter dateFromString:startTime];
    }
    
    NSString *endTime = [ptsJson objectForKey:@"pts_end_time"];
    if (endTime != nil && ![endTime isEqualToString:@"0"]) {
        pts.ptsEndTime = [dateFormatter dateFromString:endTime];
    }
    
    NSString *currentTime = [ptsJson objectForKey:@"current_time"];
    if (![currentTime isEqualToString:@"0"]) {
        pts.currentTime = [dateFormatter dateFromString:currentTime];
    }
    
    pts.executionTime = [ptsJson objectForKey:@"execute_time"]; //Change to date
    
    // comment = "";
    //"device_id" = "";
    
}

-(void) parseJsonForPTSRedCap:(NSDictionary *)ptsJson storeIn:(PTSItem *)pts completionHandler:(void(^) (PTSItem *pts))ptsToReturn{
    
    [self parsePTSFlightDetailsFromJson:ptsJson storeIn:pts];
    [self parseRedCapData:[ptsJson objectForKey:@"redcaps"] forPTS:pts fromPTSData:ptsJson tasksDictionary:nil];
    
    ptsToReturn(pts);
    
}

-(NSArray *) parseSubtaskForMasterRedCap:(NSArray *)subtasks forWing:(int)wingType alreadyAssignedIds:(NSArray *) assignedTaskIds{
    
    NSMutableArray *ptsSubListToReturn = [[NSMutableArray alloc] init];
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    NSEntityDescription *ptsSubTaskEntity = [NSEntityDescription entityForName:NSStringFromClass([PTSSubTask class]) inManagedObjectContext:moc];
    
    for (NSDictionary *ptsSubItem in subtasks) {
        PTSSubTask *ptsSubTask = (PTSSubTask*)[[NSManagedObject alloc] initWithEntity:ptsSubTaskEntity insertIntoManagedObjectContext:moc];
        
        
//        "current_time" = 0;
//        "type_id" = 1;

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
       
        ptsSubTask.subactivity = [ptsSubItem objectForKey:@"sub_activity_name"];
        ptsSubTask.subActivityType = [[ptsSubItem objectForKey:@"subactivity_type"] intValue];
        
        ptsSubTask.subactivityStartTime = [dateFormatter dateFromString:[self getDateString:[ptsSubItem objectForKey:@"subactivity_start_time"]]];
        ptsSubTask.subactivityEndTime = [dateFormatter dateFromString:[self getDateString:[ptsSubItem objectForKey:@"subactivity_end_time"]]];
        ptsSubTask.userStartTime = [dateFormatter dateFromString:[self getDateString:[ptsSubItem objectForKey:@"user_start_time"]]];
        ptsSubTask.userEndTime = [dateFormatter dateFromString:[self getDateString:[ptsSubItem objectForKey:@"user_end_time"]]];
        
//        ptsSubTask.timerStopTime = [dateFormatter dateFromString:[ptsSubItem objectForKey:@"timer_stop_time"]];
//        ptsSubTask.timerExecutedTime = [dateFormatter dateFromString:[ptsSubItem objectForKey:@"time_execute_time"]];
        
        NSString *userFeedback = [ptsSubItem objectForKey:@"user_subact_feedback"];
        ptsSubTask.userSubActFeedback =  ![userFeedback isKindOfClass:[NSNull class]] ? userFeedback : @"";
        ptsSubTask.isRunning = [[ptsSubItem objectForKey:@"is_running"] intValue];
        ptsSubTask.isComplete = [[ptsSubItem objectForKey:@"is_complete"] intValue];
        ptsSubTask.negativeDataSendServer = [[ptsSubItem objectForKey:@"negativeData_SendServer"] boolValue];
//        ptsSubTask.ptsTotalTime = [ptsSubItem objectForKey:@"pts_time"];
    
        ptsSubTask.subTaskId = [[ptsSubItem objectForKey:@"sub_activity_id"] intValue];
        ptsSubTask.mRefereceTimeId = [[ptsSubItem objectForKey:@"m_ref_time_id"] intValue];
        ptsSubTask.start = [[ptsSubItem objectForKey:@"start_time"] intValue];
        ptsSubTask.end = [[ptsSubItem objectForKey:@"end_time"] intValue];
        ptsSubTask.notations = [ptsSubItem objectForKey:@"notations"];
        ptsSubTask.referenceTime = [ptsSubItem objectForKey:@"ref_time"];
        ptsSubTask.ptsDetailsId = [[ptsSubItem objectForKey:@"pts_details_id"] intValue];
        ptsSubTask.ptsWing = wingType;
        ptsSubTask.calculatedPTSFinalTime = abs(ptsSubTask.start - ptsSubTask.end) + 1;
        
        if ([assignedTaskIds containsObject:[NSNumber numberWithInt:ptsSubTask.subTaskId]]) {
            ptsSubTask.shouldBeActive = TRUE;
        }
        
        NSError *error;
        [moc save:&error];
        
        [ptsSubListToReturn addObject:ptsSubTask];
    }
    
    return ptsSubListToReturn;
}


-(void) parseRedCapData:(NSArray *) redcapsData forPTS:(PTSItem *)pts fromPTSData:(NSDictionary *) ptsDictionary tasksDictionary:(NSDictionary *) wingsTaskDictionary
{
    NSMutableArray *tasksAssignedToRedCaps = [[NSMutableArray alloc] init];
    NSMutableArray *tasksAssignedToSelf = [[NSMutableArray alloc] init];
    NSMutableArray *redCaps = [[NSMutableArray alloc] init];
    
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    NSEntityDescription *redcapEntity = [NSEntityDescription entityForName:NSStringFromClass([RedCap class]) inManagedObjectContext:moc];
    
    BOOL isMaster = FALSE;
    
    for (NSDictionary *redCapToInsert in redcapsData) {
         RedCap *redCap = (RedCap*)[[NSManagedObject alloc] initWithEntity:redcapEntity insertIntoManagedObjectContext:moc];
        NSArray *subAtivitiesArray = [redCapToInsert objectForKey:@"group_json"];
        redCap.masterRedCap = [[redCapToInsert objectForKey:@"master_redcap"] boolValue];
        redCap.redcapName = [redCapToInsert objectForKey:@"name"];
        redCap.redCapId = [[redCapToInsert objectForKey:@"redcap_id"] intValue];
        redCap.tableGroupId = [[redCapToInsert objectForKey:@"tbl_group_id"] intValue];
        
        for (NSDictionary *rcSubActivity in subAtivitiesArray) {
            if ([[rcSubActivity objectForKey:@"type"] isEqualToString:@"ABOVE THE WING ACTIVITY"]) {
                redCap.aboveWingSubTasks = [NSSet setWithArray:[self parseRedCapSubActivity:[rcSubActivity objectForKey:@"sub_act_array"]]];
            }else{
                redCap.belowWingSubtask = [NSSet setWithArray:[self parseRedCapSubActivity:[rcSubActivity objectForKey:@"sub_act_array"]]];
            }
        }
        
        User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];

        if (redCap.redCapId == loggedInUser.userId) {
            [tasksAssignedToSelf addObjectsFromArray:[redCap.aboveWingSubTasks valueForKey:@"taskId"]];
            [tasksAssignedToSelf addObjectsFromArray:[redCap.belowWingSubtask valueForKey:@"taskId"]];
        }
        
        if (redCap.redCapId != loggedInUser.userId && !redCap.masterRedCap) {
            [tasksAssignedToRedCaps addObjectsFromArray:[redCap.aboveWingSubTasks valueForKey:@"taskId"]];
            [tasksAssignedToRedCaps addObjectsFromArray:[redCap.belowWingSubtask valueForKey:@"taskId"]];
        }
        
        if (redCap.masterRedCap && redCap.redCapId == loggedInUser.userId) {
            isMaster = TRUE;
        }
        
        NSError *error;
        [moc save:&error];
        if (!error) {
            [redCaps addObject:redCap];
        }
    }
    
    [tasksAssignedToSelf removeObjectsInArray:tasksAssignedToRedCaps];
    
    pts.redCaps = [NSSet setWithArray:redCaps];
    if (wingsTaskDictionary == nil) {
        
        NSSet *aboveWingActivities = [NSSet setWithArray:[self parseSubTaskForRedcap:[ptsDictionary objectForKey:@"above_list"] storeIn:[pts.aboveWingActivities allObjects]]];
        NSSet *belowWingActivities = [NSSet setWithArray:[self parseSubTaskForRedcap:[ptsDictionary objectForKey:@"below_list"] storeIn:[pts.belowWingActivities allObjects]]];
        if (pts.aboveWingActivities.count == 0) {
            pts.aboveWingActivities = aboveWingActivities;
        }
        if (pts.belowWingActivities.count == 0) {
            pts.belowWingActivities = belowWingActivities;
        }
        
//        pts.aboveWingActivities = [NSSet setWithArray:[self parseSubtaskForMasterRedCap:[ptsDictionary objectForKey:@"above_list"] forWing:1 alreadyAssignedIds:tasksAssignedToRedCaps]];
//        pts.belowWingActivities = [NSSet setWithArray:[self parseSubtaskForMasterRedCap:[ptsDictionary objectForKey:@"below_list"] forWing:2 alreadyAssignedIds:tasksAssignedToRedCaps]];
    }else{
        pts.aboveWingActivities = [NSSet setWithArray:[self parseSubtaskForMasterRedCap:[wingsTaskDictionary objectForKey:@"above_list"] forWing:1 alreadyAssignedIds:tasksAssignedToSelf]];
        pts.belowWingActivities = [NSSet setWithArray:[self parseSubtaskForMasterRedCap:[wingsTaskDictionary objectForKey:@"below_list"] forWing:2 alreadyAssignedIds:tasksAssignedToSelf]];
    }
    
    pts.masterRedCap = isMaster;
    
    
}

-(NSArray *) parseRedCapSubActivity:(NSArray *) redcapSubActivities{
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    NSEntityDescription *redcapSubTaskEntity = [NSEntityDescription entityForName:NSStringFromClass([RedCapSubtask class]) inManagedObjectContext:moc];
    
    NSMutableArray *subActivityArray = [[NSMutableArray alloc] init];
    for (NSDictionary *subActivity in redcapSubActivities) {
        RedCapSubtask *redcapSubtask = [[RedCapSubtask alloc] initWithEntity:redcapSubTaskEntity insertIntoManagedObjectContext:moc];
        
        redcapSubtask.taskId = [[subActivity objectForKey:@"id"] intValue];
        redcapSubtask.start = [[subActivity objectForKey:@"start"] intValue];
        redcapSubtask.end = [[subActivity objectForKey:@"end"] intValue];
        redcapSubtask.notations = [subActivity objectForKey:@"notations"];
        redcapSubtask.subactivity = [subActivity objectForKey:@"subactivity"];
        
        NSError *error;
        [moc save:&error];
        if (!error) {
            [subActivityArray addObject:redcapSubtask];
        }
    }
    
    return subActivityArray;
}


-(void) parsePTSUpdateReceivedForRedCap:(NSDictionary *) updatedPtsData{
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PTSItem"];
    NSError *error;
    NSArray *ptsArray = [moc executeFetchRequest:fetchRequest error:&error];
    int flightId = [[updatedPtsData objectForKey:@"flight_id"] intValue];
    NSPredicate *predicateForPTSWithId = [NSPredicate predicateWithFormat:@"flightId = %d", flightId];
    NSArray *ptsListForPTSId = [ptsArray filteredArrayUsingPredicate:predicateForPTSWithId];
    
    if (ptsListForPTSId.count > 0) {
        PTSItem *ptsItemToEdit = [ptsListForPTSId objectAtIndex:0];
        [self parsePTSItemForRedcap:updatedPtsData storeIn:ptsItemToEdit];
        
//        [self parseJsonForPTSRedCap:updatedPtsData storeIn:ptsItemToEdit completionHandler:^(PTSItem *pts) {
//
//        }];
        
        NSError *error;
        [moc save:&error];
        [self updatePTSListForAdminOnView];
        
    }
    
}

-(PTSItem *) parsePTSItemForRedcap:(NSDictionary *)ptsTaskDictionary storeIn:(PTSItem *) ptsItem{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
//    "user_name": "Shweta Sawant",
//    "userid": 25,
//    "current_time": "0",
//    "device_id": "2769DBFB-7AC7-48D4-AB02-6D1405AE90D4",
//    "MsgType": 2,
//    "user_type": 3,
    
//    "master_redcap" : true, admin
//    "user_type" : 3,admin
    
    
    if (ptsItem == nil) {
        NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
        NSEntityDescription *ptsEntity = [NSEntityDescription entityForName:NSStringFromClass([PTSItem class]) inManagedObjectContext:moc];
        ptsItem = (PTSItem*)[[NSManagedObject alloc] initWithEntity:ptsEntity insertIntoManagedObjectContext:moc];
    }
    
    ptsItem.flightDate = [ptsTaskDictionary objectForKey:@"flight_date"];
    ptsItem.flightId = [[ptsTaskDictionary objectForKey:@"flight_id"] intValue];
    ptsItem.flightNo = [ptsTaskDictionary objectForKey:@"flight_num"];
    ptsItem.flightType = [[ptsTaskDictionary objectForKey:@"flight_type"] intValue];
    ptsItem.flightTime = [ptsTaskDictionary objectForKey:@"arr_dep_type"];
    ptsItem.isRunning = [[ptsTaskDictionary objectForKey:@"is_running"] intValue];
    
    NSString *ptsStartTimeString = [ptsTaskDictionary objectForKey:@"pts_start_time"];
    NSString *ptsEndTimeString = [ptsTaskDictionary objectForKey:@"pts_end_time"];
    
    if (ptsStartTimeString.length != 0 && ptsStartTimeString.integerValue != 0) {
        ptsItem.ptsStartTime = [dateFormatter dateFromString:ptsStartTimeString];
    }
    
    if (ptsEndTimeString.length != 0 && ptsEndTimeString.integerValue != 0) {
        ptsItem.ptsEndTime = [dateFormatter dateFromString:ptsEndTimeString];
    }
    
    ptsItem.ptsName = [ptsTaskDictionary objectForKey:@"pts_name"];
    ptsItem.timeWindow = [[ptsTaskDictionary objectForKey:@"pts_time"] intValue];
    ptsItem.ptsSubTaskId = [[ptsTaskDictionary objectForKey:@"m_pts_id"] intValue];
    ptsItem.airlineName = [ptsTaskDictionary objectForKey:@"airline_name"];
    ptsItem.executionTime = [ptsTaskDictionary objectForKey:@"execute_time"];
    ptsItem.coment = [ptsTaskDictionary objectForKey:@"comment"];
    
    NSString *currentTime = [ptsTaskDictionary objectForKey:@"current_time"];
    if (![currentTime isEqualToString:@"0"]) {
        ptsItem.currentTime = [dateFormatter dateFromString:currentTime];
    }
    ptsItem.timerStopTime = [dateFormatter dateFromString:[ptsTaskDictionary objectForKey:@"timer_stop_time"]];

    
    NSSet *aboveWingActivities = [NSSet setWithArray:[self parseSubTaskForRedcap:[ptsTaskDictionary objectForKey:@"above_list"] storeIn:[ptsItem.aboveWingActivities allObjects]]];
    NSSet *belowWingActivities = [NSSet setWithArray:[self parseSubTaskForRedcap:[ptsTaskDictionary objectForKey:@"below_list"] storeIn:[ptsItem.belowWingActivities allObjects]]];
    if (ptsItem.aboveWingActivities.count == 0) {
        ptsItem.aboveWingActivities = aboveWingActivities;
    }
    if (ptsItem.belowWingActivities.count == 0) {
        ptsItem.belowWingActivities = belowWingActivities;
    }
    
    return ptsItem;
}

-(NSArray *) parseSubTaskForRedcap:(NSDictionary *)subTaskListDictionary storeIn:(NSArray *) subTasks{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSMutableArray *subTaskList = [[NSMutableArray alloc] init];
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    NSEntityDescription *ptsSubTaskEntity = [NSEntityDescription entityForName:NSStringFromClass([PTSSubTask class]) inManagedObjectContext:moc];
    for (NSDictionary *ptsSubItem in subTaskListDictionary) {
        PTSSubTask *ptsSubTask;
        if (subTasks.count > 0) {
            NSPredicate *predicateForSubtask = [NSPredicate predicateWithFormat:@"subTaskId = %d", [[ptsSubItem objectForKey:@"sub_activity_id"] intValue]];
            NSArray *subTaskToEdit = [subTasks filteredArrayUsingPredicate:predicateForSubtask];
            if (subTaskToEdit.count > 0) {
                ptsSubTask = [subTaskToEdit objectAtIndex:0];
            }else{
                ptsSubTask = (PTSSubTask*)[[NSManagedObject alloc] initWithEntity:ptsSubTaskEntity insertIntoManagedObjectContext:moc];
            }
        }else{
            ptsSubTask = (PTSSubTask*)[[NSManagedObject alloc] initWithEntity:ptsSubTaskEntity insertIntoManagedObjectContext:moc];
        }
        
        //            "type_id": "2",
        //            "current_time": "0",
        
//        if (ptsSubTask.shouldBeActive) {
//            break;
//        }
        NSString *cTime = [ptsSubItem objectForKey:@"currentTime"];
        if (![cTime isEqualToString:@"0"]) {
            ptsSubTask.current_time = [[NSDate alloc] initWithTimeIntervalSince1970:cTime.doubleValue];
        }
        ptsSubTask.subTaskId = [[ptsSubItem objectForKey:@"sub_activity_id"] intValue];
        //            ptsSubTask.mRefereceTimeId = [[ptsSubItem objectForKey:@"m_ref_time_id"] intValue];
        ptsSubTask.start = [[ptsSubItem objectForKey:@"start_time"] intValue];
        ptsSubTask.end = [[ptsSubItem objectForKey:@"end_time"] intValue];
        //            ptsSubTask.referenceTime = [ptsSubItem objectForKey:@"ref_time"];
        //            ptsSubTask.ptsDetailsId = [[ptsSubItem objectForKey:@"pts_details_id"] intValue];
        ptsSubTask.ptsWing = 1;
        ptsSubTask.calculatedPTSFinalTime = abs(ptsSubTask.start - ptsSubTask.end) + 1;
        ptsSubTask.subactivity = [ptsSubItem objectForKey:@"sub_activity_name"];
        ptsSubTask.subActivityType = [[ptsSubItem objectForKey:@"subactivity_type"] intValue];
        
        ptsSubTask.subactivityStartTime = [dateFormatter dateFromString:[self getDateString:[ptsSubItem objectForKey:@"subactivity_start_time"]]];
        ptsSubTask.subactivityEndTime = [dateFormatter dateFromString:[self getDateString:[ptsSubItem objectForKey:@"subactivity_end_time"]]];
        ptsSubTask.userStartTime = [dateFormatter dateFromString:[self getDateString:[ptsSubItem objectForKey:@"user_start_time"]]];
        ptsSubTask.userEndTime = [dateFormatter dateFromString:[self getDateString:[ptsSubItem objectForKey:@"user_end_time"]]];
        
        ptsSubTask.timerStopTime = [dateFormatter dateFromString:[ptsSubItem objectForKey:@"timer_stop_time"]];
        
        if (![[ptsSubItem objectForKey:@"time_execute_time"] isKindOfClass:[NSNull class]]) {
            ptsSubTask.timerExecutedTime = [ptsSubItem objectForKey:@"time_execute_time"];
        }
        if (![[ptsSubItem objectForKey:@"user_subact_feedback"] isKindOfClass:[NSNull class]]) {
            ptsSubTask.userSubActFeedback = [ptsSubItem objectForKey:@"user_subact_feedback"];
        }
        
        ptsSubTask.isRunning = [[ptsSubItem objectForKey:@"is_running"] intValue];
        ptsSubTask.isComplete = [[ptsSubItem objectForKey:@"is_complete"] intValue];
        ptsSubTask.negativeDataSendServer = [[ptsSubItem objectForKey:@"negativeData_SendServer"] boolValue];
        ptsSubTask.notations = [ptsSubItem objectForKey:@"notations"];
        //            ptsSubTask.ptsTotalTime = [ptsSubItem objectForKey:@"pts_time"];
        
        [subTaskList addObject:ptsSubTask];
        
    }
    
    return subTaskList;
}

#pragma mark PTS Sub Item Call
-(void) fetchPTSSubItemsListPTS:(PTSItem *)ptsItem completionHandler:(void(^)(BOOL fetchComplete, PTSItem *ptsItem, NSError *error))fetchPTSCompletionHandler{
    [[WebApiManager sharedInstance] initiatePost:[self getRequestDataToFetchPTSSubItemList:ptsItem.ptsSubTaskId] completionHandler:^(BOOL requestSuccessfull, id responseData) {
        if (requestSuccessfull) {
            PTSItem *ptsItemToReturn = [self insertSubTaskForPTS:ptsItem.flightId subTasks:[self parsePTSSubItemList:responseData subTaskId:ptsItem.ptsSubTaskId]];
            fetchPTSCompletionHandler(requestSuccessfull, ptsItemToReturn, nil);
        }
       
    }];
}

-(ApiRequestData *) getRequestDataToFetchPTSSubItemList:(int)ptsItemId{
    ApiRequestData *requestData = [[ApiRequestData alloc] init];
    requestData.baseURL = [NSString stringWithFormat:@"%@pts_work_file/send_pts_info.php?cmd=", SERVICE_API_URL];
    requestData.postData = [self getPTSSubitemRequest:ptsItemId];
    
    return requestData;
}

-(NSDictionary *) getPTSSubitemRequest:(int)ptsItemId{
    NSMutableDictionary *getListData = [[NSMutableDictionary alloc] init];
    
    [getListData setObject:[NSNumber numberWithInt:ptsItemId] forKey:@"pts_num"];
    return getListData;
}

-(NSArray *) parsePTSSubItemList:(NSDictionary *)responseData subTaskId:(int)taskId{
    
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    NSEntityDescription *ptsSubTaskEntity = [NSEntityDescription entityForName:NSStringFromClass([PTSSubTask class]) inManagedObjectContext:moc];

    
    NSMutableArray *ptsSubListToReturn = [[NSMutableArray alloc] init];
    NSString *ptsKey = [NSString stringWithFormat:@"pts_%d",taskId];
    NSArray *ptsListSubTasks = [responseData objectForKey:ptsKey];
    for (NSDictionary *tasksDic in ptsListSubTasks) {
        if ([[tasksDic objectForKey:@"type"] isEqualToString:@"ABOVE THE WING ACTIVITY"]) {
            NSArray *aboveWingTaskList = [tasksDic objectForKey:@"sub_act_array"];
            for (NSDictionary *ptsSubItem in aboveWingTaskList) {
                PTSSubTask *ptsSubTask = (PTSSubTask*)[[NSManagedObject alloc] initWithEntity:ptsSubTaskEntity insertIntoManagedObjectContext:moc];
                
                ptsSubTask.subTaskId = [[ptsSubItem objectForKey:@"id"] intValue];
                ptsSubTask.mRefereceTimeId = [[ptsSubItem objectForKey:@"m_ref_time_id"] intValue];
                ptsSubTask.start = [[ptsSubItem objectForKey:@"start"] intValue];
                ptsSubTask.end = [[ptsSubItem objectForKey:@"end"] intValue];
                ptsSubTask.subactivity = [ptsSubItem objectForKey:@"subactivity"];
                ptsSubTask.notations = [ptsSubItem objectForKey:@"notations"];
                ptsSubTask.referenceTime = [ptsSubItem objectForKey:@"ref_time"];
                ptsSubTask.ptsDetailsId = [[ptsSubItem objectForKey:@"pts_details_id"] intValue];
                ptsSubTask.ptsWing = 1;
                ptsSubTask.calculatedPTSFinalTime = abs(ptsSubTask.start - ptsSubTask.end) + 1;
                [ptsSubListToReturn addObject:ptsSubTask];
            }
            
        }else{
            NSArray *belowWingTaskList = [tasksDic objectForKey:@"sub_act_array"];
            for (NSDictionary *ptsSubItem in belowWingTaskList) {
                PTSSubTask *ptsSubTask = (PTSSubTask*)[[NSManagedObject alloc] initWithEntity:ptsSubTaskEntity insertIntoManagedObjectContext:moc];
                
                ptsSubTask.subTaskId = [[ptsSubItem objectForKey:@"id"] intValue];
                ptsSubTask.mRefereceTimeId = [[ptsSubItem objectForKey:@"m_ref_time_id"] intValue];
                ptsSubTask.start = [[ptsSubItem objectForKey:@"start"] intValue];
                ptsSubTask.end = [[ptsSubItem objectForKey:@"end"] intValue];
                ptsSubTask.subactivity = [ptsSubItem objectForKey:@"subactivity"];
                ptsSubTask.notations = [ptsSubItem objectForKey:@"notations"];
                ptsSubTask.referenceTime = [ptsSubItem objectForKey:@"ref_time"];
                ptsSubTask.ptsDetailsId = [[ptsSubItem objectForKey:@"pts_details_id"] intValue];
                ptsSubTask.ptsWing = 2;
                ptsSubTask.calculatedPTSFinalTime = abs(ptsSubTask.start - ptsSubTask.end) + 1;
                [ptsSubListToReturn addObject:ptsSubTask];
            }
        }
    }
    return ptsSubListToReturn;
}

-(PTSItem *) insertSubTaskForPTS:(int)ptsId subTasks:(NSArray *) subTasks{
    
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([PTSItem class])];
    NSError *error;
    NSArray *ptsItemList = [moc executeFetchRequest:fetchRequest error:&error];
    NSPredicate *predicateForPTSWithId = [NSPredicate predicateWithFormat:@"flightId = %d", ptsId];
    NSArray *ptsListForPTSId = [ptsItemList filteredArrayUsingPredicate:predicateForPTSWithId];

    PTSItem *ptsItemToReturn;
    if (ptsListForPTSId.count >0) {
        ptsItemToReturn = [ptsListForPTSId objectAtIndex:0];
    }
    
    NSPredicate *predicateForAWing = [NSPredicate predicateWithFormat:@"ptsWing = %d", 1];
    NSArray *wingATasks = [subTasks filteredArrayUsingPredicate:predicateForAWing];
    ptsItemToReturn.aboveWingActivities = [NSSet setWithArray:wingATasks];

    NSPredicate *predicateForBWing = [NSPredicate predicateWithFormat:@"ptsWing = %d", 2];
    NSArray *wingBTasks = [subTasks filteredArrayUsingPredicate:predicateForBWing];
    ptsItemToReturn.belowWingActivities = [NSSet setWithArray:wingBTasks];

    [moc save:&error];
    return ptsItemToReturn;
}

#pragma mark Update remark
-(void) updateRemarkForSubtask:(PTSSubTask *)task forFlight:(int) flightId completionHandler:(void(^)(BOOL isSuccessfull))remarkUpdateCompletionHandler{
    [[WebApiManager sharedInstance] initiatePost:[self getRequestDataToUpdatePTSSubTaskRemark:task forFlight:flightId] completionHandler:^(BOOL requestSuccessfull, id responseData) {
        remarkUpdateCompletionHandler(requestSuccessfull);
    }];
}

-(ApiRequestData *) getRequestDataToUpdatePTSSubTaskRemark:(PTSSubTask *)task forFlight:(int) flightId{
    ApiRequestData *requestData = [[ApiRequestData alloc] init];
    
    requestData.baseURL = [NSString stringWithFormat:@"%@update_remarks.php?cmd=", SERVICE_API_URL];
    requestData.postData = [self getDatForUpdateRemark:task forFlight:flightId];
    
    return requestData;
}

-(NSDictionary *) getDatForUpdateRemark:(PTSSubTask *)task forFlight:(int) flightId{
    NSMutableDictionary *remarkUpdateData = [[NSMutableDictionary alloc] init];
    User *user = [self getLoggedInUser];

    UIDevice *device = [UIDevice currentDevice];
    NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
    [remarkUpdateData setObject:currentDeviceId forKey:@"deviceid"];
    [remarkUpdateData setObject:[NSNumber numberWithDouble:user.userId] forKey:@"userid"];
    [remarkUpdateData setObject:[NSNumber numberWithInt:flightId] forKey:@"actual_flight_id"];
    [remarkUpdateData setObject:[NSNumber numberWithInt:task.subTaskId] forKey:@"sub_activity_id"];
    [remarkUpdateData setObject:task.userSubActFeedback forKey:@"remarks"];
    
    return remarkUpdateData;
}

-(User *) getLoggedInUser{
    
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSError *error;
    NSArray *userArray = [moc executeFetchRequest:fetchRequest error:&error];
    User *loggedInUser;
    if (userArray.count >0) {
        loggedInUser = [userArray objectAtIndex:0];
    }
    
    return loggedInUser;
}

#pragma mark Admin methods
//-(NSArray *) parsePTSListForAdmin:(NSDictionary *)responseData existingPTSData:(NSArray *)ptsTaskIds{
//    NSMutableArray *ptsListToReturn = [[NSMutableArray alloc] init];
//    NSArray *ptsList = [responseData objectForKey:@"flight_pts_info"];
//    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
//    NSEntityDescription *ptsEntity = [NSEntityDescription entityForName:NSStringFromClass([PTSItem class]) inManagedObjectContext:moc];
//
//    for (NSDictionary *ptsItem in ptsList) {
//        //        "adhoc_pts_id" = 5;
//
//        NSNumber *ptsId = [NSNumber numberWithInt:[[ptsItem objectForKey:@"id"] intValue]];
//
//        if (![ptsTaskIds containsObject:ptsId]) {
//            PTSItem *pts = (PTSItem*)[[NSManagedObject alloc] initWithEntity:ptsEntity insertIntoManagedObjectContext:moc];
//
//            //            pts.airlineName = [ptsItem objectForKey:@"airline_name"];
//            pts.dutyManagerId = [[ptsItem objectForKey:@"duty_manager_id"] intValue];
//            pts.dutyManagerName = [ptsItem objectForKey:@"dutymanager_name"];
//            pts.supervisorId = [[ptsItem objectForKey:@"supervisor_id"] intValue];
//            pts.supervisorName = [ptsItem objectForKey:@"supervisor_name"];
//            pts.redCapId = [[ptsItem objectForKey:@"redcap_id"] intValue];
//            pts.redCapName = [ptsItem objectForKey:@"redcap_name"];
//            pts.ptsSubTaskId = [[ptsItem objectForKey:@"adhoc_pts_id"] intValue];
//            pts.flightId = [[ptsItem objectForKey:@"id"] intValue];//pts id
//
//            NSError *jsonError;
//            NSString *originalString = [ptsItem objectForKey:@"json_data"];
//            NSData *data = [[NSData alloc] initWithBase64EncodedString:originalString options:0];//[NSData dataFromBase64String:originalString];
//            NSDictionary *jsonForPTSItem = [NSJSONSerialization JSONObjectWithData:data
//                                                                           options:NSJSONReadingMutableContainers
//                                                                             error:&jsonError];
//
//            //            "current_time" = 0;
//            //            "device_id" = "2CF35E75-2C65-4F73-AE08-7034F96ED28E";
//            //            "execute_time" = "";
//            //            "timer_stop_time" = 0;
//            //            "user_name" = "Shweta Sawant";
//            //            "user_type" = 3;
//            //            userid = 25;
//            //            "arr_dep_type" = "07:46";
//
//
//            pts.flightDate = [jsonForPTSItem objectForKey:@"flight_date"];
//            pts.flightNo = [jsonForPTSItem objectForKey:@"flight_num"];
//            pts.flightTime = [jsonForPTSItem objectForKey:@"arr_dep_type"];
//            pts.ptsName = [jsonForPTSItem objectForKey:@"pts_name"];
//            //            pts.remarks = [ptsItem objectForKey:@"remarks"];
//            pts.timeWindow = [[jsonForPTSItem objectForKey:@"pts_time"] intValue];
//            pts.flightType = [[jsonForPTSItem objectForKey:@"flight_type"] intValue];
//
//            pts.isRunning = [[jsonForPTSItem objectForKey:@"is_running"] intValue];
//            pts.ptsSubTaskId = [[jsonForPTSItem objectForKey:@"m_pts_id"] intValue];
//
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//            pts.ptsStartTime = [dateFormatter dateFromString:[jsonForPTSItem objectForKey:@"pts_start_time"]];
//            pts.ptsEndTime = [dateFormatter dateFromString:[jsonForPTSItem objectForKey:@"pts_end_time"] ];
//
//            pts.airlineName = [jsonForPTSItem objectForKey:@"airline_name"];
//
//            pts.aboveWingActivities = [NSSet setWithArray:[self parseSubTaskForAdmin:[jsonForPTSItem objectForKey:@"above_list"] storeIn:nil]];
//            pts.belowWingActivities = [NSSet setWithArray:[self parseSubTaskForAdmin:[jsonForPTSItem objectForKey:@"below_list"] storeIn:nil]];
//
//            NSError *error;
//            [moc save:&error];
//            if (!error) {
//                [ptsListToReturn addObject:pts];
//            }
//        }
//
//    }
//    return ptsListToReturn;
//}

-(void) parseUpdatesReceivedForPTS:(NSDictionary *)ptsTask{
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PTSItem"];
    NSError *error;
    NSArray *ptsArray = [moc executeFetchRequest:fetchRequest error:&error];
//    NSArray *flightIdsDBArray = [ptsArray valueForKey:@"flightId"];
    
    int flightId = [[ptsTask objectForKey:@"flight_id"] intValue];
    NSPredicate *predicateForPTSWithId = [NSPredicate predicateWithFormat:@"flightId = %d", flightId];
    NSArray *ptsListForPTSId = [ptsArray filteredArrayUsingPredicate:predicateForPTSWithId];

    if (ptsListForPTSId.count > 0) {
        PTSItem *ptsItemToEdit = [ptsListForPTSId objectAtIndex:0];
//    }
//    if ([flightIdsDBArray containsObject:[NSNumber numberWithInt:[[ptsTask objectForKey:@"flight_id"] intValue]]]) {
        PTSItem *itemFromSocket = [self parsePTSItemForAdmin:ptsTask storeIn:ptsItemToEdit];
        
//        if (itemFromSocket != nil && [flightIdsDBArray containsObject:[NSNumber numberWithInt:itemFromSocket.flightId]]) {
//            NSPredicate *predicateForPTSWithId = [NSPredicate predicateWithFormat:@"flightId = %d", itemFromSocket.flightId];
//            NSArray *ptsListForPTSId = [ptsArray filteredArrayUsingPredicate:predicateForPTSWithId];
//
//            PTSItem *ptsItemToEdit;
//            if (ptsListForPTSId.count > 0) {
//                ptsItemToEdit = [ptsListForPTSId objectAtIndex:0];
//            }
//
//            ptsItemToEdit.flightId = itemFromSocket.flightId;
//            ptsItemToEdit.flightNo = itemFromSocket.flightNo;
//            ptsItemToEdit.flightType = itemFromSocket.flightType;
//            ptsItemToEdit.flightTime = itemFromSocket.flightTime;
//            ptsItemToEdit.isRunning = itemFromSocket.isRunning;
//            ptsItemToEdit.ptsStartTime = itemFromSocket.ptsStartTime;
//            ptsItemToEdit.ptsEndTime = itemFromSocket.ptsEndTime;
//            ptsItemToEdit.ptsName = itemFromSocket.ptsName;
//            ptsItemToEdit.timeWindow = itemFromSocket.timeWindow;
//            ptsItemToEdit.ptsSubTaskId = itemFromSocket.ptsSubTaskId;
//            ptsItemToEdit.airlineName = itemFromSocket.airlineName;
//            ptsItemToEdit.executionTime = itemFromSocket.executionTime;
//            ptsItemToEdit.currentTime = itemFromSocket.currentTime;
//            ptsItemToEdit.timerStopTime = itemFromSocket.timerStopTime;
//            //        itemFromSocket. = [ptsTask objectForKey:@"MsgType"];
//            //        itemFromSocket. = [ptsTask objectForKey:@"user_name"];
//            //        itemFromSocket. = [ptsTask objectForKey:@"user_type"];
//
//            ptsItemToEdit.aboveWingActivities = itemFromSocket.aboveWingActivities;
//            ptsItemToEdit.belowWingActivities = itemFromSocket.belowWingActivities;
//
//
//        }
        NSError *error;
        [moc save:&error];
        [self updatePTSListForAdminOnView];
    }
}

-(PTSItem *) parsePTSItemForAdmin:(NSDictionary *)ptsTaskDictionary storeIn:(PTSItem *) ptsItem{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
//    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
//    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PTSItem"];
//    NSError *error;
//    NSArray *ptsArray = [moc executeFetchRequest:fetchRequest error:&error];
//    NSPredicate *predicateForPTSWithId = [NSPredicate predicateWithFormat:@"flightId = %d", ptsId];
//    NSArray *ptsListForPTSId = [ptsItemList filteredArrayUsingPredicate:predicateForPTSWithId];

    if (ptsItem == nil) {
        NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
        NSEntityDescription *ptsEntity = [NSEntityDescription entityForName:NSStringFromClass([PTSItem class]) inManagedObjectContext:moc];
        ptsItem = (PTSItem*)[[NSManagedObject alloc] initWithEntity:ptsEntity insertIntoManagedObjectContext:moc];
    }
    
    //        itemFromSocket. = [ptsTask objectForKey:@"userid"];
    //        itemFromSocket.dev = [ptsTask objectForKey:@"device_id"];
    ptsItem.flightId = [[ptsTaskDictionary objectForKey:@"flight_id"] intValue];
    ptsItem.flightNo = [ptsTaskDictionary objectForKey:@"flight_num"];
    ptsItem.flightType = [[ptsTaskDictionary objectForKey:@"flight_type"] intValue];
    ptsItem.flightTime = [ptsTaskDictionary objectForKey:@"arr_dep_type"];
    ptsItem.isRunning = [[ptsTaskDictionary objectForKey:@"is_running"] intValue];
    
    ptsItem.ptsStartTime = [dateFormatter dateFromString:[ptsTaskDictionary objectForKey:@"pts_start_time"]];
    ptsItem.ptsEndTime = [dateFormatter dateFromString:[ptsTaskDictionary objectForKey:@"pts_end_time"]];
    
    ptsItem.ptsName = [ptsTaskDictionary objectForKey:@"pts_name"];
    ptsItem.timeWindow = [[ptsTaskDictionary objectForKey:@"pts_time"] intValue];
    ptsItem.ptsSubTaskId = [[ptsTaskDictionary objectForKey:@"m_pts_id"] intValue];
    ptsItem.airlineName = [ptsTaskDictionary objectForKey:@"airline_name"];
    ptsItem.executionTime = [ptsTaskDictionary objectForKey:@"execute_time"];
    NSString *currentTime = [ptsTaskDictionary objectForKey:@"current_time"];
    if (![currentTime isEqualToString:@"0"]) {
        ptsItem.currentTime = [dateFormatter dateFromString:currentTime];
    }

    ptsItem.timerStopTime = [dateFormatter dateFromString:[ptsTaskDictionary objectForKey:@"timer_stop_time"]];
    //        itemFromSocket. = [ptsTask objectForKey:@"MsgType"];
    //        itemFromSocket. = [ptsTask objectForKey:@"user_name"];
    //        itemFromSocket. = [ptsTask objectForKey:@"user_type"];
    
    
    NSSet *aboveWingActivities = [NSSet setWithArray:[self parseSubTaskForAdmin:[ptsTaskDictionary objectForKey:@"above_list"] storeIn:[ptsItem.aboveWingActivities allObjects]]];
    NSSet *belowWingActivities = [NSSet setWithArray:[self parseSubTaskForAdmin:[ptsTaskDictionary objectForKey:@"below_list"] storeIn:[ptsItem.belowWingActivities allObjects]]];
    if (ptsItem.aboveWingActivities.count == 0) {
        ptsItem.aboveWingActivities = aboveWingActivities;
    }
    if (ptsItem.belowWingActivities.count == 0) {
        ptsItem.belowWingActivities = belowWingActivities;
    }
    
    return ptsItem;
}

-(NSArray *) parseSubTaskForAdmin:(NSDictionary *)subTaskListDictionary storeIn:(NSArray *) subTasks{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSMutableArray *subTaskList = [[NSMutableArray alloc] init];
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    NSEntityDescription *ptsSubTaskEntity = [NSEntityDescription entityForName:NSStringFromClass([PTSSubTask class]) inManagedObjectContext:moc];
    for (NSDictionary *ptsSubItem in subTaskListDictionary) {
        PTSSubTask *ptsSubTask;
        if (subTasks != nil) {
            NSPredicate *predicateForSubtask = [NSPredicate predicateWithFormat:@"subTaskId = %d", [[ptsSubItem objectForKey:@"sub_activity_id"] intValue]];
            NSArray *subTaskToEdit = [subTasks filteredArrayUsingPredicate:predicateForSubtask];
            ptsSubTask = [subTaskToEdit objectAtIndex:0];
        }else{
            ptsSubTask = (PTSSubTask*)[[NSManagedObject alloc] initWithEntity:ptsSubTaskEntity insertIntoManagedObjectContext:moc];
        }

        //            "type_id": "2",
        //            "current_time": "0",
        
        NSString *cTime = [ptsSubItem objectForKey:@"currentTime"];
        if (![cTime isEqualToString:@"0"]) {
            ptsSubTask.current_time = [[NSDate alloc] initWithTimeIntervalSince1970:cTime.doubleValue];
        }
        
        ptsSubTask.subTaskId = [[ptsSubItem objectForKey:@"sub_activity_id"] intValue];
        //            ptsSubTask.mRefereceTimeId = [[ptsSubItem objectForKey:@"m_ref_time_id"] intValue];
        ptsSubTask.start = [[ptsSubItem objectForKey:@"start_time"] intValue];
        ptsSubTask.end = [[ptsSubItem objectForKey:@"end_time"] intValue];
        //            ptsSubTask.referenceTime = [ptsSubItem objectForKey:@"ref_time"];
        //            ptsSubTask.ptsDetailsId = [[ptsSubItem objectForKey:@"pts_details_id"] intValue];
        ptsSubTask.ptsWing = 1;
        ptsSubTask.calculatedPTSFinalTime = abs(ptsSubTask.start - ptsSubTask.end) + 1;
        ptsSubTask.subactivity = [ptsSubItem objectForKey:@"sub_activity_name"];
        ptsSubTask.subActivityType = [[ptsSubItem objectForKey:@"subactivity_type"] intValue];
        
        ptsSubTask.subactivityStartTime = [dateFormatter dateFromString:[self getDateString:[ptsSubItem objectForKey:@"subactivity_start_time"]]];
        ptsSubTask.subactivityEndTime = [dateFormatter dateFromString:[self getDateString:[ptsSubItem objectForKey:@"subactivity_end_time"]]];
        ptsSubTask.userStartTime = [dateFormatter dateFromString:[self getDateString:[ptsSubItem objectForKey:@"user_start_time"]]];
        ptsSubTask.userEndTime = [dateFormatter dateFromString:[self getDateString:[ptsSubItem objectForKey:@"user_end_time"]]];
        
        ptsSubTask.timerStopTime = [dateFormatter dateFromString:[ptsSubItem objectForKey:@"timer_stop_time"]];
        
        if (![[ptsSubItem objectForKey:@"time_execute_time"] isKindOfClass:[NSNull class]]) {
            ptsSubTask.timerExecutedTime = [ptsSubItem objectForKey:@"time_execute_time"];
        }
        
        ptsSubTask.userSubActFeedback = [ptsSubItem objectForKey:@"user_subact_feedback"];
        ptsSubTask.isRunning = [[ptsSubItem objectForKey:@"is_running"] intValue];
        ptsSubTask.isComplete = [[ptsSubItem objectForKey:@"is_complete"] intValue];
        ptsSubTask.negativeDataSendServer = [[ptsSubItem objectForKey:@"negativeData_SendServer"] boolValue];
        ptsSubTask.notations = [ptsSubItem objectForKey:@"notations"];
        //            ptsSubTask.ptsTotalTime = [ptsSubItem objectForKey:@"pts_time"];
        
        [subTaskList addObject:ptsSubTask];
        
    }
    
    return subTaskList;
}

-(void) updatePTSListForAdminOnView{
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PTSItem"];
    NSError *error;
    NSArray *ptsArray = [moc executeFetchRequest:fetchRequest error:&error];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PTSListUpdated" object:ptsArray];
}

@end
