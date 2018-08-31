//
//  PTSItem+CoreDataProperties.h
//  
//
//  Created by Shweta Sawant on 31/08/18.
//
//

#import "PTSItem+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface PTSItem (CoreDataProperties)

+ (NSFetchRequest<PTSItem *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *airlineName;
@property (nullable, nonatomic, copy) NSString *coment;
@property (nullable, nonatomic, copy) NSDate *currentTime;
@property (nonatomic) int16_t dutyManagerId;
@property (nullable, nonatomic, copy) NSString *dutyManagerName;
@property (nullable, nonatomic, copy) NSString *executionTime;
@property (nullable, nonatomic, copy) NSString *flightDate;
@property (nonatomic) int16_t flightId;
@property (nullable, nonatomic, copy) NSString *flightNo;
@property (nullable, nonatomic, copy) NSString *flightTime;
@property (nonatomic) int16_t flightType;
@property (nonatomic) int16_t isRunning;
@property (nullable, nonatomic, copy) NSString *jsonData;
@property (nonatomic) BOOL masterRedCap;
@property (nullable, nonatomic, copy) NSDate *ptsEndTime;
@property (nullable, nonatomic, copy) NSString *ptsName;
@property (nullable, nonatomic, copy) NSDate *ptsStartTime;
@property (nonatomic) int16_t ptsSubTaskId;
@property (nonatomic) int16_t redCapId;
@property (nullable, nonatomic, copy) NSString *redCapName;
@property (nullable, nonatomic, copy) NSString *remarks;
@property (nonatomic) int16_t supervisorId;
@property (nullable, nonatomic, copy) NSString *supervisorName;
@property (nullable, nonatomic, copy) NSDate *timerStopTime;
@property (nonatomic) int16_t timeWindow;
@property (nullable, nonatomic, retain) NSSet<PTSSubTask *> *aboveWingActivities;
@property (nullable, nonatomic, retain) NSSet<PTSSubTask *> *belowWingActivities;
@property (nullable, nonatomic, retain) NSSet<RedCap *> *redCaps;

@end

@interface PTSItem (CoreDataGeneratedAccessors)

- (void)addAboveWingActivitiesObject:(PTSSubTask *)value;
- (void)removeAboveWingActivitiesObject:(PTSSubTask *)value;
- (void)addAboveWingActivities:(NSSet<PTSSubTask *> *)values;
- (void)removeAboveWingActivities:(NSSet<PTSSubTask *> *)values;

- (void)addBelowWingActivitiesObject:(PTSSubTask *)value;
- (void)removeBelowWingActivitiesObject:(PTSSubTask *)value;
- (void)addBelowWingActivities:(NSSet<PTSSubTask *> *)values;
- (void)removeBelowWingActivities:(NSSet<PTSSubTask *> *)values;

- (void)addRedCapsObject:(RedCap *)value;
- (void)removeRedCapsObject:(RedCap *)value;
- (void)addRedCaps:(NSSet<RedCap *> *)values;
- (void)removeRedCaps:(NSSet<RedCap *> *)values;

@end

NS_ASSUME_NONNULL_END
