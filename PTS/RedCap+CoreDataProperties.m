//
//  RedCap+CoreDataProperties.m
//  
//
//  Created by Shweta Sawant on 03/07/18.
//
//

#import "RedCap+CoreDataProperties.h"

@implementation RedCap (CoreDataProperties)

+ (NSFetchRequest<RedCap *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"RedCap"];
}

@dynamic redCapId;
@dynamic tableGroupId;
@dynamic redcapName;
@dynamic masterRedCap;
@dynamic aboveWingSubTasks;
@dynamic belowWingSubtask;

@end
