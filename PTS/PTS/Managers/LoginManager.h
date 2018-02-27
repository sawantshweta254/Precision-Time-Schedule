//
//  LoginManager.h
//  PTS
//
//  Created by Shweta Sawant on 15/02/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginManager : NSObject
+(instancetype) sharedInstance;
-(void) loginUser:(NSString *) username withPassword:(NSString *) password completionHandler:(void (^)(BOOL didLogin))loginCompletionHandler;
@end
