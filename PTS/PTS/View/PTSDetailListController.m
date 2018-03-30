//
//  PTSDetailListController.m
//  PTS
//
//  Created by Shweta Sawant on 04/03/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "PTSDetailListController.h"
#import "PTSManager.h"

@interface PTSDetailListController ()
@property (weak, nonatomic) IBOutlet UILabel *labelArrivalTime;

@property (weak, nonatomic) IBOutlet UILabel *labelFlightName;
@property (weak, nonatomic) IBOutlet UILabel *labelPtsTime;
//@property (weak, nonatomic) IBOutlet UIButton *buttonPtsTimer;
@property (weak, nonatomic) IBOutlet UIImageView *flightTypeIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelPtsTimer;

@property (nonatomic, retain) NSArray *ptsAWingSubItemList;
@property (nonatomic, retain) NSArray *ptsBWingSubItemList;
@property (weak, nonatomic) IBOutlet UICollectionView *ptsSubTasksCollectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *wingSegmentCOntroller;
@property (weak, nonatomic) IBOutlet UISegmentedControl *listTypeSegmentController;

@property (nonatomic) NSInteger selectedWingIndex;
@property (nonatomic) NSInteger selectedListTypeIndex;

@property (nonatomic, strong) NSTimer *ptsTaskTimer;
@end

@implementation PTSDetailListController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setFlightDetails];

    if (self.ptsTask.ptsStartTime != nil) {
        [self setCallTime];
        [self startPTSTimer];
    }
    
    if (self.ptsTask.aboveWingActivities.count != 0 && self.ptsTask.belowWingActivities.count != 0) {
        self.ptsAWingSubItemList = [self.ptsTask.aboveWingActivities allObjects];
        self.ptsBWingSubItemList = [self.ptsTask.belowWingActivities allObjects];

        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"subTaskId" ascending:YES];
        self.ptsAWingSubItemList = [self.ptsAWingSubItemList sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        self.ptsBWingSubItemList = [self.ptsBWingSubItemList sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    }else{
        [[PTSManager sharedInstance] fetchPTSSubItemsListPTS:self.ptsTask completionHandler:^(BOOL fetchComplete, PTSItem *ptsItem, NSError *error) {
            if (ptsItem.aboveWingActivities.count > 0 && ptsItem.belowWingActivities.count > 0  ) {
                NSSet *wingATaskSet = ptsItem.aboveWingActivities;
                self.ptsAWingSubItemList = [wingATaskSet allObjects];
                NSSet *wingBTaskSet = ptsItem.belowWingActivities;
                self.ptsBWingSubItemList = [wingBTaskSet allObjects];
                self.ptsTask.aboveWingActivities = [NSSet setWithArray:self.ptsAWingSubItemList];
                self.ptsTask.belowWingActivities = [NSSet setWithArray:self.ptsBWingSubItemList];
            }
            
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"subTaskId" ascending:YES];
            self.ptsAWingSubItemList = [self.ptsAWingSubItemList sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            self.ptsBWingSubItemList = [self.ptsBWingSubItemList sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            
            [self.ptsSubTasksCollectionView reloadData];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) setFlightDetails{
    
    self.labelFlightName.text = self.ptsTask.flightNo;
    self.labelPtsTime.text = [NSString stringWithFormat:@"PTS Time %d", self.ptsTask.timeWindow];
    
    if (self.ptsTask.flightType == ArrivalType) {
        self.labelArrivalTime.text = [NSString stringWithFormat:@"Arrival at %@", self.ptsTask.flightTime];
        [self.flightTypeIcon setImage:[UIImage imageNamed:@"arrival_flight"]];
    }else{
        self.labelArrivalTime.text = [NSString stringWithFormat:@"Departure at %@", self.ptsTask.flightTime];
        [self.flightTypeIcon setImage:[UIImage imageNamed:@"departure_flight"]];
    }
    
    
    NSDateComponentsFormatter *timeFormatter = [[NSDateComponentsFormatter alloc] init];
    timeFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    timeFormatter.allowedUnits = NSCalendarUnitMinute|NSCalendarUnitSecond;
    self.labelPtsTimer.text = [NSString stringWithFormat:@"%@",[timeFormatter stringFromTimeInterval:self.ptsTask.timeWindow * 60]];
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
    PTSSubTask *subTask;
    if (self.selectedWingIndex == 0) {
        subTask = [self.ptsAWingSubItemList objectAtIndex:indexPath.row];
    }else{
        subTask = [self.ptsBWingSubItemList objectAtIndex:indexPath.row];
    }
    detailCell.cellIndex = indexPath.row;
    detailCell.ptsItem = self.ptsTask;
    detailCell.delegate = self;
    [detailCell setCellData:subTask forFlight:self.ptsTask.flightId];

    return detailCell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.selectedWingIndex == 0) {
        return self.ptsAWingSubItemList.count;
    }
    return self.ptsBWingSubItemList.count;
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (self.selectedListTypeIndex == 0) {
        return 1;
    }else{
        return 2;
    }
}

#pragma mark Button Actions
- (IBAction)closeDetails:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)displayStyleChanged:(id)sender {
    self.selectedListTypeIndex = self.listTypeSegmentController.selectedSegmentIndex;
    [self.ptsSubTasksCollectionView reloadData];
}

- (IBAction)wingTypeChanged:(id)sender {
    self.selectedWingIndex = self.wingSegmentCOntroller.selectedSegmentIndex;
    [self.ptsSubTasksCollectionView reloadData];
}

- (IBAction)updatePTSItemTimer:(id)sender {
    if (((UILongPressGestureRecognizer*)sender).state == UIGestureRecognizerStateEnded ) {
        UIAlertController *updateTimerAlert = [UIAlertController alertControllerWithTitle:nil message:@"Would you like to start the tasks?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionYes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self startPTSTimer];
        }];
        
        UIAlertAction *actionNo = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:nil];
        
        [updateTimerAlert addAction:actionYes];
        [updateTimerAlert addAction:actionNo];
        
        [self presentViewController:updateTimerAlert animated:YES completion:nil];
    }
}

#pragma mark Utility Methods
-(void) startPTSTimer
{
    if (self.ptsTask.ptsStartTime == nil) {
        self.ptsTask.ptsStartTime = [NSDate date];
        self.ptsTask.isRunning = 1;
        NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
        NSError *error;
        [moc save:&error];
        [self.taskUpdateClient updateFlightTask:self.ptsTask];
        self.ptsSubTasksCollectionView.userInteractionEnabled = YES;
        [self.ptsTaskTimer invalidate];
        self.ptsTaskTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setCallTime) userInfo:nil repeats:YES];
    }else{
        self.ptsTask.ptsEndTime = [NSDate date];
        NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
        NSError *error;
        [moc save:&error];
        self.ptsSubTasksCollectionView.userInteractionEnabled = YES;
        [self.ptsTaskTimer invalidate];
        self.ptsTaskTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setCallTime) userInfo:nil repeats:YES];
    }
    
    [self.taskUpdateClient updateFlightTask:self.ptsTask];
    
}

-(void) setCallTime{
    NSTimeInterval timeInterval = fabs([self.ptsTask.ptsStartTime timeIntervalSinceNow]);
    int ptsTaskTimeWindow = self.ptsTask.timeWindow * 60;
    int duration = (int)timeInterval;
    NSDateComponentsFormatter *timeFormatter = [[NSDateComponentsFormatter alloc] init];
    timeFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    if (duration > 3600) {
        timeFormatter.allowedUnits = NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    }else{
        timeFormatter.allowedUnits = NSCalendarUnitMinute|NSCalendarUnitSecond;
    }
    
    int timeElapsed = ptsTaskTimeWindow - duration;
    
    [self.labelPtsTimer setText:[NSString stringWithFormat:@"%@",[timeFormatter stringFromTimeInterval:timeElapsed]]];
}

#pragma mark Cell Delegate methods
-(void) updateFlightPTS{
    [self.taskUpdateClient updateFlightTask:self.ptsTask];
}

@end
