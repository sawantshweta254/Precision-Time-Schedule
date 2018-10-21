//
//  AddRemarkViewController.h
//  PTS
//
//  Created by Shweta Sawant on 30/03/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTSSubTask+CoreDataProperties.h"

@protocol AddRemarkViewDelegate
-(void) updateSubTaskWithRemark;
@end

@interface AddRemarkViewController : UIViewController
@property (nonatomic, retain) PTSSubTask *subTask;
@property (nonatomic) int flightId;

@property (nonatomic, weak) id <AddRemarkViewDelegate> delegate;

@end
