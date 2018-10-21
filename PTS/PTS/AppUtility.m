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
    
    if (startTime == nil || endTime == nil) {
        return @"";
    }
    double timeInterval = [endTime timeIntervalSinceDate:startTime];
    NSDateComponentsFormatter *timeFormatter = [[NSDateComponentsFormatter alloc] init];
    timeFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    if (timeInterval > 3600) {
        timeFormatter.allowedUnits = NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    }else{
        timeFormatter.allowedUnits = NSCalendarUnitMinute|NSCalendarUnitSecond;
    }
    

    NSString *appendZero = @"";
    if (timeInterval > 3600) {
        NSUInteger hours = (((NSUInteger)round(timeInterval))/3600);
        if (hours < 10) {
            appendZero = [appendZero stringByAppendingString:@"0"];
        }
    }else{
        NSUInteger minutes = (((NSUInteger)round(timeInterval))/60) % 60;
        if (minutes < 10) {
            appendZero = [appendZero stringByAppendingString:@"0"];
        }
    }
    return [NSString stringWithFormat:@"%@%@",appendZero, [timeFormatter stringFromTimeInterval:timeInterval]];
}
@end
