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

@implementation LoginManager

static LoginManager *sharedInstance;

+(instancetype) sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LoginManager alloc] init];
    });
    return sharedInstance;
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

-(void) saveListTypeForUser:(BOOL)shouldSetGrid{
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;

    User *loggedInUser = [self getLoggedInUser];
    loggedInUser.gridViewSelected = shouldSetGrid;
    
    NSError *error;
    [moc save:&error];
}

-(void) loginUser:(NSString *) username withPassword:(NSString *) password completionHandler:(void (^)(BOOL didLogin, User *user, NSString *errorMessage))loginCompletionHandler{
    Login *loginObj = [[Login alloc] init];
    loginObj.userName = username;
    loginObj.password = password;
    [[WebApiManager sharedInstance] initiatePost:[self getRequestDataForLogin:loginObj] completionHandler:^(BOOL requestSuccessfull, id responseData) {
        if (requestSuccessfull) {
            if ([[responseData objectForKey:@"api_status"] integerValue] == 1) {
                loginCompletionHandler(requestSuccessfull,[self parseUserLoginResponse:responseData], nil);
            }else{
                NSString *failureMessage = [responseData objectForKey:@"message"];
                loginCompletionHandler(FALSE,nil, failureMessage);
            }
        }else{
            loginCompletionHandler(FALSE,nil, @"Login failed.");
        }
        
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
    
    requestData.baseURL = [NSString stringWithFormat:@"%@signup.php?cmd=", SERVICE_API_URL];
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

-(User *)parseUserLoginResponse:(NSDictionary *)responseDictionary{
    double apiStatus = [[responseDictionary objectForKey:@"api_status"] doubleValue];
    double userId = [[responseDictionary objectForKey:@"userid"] doubleValue];
    double airportId = [[responseDictionary objectForKey:@"airport_id"] doubleValue];
    NSString *userName = [responseDictionary objectForKey:@"username"];
    NSInteger port = [[responseDictionary objectForKey:@"port"] integerValue];
    NSString *message = [responseDictionary objectForKey:@"msg"];
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
    return user;
    
}

@end
