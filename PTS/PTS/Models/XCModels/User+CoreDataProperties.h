//
//  User+CoreDataProperties.h
//  
//
//  Created by Shweta Sawant on 29/07/18.
//
//

#import "User+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

+ (NSFetchRequest<User *> *)fetchRequest;

@property (nonatomic) double airportId;
@property (nonatomic) double apiStatus;
@property (nonatomic) int16_t empType;
@property (nullable, nonatomic, retain) NSData *flightPTSInfo;
@property (nonatomic) BOOL gridViewSelected;
@property (nullable, nonatomic, copy) NSString *message;
@property (nonatomic) int16_t port;
@property (nonatomic) double userId;
@property (nullable, nonatomic, copy) NSString *userName;

@end

NS_ASSUME_NONNULL_END
