//
//  AppUtility.h
//  PTS
//
//  Created by Shweta Sawant on 18/03/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FlightType) {
    DepartureType = 1,
    ArrivalType = 2
};

typedef NS_ENUM(NSInteger, UserType) {
    UserTypeAdmin = 1,
    UserTypeSupervisor = 2,
    UserTypeRedCap = 3
};

@interface AppUtility : NSObject

+(NSString *) getFormattedPTSTime:(int) timeInMinutes;
+(NSString *)getTimeDifference:(NSDate *)startTime toEndTime:(NSDate *)endTime;
@end
