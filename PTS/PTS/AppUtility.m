//
//  AppUtility.m
//  PTS
//
//  Created by Shweta Sawant on 18/03/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "AppUtility.h"

@implementation AppUtility

+(NSString *) getFormattedPTSTime:(int) timeInMinutes{
    NSDateComponentsFormatter *timeFormatter = [[NSDateComponentsFormatter alloc] init];
    timeFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    timeFormatter.allowedUnits = NSCalendarUnitMinute|NSCalendarUnitSecond;
    return [timeFormatter stringFromTimeInterval:timeInMinutes * 60];
}

+(NSString *)getTimeDifference:(NSDate *)startTime toEndTime:(NSDate *)endTime{
    double timeInterval = [endTime timeIntervalSinceDate:startTime];
    NSDateComponentsFormatter *timeFormatter = [[NSDateComponentsFormatter alloc] init];
    timeFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    if (timeInterval > 3600) {
        timeFormatter.allowedUnits = NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    }else{
        timeFormatter.allowedUnits = NSCalendarUnitMinute|NSCalendarUnitSecond;
    }
    return [NSString stringWithFormat:@"%@",[timeFormatter stringFromTimeInterval:timeInterval]];
}
@end
