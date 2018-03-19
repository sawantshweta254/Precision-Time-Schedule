//
//  PTSItem+CoreDataProperties.m
//  
//
//  Created by Shweta Sawant on 19/03/18.
//
//

#import "PTSItem+CoreDataProperties.h"

@implementation PTSItem (CoreDataProperties)

+ (NSFetchRequest<PTSItem *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"PTSItem"];
}

@dynamic airlineName;
@dynamic dutyManagerId;
@dynamic dutyManagerName;
@dynamic flightDate;
@dynamic flightId;
@dynamic flightNo;
@dynamic flightTime;
@dynamic flightType;
@dynamic jsonData;
@dynamic ptsName;
@dynamic ptsStartTime;
@dynamic ptsSubTaskId;
@dynamic redCapId;
@dynamic redCapName;
@dynamic remarks;
@dynamic supervisorId;
@dynamic supervisorName;
@dynamic timeWindow;
@dynamic ptsEndTime;
@dynamic aboveWingActivities;
@dynamic belowWingActivities;

@end
