//
//  PTSSubTask+CoreDataProperties.h
//  
//
//  Created by Shweta Sawant on 06/03/18.
//
//

#import "PTSSubTask+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface PTSSubTask (CoreDataProperties)

+ (NSFetchRequest<PTSSubTask *> *)fetchRequest;

@property (nonatomic) int16_t end;
@property (nonatomic) int16_t subTaskId;
@property (nonatomic) int16_t ptsDetailsId;
@property (nonatomic) int16_t mRefereceTimeId;
@property (nullable, nonatomic, copy) NSString *notations;
@property (nullable, nonatomic, copy) NSString *referenceTime;
@property (nonatomic) int16_t start;
@property (nullable, nonatomic, copy) NSString *subactivity;
@property (nonatomic) int16_t ptsWing;

@end

NS_ASSUME_NONNULL_END
