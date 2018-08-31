//
//  PTSListViewCell.h
//  PTS
//
//  Created by Shweta Sawant on 20/02/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTSItem+CoreDataProperties.h"

@protocol PTSListViewCellDelegate
-(void) showSupervisor;
- (void)showComment:(NSString *)comment;
@end

@interface PTSListViewCell : UITableViewCell

@property (nonatomic, weak) id <PTSListViewCellDelegate> delegate;

-(void) setPTSDetails:(PTSItem *)ptsItem;
@end
