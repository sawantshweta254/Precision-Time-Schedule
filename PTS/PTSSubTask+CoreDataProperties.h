//
//  PTSSubTask+CoreDataProperties.h
//  
//
//  Created by Shweta Sawant on 19/03/18.
//
//

#import "PTSSubTask+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface PTSSubTask (CoreDataProperties)

+ (NSFetchRequest<PTSSubTask *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *current_time;
@property (nonatomic) int16_t end;
@property (nonatomic) int16_t isComplete;
@property (nonatomic) int16_t isRunning;
@property (nonatomic) int16_t mRefereceTimeId;
@property (nullable, nonatomic, copy) NSString *negativeData_SendServer;
@property (nullable, nonatomic, copy) NSString *notations;
@property (nonatomic) int16_t ptsDetailsId;
@property (nonatomic) int16_t ptsTotalTime;
@property (nonatomic) int16_t ptsWing;
@property (nullable, nonatomic, copy) NSString *referenceTime;
@property (nonatomic) int16_t start;
@property (nullable, nonatomic, copy) NSString *subactivity;
@property (nullable, nonatomic, copy) NSDate *subactivity_end_time;
@property (nullable, nonatomic, copy) NSDate *subactivity_start_time;
@property (nonatomic) int16_t subActivityType;
@property (nonatomic) int16_t subTaskId;
@property (nonatomic) int16_t timer_executed_time;
@property (nullable, nonatomic, copy) NSDate *timer_stop_time;
@property (nullable, nonatomic, copy) NSDate *user_end_time;
@property (nullable, nonatomic, copy) NSDate *user_start_time;
@property (nullable, nonatomic, copy) NSString *userSubActFeedback;

@end

NS_ASSUME_NONNULL_END
