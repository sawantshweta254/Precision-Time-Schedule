//
//  User+CoreDataProperties.m
//  
//
//  Created by Shweta Sawant on 27/02/18.
//
//

#import "User+CoreDataProperties.h"

@implementation User (CoreDataProperties)

+ (NSFetchRequest<User *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"User"];
}

@dynamic userName;
@dynamic flightPTSInfo;
@dynamic airportId;
@dynamic userId;
@dynamic apiStatus;
@dynamic port;
@dynamic message;
@dynamic empType;

@end
