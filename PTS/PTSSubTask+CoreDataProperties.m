//
//  PTSSubTask+CoreDataProperties.m
//  
//
//  Created by Shweta Sawant on 21/10/18.
//
//

#import "PTSSubTask+CoreDataProperties.h"

@implementation PTSSubTask (CoreDataProperties)

+ (NSFetchRequest<PTSSubTask *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"PTSSubTask"];
}

@dynamic calculatedPTSFinalTime;
@dynamic current_time;
@dynamic end;
@dynamic hasExceededTime;
@dynamic isComplete;
@dynamic isEnabled;
@dynamic isRunning;
@dynamic mRefereceTimeId;
@dynamic negativeDataSendServer;
@dynamic notations;
@dynamic ptsDetailsId;
@dynamic ptsTotalTime;
@dynamic ptsWing;
@dynamic referenceTime;
@dynamic shouldBeActive;
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

@end
