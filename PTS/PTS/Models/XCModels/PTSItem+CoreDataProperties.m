//
//  PTSItem+CoreDataProperties.m
//  
//
//  Created by Shweta Sawant on 01/03/18.
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
@dynamic flightTime;
@dynamic flightNo;
@dynamic ptsId;
@dynamic jsonData;
@dynamic ptsSubTaskId;
@dynamic ptsName;
@dynamic redCapId;
@dynamic redCapName;
@dynamic remarks;
@dynamic supervisorId;
@dynamic supervisorName;
@dynamic timeWindow;
@dynamic ptsType;

-(NSString *) flightArrivalDateInString{
    return @"";
}

-(NSString *) flightArrivalTimeInString{
    return @"";
}

-(NSString *) ptsDurationInString{
    return @"";
}

@end
