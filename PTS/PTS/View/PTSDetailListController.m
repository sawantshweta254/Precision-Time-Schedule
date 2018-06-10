//
//  PTSDetailListController.m
//  PTS
//
//  Created by Shweta Sawant on 04/03/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "PTSDetailListController.h"
#import "PTSManager.h"
#import "LoginManager.h"

#define cellHeight 100

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

    [self.wingSegmentCOntroller setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateSelected];
    [self.listTypeSegmentController setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateSelected];
    

    if (self.ptsTask.isRunning == 1) {
        [self setCallTime];
        [self.ptsTaskTimer invalidate];
        self.ptsTaskTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setCallTime) userInfo:nil repeats:YES];
    }else if (self.ptsTask.ptsStartTime != nil){
        [self.labelPtsTimer setText:[AppUtility getTimeDifference:self.ptsTask.ptsStartTime toEndTime:self.ptsTask.ptsEndTime]];  
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChangesForPTS:) name:@"PTSListUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSocketConnectivity:) name:@"SocketConnectionUpdated" object:nil];

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

#pragma mark NSNotification methods
-(void) updateChangesForPTS:(NSNotification *) notification
{
    [self.ptsSubTasksCollectionView reloadData];
}

-(void) updateSocketConnectivity:(NSNotification *) notification{
    if ([notification.object boolValue]) {
        [self.taskUpdateClient updateFlightTask:self.ptsTask];
    }
}

#pragma mark- Navigation

-(BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"SetTastTime"]){
        User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];
        if (loggedInUser.empType == 2) {
            return FALSE;
        }
    }
    
    return TRUE;
}
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddRemarkSegue"]) {
//        CGPoint buttonPoint =  [sender convertPoint:CGPointZero toView:self.ptsSubTasksCollectionView];
//        NSIndexPath *buttonIndexPath = [self.ptsSubTasksCollectionView indexPathForItemAtPoint:buttonPoint];
        AddRemarkViewController *addRemarkViewController = segue.destinationViewController;
        addRemarkViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        addRemarkViewController.flightId = self.ptsTask.flightId;
        addRemarkViewController.subTask = (PTSSubTask *)sender;
        addRemarkViewController.delegate = self;
//        if (self.selectedWingIndex == 0) {
////            addRemarkViewController.subTask = [self.ptsAWingSubItemList objectAtIndex:buttonIndexPath.row];
//        }else{
////            addRemarkViewController.subTask = [self.ptsBWingSubItemList objectAtIndex:buttonIndexPath.row];
//        }
    }else{
        CGPoint buttonPoint =  [sender convertPoint:CGPointZero toView:self.ptsSubTasksCollectionView];
        NSIndexPath *buttonIndexPath = [self.ptsSubTasksCollectionView indexPathForItemAtPoint:buttonPoint];
        SetTimeViewController *setTimeViewController = segue.destinationViewController;
        setTimeViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        setTimeViewController.delegate = self;
        
        if (self.selectedWingIndex == 0) {
            setTimeViewController.subTask = [self.ptsAWingSubItemList objectAtIndex:buttonIndexPath.row];
        }else{
            setTimeViewController.subTask = [self.ptsBWingSubItemList objectAtIndex:buttonIndexPath.row];
        }
     }
}


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

//- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
//    if (self.selectedListTypeIndex == 0) {
//        return 1;
//    }else{
//        return 2;
//    }
//}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    float cellWidth = screenWidth / 2.0; //Replace the divisor with the column count requirement. Make sure to have it in float.
    
    
    if (self .selectedListTypeIndex == 0) {
        CGSize size = CGSizeMake(screenWidth, cellHeight);
        return size;
    }
    
    CGSize size = CGSizeMake(cellWidth, cellHeight);
    return size;
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
    User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];
    if (loggedInUser.empType == 2) {
        return;
    }
    
    if (((UILongPressGestureRecognizer*)sender).state == UIGestureRecognizerStateEnded ) {
        
        if (self.ptsTask.isRunning == 0) {
            NSString *message = [NSString stringWithFormat:@"Please confirm if you want to start PTS for flight %@", self.ptsTask.flightNo];
            UIAlertController *updateTimerAlert = [UIAlertController alertControllerWithTitle:@"Message" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionYes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self startPTSTimer];
            }];
            
            UIAlertAction *actionNo = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:nil];
            
            [updateTimerAlert addAction:actionYes];
            [updateTimerAlert addAction:actionNo];
            
            [self presentViewController:updateTimerAlert animated:YES completion:nil];
        }else  if (self.ptsTask.isRunning == 1){
            NSString *message = [NSString stringWithFormat:@"Please confirm if you want to stop PTS for flight %@", self.ptsTask.flightNo];
            UIAlertController *updateTimerAlert = [UIAlertController alertControllerWithTitle:@"Message" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionYes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self startPTSTimer];
            }];
            
            UIAlertAction *actionNo = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:nil];
            
            [updateTimerAlert addAction:actionYes];
            [updateTimerAlert addAction:actionNo];
            
            [self presentViewController:updateTimerAlert animated:YES completion:nil];
        }
        
    }
}

#pragma mark Utility Methods
-(void) startPTSTimer
{
    if (self.ptsTask.isRunning == 0) {
        self.ptsTask.ptsStartTime = [NSDate date];
        self.ptsTask.isRunning = 1;
        NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
        NSError *error;
        [moc save:&error];
        [self.taskUpdateClient updateFlightTask:self.ptsTask];
        self.ptsSubTasksCollectionView.userInteractionEnabled = YES;
        [self.ptsTaskTimer invalidate];
        self.ptsTaskTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setCallTime) userInfo:nil repeats:YES];
    }else if (self.ptsTask.isRunning == 1){
        self.ptsTask.ptsEndTime = [NSDate date];
        self.ptsTask.isRunning = 2;
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

-(void) updateRemarkForSubtask:(PTSSubTask *)subTask{
    [self performSegueWithIdentifier:@"AddRemarkSegue" sender:subTask];
}

#pragma mark AddRemarkView delegate methods
-(void) updateSubTaskWithRemark{
    [self.taskUpdateClient updateFlightTask:self.ptsTask];
}

#pragma mark SetTimeView delegate methods
-(void) updateSubTaskTime{
    [self.taskUpdateClient updateFlightTask:self.ptsTask];
    [self.ptsSubTasksCollectionView reloadData];
}
@end
