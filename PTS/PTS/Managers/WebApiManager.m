//
//  WebApiManager.m
//  PTS
//
//  Created by Shweta Sawant on 16/02/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "WebApiManager.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFNetworkReachabilityManager.h"


@implementation WebApiManager
static WebApiManager *sharedInstance;

+(instancetype) sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WebApiManager alloc] init];
    });
    
    return sharedInstance;
}

-(void) initiatePost:(ApiRequestData *) requestData completionHandler:(void (^)(BOOL requestSuccessfull, id responseData))requestCompletionHandler{
//    [self initiatePost1:requestData];
    

//    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"3.4.0",@"appVer",@"ms2user2@shweta.netsferedev.org", @"email", nil];
    NSData *conversationKeysJsonData = [NSJSONSerialization dataWithJSONObject:requestData.postData
                                                                       options:NSJSONWritingPrettyPrinted
                                                                         error:nil];
    NSString *conversationKeysJsonString = [[NSString alloc] initWithData:conversationKeysJsonData encoding:NSUTF8StringEncoding];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestData.postData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString *jsonString;
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    

    NSString *finalUrl = [requestData.baseURL stringByAppendingString:jsonString];
    NSString *encoded = [finalUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [manager.requestSerializer setHTTPMethodsEncodingParametersInURI:];
    
    [manager POST:encoded parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData){
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        requestCompletionHandler(TRUE, responseObject);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        requestCompletionHandler(FALSE, error);
    }];

}

@end
