//
//  PTSSubTask+CoreDataProperties.h
//  
//
//  Created by Shweta Sawant on 23/07/18.
//
//

#import "PTSSubTask+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface PTSSubTask (CoreDataProperties)

+ (NSFetchRequest<PTSSubTask *> *)fetchRequest;

@property (nonatomic) int16_t calculatedPTSFinalTime;
@property (nullable, nonatomic, copy) NSDate *current_time;
@property (nonatomic) int16_t end;
@property (nonatomic) int16_t isComplete;
@property (nonatomic) int16_t isRunning;
@property (nonatomic) int16_t mRefereceTimeId;
@property (nullable, nonatomic, copy) NSString *negativeDataSendServer;
@property (nullable, nonatomic, copy) NSString *notations;
@property (nonatomic) int16_t ptsDetailsId;
@property (nonatomic) int16_t ptsTotalTime;
@property (nonatomic) int16_t ptsWing;
@property (nullable, nonatomic, copy) NSString *referenceTime;
@property (nonatomic) BOOL shouldBeInActive;
@property (nonatomic) int16_t start;
@property (nullable, nonatomic, copy) NSString *subactivity;
@property (nullable, nonatomic, copy) NSDate *subactivityEndTime;
@property (nullable, nonatomic, copy) NSDate *subactivityStartTime;
@property (nonatomic) int16_t subActivityType;
@property (nonatomic) int16_t subTaskId;
@property (nullable, nonatomic, copy) NSDate *timerExecutedTime;
@property (nullable, nonatomic, copy) NSDate *timerStopTime;
@property (nullable, nonatomic, copy) NSDate *userEndTime;
@property (nullable, nonatomic, copy) NSDate *userStartTime;
@property (nullable, nonatomic, copy) NSString *userSubActFeedback;
@property (nonatomic) BOOL hasExceededTime;

@end

NS_ASSUME_NONNULL_END
