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
        fetchPTSCompletionHandler(requestSuccessfull, [self parsePTSList:responseData], nil);
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

-(NSArray *) parsePTSList:(NSDictionary *)responseData{
    NSMutableArray *ptsListToReturn = [[NSMutableArray alloc] init];
    NSArray *ptsList = [responseData objectForKey:@"flight_pts_info"];
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    NSEntityDescription *ptsEntity = [NSEntityDescription entityForName:NSStringFromClass([PTSItem class]) inManagedObjectContext:moc];
    for (NSDictionary *ptsItem in ptsList) {
        PTSItem *pts = (PTSItem*)[[NSManagedObject alloc] initWithEntity:ptsEntity insertIntoManagedObjectContext:moc];
        
        pts.airlineName = [ptsItem objectForKey:@"airline_name"];
        pts.dutyManagerId = [[ptsItem objectForKey:@"duty_manager_id"] intValue];
        pts.dutyManagerName = [ptsItem objectForKey:@"dutymanager_name"];
        pts.flightDate = [ptsItem objectForKey:@"flight_date"];
        pts.flightNo = [ptsItem objectForKey:@"flight_no"];
        pts.flightTime = [ptsItem objectForKey:@"flight_time"];
        pts.ptsId = [[ptsItem objectForKey:@"id"] intValue];
        pts.jsonData = [ptsItem objectForKey:@"json_data"];
        pts.ptsSubTaskId = [[ptsItem objectForKey:@"m_pts_id"] intValue];
        pts.ptsName = [ptsItem objectForKey:@"pts_name"];
        pts.redCapId = [[ptsItem objectForKey:@"redcap_id"] intValue];
        pts.redCapName = [ptsItem objectForKey:@"redcap_name"];
        pts.remarks = [ptsItem objectForKey:@"remarks"];
        pts.supervisorId = [[ptsItem objectForKey:@"supervisor_id"] intValue];
        pts.supervisorName = [ptsItem objectForKey:@"supervisor_name"];
        pts.timeWindow = [[ptsItem objectForKey:@"time_window"] intValue];
        pts.ptsType = [[ptsItem objectForKey:@"type"] intValue];
        
        NSError *error;
        [moc save:&error];
        if (!error) {
            [ptsListToReturn addObject:pts];
        }
        
    }
    
    return ptsListToReturn;
}

#pragma mark PTS Sub Item Call
-(void) fetchPTSSubItemsListPTS:(PTSItem *)ptsItem completionHandler:(void(^)(BOOL fetchComplete, PTSItem *ptsItem, NSError *error))fetchPTSCompletionHandler{
    [[WebApiManager sharedInstance] initiatePost:[self getRequestDataToFetchPTSSubItemList:ptsItem.ptsSubTaskId] completionHandler:^(BOOL requestSuccessfull, id responseData) {
        PTSItem *ptsItemToReturn = [self insertSubTaskForPTS:ptsItem.ptsId subTasks:[self parsePTSSubItemList:responseData]];
        fetchPTSCompletionHandler(requestSuccessfull, ptsItemToReturn, nil);
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

-(NSArray *) parsePTSSubItemList:(NSDictionary *)responseData{
    
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    NSEntityDescription *ptsSubTaskEntity = [NSEntityDescription entityForName:NSStringFromClass([PTSSubTask class]) inManagedObjectContext:moc];

    
    NSMutableArray *ptsSubListToReturn = [[NSMutableArray alloc] init];
    NSArray *ptsListSubTasks = [responseData objectForKey:@"pts_1"];
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
                [ptsSubListToReturn addObject:ptsSubTask];
            }
            
        }else{
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
                ptsSubTask.ptsWing = 2;
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
    NSPredicate *predicateForPTSWithId = [NSPredicate predicateWithFormat:@"ptsId = %d", ptsId];
    NSArray *ptsListForPTSId = [ptsItemList filteredArrayUsingPredicate:predicateForPTSWithId];

    PTSItem *ptsItemToReturn;
    if (ptsListForPTSId.count >0) {
        ptsItemToReturn = [ptsListForPTSId objectAtIndex:0];
    }
    
    NSPredicate *predicateForAWing = [NSPredicate predicateWithFormat:@"ptsWing = %d", 1];
    NSArray *wingATasks = [subTasks filteredArrayUsingPredicate:predicateForAWing];
    ptsItemToReturn.aboveWingActivities = [NSSet setWithArray:wingATasks];

    NSPredicate *predicateForBWing = [NSPredicate predicateWithFormat:@"subTaskId = %d", 2];
    NSArray *wingBTasks = [subTasks filteredArrayUsingPredicate:predicateForBWing];
    ptsItemToReturn.belowWingActivities = [NSSet setWithArray:wingBTasks];

    [moc save:&error];
    return ptsItemToReturn;
}

@end
