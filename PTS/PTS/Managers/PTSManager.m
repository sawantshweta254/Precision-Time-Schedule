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
            
            NSArray *fetchedList;
            
            if (user.empType == 2) {
               fetchedList = [self parsePTSListForAdmin:responseData existingPTSData:ptsIdsDBArray];
                if (fetchedList.count > 0) {
                    [finalPTSList addObjectsFromArray:fetchedList];
                }
                fetchPTSCompletionHandler(requestSuccessfull, finalPTSList, nil);
            }else if (user.empType == 3){
                NSArray *ptsList = [responseData objectForKey:@"flight_pts_info"];
                [self parsePTSListForMasterRedCap:ptsList existingPTSData:ptsIdsDBArray originalResponseData:responseData didParse:^(BOOL didParse, NSArray *parsedList) {
                    if (parsedList.count > 0) {
                        [finalPTSList addObjectsFromArray:fetchedList];
                    }
                    fetchPTSCompletionHandler(requestSuccessfull, finalPTSList, nil);
                }];
            }
//            else{
//                fetchedList = [self parsePTSList:responseData existingPTSData:ptsIdsDBArray];
//            }
            
//            if (fetchedList.count > 0) {
//                [finalPTSList addObjectsFromArray:fetchedList];
//            }
            
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
//    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
//
//
//    NSError *error;
//
//
//    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
//    NSArray *userArray = [moc executeFetchRequest:fetchRequest error:&error];
//    User *useTo;
//
//    if (userArray.count >0) {
//        for (User *user in userArray) {
//            NSLog(@"User name %@", user.userName);
//            useTo = user;
//        }
//
//    }
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

-(NSArray *) parsePTSList:(NSDictionary *)responseData existingPTSData:(NSArray *)ptsTaskIds{
    NSMutableArray *ptsListToReturn = [[NSMutableArray alloc] init];
    NSArray *ptsList = [responseData objectForKey:@"flight_pts_info"];
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    NSEntityDescription *ptsEntity = [NSEntityDescription entityForName:NSStringFromClass([PTSItem class]) inManagedObjectContext:moc];
    for (NSDictionary *ptsItem in ptsList) {
        NSNumber *ptsId = [NSNumber numberWithInt:[[ptsItem objectForKey:@"id"] intValue]];
        
        if (![ptsTaskIds containsObject:ptsId]) {
            PTSItem *pts = (PTSItem*)[[NSManagedObject alloc] initWithEntity:ptsEntity insertIntoManagedObjectContext:moc];
            
            pts.airlineName = [ptsItem objectForKey:@"airline_name"];
            pts.dutyManagerId = [[ptsItem objectForKey:@"duty_manager_id"] intValue];
            pts.dutyManagerName = [ptsItem objectForKey:@"dutymanager_name"];
            pts.flightDate = [ptsItem objectForKey:@"flight_date"];
            pts.flightNo = [ptsItem objectForKey:@"flight_no"];
            pts.flightTime = [ptsItem objectForKey:@"flight_time"];
            pts.flightId = [[ptsItem objectForKey:@"id"] intValue];//pts id
            pts.jsonData = [ptsItem objectForKey:@"json_data"];
            pts.ptsSubTaskId = [[ptsItem objectForKey:@"m_pts_id"] intValue];
            pts.ptsName = [ptsItem objectForKey:@"pts_name"];
            pts.redCapId = [[ptsItem objectForKey:@"redcap_id"] intValue];
            pts.redCapName = [ptsItem objectForKey:@"redcap_name"];
            pts.remarks = [ptsItem objectForKey:@"remarks"];
            pts.supervisorId = [[ptsItem objectForKey:@"supervisor_id"] intValue];
            pts.supervisorName = [ptsItem objectForKey:@"supervisor_name"];
            pts.timeWindow = [[ptsItem objectForKey:@"time_window"] intValue];
            pts.flightType = [[ptsItem objectForKey:@"type"] intValue];
            
            NSError *error;
            [moc save:&error];
            if (!error) {
                [ptsListToReturn addObject:pts];
            }
        }
        
        
    }
    
    return ptsListToReturn;
}

#pragma mark PTS For Master Redcap
-(void) parseInitialPTSTasksList:(NSArray *)flightInfo didParse:(void (^)(BOOL didParse))completionHandler{
    [self parsePTSListForMasterRedCap:flightInfo existingPTSData:nil originalResponseData: nil didParse:^(BOOL didParse, NSArray *parsedList) {
        completionHandler(didParse);
    }];
}

-(void) parsePTSListForMasterRedCap:(NSArray *)ptsList existingPTSData:(NSArray *)ptsTaskIds originalResponseData:(NSDictionary *)responseData didParse:(void (^)(BOOL didParse, NSArray *parsedList))completionHandler{
    
    NSMutableArray *ptsListToReturn = [[NSMutableArray alloc] init];
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    NSEntityDescription *ptsEntity = [NSEntityDescription entityForName:NSStringFromClass([PTSItem class]) inManagedObjectContext:moc];
   
    for (NSDictionary *ptsItem in ptsList) {
        
        NSNumber *ptsId = [NSNumber numberWithInt:[[ptsItem objectForKey:@"id"] intValue]];
        
        if (![ptsTaskIds containsObject:ptsId]) {
            PTSItem *pts = (PTSItem*)[[NSManagedObject alloc] initWithEntity:ptsEntity insertIntoManagedObjectContext:moc];
            
            
//                "tbl_group_id" = 1;
//                type = 1;
//                "flight_time" = "18:00";

            pts.dutyManagerId = [[ptsItem objectForKey:@"duty_manager_id"] intValue];
            pts.dutyManagerName = [ptsItem objectForKey:@"dutymanager_name"];
            pts.supervisorId = [[ptsItem objectForKey:@"supervisor_id"] intValue];
            pts.supervisorName = [ptsItem objectForKey:@"supervisor_name"];
            pts.redCapId = [[ptsItem objectForKey:@"redcap_id"] intValue];
            pts.redCapName = [ptsItem objectForKey:@"redcap_name"];
            pts.flightDate = [ptsItem objectForKey:@"flight_date"];
            pts.flightNo = [ptsItem objectForKey:@"flight_no"];
            pts.airlineName = [ptsItem objectForKey:@"airline_name"];
            pts.remarks = [ptsItem objectForKey:@"remarks"];
            pts.ptsName = [ptsItem objectForKey:@"pts_name"];
            pts.ptsSubTaskId = [[ptsItem objectForKey:@"m_pts_id"] intValue];
            pts.flightId = [[ptsItem objectForKey:@"id"] intValue];//pts id
            pts.flightType = [[ptsItem objectForKey:@"type"] intValue];
            pts.timeWindow = [[ptsItem objectForKey:@"time_window"] intValue];
            pts.flightTime = [ptsItem objectForKey:@"flight_time"];
            
            NSError *jsonError;
            NSString *originalString = [ptsItem objectForKey:@"json_data"];
            NSData *data = [[NSData alloc] initWithBase64EncodedString:originalString options:0];//[NSData dataFromBase64String:originalString];
            NSDictionary *jsonForPTSItem;
            if (data != nil) {
                jsonForPTSItem = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];
            }
            
           // comment = "";
           // "current_time" = 1530606135008;
            //"device_id" = "";
           // "execute_time" = 1801;
            
            //***********************"flight_id" = 7748;
            
          
            
//            pts.isRunning = [[jsonForPTSItem objectForKey:@"is_running"] intValue];
//
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//            pts.ptsStartTime = [dateFormatter dateFromString:[jsonForPTSItem objectForKey:@"pts_start_time"]];
//            pts.ptsEndTime = [dateFormatter dateFromString:[jsonForPTSItem objectForKey:@"pts_end_time"] ];
        
            pts.masterRedCap = [[jsonForPTSItem objectForKey:@"master_redcap"] boolValue];
            
            [self parseRedCapData:[ptsItem objectForKey:@"redcaps"] parsingCompleted:^(NSArray *redCaps, NSArray *tasksAssignedToRedCaps, BOOL isMasterRedcap) {
                pts.redCaps = [NSSet setWithArray:redCaps];
                if (jsonForPTSItem == nil) {
                    NSDictionary *ptsTasksDictionary = [[responseData objectForKey:@"pts"] valueForKey:[NSString stringWithFormat:@"%d",pts.ptsSubTaskId]];
                    pts.aboveWingActivities = [NSSet setWithArray:[self parseSubtaskForMasterRedCap:[ptsTasksDictionary objectForKey:@"above_list"] forWing:1 alreadyAssignedIds:tasksAssignedToRedCaps]];
                    pts.belowWingActivities = [NSSet setWithArray:[self parseSubtaskForMasterRedCap:[ptsTasksDictionary objectForKey:@"below_list"] forWing:2 alreadyAssignedIds:tasksAssignedToRedCaps]];
                    pts.masterRedCap = isMasterRedcap;
                }else{
                    [self parseJsonForPTSRedCap:jsonForPTSItem];
                }
                
            }];
           
            
            
            NSError *error;
            [moc save:&error];
            if (!error) {
                [ptsListToReturn addObject:pts];
            }
        }
        
    }
        
    
    completionHandler(TRUE, ptsListToReturn);
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
        
        ptsSubTask.userSubActFeedback = [ptsSubItem objectForKey:@"user_subact_feedback"];
        ptsSubTask.isRunning = [[ptsSubItem objectForKey:@"is_running"] intValue];
        ptsSubTask.isComplete = [[ptsSubItem objectForKey:@"is_complete"] intValue];
        ptsSubTask.negativeDataSendServer = [ptsSubItem objectForKey:@"negativeData_SendServer"];
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
            ptsSubTask.shouldBeInActive = TRUE;
        }
        
        NSError *error;
        [moc save:&error];
        
        [ptsSubListToReturn addObject:ptsSubTask];
    }
    
    return ptsSubListToReturn;
}


-(void) parseRedCapData:(NSArray *) redcapsData parsingCompleted:(void (^)(NSArray *redCaps, NSArray *tasksAssignedToRedCaps, BOOL isMasterRedcap))completionHandler{
    
    NSMutableArray *tasksAssignedToRedCaps = [[NSMutableArray alloc] init];
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

        if (redCap.redCapId != loggedInUser.userId) {
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
    
    completionHandler(redCaps, tasksAssignedToRedCaps, isMaster);
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

-(void) parseJsonForPTSRedCap:(NSDictionary *)ptsJson{
    
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
    
    
    if (ptsItem == nil) {
        NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
        NSEntityDescription *ptsEntity = [NSEntityDescription entityForName:NSStringFromClass([PTSItem class]) inManagedObjectContext:moc];
        ptsItem = (PTSItem*)[[NSManagedObject alloc] initWithEntity:ptsEntity insertIntoManagedObjectContext:moc];
    }
    
    //        itemFromSocket. = [ptsTask objectForKey:@"userid"];
    //        itemFromSocket.dev = [ptsTask objectForKey:@"device_id"];
    ptsItem.flightDate = [ptsTaskDictionary objectForKey:@"flight_date"];
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
    //    ptsItem.currentTime = [ptsTaskDictionary objectForKey:@"current_time"];//1528377701972 change to date format
    ptsItem.timerStopTime = [dateFormatter dateFromString:[ptsTaskDictionary objectForKey:@"timer_stop_time"]];
    //        itemFromSocket. = [ptsTask objectForKey:@"MsgType"];
    //        itemFromSocket. = [ptsTask objectForKey:@"user_name"];
    //        itemFromSocket. = [ptsTask objectForKey:@"user_type"];
    
    
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
        if (subTasks != nil) {
            NSPredicate *predicateForSubtask = [NSPredicate predicateWithFormat:@"subTaskId = %d", [[ptsSubItem objectForKey:@"sub_activity_id"] intValue]];
            NSArray *subTaskToEdit = [subTasks filteredArrayUsingPredicate:predicateForSubtask];
            ptsSubTask = [subTaskToEdit objectAtIndex:0];
        }else{
            ptsSubTask = (PTSSubTask*)[[NSManagedObject alloc] initWithEntity:ptsSubTaskEntity insertIntoManagedObjectContext:moc];
        }
        
        //            "type_id": "2",
        //            "current_time": "0",
        
        //                ptsSubTask.current_time = [ptsSubItem objectForKey:@"start_time"];
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
        ptsSubTask.timerExecutedTime = [dateFormatter dateFromString:[ptsSubItem objectForKey:@"time_execute_time"]];
        
        ptsSubTask.userSubActFeedback = [ptsSubItem objectForKey:@"user_subact_feedback"];
        ptsSubTask.isRunning = [[ptsSubItem objectForKey:@"is_running"] intValue];
        ptsSubTask.isComplete = [[ptsSubItem objectForKey:@"is_complete"] intValue];
        ptsSubTask.negativeDataSendServer = [ptsSubItem objectForKey:@"negativeData_SendServer"];
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
-(NSArray *) parsePTSListForAdmin:(NSDictionary *)responseData existingPTSData:(NSArray *)ptsTaskIds{
    NSMutableArray *ptsListToReturn = [[NSMutableArray alloc] init];
    NSArray *ptsList = [responseData objectForKey:@"flight_pts_info"];
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    NSEntityDescription *ptsEntity = [NSEntityDescription entityForName:NSStringFromClass([PTSItem class]) inManagedObjectContext:moc];
    
    for (NSDictionary *ptsItem in ptsList) {
        //        "adhoc_pts_id" = 5;
        
        NSNumber *ptsId = [NSNumber numberWithInt:[[ptsItem objectForKey:@"id"] intValue]];
        
        if (![ptsTaskIds containsObject:ptsId]) {
            PTSItem *pts = (PTSItem*)[[NSManagedObject alloc] initWithEntity:ptsEntity insertIntoManagedObjectContext:moc];
            
            //            pts.airlineName = [ptsItem objectForKey:@"airline_name"];
            pts.dutyManagerId = [[ptsItem objectForKey:@"duty_manager_id"] intValue];
            pts.dutyManagerName = [ptsItem objectForKey:@"dutymanager_name"];
            pts.supervisorId = [[ptsItem objectForKey:@"supervisor_id"] intValue];
            pts.supervisorName = [ptsItem objectForKey:@"supervisor_name"];
            pts.redCapId = [[ptsItem objectForKey:@"redcap_id"] intValue];
            pts.redCapName = [ptsItem objectForKey:@"redcap_name"];
            pts.ptsSubTaskId = [[ptsItem objectForKey:@"adhoc_pts_id"] intValue];
            pts.flightId = [[ptsItem objectForKey:@"id"] intValue];//pts id
            
            NSError *jsonError;
            NSString *originalString = [ptsItem objectForKey:@"json_data"];
            NSData *data = [[NSData alloc] initWithBase64EncodedString:originalString options:0];//[NSData dataFromBase64String:originalString];
            NSDictionary *jsonForPTSItem = [NSJSONSerialization JSONObjectWithData:data
                                                                           options:NSJSONReadingMutableContainers
                                                                             error:&jsonError];
            
            //            "current_time" = 0;
            //            "device_id" = "2CF35E75-2C65-4F73-AE08-7034F96ED28E";
            //            "execute_time" = "";
            //            "timer_stop_time" = 0;
            //            "user_name" = "Shweta Sawant";
            //            "user_type" = 3;
            //            userid = 25;
            //            "arr_dep_type" = "07:46";
            
            
            pts.flightDate = [jsonForPTSItem objectForKey:@"flight_date"];
            pts.flightNo = [jsonForPTSItem objectForKey:@"flight_num"];
            pts.flightTime = [jsonForPTSItem objectForKey:@"arr_dep_type"];
            pts.ptsName = [jsonForPTSItem objectForKey:@"pts_name"];
            //            pts.remarks = [ptsItem objectForKey:@"remarks"];
            pts.timeWindow = [[jsonForPTSItem objectForKey:@"pts_time"] intValue];
            pts.flightType = [[jsonForPTSItem objectForKey:@"flight_type"] intValue];
            
            pts.isRunning = [[jsonForPTSItem objectForKey:@"is_running"] intValue];
            pts.ptsSubTaskId = [[jsonForPTSItem objectForKey:@"m_pts_id"] intValue];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            pts.ptsStartTime = [dateFormatter dateFromString:[jsonForPTSItem objectForKey:@"pts_start_time"]];
            pts.ptsEndTime = [dateFormatter dateFromString:[jsonForPTSItem objectForKey:@"pts_end_time"] ];
            
            pts.airlineName = [jsonForPTSItem objectForKey:@"airline_name"];
            
            pts.aboveWingActivities = [NSSet setWithArray:[self parseSubTaskForAdmin:[jsonForPTSItem objectForKey:@"above_list"] storeIn:nil]];
            pts.belowWingActivities = [NSSet setWithArray:[self parseSubTaskForAdmin:[jsonForPTSItem objectForKey:@"below_list"] storeIn:nil]];

            NSError *error;
            [moc save:&error];
            if (!error) {
                [ptsListToReturn addObject:pts];
            }
        }
    
    }
    return ptsListToReturn;
}

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
//    ptsItem.currentTime = [ptsTaskDictionary objectForKey:@"current_time"];//1528377701972 change to date format
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
        
        //                ptsSubTask.current_time = [ptsSubItem objectForKey:@"start_time"];
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
        ptsSubTask.timerExecutedTime = [dateFormatter dateFromString:[ptsSubItem objectForKey:@"time_execute_time"]];
        
        ptsSubTask.userSubActFeedback = [ptsSubItem objectForKey:@"user_subact_feedback"];
        ptsSubTask.isRunning = [[ptsSubItem objectForKey:@"is_running"] intValue];
        ptsSubTask.isComplete = [[ptsSubItem objectForKey:@"is_complete"] intValue];
        ptsSubTask.negativeDataSendServer = [ptsSubItem objectForKey:@"negativeData_SendServer"];
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
