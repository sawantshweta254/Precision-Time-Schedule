//
//  SetTimeViewController.h
//  PTS
//
//  Created by Shweta Sawant on 12/04/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTSSubTask+CoreDataProperties.h"

@protocol SetTimeViewDelegate
-(void) updateSubTaskTime;
@end

@interface SetTimeViewController : UIViewController

@property (nonatomic, retain) PTSSubTask *subTask;
@property (nonatomic, weak) id <SetTimeViewDelegate> delegate;

@end
