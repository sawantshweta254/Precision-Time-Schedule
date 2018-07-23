//
//  User+CoreDataProperties.m
//  
//
//  Created by Shweta Sawant on 23/07/18.
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
@dynamic message;
@dynamic port;
@dynamic userId;
@dynamic userName;
@dynamic gridViewSelected;

@end
