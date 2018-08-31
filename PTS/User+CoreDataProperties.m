//
//  User+CoreDataProperties.m
//  
//
//  Created by Shweta Sawant on 31/08/18.
//
//

#import "User+CoreDataProperties.h"

@implementation User (CoreDataProperties)

+ (NSFetchRequest<User *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"User"];
}

@dynamic airportId;
@dynamic apiStatus;
@dynamic empType;
@dynamic flightPTSInfo;
@dynamic gridViewSelected;
@dynamic message;
@dynamic port;
@dynamic userId;
@dynamic userName;

@end
