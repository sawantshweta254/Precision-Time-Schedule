//
//  WebsocketMessageFactory.h
//  PTS
//
//  Created by Shweta Sawant on 12/03/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTSItem+CoreDataProperties.h"
#import "PTSSubTask+CoreDataProperties.h"

@interface WebsocketMessageFactory : NSObject

-(NSString *) createLoggedInUserMessageForFlight:(NSArray *)ptsItemsIdArray;
-(NSString *) createUpdateMessageForFlight:(PTSItem *)ptsItem;

@end
