//
//  PTSSubTask+CoreDataProperties.m
//  
//
//  Created by Shweta Sawant on 19/03/18.
//
//

#import "PTSSubTask+CoreDataProperties.h"

@implementation PTSSubTask (CoreDataProperties)

+ (NSFetchRequest<PTSSubTask *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"PTSSubTask"];
}

@dynamic current_time;
@dynamic end;
@dynamic isComplete;
@dynamic isRunning;
@dynamic mRefereceTimeId;
@dynamic negativeData_SendServer;
@dynamic notations;
@dynamic ptsDetailsId;
@dynamic ptsTotalTime;
@dynamic ptsWing;
@dynamic referenceTime;
@dynamic start;
@dynamic subactivity;
@dynamic subactivity_end_time;
@dynamic subactivity_start_time;
@dynamic subActivityType;
@dynamic subTaskId;
@dynamic timer_executed_time;
@dynamic timer_stop_time;
@dynamic user_end_time;
@dynamic user_start_time;
@dynamic userSubActFeedback;

@end
