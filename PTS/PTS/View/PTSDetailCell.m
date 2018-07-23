//
//  PTSDetailCell.m
//  PTS
//
//  Created by Shweta Sawant on 04/03/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "PTSDetailCell.h"
#import "User+CoreDataProperties.h"
#import "LoginManager.h"

@interface PTSDetailCell()
@property (weak, nonatomic) IBOutlet UILabel *taskNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *taskNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *eidtTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *remarkButton;
@property (weak, nonatomic) IBOutlet UIButton *taskTimerButton;
@property (weak, nonatomic) IBOutlet UILabel *labelSubTaskTimer;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *labelUserTaskTime;

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
    self.subTask.hasExceededTime = FALSE;
    
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
    
    if (self.subTask.subactivityStartTime != nil && self.subTask.isRunning == 1 && self.ptsItem.isRunning == 1 && !self.labelSubTaskTimer.hidden) {
        [self setTaskTime:nil];
        if (self.ptsTaskTimer == nil) {
            self.ptsTaskTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setTaskTime:) userInfo:nil repeats:YES];
        }
    }else if (self.subTask.isRunning == 2 || (self.subTask.isRunning == 1 && self.ptsItem.isRunning != 1)){
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
        
        
    }
    
    [self setTimeLabels];
    [self setContainerViewBackground];
    
}

- (void)updatePtsSubTaskTimer:(UILongPressGestureRecognizer*)gesture {
    User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];
    if (loggedInUser.empType == 2 || self.subTask.shouldBeInActive) {
        return;
    }
    if (gesture.state == UIGestureRecognizerStateEnded && self.ptsItem.isRunning == 1) {
        if (self.subTask.subactivityStartTime == nil && self.subTask.isRunning == 0) {
            self.subTask.subactivityStartTime = [NSDate date];
            self.subTask.isRunning = 1;
            NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
            NSError *error;
            [moc save:&error];
            self.ptsTaskTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setTaskTime:) userInfo:nil repeats:YES];
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
    
    [self setTimeLabels];
    [self setContainerViewBackground];
    
}

-(void) setTaskTime:(id)nsTimer{
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
        if (duration > ptsTaskTimeWindow && !self.subTask.hasExceededTime && !self.labelSubTaskTimer.hidden) {
            self.subTask.hasExceededTime = TRUE;
            [self setContainerViewBackground];
            [self.delegate updateFlightPTS];
        }
    });
}

-(void) setContainerViewBackground
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"hh:mm";
//        self.eidtTimeButton.titleLabel.text = [NSString stringWithFormat:@"%@ to %@",[dateFormatter stringFromDate:self.subTask.subactivityStartTime],[dateFormatter stringFromDate:self.subTask.subactivityEndTime]];
        
        if(self.subTask.hasExceededTime){
            self.containerView.backgroundColor = [UIColor redColor];
        }else if (self.subTask.isRunning == 1) {
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
        if (self.subTask.shouldBeInActive) {
            self.containerView.backgroundColor = [UIColor grayColor];
        }
    });
}

-(void) setTimeLabels{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *systemTaskTime;
    NSString *userTaskTime;
    
    self.eidtTimeButton.hidden = FALSE;
    if ((self.subTask.subactivityStartTime != nil && self.subTask.subactivityEndTime != nil) && (self.subTask.start - self.subTask.end != 0)) {
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
        
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:15];
        NSDictionary *userAttributes = @{NSFontAttributeName: font};
        const CGSize textSize = [systemTaskTime sizeWithAttributes: userAttributes];
        
        self.eidtTimeButton.imageEdgeInsets = UIEdgeInsetsMake(0.f, textSize.width + 5, 0.f, 0.f);
    });
}

#pragma mark Button Actions
- (IBAction)timerTapped:(id)sender {
    User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];
    if (loggedInUser.empType == 2 || self.subTask.shouldBeInActive) {
        return;
    }
    if (self.ptsItem.isRunning == 1) {
        self.containerView.backgroundColor = [UIColor colorWithRed:144/255.0 green:192/255.0 blue:88/255.0 alpha:1];
        self.subTask.subactivityStartTime = [NSDate date];
        self.subTask.isRunning = 2;
        self.subTask.isComplete = 1;
        self.subTask.subactivityEndTime = [NSDate date];
        [self.taskTimerButton setTitle:@"Finished" forState:UIControlStateNormal];
        
        [self setTimeLabels];
        NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
        NSError *error;
        [moc save:&error];
        [self.delegate updateFlightPTS];
    }
}

- (IBAction)addRemark:(id)sender {
    if ([self shouldPerformAction]) {
        [self.delegate updateRemarkForSubtask:self.subTask];
    }
}

- (IBAction)addTime:(id)sender {
    if ([self shouldPerformAction]) {
        [self.delegate updateUSerTimeForSubtask:self.subTask];
    }
}

-(BOOL) shouldPerformAction{
    User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];
    if (self.subTask.isRunning == 0 || self.subTask.shouldBeInActive || loggedInUser.empType == 2){
        return FALSE;
    }
    return TRUE;
}

@end
