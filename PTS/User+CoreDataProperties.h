//
//  User+CoreDataProperties.h
//  
//
//  Created by Shweta Sawant on 06/10/18.
//
//

#import "User+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

+ (NSFetchRequest<User *> *)fetchRequest;

@property (nonatomic) double airportId;
@property (nonatomic) double apiStatus;
@property (nonatomic) int16_t empType;
@property (nonatomic) int64_t faqChecksum;
@property (nullable, nonatomic, retain) NSData *flightPTSInfo;
@property (nonatomic) BOOL gridViewSelected;
@property (nullable, nonatomic, copy) NSString *message;
@property (nonatomic) int16_t port;
@property (nonatomic) double userId;
@property (nullable, nonatomic, copy) NSString *userName;
@property (nullable, nonatomic, retain) NSSet<FAQ *> *faqs;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addFaqsObject:(FAQ *)value;
- (void)removeFaqsObject:(FAQ *)value;
- (void)addFaqs:(NSSet<FAQ *> *)values;
- (void)removeFaqs:(NSSet<FAQ *> *)values;

@end

NS_ASSUME_NONNULL_END
