//
//  PTSManager.m
//  PTS
//
//  Created by Shweta Sawant on 20/02/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "PTSManager.h"
#import "PTSItem+CoreDataProperties.h"
#import "ApiRequestData.h"
#import <UIKit/UIKit.h>
#import "WebApiManager.h"
#import "User+CoreDataClass.h"

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
    NSEntityDescription *ptsEntity = [NSEntityDescription entityForName:@"PTSItem" inManagedObjectContext:moc];
    for (NSDictionary *ptsItem in ptsList) {
        PTSItem *pts = (PTSItem*)[[NSManagedObject alloc] initWithEntity:ptsEntity insertIntoManagedObjectContext:moc];
        
        pts.airlineName = [ptsItem objectForKey:@"airline_name"];
        pts.dutyManagerId = [[ptsItem objectForKey:@"duty_manager_id"] intValue];
        pts.dutyManagerName = [ptsItem objectForKey:@"dutymanager_name"];
//        pts.flightDate = [[ptsItem objectForKey:@"flight_date"]];
        pts.flightNo = [ptsItem objectForKey:@"flight_no"];
//        pts.flightTime = [ptsItem objectForKey:@"flight_time"];
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
@end
