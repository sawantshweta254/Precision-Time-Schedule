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
#import "FAQ+CoreDataProperties.h"

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

-(void) fetchFAQ{
    [[WebApiManager sharedInstance] initiatePost:[self getRequestDataForLogin] completionHandler:^(BOOL requestSuccessfull, id responseData) {
        if (requestSuccessfull) {
            NSArray *faqsArray = [responseData objectForKey:@"faq_json"];
            NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
            for (NSDictionary *faqDic in faqsArray) {
                NSEntityDescription *faqEntity = [NSEntityDescription entityForName:@"FAQ" inManagedObjectContext:moc];
                FAQ *faq = (FAQ*)[[NSManagedObject alloc] initWithEntity:faqEntity insertIntoManagedObjectContext:moc];
                faq.faqId = [[faqDic objectForKey:@"id"] intValue];
                faq.faq_q = [faqDic objectForKey:@"faq_q"];
                faq.faq_a = [faqDic objectForKey:@"faq_a"];
                faq.faq_status = [[faqDic objectForKey:@"faq_status"] intValue];
                faq.creation_on = [faqDic objectForKey:@""];
                faq.updated_on = [faqDic objectForKey:@""];
            }
            NSError *error;
            [moc save:&error];
            
        }else{
        }
        
    }];
}

-(ApiRequestData *) getRequestDataForLogin{
    ApiRequestData *requestData = [[ApiRequestData alloc] init];
    
//    requestData.baseURL = @"http://techdew.co.in/pts1/faq_json/faq_json.txt?";
    requestData.baseURL = @"http://13.251.75.155/TAT/faq_json/faq_json.txt?";
    requestData.postData = [[NSDictionary alloc] init];
    
    return requestData;
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
    long faqChecksum = [[responseDictionary objectForKey:@"faq_json"] longLongValue];
    
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
    user.faqChecksum = faqChecksum;

    user.empType = empType;
    
    [self fetchFAQ];
    
    NSError *error;
    [moc save:&error];
    if (error) {
        
    }
    return user;
    
}

@end
