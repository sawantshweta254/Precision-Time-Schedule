//
//  SupervisorTableViewController.h
//  PTS
//
//  Created by Shweta Sawant on 05/09/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTSItem+CoreDataProperties.h"

@interface SupervisorTableViewController : UITableViewController
@property (nonatomic, strong) PTSItem *selectedItem;
@end
