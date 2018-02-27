//
//  PTSManager.m
//  PTS
//
//  Created by Shweta Sawant on 20/02/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "PTSManager.h"
#import "PTSItem.h"
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

-(void) fetchPTSList:(void(^)(BOOL fetchComplete, NSArray *ptsTasks, NSError *error))fetchPTSCompletionHandler{
    
    [[WebApiManager sharedInstance] initiatePost:[self getRequestDataToFetchPTSList] completionHandler:^(BOOL requestSuccessfull, id responseData) {
        fetchPTSCompletionHandler(requestSuccessfull, responseData, nil);
    }];
    
}

-(ApiRequestData *) getRequestDataToFetchPTSList{
    ApiRequestData *requestData = [[ApiRequestData alloc] init];

    requestData.baseURL = @"http://techdew.co.in/pts/webapi/getmyappdata.php?cmd=";
    requestData.postData = [self getDataRequest];
    
    return requestData;
}

-(NSDictionary *) getDataRequest{
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    
    
    NSError *error;
    
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSArray *userArray = [moc executeFetchRequest:fetchRequest error:&error];
    User *useTo;
    
    if (userArray.count >0) {
        for (User *user in userArray) {
            NSLog(@"User name %@", user.userName);
            useTo = user;
        }
        
    }
    NSMutableDictionary *getListData = [[NSMutableDictionary alloc] init];
    
    UIDevice *device = [UIDevice currentDevice];
    NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
    [getListData setObject:currentDeviceId forKey:@"deviceid"];
    [getListData setObject:[NSNumber numberWithInt:25] forKey:@"userid"];
    [getListData setObject:[NSNumber numberWithInteger:3] forKey:@"emp_type"];
    [getListData setObject:[NSNumber numberWithInteger:3] forKey:@"tbl_airport_id"];
    
    return getListData;
}

@end
