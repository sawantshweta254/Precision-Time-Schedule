//
//  PTSDetailCell.h
//  PTS
//
//  Created by Shweta Sawant on 04/03/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTSSubTask+CoreDataProperties.h"

@interface PTSDetailCell : UICollectionViewCell
-(void) setCellData:(PTSSubTask *) subTask;

@end
