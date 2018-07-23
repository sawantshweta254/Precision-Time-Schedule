//
//  RedCap+CoreDataProperties.h
//  
//
//  Created by Shweta Sawant on 03/07/18.
//
//

#import "RedCap+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface RedCap (CoreDataProperties)

+ (NSFetchRequest<RedCap *> *)fetchRequest;

@property (nonatomic) int16_t redCapId;
@property (nonatomic) int16_t tableGroupId;
@property (nullable, nonatomic, copy) NSString *redcapName;
@property (nullable, nonatomic, copy) NSString *masterRedCap;
@property (nullable, nonatomic, retain) NSSet<RedCapSubtask *> *aboveWingSubTasks;
@property (nullable, nonatomic, retain) NSSet<RedCapSubtask *> *belowWingSubtask;

@end

@interface RedCap (CoreDataGeneratedAccessors)

- (void)addAboveWingSubTasksObject:(RedCapSubtask *)value;
- (void)removeAboveWingSubTasksObject:(RedCapSubtask *)value;
- (void)addAboveWingSubTasks:(NSSet<RedCapSubtask *> *)values;
- (void)removeAboveWingSubTasks:(NSSet<RedCapSubtask *> *)values;

- (void)addBelowWingSubtaskObject:(RedCapSubtask *)value;
- (void)removeBelowWingSubtaskObject:(RedCapSubtask *)value;
- (void)addBelowWingSubtask:(NSSet<RedCapSubtask *> *)values;
- (void)removeBelowWingSubtask:(NSSet<RedCapSubtask *> *)values;

@end

NS_ASSUME_NONNULL_END
