//
//  RedCapSubtask+CoreDataProperties.m
//  
//
//  Created by Shweta Sawant on 29/07/18.
//
//

#import "RedCapSubtask+CoreDataProperties.h"

@implementation RedCapSubtask (CoreDataProperties)

+ (NSFetchRequest<RedCapSubtask *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"RedCapSubtask"];
}

@dynamic end;
@dynamic notations;
@dynamic start;
@dynamic subactivity;
@dynamic taskId;

@end
