//
//  WebsocketMessageFactory.m
//  PTS
//
//  Created by Shweta Sawant on 12/03/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "WebsocketMessageFactory.h"
#import "LoginManager.h"
#import "AppUtility.h"

@implementation WebsocketMessageFactory

-(NSString *) createLoggedInUserMessageForFlight:(PTSItem *)ptsItem{
    
    User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];

    NSMutableDictionary *messageDict = [NSMutableDictionary dictionary];
    [messageDict setValue:[NSNumber numberWithDouble:loggedInUser.userId] forKey:@"userid"];
    [messageDict setValue:[NSNumber numberWithInteger:1] forKey:@"MsgType"];
    [messageDict setValue:loggedInUser.userName forKey:@"user_name"];
    [messageDict setValue:[NSNumber numberWithInteger:loggedInUser.empType] forKey:@"user_type"];

    /*if (loggedInUser.empType == 1 || loggedInUser.empType == 2 || loggedInUser.empType == 4) {
//        [messageDict setValue:[NSArray arrayWithObjects:[NSNumber numberWithInteger:607],[NSNumber numberWithInteger:608], nil] forKey:@"flights_id"];
    }else{
        
    }*/
    if (ptsItem!=nil) {
        NSArray *flightIds = [NSArray arrayWithObject:[NSNumber numberWithInt:ptsItem.flightId]];
        [messageDict setValue:flightIds forKey:@"flights_id"];
    }else{
        [messageDict setValue:@"" forKey:@"flight_id"];
    }
    
    
    return [self translateToString:messageDict];
}

-(NSString *) createUpdateMessageForFlight:(PTSItem *)ptsItem{
    User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];
    UIDevice *device = [UIDevice currentDevice];
    NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
    
    NSMutableDictionary *messageDict = [NSMutableDictionary dictionary];
    [messageDict setValue:[NSNumber numberWithDouble:loggedInUser.userId] forKey:@"userid"];
    [messageDict setValue:[self ptsTimesInString:ptsItem.ptsStartTime] forKey:@"pts_start_time"];
    
//    if (ptsItem.ptsEndTime == nil) {
        [messageDict setValue:@"0" forKey:@"pts_end_time"];
//    }else{
//        [messageDict setValue:[self ptsTimesInString:ptsItem.ptsEndTime] forKey:@"pts_end_time"];
//    }
    

    [messageDict setValue:currentDeviceId forKey:@"device_id"];
    [messageDict setValue:[NSString stringWithFormat:@"%d",ptsItem.flightId] forKey:@"flight_id"];
    [messageDict setValue:ptsItem.flightNo forKey:@"flight_num"];
    [messageDict setValue:[NSNumber numberWithInteger:ptsItem.flightType] forKey:@"flight_type"];
    [messageDict setValue:ptsItem.flightTime forKey:@"arr_dep_type"];
    [messageDict setValue:[NSNumber numberWithInteger:1] forKey:@"is_running"];
    
    [messageDict setValue:ptsItem.ptsName forKey:@"pts_name"];
    [messageDict setValue:[NSNumber numberWithInteger:ptsItem.timeWindow] forKey:@"pts_time"];
    [messageDict setValue:ptsItem.flightDate forKey:@"flight_date"];
    [messageDict setValue:[NSNumber numberWithInteger:ptsItem.ptsSubTaskId] forKey:@"m_pts_id"];
    [messageDict setValue:ptsItem.airlineName forKey:@"airline_name"];
    
    [messageDict setValue:@"" forKey:@"execute_time"];
    [messageDict setValue:[self ptsTimesInString:ptsItem.currentTime] forKey:@"current_time"];
    [messageDict setValue:[self ptsTimesInString:ptsItem.timerStopTime] forKey:@"timer_stop_time"];
    
    if (loggedInUser.empType == UserTypeRedCap) {
        [messageDict setValue:[NSNumber numberWithInteger:2] forKey:@"MsgType"];
    }
    
    [messageDict setValue:loggedInUser.userName forKey:@"user_name"];
    [messageDict setValue:[NSNumber numberWithInteger:loggedInUser.empType] forKey:@"user_type"];
    
    NSMutableArray *wingSubTasks = [[NSMutableArray alloc] init];
    for (PTSSubTask *subTaskInAboveWing in ptsItem.aboveWingActivities) {
        [wingSubTasks addObject:[self getSubTaskUpdateDictionaryFor:subTaskInAboveWing forPTS:ptsItem]];
    }
    NSMutableArray *wingBSubTasks = [[NSMutableArray alloc] init];
    for (PTSSubTask *subTaskInAboveWing in ptsItem.belowWingActivities) {
        [wingBSubTasks addObject:[self getSubTaskUpdateDictionaryFor:subTaskInAboveWing forPTS:ptsItem]];
    }
    [messageDict setValue:wingSubTasks forKey:@"above_list"];
    [messageDict setValue:wingBSubTasks forKey:@"below_list"];
    
    return [self translateToString:messageDict];
}

-(NSString *) ptsTimesInString:(NSDate *) ptsDate{
    if (ptsDate == nil) {
        return @"0";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYY-MM-dd hh:mm:ss";
    return [dateFormatter stringFromDate:ptsDate];
}

-(NSString *) getWingTaskDicForPTS:(PTSItem *)pts from:(NSArray *) wingTasks{
    NSMutableArray *wingSubTasks = [[NSMutableArray alloc] init];
    for (PTSSubTask *subTaskInAboveWing in wingTasks) {
        [wingSubTasks addObject:[self getSubTaskUpdateDictionaryFor:subTaskInAboveWing forPTS:pts]];
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:wingSubTasks options:NSJSONWritingPrettyPrinted error:&error];
    if(error != nil)
        return Nil;
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

-(NSMutableDictionary *) getSubTaskUpdateDictionaryFor:(PTSSubTask *)ptsSubTask forPTS:(PTSItem *)pts{
    NSMutableDictionary *subTaskDictionary = [[NSMutableDictionary alloc] init];
    [subTaskDictionary setValue:[NSNumber numberWithInteger:pts.flightType] forKey:@"type_id"];
    [subTaskDictionary setValue:[NSNumber numberWithInteger:ptsSubTask.subTaskId] forKey:@"sub_activity_id"];
    [subTaskDictionary setValue:ptsSubTask.subactivity forKey:@"sub_activity_name"];
    [subTaskDictionary setValue:[NSNumber numberWithInteger:ptsSubTask.start] forKey:@"start_time"];
    [subTaskDictionary setValue:[NSNumber numberWithInteger:ptsSubTask.end] forKey:@"end_time"];
    [subTaskDictionary setValue:[NSNumber numberWithInt:abs(ptsSubTask.start - ptsSubTask.end) + 1] forKey:@"pts_time"]; //// total time
    [subTaskDictionary setValue:[NSNumber numberWithInteger:ptsSubTask.subActivityType] forKey:@"subactivity_type"];// 2mins or more mins
    [subTaskDictionary setValue:[self ptsTimesInString:ptsSubTask.current_time] forKey:@"current_time"];
    [subTaskDictionary setValue:[NSNumber numberWithInteger:ptsSubTask.isRunning] forKey:@"is_running"];
    [subTaskDictionary setValue:[self ptsTimesInString:ptsSubTask.timerExecutedTime] forKey:@"time_execute_time"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat:@"hh:mm"];
    
//    [subTaskDictionary setValue:@"0" forKey:@"subactivity_start_time"];
//     [subTaskDictionary setValue:@"0" forKey:@"subactivity_end_time"];
//    [subTaskDictionary setValue:@"0" forKey:@"user_start_time"];
//    [subTaskDictionary setValue:@"0" forKey:@"user_end_time"];
    
    if (ptsSubTask.subactivityStartTime != nil ) {
        [subTaskDictionary setValue:[NSString stringWithFormat:@"%@@@%@", [dateFormatter1 stringFromDate:ptsSubTask.subactivityStartTime], [dateFormatter stringFromDate:ptsSubTask.subactivityStartTime]] forKey:@"subactivity_start_time"];
    }
    
    if (ptsSubTask.subactivityEndTime != nil ) {
        [subTaskDictionary setValue:[NSString stringWithFormat:@"%@@@%@", [dateFormatter1 stringFromDate:ptsSubTask.subactivityEndTime], [dateFormatter stringFromDate:ptsSubTask.subactivityEndTime]] forKey:@"subactivity_end_time"];
    }
    
    [subTaskDictionary setValue:[NSNumber numberWithInteger:ptsSubTask.isComplete] forKey:@"is_complete"];
    
    if (ptsSubTask.userStartTime != nil) {
        [subTaskDictionary setValue:[NSString stringWithFormat:@"%@@@%@", [dateFormatter1 stringFromDate:ptsSubTask.userStartTime], [dateFormatter stringFromDate:ptsSubTask.userStartTime]] forKey:@"user_start_time"];
    }
    
    if (ptsSubTask.userEndTime != nil) {
        [subTaskDictionary setValue:[NSString stringWithFormat:@"%@@@%@", [dateFormatter1 stringFromDate:ptsSubTask.userEndTime], [dateFormatter stringFromDate:ptsSubTask.userEndTime]] forKey:@"user_end_time"];
    }
   
    [subTaskDictionary setValue:ptsSubTask.notations forKey:@"notations"];
    [subTaskDictionary setValue:[self ptsTimesInString:ptsSubTask.timerStopTime] forKey:@"timer_stop_time"];
    [subTaskDictionary setValue:ptsSubTask.userSubActFeedback forKey:@"user_subact_feedback"];
    [subTaskDictionary setValue:ptsSubTask.negativeDataSendServer forKey:@"negativeData_SendServer"];
    
    return subTaskDictionary;
}

- (NSString*) translateToString:(NSDictionary *) messageDict {
    
    NSData *messageData = [NSJSONSerialization dataWithJSONObject:messageDict options:NSJSONWritingPrettyPrinted error:NULL];
    NSString *message = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
    return message;
}

@end
