//
//  SetTimeViewController.m
//  PTS
//
//  Created by Shweta Sawant on 12/04/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "SetTimeViewController.h"

#define Start_Timer_Picker 0
#define End_Timer_Picker 1

@interface SetTimeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *buttonStartTime;
@property (weak, nonatomic) IBOutlet UIButton *buttonEndTime;
@property (weak, nonatomic) IBOutlet UILabel *labelHeaderSetTime;

//Picker View
@property (weak, nonatomic) IBOutlet UIView *pickerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (weak, nonatomic) IBOutlet UILabel *labelPickerViewTime;

@property (nonatomic) NSInteger timerPickedFor;

@end

@implementation SetTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.timePicker addTarget:self action:@selector(dateSelected:) forControlEvents:UIControlEventValueChanged];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"NL"];
    [self.timePicker setLocale:locale];
    
    [self.buttonEndTime setHidden:NO];
    if (self.subTask.start - self.subTask.end == 0 || self.subTask.start - self.subTask.end == 1) {
        [self.buttonEndTime setHidden:YES];
    }

    
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self setUserDefinedTime];
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
- (IBAction)setStartTime:(id)sender { 
    [self updatePickerPageTimeLabel];
    self.timerPickedFor = Start_Timer_Picker;
}

- (IBAction)setEndTime:(id)sender {
    [self updatePickerPageTimeLabel];
    self.timerPickedFor = End_Timer_Picker;
}

- (void) updatePickerPageTimeLabel{
    self.pickerView.hidden = FALSE;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    self.labelPickerViewTime.text = [dateFormatter stringFromDate:[NSDate date]];
}

- (IBAction)pickerViewOkTapped:(id)sender {
//    NSDate *pickedDate = self.timePicker.date;
    if (self.timerPickedFor == Start_Timer_Picker) {
        self.buttonStartTime.titleLabel.text = [NSString stringWithFormat:@"Start Time      %@",self.labelPickerViewTime.text];
        self.subTask.userStartTime = [self.timePicker date];
    }else{
        self.buttonEndTime.titleLabel.text = [NSString stringWithFormat:@"End Time      %@",self.labelPickerViewTime.text];
        self.subTask.userEndTime = [self.timePicker date];
    }
    
    self.pickerView.hidden = TRUE;
}

- (IBAction)cancelPickerView:(id)sender {
    self.pickerView.hidden = TRUE;
}

- (IBAction)submitTime:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate updateSubTaskTime];
    }];
}

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void) dateSelected:(UIDatePicker *)picker{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    self.labelPickerViewTime.text = [dateFormatter stringFromDate:picker.date];
}

-(void) setUserDefinedTime{
    if (self.subTask.userStartTime != nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        [self.buttonStartTime.titleLabel setText:[NSString stringWithFormat:@"Start Time      %@",[dateFormatter stringFromDate:self.subTask.userStartTime]]];
    }
    
    if (self.subTask.userEndTime != nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        [self.buttonEndTime.titleLabel setText:[NSString stringWithFormat:@"End Time      %@",[dateFormatter stringFromDate:self.subTask.userEndTime]]];
    }
}
@end
