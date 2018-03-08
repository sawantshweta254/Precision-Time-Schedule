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

@end

@implementation PTSDetailCell

-(void) setCellData:(PTSSubTask *) subTask{
//    self.taskNumLabel.text = subTask.
    self.taskNameLabel.text = subTask.subactivity;
}

- (IBAction)timerTapped:(id)sender {
}

- (IBAction)addRemark:(id)sender {
}

- (IBAction)addTime:(id)sender {
}

@end
