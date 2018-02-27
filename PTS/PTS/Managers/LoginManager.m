//
//  LoginManager.m
//  PTS
//
//  Created by Shweta Sawant on 15/02/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "LoginManager.h"
#import "WebApiManager.h"
#import "ApiRequestData.h"
#import "Login.h"
#include <sys/sysctl.h>
#import <UIKit/UIKit.h>
#import "User+CoreDataClass.h"
#import "User+CoreDataProperties.h"

@implementation LoginManager

static LoginManager *sharedInstance;

+(instancetype) sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LoginManager alloc] init];
    });
    return sharedInstance;
}

-(void) loginUser:(NSString *) username withPassword:(NSString *) password completionHandler:(void (^)(BOOL didLogin))loginCompletionHandler{
    Login *loginObj = [[Login alloc] init];
    loginObj.userName = username;
    loginObj.password = password;
    [[WebApiManager sharedInstance] initiatePost:[self getRequestDataForLogin:loginObj] completionHandler:^(BOOL requestSuccessfull, id responseData) {
        [self parseLoginResponse:responseData];
        loginCompletionHandler(requestSuccessfull);
    }];
}

-(void) loginUser:(NSString *) username withPassword:(NSString *) password{
    Login *loginObj = [[Login alloc] init];
    loginObj.userName = username;
    loginObj.password = password;
//    [[WebApiManager sharedInstance] initiatePost:[self getRequestDataForLogin:loginObj]];
}

-(ApiRequestData *) getRequestDataForLogin:(Login *) loginObject{
    ApiRequestData *requestData = [[ApiRequestData alloc] init];
    
    requestData.baseURL = @"http://techdew.co.in/pts/webapi/signup.php?cmd=";
    requestData.postData = [self getDataForLoginRequest:loginObject];
    
    return requestData;
}

-(NSDictionary *) getDataForLoginRequest:(Login *) loginObject{
    NSMutableDictionary *loginDataDic = [[NSMutableDictionary alloc] init];
    
    UIDevice *device = [UIDevice currentDevice];
    NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
    [loginDataDic setObject:currentDeviceId forKey:@"deviceid"];
    [loginDataDic setObject:@"1.0" forKey:@"appversion"];
    [loginDataDic setObject:loginObject.userName forKey:@"email"];
    [loginDataDic setObject:@"3" forKey:@"emp_type"];
    [loginDataDic setObject:loginObject.password forKey:@"pword"];
    [loginDataDic setObject:[self getModel] forKey:@"phonemodel"];
    [loginDataDic setObject:@"Apple" forKey:@"phonemanuf"];
    [loginDataDic setObject:[UIDevice currentDevice].systemVersion forKey:@"osversion"];
    
    return loginDataDic;
}

- (NSString *)getModel {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *model = malloc(size);
    sysctlbyname("hw.machine", model, &size, NULL, 0);
    NSString *deviceModel = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
    free(model);
    return deviceModel;
}

#pragma mark DB methods
-(void)parseLoginResponse:(NSDictionary *)responseDictionary{
    double apiStatus = [[responseDictionary objectForKey:@"api_status"] doubleValue];
    double userId = [[responseDictionary objectForKey:@"user_id"] doubleValue];
    double airportId = [[responseDictionary objectForKey:@"airport_id"] doubleValue];
    NSString *userName = [responseDictionary objectForKey:@"username"];
    NSInteger port = [[responseDictionary objectForKey:@"port"] integerValue];
    NSString *message = [responseDictionary objectForKey:@"message"];
    NSArray *flightPTSInfo = [responseDictionary objectForKey:@"flight_pts_info"];
    NSInteger empType = [[responseDictionary objectForKey:@"emptype"] integerValue];
    
    
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    NSEntityDescription *userEntity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:moc];
    User *user = (User*)[[NSManagedObject alloc] initWithEntity:userEntity insertIntoManagedObjectContext:moc];
    
    user.apiStatus = apiStatus;
    user.userId = userId;
    user.airportId = airportId;
    user.userName = userName;
    user.port = port;
    user.message = message;
//    user.flightPTSInfo = flightPTSInfo;
    user.empType = empType;
    
    NSError *error;
    [moc save:&error];
    if (error) {
        
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSArray *userArray = [moc executeFetchRequest:fetchRequest error:&error];
    
    if (userArray.count >0) {
        User *userf = [userArray objectAtIndex:0];
        if (userf) {
            NSLog(@"User name %@", userf.userName);
            NSLog(@"User id %f", userf.userId);
            NSLog(@"User airport %f", userf.airportId);
        }
    }
    
}

@end