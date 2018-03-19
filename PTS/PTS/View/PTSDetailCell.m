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

@end

@implementation PTSDetailCell

-(void) setCellData:(PTSSubTask *) subTask{
    self.taskNameLabel.text = subTask.subactivity;
    self.taskNumLabel.text = [NSString stringWithFormat:@"%d",subTask.subTaskId ];
    
    if (subTask.start - subTask.end == 0) {
        [self.labelSubTaskTimer setHidden:YES];
        [self.taskTimerButton setHidden:NO];
    }else{
        [self.taskTimerButton setHidden:YES];
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [self.labelSubTaskTimer addGestureRecognizer:longPressGestureRecognizer];
        [self.labelSubTaskTimer setHidden:NO];
    }
    
    self.subTask = subTask;
}

- (void)longPress:(UILongPressGestureRecognizer*)gesture {
    [self.ptsTaskTimer invalidate];
    self.ptsTaskTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setCallTime) userInfo:nil repeats:YES];
}

-(void) setCallTime{
////    NSTimeInterval timeInterval = fabs([self.subTask.start timeIntervalSinceNow]);
//    int duration = (int)timeInterval;
//    NSDateComponentsFormatter *timeFormatter = [[NSDateComponentsFormatter alloc] init];
//    timeFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
//    if (duration > 3600) {
//        timeFormatter.allowedUnits = NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
//    }else{
//        timeFormatter.allowedUnits = NSCalendarUnitMinute|NSCalendarUnitSecond;
//    }
//    
//    [self.labelSubTaskTimer setText:[NSString stringWithFormat:@"%@",[timeFormatter stringFromTimeInterval:timeInterval]]];
}
- (IBAction)timerTapped:(id)sender {
    self.backgroundColor = [UIColor lightGrayColor];
}

- (IBAction)addRemark:(id)sender {
}

- (IBAction)addTime:(id)sender {
}

@end
