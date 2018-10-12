//
//  RedCap+CoreDataProperties.m
//  
//
//  Created by Shweta Sawant on 09/10/18.
//
//

#import "RedCap+CoreDataProperties.h"

@implementation RedCap (CoreDataProperties)

+ (NSFetchRequest<RedCap *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"RedCap"];
}

@dynamic masterRedCap;
@dynamic redCapId;
@dynamic redcapName;
@dynamic tableGroupId;
@dynamic aboveWingSubTasks;
@dynamic belowWingSubtask;

@end
