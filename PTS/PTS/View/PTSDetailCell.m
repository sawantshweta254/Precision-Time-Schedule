//
//  PTSDetailCell.m
//  PTS
//
//  Created by Shweta Sawant on 04/03/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "PTSDetailCell.h"

@interface PTSDetailCell()
@property (weak, nonatomic) IBOutlet UILabel *taskNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *taskNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *eidtTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *remarkButton;
@property (weak, nonatomic) IBOutlet UIButton *taskTimerButton;
@property (weak, nonatomic) IBOutlet UILabel *labelSubTaskTimer;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, strong) PTSSubTask *subTask;
@property (nonatomic, strong) NSTimer *ptsTaskTimer;
@property (nonatomic) NSInteger flightId;
@end

@implementation PTSDetailCell

-(void) setCellData:(PTSSubTask *) subTask forFlight:(int)flightId{
    
    self.flightId = flightId;
    self.taskNameLabel.text = subTask.subactivity;
    self.taskNumLabel.text = [NSString stringWithFormat:@"%ld",self.cellIndex + 1];
    
    if (subTask.start - subTask.end == 0) {
        [self.labelSubTaskTimer setHidden:YES];
        [self.taskTimerButton setHidden:NO];
    }else{
        [self.taskTimerButton setHidden:YES];
        UILongPressGestureRecognizer *tapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(updatePtsSubTaskTimer:)];
        [self.labelSubTaskTimer addGestureRecognizer:tapGestureRecognizer];
        
        self.labelSubTaskTimer.text = [NSString stringWithFormat:@"%@",[AppUtility getFormattedPTSTime: subTask.calculatedPTSFinalTime]];
        
        [self.labelSubTaskTimer setHidden:NO];
        self.labelSubTaskTimer.userInteractionEnabled = TRUE;
    }
    
    if (self.subTask.subactivityStartTime != nil && self.subTask.isRunning == 1) {
        [self setCallTime];
        self.ptsTaskTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setCallTime) userInfo:nil repeats:YES];

    }
    
    
    [self setContainerViewBackground];
    
    self.subTask = subTask;
}

- (void)updatePtsSubTaskTimer:(UILongPressGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded && self.ptsItem.isRunning == 1) {
        if (self.subTask.subactivityStartTime == nil && self.subTask.isRunning == 0) {
            self.subTask.subactivityStartTime = [NSDate date];
            self.subTask.isRunning = 1;
            NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
            NSError *error;
            [moc save:&error];
            self.ptsTaskTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setCallTime) userInfo:nil repeats:YES];
        }else if(self.subTask.isRunning == 1){
            [self.ptsTaskTimer invalidate];
            self.ptsTaskTimer = nil;
            self.subTask.subactivityEndTime = [NSDate date];
            self.subTask.isRunning = 2;
            self.subTask.isComplete = 1;
            NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
            NSError *error;
            [moc save:&error];
        }
        
        [self.delegate updateFlightPTS];
    }
    
    [self setContainerViewBackground];
    
}

-(void) setCallTime{
    NSTimeInterval timeInterval = fabs([self.subTask.subactivityStartTime timeIntervalSinceNow]);
    int ptsTaskTimeWindow = self.subTask.calculatedPTSFinalTime * 60;
    int duration = (int)timeInterval;
    NSDateComponentsFormatter *timeFormatter = [[NSDateComponentsFormatter alloc] init];
    timeFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    if (duration > 3600) {
        timeFormatter.allowedUnits = NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    }else{
        timeFormatter.allowedUnits = NSCalendarUnitMinute|NSCalendarUnitSecond;
    }
    
    int timeElapsed = ptsTaskTimeWindow - duration;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.labelSubTaskTimer setText:[NSString stringWithFormat:@"%@",[timeFormatter stringFromTimeInterval:timeElapsed]]];
    });
}

-(void) setContainerViewBackground
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.subTask.isRunning == 1) {
            self.containerView.backgroundColor = [UIColor yellowColor];
        }else if(self.subTask.isComplete){
            self.containerView.backgroundColor = [UIColor greenColor];
        }else{
            self.containerView.backgroundColor = [UIColor whiteColor];
        }
    });
}

#pragma mark Button Actions
- (IBAction)timerTapped:(id)sender {
     self.containerView.backgroundColor = [UIColor greenColor];
    self.subTask.subactivityStartTime = [NSDate date];
    self.subTask.isRunning = 0;
    self.subTask.isComplete = 1;
    self.subTask.subactivityEndTime = [NSDate date];
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    NSError *error;
    [moc save:&error];
    [self.delegate updateFlightPTS];
}

- (IBAction)addRemark:(id)sender {
}

- (IBAction)addTime:(id)sender {
}

@end
