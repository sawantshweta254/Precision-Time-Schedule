//
//  PTSSubTask+CoreDataProperties.m
//  
//
//  Created by Shweta Sawant on 06/03/18.
//
//

#import "PTSSubTask+CoreDataProperties.h"

@implementation PTSSubTask (CoreDataProperties)

+ (NSFetchRequest<PTSSubTask *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"PTSSubTask"];
}

@dynamic end;
@dynamic subTaskId;
@dynamic ptsDetailsId;
@dynamic mRefereceTimeId;
@dynamic notations;
@dynamic referenceTime;
@dynamic start;
@dynamic subactivity;
@dynamic ptsWing;

@end
