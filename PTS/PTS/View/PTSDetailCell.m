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
@property (weak, nonatomic) IBOutlet UILabel *labelUserTaskTime;
@property (weak, nonatomic) IBOutlet UILabel *labelSystemTaskTime;
@property (weak, nonatomic) IBOutlet UIView *viewEditTime;

@property (nonatomic, strong) PTSSubTask *subTask;
@property (nonatomic, strong) NSTimer *ptsTaskTimer;
@property (nonatomic) NSInteger flightId;
@end

@implementation PTSDetailCell

-(void) setCellData:(PTSSubTask *) subTask forFlight:(int)flightId{
    self.subTask = subTask;

    self.flightId = flightId;
    self.taskNameLabel.text = subTask.subactivity;
    self.taskNumLabel.text = subTask.notations;
    
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
    
    self.viewEditTime.hidden = TRUE;
    
    if (self.subTask.subactivityStartTime != nil && self.subTask.isRunning == 1) {
        [self setTaskTime];
        self.ptsTaskTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setTaskTime) userInfo:nil repeats:YES];
    }else if (self.subTask.isRunning == 2){
        NSTimeInterval timeInterval = fabs([self.subTask.subactivityEndTime timeIntervalSinceDate:self.subTask.subactivityStartTime]);
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
        
        [self setTimeLabels];
    }
    
    
    [self setContainerViewBackground];
    
}

- (void)updatePtsSubTaskTimer:(UILongPressGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded && self.ptsItem.isRunning == 1) {
        if (self.subTask.subactivityStartTime == nil && self.subTask.isRunning == 0) {
            self.subTask.subactivityStartTime = [NSDate date];
            self.subTask.userStartTime = self.subTask.subactivityStartTime;
            self.subTask.isRunning = 1;
            NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
            NSError *error;
            [moc save:&error];
            self.ptsTaskTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setTaskTime) userInfo:nil repeats:YES];
        }else if(self.subTask.isRunning == 1){
            [self.ptsTaskTimer invalidate];
            self.ptsTaskTimer = nil;
            self.subTask.subactivityEndTime = [NSDate date];
             self.subTask.userEndTime = self.subTask.subactivityEndTime;
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

-(void) setTaskTime{
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
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"hh:mm";
        self.eidtTimeButton.titleLabel.text = [NSString stringWithFormat:@"%@ to %@",[dateFormatter stringFromDate:self.subTask.subactivityStartTime],[dateFormatter stringFromDate:self.subTask.subactivityEndTime]];
        if (self.subTask.isRunning == 1) {
            self.containerView.backgroundColor = [UIColor colorWithRed:255/255.0 green:155/255.0 blue:16/255.0 alpha:1];
        }else if(self.subTask.isComplete){
            self.containerView.backgroundColor = [UIColor colorWithRed:144/255.0 green:192/255.0 blue:88/255.0 alpha:1];
            [self.taskTimerButton setTitle:@"Finished" forState:UIControlStateNormal];
        }else{
            self.containerView.backgroundColor = [UIColor whiteColor];
            if (self.subTask.start - self.subTask.end == 0) {
                [self.labelSubTaskTimer setHidden:YES];
                [self.taskTimerButton setHidden:NO];
                [self.taskTimerButton setTitle:@"Done" forState:UIControlStateNormal];
            }else{
                [self.taskTimerButton setHidden:YES];
                [self.labelSubTaskTimer setHidden:NO];
                self.labelSubTaskTimer.text = [NSString stringWithFormat:@"%@",[AppUtility getFormattedPTSTime: self.subTask.calculatedPTSFinalTime]];
            }
        }
    });
}

-(void) setTimeLabels{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *systemTaskTime;
    NSString *userTaskTime;
    
    self.eidtTimeButton.hidden = FALSE;
    if (self.subTask.subactivityStartTime != nil && self.subTask.subactivityEndTime != nil) {
        systemTaskTime = [NSString stringWithFormat:@"%@ to %@", [dateFormatter stringFromDate:self.subTask.subactivityStartTime], [dateFormatter stringFromDate:self.subTask.subactivityEndTime]];
    }else if (self.subTask.subactivityStartTime != nil){
        systemTaskTime = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:self.subTask.subactivityStartTime]];
    }else{
        self.eidtTimeButton.hidden = TRUE;
    }
    
    self.labelUserTaskTime.hidden = FALSE;
    if (self.subTask.userStartTime != nil && self.subTask.userEndTime != nil) {
        userTaskTime = [NSString stringWithFormat:@"%@ to %@", [dateFormatter stringFromDate:self.subTask.userStartTime], [dateFormatter stringFromDate:self.subTask.userEndTime]];
    }else if (self.subTask.userStartTime != nil){
        userTaskTime = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:self.subTask.userStartTime]];
    }else{
        self.labelUserTaskTime.hidden = TRUE;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.eidtTimeButton setTitle:systemTaskTime forState:UIControlStateNormal];
        [self.labelUserTaskTime setText:userTaskTime];
    });
}

#pragma mark Button Actions
- (IBAction)timerTapped:(id)sender {
    if (self.ptsItem.isRunning == 1) {
        self.containerView.backgroundColor = [UIColor colorWithRed:144/255.0 green:192/255.0 blue:88/255.0 alpha:1];
        self.subTask.subactivityStartTime = [NSDate date];
        self.subTask.isRunning = 2;
        self.subTask.isComplete = 1;
        self.subTask.subactivityEndTime = [NSDate date];
        self.subTask.userEndTime = self.subTask.userEndTime;
        [self.taskTimerButton setTitle:@"Finished" forState:UIControlStateNormal];
        
        NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
        NSError *error;
        [moc save:&error];
        [self.delegate updateFlightPTS];
    }
}

- (IBAction)addRemark:(id)sender {
    if (self.ptsItem.isRunning == 1) {
        [self.delegate updateRemarkForSubtask:self.subTask];
    }
}

- (IBAction)addTime:(id)sender {
}

@end
