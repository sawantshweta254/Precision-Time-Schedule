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

- (void) connectToWebSocket:(void (^)(BOOL isConnected))socketConnected;
- (void) updateUserForFlight:(PTSItem *)pts;
- (void) updateFlightTask:(PTSItem *)pts;
- (BOOL) isWebSocketConnected;

@end
