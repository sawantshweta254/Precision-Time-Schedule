//
//  FAQ+CoreDataProperties.h
//  
//
//  Created by Shweta Sawant on 09/10/18.
//
//

#import "FAQ+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface FAQ (CoreDataProperties)

+ (NSFetchRequest<FAQ *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *creation_on;
@property (nullable, nonatomic, copy) NSString *faq_a;
@property (nullable, nonatomic, copy) NSString *faq_q;
@property (nonatomic) int16_t faq_status;
@property (nonatomic) int32_t faqId;
@property (nullable, nonatomic, copy) NSDate *updated_on;

@end

NS_ASSUME_NONNULL_END
