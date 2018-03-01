//
//  PTSItem+CoreDataProperties.h
//  
//
//  Created by Shweta Sawant on 01/03/18.
//
//

#import "PTSItem+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface PTSItem (CoreDataProperties)

+ (NSFetchRequest<PTSItem *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *airlineName;
@property (nonatomic) int16_t dutyManagerId;
@property (nullable, nonatomic, copy) NSString *dutyManagerName;
@property (nullable, nonatomic, copy) NSDate *flightDate;
@property (nullable, nonatomic, copy) NSDate *flightTime;
@property (nullable, nonatomic, copy) NSString *flightNo;
@property (nonatomic) int16_t ptsId;
@property (nullable, nonatomic, copy) NSString *jsonData;
@property (nonatomic) int16_t ptsSubTaskId;
@property (nullable, nonatomic, copy) NSString *ptsName;
@property (nonatomic) int16_t redCapId;
@property (nullable, nonatomic, copy) NSString *redCapName;
@property (nullable, nonatomic, copy) NSString *remarks;
@property (nonatomic) int16_t supervisorId;
@property (nullable, nonatomic, copy) NSString *supervisorName;
@property (nonatomic) int16_t timeWindow;
@property (nonatomic) int16_t ptsType;

-(NSString *) flightArrivalDateInString;
-(NSString *) flightArrivalTimeInString;
-(NSString *) ptsDurationInString;

@end

NS_ASSUME_NONNULL_END
