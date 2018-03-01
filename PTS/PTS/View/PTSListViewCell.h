//
//  PTSListViewCell.h
//  PTS
//
//  Created by Shweta Sawant on 20/02/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTSItem+CoreDataProperties.h"

@interface PTSListViewCell : UITableViewCell

-(void) setPTSDetails:(PTSItem *)ptsItem;
@end
