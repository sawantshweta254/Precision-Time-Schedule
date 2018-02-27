//
//  PTSManager.h
//  PTS
//
//  Created by Shweta Sawant on 20/02/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTSManager : NSObject
+(instancetype) sharedInstance;
-(void) fetchPTSList:(void(^)(BOOL fetchComplete, NSArray *ptsTasks, NSError *error))fetchPTSCompletionHandler;
@end
