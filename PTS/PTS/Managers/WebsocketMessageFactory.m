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

-(NSString *) createLoggedInUserMessageForFlight:(NSInteger)flightID{
    
    User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];

    NSMutableDictionary *messageDict = [NSMutableDictionary dictionary];
    [messageDict setValue:[NSNumber numberWithDouble:loggedInUser.userId] forKey:@"userid"];
    [messageDict setValue:[NSNumber numberWithInteger:1] forKey:@"MsgType"];
    [messageDict setValue:loggedInUser.userName forKey:@"user_name"];
    [messageDict setValue:[NSNumber numberWithInteger:loggedInUser.empType] forKey:@"user_type"];
    
    if (loggedInUser.empType == 1 || loggedInUser.empType == 2 || loggedInUser.empType == 4) {
//        [messageDict setValue:[NSArray arrayWithObjects:[NSNumber numberWithInteger:607],[NSNumber numberWithInteger:608], nil] forKey:@"flights_id"];
    }else{
        [messageDict setValue:[NSNumber numberWithInteger:flightID] forKey:@"flight_id"];

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
    [messageDict setValue:[self ptsTimesInString:ptsItem.ptsEndTime] forKey:@"pts_end_time"];
    [messageDict setValue:currentDeviceId forKey:@"device_id"];
    [messageDict setValue:[NSNumber numberWithInteger:ptsItem.flightId] forKey:@"flight_id"];
    [messageDict setValue:ptsItem.flightNo forKey:@"flight_num"];
    [messageDict setValue:[NSNumber numberWithInteger:ptsItem.flightType] forKey:@"flight_type"];
    [messageDict setValue:ptsItem.flightTime forKey:@"arr_dep_type"];
    [messageDict setValue:[NSNumber numberWithInteger:1] forKey:@"is_running"];
    
    [messageDict setValue:ptsItem.ptsName forKey:@"pts_name"];
    [messageDict setValue:[NSNumber numberWithInteger:ptsItem.timeWindow] forKey:@"pts_time"];
    [messageDict setValue:ptsItem.flightDate forKey:@"flight_date"];
    [messageDict setValue:[NSNumber numberWithInteger:ptsItem.ptsSubTaskId] forKey:@"m_pts_id"];
    [messageDict setValue:ptsItem.airlineName forKey:@"airline_name"];
    
    [messageDict setValue:ptsItem.executionTime forKey:@"execute_time"];
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
    dateFormatter.dateFormat = @"YYYY-mm-dd hh:mm:ss";
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
    [subTaskDictionary setValue:ptsSubTask.referenceTime forKey:@"pts_time"]; //// total time
    [subTaskDictionary setValue:[NSNumber numberWithInteger:ptsSubTask.subActivityType] forKey:@"subactivity_type"];// 2mins or more mins
    [subTaskDictionary setValue:[self ptsTimesInString:ptsSubTask.current_time] forKey:@"current_time"];
    [subTaskDictionary setValue:[NSNumber numberWithInteger:ptsSubTask.isRunning] forKey:@"is_running"];
    [subTaskDictionary setValue:[self ptsTimesInString:ptsSubTask.timerExecutedTime] forKey:@"time_execute_time"];
    [subTaskDictionary setValue:[NSNumber numberWithInteger:ptsSubTask.start] forKey:@"subactivity_start_time"];
    [subTaskDictionary setValue:[NSNumber numberWithInteger:ptsSubTask.end] forKey:@"subactivity_end_time"];
    [subTaskDictionary setValue:[NSNumber numberWithInteger:ptsSubTask.isComplete] forKey:@"is_complete"];
    
    [subTaskDictionary setValue:[self ptsTimesInString:ptsSubTask.userStartTime] forKey:@"user_start_time"];
    [subTaskDictionary setValue:[self ptsTimesInString:ptsSubTask.userEndTime] forKey:@"user_end_time"];
    
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
