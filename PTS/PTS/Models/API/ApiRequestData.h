//
//  ApiRequestData.h
//  PTS
//
//  Created by Shweta Sawant on 16/02/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SERVICE_API_URL @"http://techdew.co.in/pts1/webapi/"

@interface ApiRequestData : NSObject

/// base url of server
@property(nonatomic,retain) NSString *baseURL;

/// web service name
@property(nonatomic,retain) NSString *webServiceURL;

/// set your query dic in case of Post method
@property(nonatomic,retain) NSDictionary *postData;

@end
