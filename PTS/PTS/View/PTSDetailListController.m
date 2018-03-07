//
//  PTSDetailListController.m
//  PTS
//
//  Created by Shweta Sawant on 04/03/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "PTSDetailListController.h"
#import "PTSDetailCell.h"
#import "PTSManager.h"

@interface PTSDetailListController ()
@property (nonatomic, retain) NSArray *ptsAWingSubItemList;
@property (nonatomic, retain) NSArray *ptsBWingSubItemList;
@property (nonatomic, retain) NSArray *ptsSubItemList;
@end

@implementation PTSDetailListController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[PTSManager sharedInstance] fetchPTSSubItemsListPTS:self.ptsTask.ptsSubTaskId completionHandler:^(BOOL fetchComplete, PTSItem *ptsItem, NSError *error) {
        if (ptsItem.belowWingActivities.count > 0 && ptsItem.belowWingActivities.count > 0  ) {
            self.ptsAWingSubItemList = [NSMutableArray arrayWithObject:ptsItem.aboveWingActivities];
            self.ptsBWingSubItemList = [NSMutableArray arrayWithObject:ptsItem.belowWingActivities];
        }
//        [self.coll reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PTSDetailCell *detailCell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PTSDetailCell class]) forIndexPath:indexPath];
    
    return detailCell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.ptsSubItemList count];
}

#pragma mark Button Actions
- (IBAction)closeDetails:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
