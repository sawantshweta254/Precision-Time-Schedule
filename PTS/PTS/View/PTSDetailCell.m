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
@property (weak, nonatomic) IBOutlet UIImageView *imageViewWatch;

@property (nonatomic, strong) PTSSubTask *subTask;
@property (nonatomic, strong) NSTimer *ptsTaskTimer;
@property (nonatomic) NSInteger flightId;

@property (nonatomic) BOOL isLessTimeTask;
@end

@implementation PTSDetailCell

-(void) setCellData:(PTSSubTask *) subTask forFlight:(int)flightId{
    self.subTask = subTask;

    self.flightId = flightId;
    self.taskNameLabel.text = subTask.subactivity;
    self.taskNumLabel.text = subTask.notations;
    self.isLessTimeTask = FALSE;
    
    if (subTask.start - subTask.end == 0 || subTask.start - subTask.end == 1){
        self.isLessTimeTask = TRUE;
    }
    
    [self hideWatchIconIfNeeded];
    if (self.isLessTimeTask) {
        [self.labelSubTaskTimer setHidden:YES];
        [self.taskTimerButton setHidden:NO];
    }else{
        [self.taskTimerButton setHidden:YES];
        UILongPressGestureRecognizer *tapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(updatePtsSubTaskTimer:)];
        [self.labelSubTaskTimer addGestureRecognizer:tapGestureRecognizer];
        
        self.labelSubTaskTimer.text = [NSString stringWithFormat:@" %@ ",[AppUtility getFormattedPTSTime: subTask.calculatedPTSFinalTime]];
        
        [self.labelSubTaskTimer setHidden:NO];
        self.labelSubTaskTimer.userInteractionEnabled = TRUE;
    }
    
    if (self.subTask.subactivityStartTime != nil && self.subTask.isRunning == 1 && !self.labelSubTaskTimer.hidden) {
        [self setTaskTime:fabs([self.subTask.subactivityStartTime timeIntervalSinceNow])];
        self.ptsTaskTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerUpdated:) userInfo:nil repeats:YES];
    }else if (self.subTask.isRunning == 2 || (self.subTask.isRunning == 1 && self.ptsItem.isRunning != 1)){
        [self setTaskTime:fabs([self.subTask.subactivityEndTime timeIntervalSinceDate:self.subTask.subactivityStartTime])];
    }
    
    if (self.subTask.isRunning != 1 && self.ptsTaskTimer != nil) {
        [self.ptsTaskTimer invalidate];
        self.ptsTaskTimer = nil;
    }
    [self setTimeLabels];
    [self setContainerViewBackground];
    
    self.labelSubTaskTimer.layer.borderColor = [UIColor blackColor].CGColor;
    self.labelSubTaskTimer.layer.borderWidth = 1.0;
    self.labelSubTaskTimer.layer.cornerRadius = 5;
    self.labelSubTaskTimer.clipsToBounds = TRUE;
    
    self.taskTimerButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.taskTimerButton.layer.borderWidth = 1.0;
    self.taskTimerButton.layer.cornerRadius = 5;
    self.taskTimerButton.clipsToBounds = TRUE;
   
    User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];
    if (loggedInUser.empType != 3) {
        [self.eidtTimeButton setImage:nil forState:UIControlStateNormal];
        if (self.subTask.userSubActFeedback.length == 0) {
            [self.remarkButton setHidden:YES];
        }else{
            [self.remarkButton setHidden:NO];
        }
    }
}

-(void) hideWatchIconIfNeeded{
    
    if (self.isLessTimeTask || [self.delegate shouldHideWatchIcon]) {
        [self.imageViewWatch setHidden:TRUE];
    }else{
        [self.imageViewWatch setHidden:NO];
    }
}

- (void)updatePtsSubTaskTimer:(UILongPressGestureRecognizer*)gesture {
    User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];
    if (loggedInUser.empType != 3 || !self.subTask.shouldBeActive || !self.subTask.isEnabled) {
        return;
    }
    if (gesture.state == UIGestureRecognizerStateEnded && self.ptsItem.isRunning > 0) {
        if (self.subTask.subactivityStartTime == nil && self.subTask.isRunning == 0) {
//             self.subTask.current_time = [NSDate date];
            self.subTask.current_time = [NSString stringWithFormat:@"%.f", [[NSDate date] timeIntervalSince1970]*1000];
            self.subTask.subactivityStartTime = [NSDate date];
            self.subTask.isRunning = 1;
            NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
            NSError *error;
            [moc save:&error];
            self.ptsTaskTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerUpdated:) userInfo:nil repeats:YES];
        }else if(self.subTask.isRunning == 1){
            [self.ptsTaskTimer invalidate];
            self.ptsTaskTimer = nil;
            self.subTask.subactivityEndTime = [NSDate date];
            self.subTask.isRunning = 2;
            self.subTask.isComplete = 1;
            
            long ptsTaskTimeWindowInMilis = self.subTask.calculatedPTSFinalTime * 60 * 1000;
            long remainingTimeToSend = ptsTaskTimeWindowInMilis + ([self.subTask.subactivityStartTime timeIntervalSince1970]*1000) - ([[NSDate date] timeIntervalSince1970]*1000);
            
            if (self.subTask.shouldBeActive) {
                self.subTask.timerExecutedTime = [NSString stringWithFormat:@"%ld", remainingTimeToSend];
            }
            
            NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
            NSError *error;
            [moc save:&error];
        }
        
        [self.delegate updateFlightPTS];
    }
    
    [self setTimeLabels];
    [self setContainerViewBackground];
    
}

-(void) timerUpdated:(id)nsTimer{
    if (self.subTask.isRunning == 2) {
        [nsTimer invalidate];
        nsTimer = nil;
        return;
    }
    [self setTaskTime:fabs([self.subTask.subactivityStartTime timeIntervalSinceNow])];
}

-(void) setTaskTime:(NSTimeInterval) timeIntervalToUse{
    NSTimeInterval timeInterval = timeIntervalToUse;
    int ptsTaskTimeWindow = self.subTask.calculatedPTSFinalTime * 60;
    int duration = (int)timeInterval;
    NSDateComponentsFormatter *timeFormatter = [[NSDateComponentsFormatter alloc] init];
    timeFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    if (duration > 3600) {
        timeFormatter.allowedUnits = NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    }else{
        timeFormatter.allowedUnits = NSCalendarUnitMinute|NSCalendarUnitSecond;
    }
    
    int timeElapsed;
    NSString *minusSign = @"";
    if (duration > ptsTaskTimeWindow) {
        timeElapsed = duration - ptsTaskTimeWindow;
        minusSign = @"-";
    }else{
        timeElapsed = ptsTaskTimeWindow - duration;
    }
    
    if (timeElapsed > 3600) {
        NSUInteger hours = (((NSUInteger)round(timeElapsed))/3600);
        if (hours < 10) {
            minusSign = [minusSign stringByAppendingString:@"0"];
        }
    }else{
        NSUInteger minutes = (((NSUInteger)round(timeElapsed))/60) % 60;
        if (minutes < 10) {
            minusSign = [minusSign stringByAppendingString:@"0"];
        }
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.labelSubTaskTimer setText:[NSString stringWithFormat:@" %@%@ ",minusSign, [timeFormatter stringFromTimeInterval:timeElapsed]]];
        if (duration > ptsTaskTimeWindow && !self.subTask.negativeDataSendServer && !self.labelSubTaskTimer.hidden && self.subTask.shouldBeActive) {
            self.subTask.negativeDataSendServer = TRUE;
            NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
            NSError *error;
            [moc save:&error];
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
        
        if(self.subTask.negativeDataSendServer){
            self.containerView.backgroundColor = [UIColor redColor];
        }else if (self.subTask.isRunning == 1) {
            self.containerView.backgroundColor = [UIColor colorWithRed:255/255.0 green:155/255.0 blue:16/255.0 alpha:1];
        }else if(self.subTask.isComplete){
            self.containerView.backgroundColor = [UIColor colorWithRed:144/255.0 green:192/255.0 blue:88/255.0 alpha:1];
            [self setFinishTitle];
        }else{
            self.containerView.backgroundColor = [UIColor whiteColor];
            if (self.isLessTimeTask) {
                [self.labelSubTaskTimer setHidden:YES];
                [self.taskTimerButton setHidden:NO];
                [self.taskTimerButton setTitle:@"Done" forState:UIControlStateNormal];
            }else{
                [self.taskTimerButton setHidden:YES];
                [self.labelSubTaskTimer setHidden:NO];
                self.labelSubTaskTimer.text = [NSString stringWithFormat:@" %@ ",[AppUtility getFormattedPTSTime: self.subTask.calculatedPTSFinalTime]];
            }
        }
        User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];
//        if (loggedInUser.empType == 3 && (!self.subTask.shouldBeActive || (self.ptsItem.isRunning == 2 && self.subTask.isRunning == 0 && self.ptsItem.masterRedCap)))
//        {
//            self.containerView.backgroundColor = [UIColor lightGrayColor];
//        }
        
        if (loggedInUser.empType == 3 && (!self.subTask.shouldBeActive ||!self.subTask.isEnabled))
        {
            self.containerView.backgroundColor = [UIColor lightGrayColor];
        }
    });
}

-(void) setTimeLabels{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *systemTaskTime;
    NSString *userTaskTime;
    
    self.eidtTimeButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.eidtTimeButton.hidden = FALSE;
    if ((self.subTask.subactivityStartTime != nil && self.subTask.subactivityEndTime != nil) && !self.isLessTimeTask) {
        systemTaskTime = [NSString stringWithFormat:@"%@ to %@  ", [dateFormatter stringFromDate:self.subTask.subactivityStartTime], [dateFormatter stringFromDate:self.subTask.subactivityEndTime]];
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
        self.eidtTimeButton.titleEdgeInsets = UIEdgeInsetsMake(0.f, 0.0f, 0.f, 0.f);
    });
}

#pragma mark Button Actions
- (IBAction)timerTapped:(id)sender {
    User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];
    if (loggedInUser.empType != 3 || !self.subTask.shouldBeActive || !self.subTask.isEnabled) {
        return;
    }
    if (self.ptsItem.isRunning > 0) {
        self.containerView.backgroundColor = [UIColor colorWithRed:144/255.0 green:192/255.0 blue:88/255.0 alpha:1];
        self.subTask.subactivityStartTime = [NSDate date];
        self.subTask.isRunning = 2;
        self.subTask.isComplete = 1;
        self.subTask.subactivityEndTime = [NSDate date];
        self.subTask.timerExecutedTime = [NSString stringWithFormat:@"0"];
        [self setFinishTitle];
        
        [self setTimeLabels];
        NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
        NSError *error;
        [moc save:&error];
        [self.delegate updateFlightPTS];
    }
}

- (IBAction)addRemark:(id)sender {
     User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];
    if ([self shouldPerformAction] || loggedInUser.empType != 3 || self.ptsItem.masterRedCap) {
        [self.delegate updateRemarkForSubtask:self.subTask];
    }
}

- (IBAction)addTime:(id)sender {
    User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];
    if ([self shouldPerformAction] && loggedInUser.empType == 3) {
        [self.delegate updateUSerTimeForSubtask:self.subTask];
    }
}

-(BOOL) shouldPerformAction{
    
    if (self.subTask.isRunning == 0 || !self.subTask.shouldBeActive){
        return FALSE;
    }
    return TRUE;
}

-(void) setFinishTitle{
    [self.taskTimerButton setTitle:@"Finished" forState:UIControlStateNormal];
    self.taskTimerButton.layer.borderWidth = 0.0;
}
@end
