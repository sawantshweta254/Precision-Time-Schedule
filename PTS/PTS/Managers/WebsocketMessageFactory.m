//
//  WebsocketMessageFactory.m
//  PTS
//
//  Created by Shweta Sawant on 12/03/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "WebsocketMessageFactory.h"
#import "LoginManager.h"

@implementation WebsocketMessageFactory

-(NSString *) createLoggedInUserMessageForFlight:(NSInteger)flightID{
    
    User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];

    NSMutableDictionary *messageDict = [NSMutableDictionary dictionary];
    [messageDict setValue:[NSNumber numberWithDouble:loggedInUser.userId] forKey:@"userid"];
    [messageDict setValue:loggedInUser.userName forKey:@"user_name"];
    [messageDict setValue:[NSNumber numberWithInteger:loggedInUser.empType] forKey:@"user_type"];
    [messageDict setValue:[NSNumber numberWithInteger:flightID] forKey:@"flight_id"];
    
    return [self translateToString:messageDict];
}

-(NSString *) createUpdateMessageForFlight:(PTSItem *)ptsItem{
    //
    User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];
    UIDevice *device = [UIDevice currentDevice];
    NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
    
    NSMutableDictionary *messageDict = [NSMutableDictionary dictionary];
    [messageDict setValue:[NSNumber numberWithDouble:loggedInUser.userId] forKey:@"userid"];
//    [messageDict setValue:ptsItem.ptsStartTime forKey:@"pts_start_time"];
//    [messageDict setValue:ptsItem.ptsEndTime forKey:@"pts_end_time"];
    [messageDict setValue:currentDeviceId forKey:@"device_id"];
    [messageDict setValue:[NSNumber numberWithInteger:ptsItem.ptsId] forKey:@"flight_id"];
    [messageDict setValue:ptsItem.flightNo forKey:@"flight_num"];
    [messageDict setValue:[NSNumber numberWithInteger:ptsItem.ptsType] forKey:@"flight_type"];
    [messageDict setValue:ptsItem.flightTime forKey:@"arr_dep_type"];
    [messageDict setValue:[NSNumber numberWithInteger:1] forKey:@"is_running"];
    
    [messageDict setValue:[NSNumber numberWithInteger:1] forKey:@"is_running"];
    [messageDict setValue:[NSNumber numberWithInteger:1] forKey:@"is_running"];
    [messageDict setValue:[NSNumber numberWithInteger:1] forKey:@"is_running"];
    [messageDict setValue:[NSNumber numberWithInteger:1] forKey:@"is_running"];
    [messageDict setValue:[NSNumber numberWithInteger:1] forKey:@"is_running"];
    [messageDict setValue:[NSNumber numberWithInteger:1] forKey:@"is_running"];
    [messageDict setValue:[NSNumber numberWithInteger:1] forKey:@"is_running"];
    [messageDict setValue:[NSNumber numberWithInteger:1] forKey:@"is_running"];
    [messageDict setValue:[NSNumber numberWithInteger:1] forKey:@"is_running"];
    [messageDict setValue:[NSNumber numberWithInteger:1] forKey:@"is_running"];
    [messageDict setValue:[NSNumber numberWithInteger:1] forKey:@"is_running"];
    
    [messageDict setValue:[self getWingTaskDicForPTS:ptsItem from:[ptsItem.aboveWingActivities allObjects]] forKey:@"above_list"];
    [messageDict setValue:[self getWingTaskDicForPTS:ptsItem from:[ptsItem.belowWingActivities allObjects]] forKey:@"below_list"];
    
    return [self translateToString:messageDict];
}

-(NSString *) getWingTaskDicForPTS:(PTSItem *)pts from:(NSArray *) wingTasks{
    NSMutableArray *aboveWingSubTasks = [[NSMutableArray alloc] init];
    for (PTSSubTask *subTaskInAboveWing in wingTasks) {
        [aboveWingSubTasks addObject:[self getSubTaskUpdateDictionaryFor:subTaskInAboveWing forPTS:pts]];
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:aboveWingSubTasks options:NSJSONWritingPrettyPrinted error:&error];
    if(error != nil)
        return Nil;
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

-(NSDictionary *) getSubTaskUpdateDictionaryFor:(PTSSubTask *)ptsSubTask forPTS:(PTSItem *)pts{
    NSDictionary *subTaskDictionary = [[NSDictionary alloc] init];
    [subTaskDictionary setValue:[NSNumber numberWithInteger:pts.ptsType] forKey:@"type_id"];
    [subTaskDictionary setValue:[NSNumber numberWithInteger:ptsSubTask.subTaskId] forKey:@"sub_activity_id"];
    [subTaskDictionary setValue:ptsSubTask.subactivity forKey:@"sub_activity_name"];
//    [subTaskDictionary setValue:[NSNumber numberWithInteger:flightID] forKey:@"start_time"];
    [subTaskDictionary setValue:ptsSubTask.referenceTime forKey:@"pts_time"];
//    [subTaskDictionary setValue:[NSNumber numberWithInteger:flightID] forKey:@"end_time"];
//    [subTaskDictionary setValue:[NSNumber numberWithInteger:ptsSubTask.] forKey:@"subactivity_type"];
//    [subTaskDictionary setValue:[NSNumber numberWithInteger:[NSDate date]] forKey:@"current_time"];
//    [subTaskDictionary setValue:[NSNumber numberWithInteger:1] forKey:@"is_running"];
//    [subTaskDictionary setValue:[NSNumber numberWithInteger:flightID] forKey:@"time_execute_time"];
    [subTaskDictionary setValue:[NSNumber numberWithInteger:ptsSubTask.start] forKey:@"subactivity_start_time"];
    [subTaskDictionary setValue:[NSNumber numberWithInteger:ptsSubTask.end] forKey:@"subactivity_end_time"];
//    [subTaskDictionary setValue:[NSNumber numberWithInteger:1] forKey:@"is_complete"];
//    [subTaskDictionary setValue:[NSNumber numberWithInteger:] forKey:@"user_start_time"];
//    [subTaskDictionary setValue:[NSNumber numberWithInteger:flightID] forKey:@"user_end_time"];
//    [subTaskDictionary setValue:[NSNumber numberWithInteger:flightID] forKey:@"notations"];
//    [subTaskDictionary setValue:[NSNumber numberWithInteger:flightID] forKey:@"timer_stop_time"];
//    [subTaskDictionary setValue:[NSNumber numberWithInteger:flightID] forKey:@"user_subact_feedback"];
//    [subTaskDictionary setValue:[NSNumber numberWithInteger:flightID] forKey:@"negativeData_SendServer"];
    
    return subTaskDictionary;
}

- (NSString*) translateToString:(NSDictionary *) messageDict {
    
    NSData *messageData = [NSJSONSerialization dataWithJSONObject:messageDict options:NSJSONWritingPrettyPrinted error:NULL];
    NSString *message = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
    return message;
}

@end
