//
//  RedCapSubtask+CoreDataProperties.h
//  
//
//  Created by Shweta Sawant on 03/07/18.
//
//

#import "RedCapSubtask+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface RedCapSubtask (CoreDataProperties)

+ (NSFetchRequest<RedCapSubtask *> *)fetchRequest;

@property (nonatomic) int16_t end;
@property (nonatomic) int16_t taskId;
@property (nullable, nonatomic, copy) NSString *notations;
@property (nonatomic) int16_t start;
@property (nullable, nonatomic, copy) NSString *subactivity;

@end

NS_ASSUME_NONNULL_END
