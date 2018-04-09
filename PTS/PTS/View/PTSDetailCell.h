//
//  PTSDetailCell.h
//  PTS
//
//  Created by Shweta Sawant on 04/03/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTSSubTask+CoreDataProperties.h"
#import "PTSItem+CoreDataProperties.h"

@protocol PTSDetailCellDelegate
-(void) updateRemarkForSubtask:(PTSSubTask *)subTask;
-(void) updateFlightPTS;
@end

@interface PTSDetailCell : UICollectionViewCell
@property(nonatomic) NSInteger cellIndex;
@property (nonatomic, retain) PTSItem *ptsItem;
@property (nonatomic, weak) id <PTSDetailCellDelegate> delegate;
-(void) setCellData:(PTSSubTask *) subTask forFlight:(int)flightId;

@end
