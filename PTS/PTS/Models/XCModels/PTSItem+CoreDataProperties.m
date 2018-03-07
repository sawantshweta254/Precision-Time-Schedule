//
//  PTSItem+CoreDataProperties.m
//  
//
//  Created by Shweta Sawant on 07/03/18.
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
@dynamic flightNo;
@dynamic flightTime;
@dynamic jsonData;
@dynamic ptsId;
@dynamic ptsName;
@dynamic ptsSubTaskId;
@dynamic ptsType;
@dynamic redCapId;
@dynamic redCapName;
@dynamic remarks;
@dynamic supervisorId;
@dynamic supervisorName;
@dynamic timeWindow;
@dynamic aboveWingActivities;
@dynamic belowWingActivities;

@end
