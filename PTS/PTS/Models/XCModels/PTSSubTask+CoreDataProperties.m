//
//  PTSSubTask+CoreDataProperties.m
//  
//
//  Created by Shweta Sawant on 21/03/18.
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
@dynamic negativeDataSendServer;
@dynamic notations;
@dynamic ptsDetailsId;
@dynamic ptsTotalTime;
@dynamic ptsWing;
@dynamic referenceTime;
@dynamic start;
@dynamic subactivity;
@dynamic subactivityEndTime;
@dynamic subactivityStartTime;
@dynamic subActivityType;
@dynamic subTaskId;
@dynamic timerExecutedTime;
@dynamic timerStopTime;
@dynamic userEndTime;
@dynamic userStartTime;
@dynamic userSubActFeedback;
@dynamic calculatedPTSFinalTime;

@end
