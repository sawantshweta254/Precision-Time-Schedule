//
//  PTSItem+CoreDataProperties.m
//  
//
//  Created by Shweta Sawant on 27/10/18.
//
//

#import "PTSItem+CoreDataProperties.h"

@implementation PTSItem (CoreDataProperties)

+ (NSFetchRequest<PTSItem *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"PTSItem"];
}

@dynamic airlineName;
@dynamic coment;
@dynamic currentTime;
@dynamic dutyManagerId;
@dynamic dutyManagerName;
@dynamic executionTime;
@dynamic flightDate;
@dynamic flightId;
@dynamic flightNo;
@dynamic flightTime;
@dynamic flightType;
@dynamic isRunning;
@dynamic jsonData;
@dynamic masterRedCap;
@dynamic ptsEndTime;
@dynamic ptsName;
@dynamic ptsStartTime;
@dynamic ptsSubTaskId;
@dynamic redCapId;
@dynamic redCapName;
@dynamic remarks;
@dynamic supervisorId;
@dynamic supervisorName;
@dynamic timerStopTime;
@dynamic timeWindow;
@dynamic timerExecutedTime;
@dynamic aboveWingActivities;
@dynamic belowWingActivities;
@dynamic redCaps;

@end
