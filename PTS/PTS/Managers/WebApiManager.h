//
//  WebApiManager.h
//  PTS
//
//  Created by Shweta Sawant on 16/02/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApiRequestData.h"

@interface WebApiManager : NSObject
+(instancetype) sharedInstance;
-(void) initiatePost:(ApiRequestData *) requestData completionHandler:(void (^)(BOOL requestSuccessfull, id responseData))requestCompletionHandler;
@end
