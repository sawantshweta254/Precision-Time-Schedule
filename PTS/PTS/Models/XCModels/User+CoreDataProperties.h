//
//  User+CoreDataProperties.h
//  
//
//  Created by Shweta Sawant on 27/02/18.
//
//

#import "User+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

+ (NSFetchRequest<User *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *userName;
@property (nullable, nonatomic, retain) NSData *flightPTSInfo;
@property (nonatomic) double airportId;
@property (nonatomic) double userId;
@property (nonatomic) double apiStatus;
@property (nonatomic) int16_t port;
@property (nullable, nonatomic, copy) NSString *message;
@property (nonatomic) int16_t empType;

@end

NS_ASSUME_NONNULL_END
