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

@end
