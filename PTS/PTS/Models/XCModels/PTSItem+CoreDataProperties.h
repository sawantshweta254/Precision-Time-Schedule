//
//  PTSItem+CoreDataProperties.h
//  
//
//  Created by Shweta Sawant on 07/03/18.
//
//

#import "PTSItem+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface PTSItem (CoreDataProperties)

+ (NSFetchRequest<PTSItem *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *airlineName;
@property (nonatomic) int16_t dutyManagerId;
@property (nullable, nonatomic, copy) NSString *dutyManagerName;
@property (nullable, nonatomic, copy) NSString *flightDate;
@property (nullable, nonatomic, copy) NSString *flightNo;
@property (nullable, nonatomic, copy) NSString *flightTime;
@property (nullable, nonatomic, copy) NSString *jsonData;
@property (nonatomic) int16_t ptsId;
@property (nullable, nonatomic, copy) NSString *ptsName;
@property (nonatomic) int16_t ptsSubTaskId;
@property (nonatomic) int16_t ptsType;
@property (nonatomic) int16_t redCapId;
@property (nullable, nonatomic, copy) NSString *redCapName;
@property (nullable, nonatomic, copy) NSString *remarks;
@property (nonatomic) int16_t supervisorId;
@property (nullable, nonatomic, copy) NSString *supervisorName;
@property (nonatomic) int16_t timeWindow;
@property (nullable, nonatomic, retain) NSSet<PTSSubTask *> *aboveWingActivities;
@property (nullable, nonatomic, retain) NSSet<PTSSubTask *> *belowWingActivities;

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

@end

NS_ASSUME_NONNULL_END