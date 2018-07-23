//
//  RedCapSubtask+CoreDataProperties.m
//  
//
//  Created by Shweta Sawant on 03/07/18.
//
//

#import "RedCapSubtask+CoreDataProperties.h"

@implementation RedCapSubtask (CoreDataProperties)

+ (NSFetchRequest<RedCapSubtask *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"RedCapSubtask"];
}

@dynamic end;
@dynamic taskId;
@dynamic notations;
@dynamic start;
@dynamic subactivity;

@end
