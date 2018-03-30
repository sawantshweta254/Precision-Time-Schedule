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
    
    if (self.subTask.subactivityStartTime != nil) {
        [self setCallTime];
        self.ptsTaskTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setCallTime) userInfo:nil repeats:YES];

    }
    self.subTask = subTask;
}

- (void)updatePtsSubTaskTimer:(UILongPressGestureRecognizer*)gesture {
    [self.ptsTaskTimer invalidate];
    if (self.subTask.subactivityStartTime == nil) {
        self.subTask.subactivityStartTime = [NSDate date];
        self.subTask.isRunning = 1;
        NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
        NSError *error;
        [moc save:&error];
        self.ptsTaskTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setCallTime) userInfo:nil repeats:YES];
    }else{
        [self.ptsTaskTimer invalidate];
        self.subTask.subactivityEndTime = [NSDate date];
        self.subTask.isRunning = 2;
        NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
        NSError *error;
        [moc save:&error];
    }
    
    [self.delegate updateFlightPTS];
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
    
    [self.labelSubTaskTimer setText:[NSString stringWithFormat:@"%@",[timeFormatter stringFromTimeInterval:timeElapsed]]];
}

- (IBAction)timerTapped:(id)sender {
    self.backgroundColor = [UIColor greenColor];
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
