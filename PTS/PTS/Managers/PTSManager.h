//
//  PTSManager.h
//  PTS
//
//  Created by Shweta Sawant on 20/02/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User+CoreDataClass.h"

@interface PTSManager : NSObject
+(instancetype) sharedInstance;
-(void) fetchPTSListForUser:(User*)user completionHandler:(void(^)(BOOL fetchComplete, NSArray *ptsTasks, NSError *error))fetchPTSCompletionHandler;
@end
