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
            NSArray *fetchedList = [self parsePTSList:responseData existingPTSData:ptsIdsDBArray];
            
            if (fetchedList.count > 0) {
                [finalPTSList addObjectsFromArray:fetchedList];
            }
            
        }
        fetchPTSCompletionHandler(requestSuccessfull, finalPTSList, nil);
    }];
    
}

-(ApiRequestData *) getRequestDataToFetchPTSList:(User *)user{
    ApiRequestData *requestData = [[ApiRequestData alloc] init];

    requestData.baseURL = @"http://techdew.co.in/pts/webapi/getmyappdata.php?cmd=";
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

-(NSArray *) parsePTSList:(NSDictionary *)responseData existingPTSData:(NSArray *)ptsTaskIds{
    NSMutableArray *ptsListToReturn = [[NSMutableArray alloc] init];
    NSArray *ptsList = [responseData objectForKey:@"flight_pts_info"];
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    NSEntityDescription *ptsEntity = [NSEntityDescription entityForName:NSStringFromClass([PTSItem class]) inManagedObjectContext:moc];
    for (NSDictionary *ptsItem in ptsList) {
        
//        NSError *jsonError;
//        NSString *originalString = [ptsItem objectForKey:@"json_data"];
//        NSData *data = [[NSData alloc] initWithBase64EncodedString:originalString options:0];//[NSData dataFromBase64String:originalString];
//        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
//                                                             options:NSJSONReadingMutableContainers
//                                                               error:&jsonError];
        
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
    requestData.baseURL = @"http://techdew.co.in/pts/webapi/pts_work_file/send_pts_info.php?cmd=";
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
    
    requestData.baseURL = @"http://techdew.co.in/pts/webapi/update_remarks.php?cmd=";
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
@end
