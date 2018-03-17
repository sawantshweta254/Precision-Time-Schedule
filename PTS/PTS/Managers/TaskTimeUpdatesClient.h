//
//  TaskTimeUpdatesManager.h
//  PTS
//
//  Created by Shweta Sawant on 12/03/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTSItem+CoreDataProperties.h"

@interface TaskTimeUpdatesClient : NSObject 

- (void)connectToWebSocket;
- (void) updateUserForFlight:(NSInteger)flightId;
- (void) updateFlightTask:(PTSItem *)pts;

@end
