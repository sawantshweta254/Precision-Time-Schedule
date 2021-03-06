//
//  PTSManager.h
//  PTS
//
//  Created by Shweta Sawant on 20/02/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User+CoreDataClass.h"
#import "PTSItem+CoreDataProperties.h"

@interface PTSManager : NSObject
+(instancetype) sharedInstance;
-(void) fetchPTSListFromDB:(User*)user completionHandler:(void(^)(NSArray *ptsTasks, NSError *error))fetchPTSCompletionHandler;
-(void) fetchPTSListForUser:(User*)user forLogin: (BOOL)initialLogin completionHandler:(void(^)(BOOL fetchComplete, NSArray *ptsTasks, NSError *error))fetchPTSCompletionHandler;
-(void) fetchPTSSubItemsListPTS:(PTSItem *)ptsItem completionHandler:(void(^)(BOOL fetchComplete, PTSItem *ptsItem, NSError *error))fetchPTSCompletionHandler;
-(void) updateRemarkForSubtask:(PTSSubTask *)task forFlight:(int) flightId completionHandler:(void(^)(BOOL isSuccessfull))remarkUpdateCompletionHandler;
-(void) parseUpdatesReceivedForPTS:(NSDictionary *)ptsTask;
-(void) parsePTSUpdateReceivedForRedCap:(NSDictionary *) updatedPtsData forInitialLogin:(BOOL) initialLogin;
@end
