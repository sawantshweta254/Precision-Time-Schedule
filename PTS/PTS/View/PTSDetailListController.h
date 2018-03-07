//
//  PTSDetailListController.h
//  PTS
//
//  Created by Shweta Sawant on 04/03/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTSItem+CoreDataProperties.h"

@interface PTSDetailListController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic, strong) PTSItem *ptsTask;

@end
