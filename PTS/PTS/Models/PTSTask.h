//
//  PTSTask.h
//  PTS
//
//  Created by Shweta Sawant on 20/02/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTSTask : NSObject
@property (nonatomic) double ptsID;
@property (nonatomic) int flightWing;
@property (nonatomic, retain) NSString *taskName;
@property (nonatomic) int *taskStatus;
@property (nonatomic, retain) NSString *comment;
@property (nonatomic) double ptsTaskTime;
@property (nonatomic) double ptsElapsedTime;
@end
