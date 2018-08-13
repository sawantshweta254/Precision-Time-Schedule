//
//  PTSDetailListController.h
//  PTS
//
//  Created by Shweta Sawant on 04/03/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTSItem+CoreDataProperties.h"
#import "TaskTimeUpdatesClient.h"
#import "PTSDetailCell.h"
#import "AddRemarkViewController.h"
#import "SetTimeViewController.h"

@interface PTSDetailListController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, PTSDetailCellDelegate, AddRemarkViewDelegate, SetTimeViewDelegate, UITextFieldDelegate>

@property(nonatomic, strong) PTSItem *ptsTask;
@property (nonatomic, retain) TaskTimeUpdatesClient *taskUpdateClient;

@end
