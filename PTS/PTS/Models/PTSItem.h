//
//  PTSItem.h
//  PTS
//
//  Created by Shweta Sawant on 20/02/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTSItem : NSObject

@property (nonatomic) double ptsID;
@property (nonatomic, retain) NSString *flightName;
@property (nonatomic) double flightArrivalTime;
@property (nonatomic) double ptsDuration;
@property (nonatomic, retain) NSDate *flightArrivalDate;

-(NSString *) flightArrivalDateInString;
-(NSString *) flightArrivalTimeInString;
-(NSString *) ptsDurationInString;

@end
