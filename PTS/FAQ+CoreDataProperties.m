//
//  FAQ+CoreDataProperties.m
//  
//
//  Created by Shweta Sawant on 06/10/18.
//
//

#import "FAQ+CoreDataProperties.h"

@implementation FAQ (CoreDataProperties)

+ (NSFetchRequest<FAQ *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"FAQ"];
}

@dynamic creation_on;
@dynamic faq_a;
@dynamic faq_q;
@dynamic faq_status;
@dynamic faqId;
@dynamic updated_on;

@end
