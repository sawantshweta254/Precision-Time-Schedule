//
//  PTSListViewCell.m
//  PTS
//
//  Created by Shweta Sawant on 20/02/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "PTSListViewCell.h"
#import "AppUtility.h"

@interface PTSListViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *flightTypeIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelFlightName;
@property (weak, nonatomic) IBOutlet UILabel *labelFlightArrivalTime;
@property (weak, nonatomic) IBOutlet UILabel *labelPTSTime;
@property (weak, nonatomic) IBOutlet UILabel *labelPTSDay;
@property (weak, nonatomic) IBOutlet UILabel *labelPtsTimer;
@property (weak, nonatomic) IBOutlet UIButton *buttonSupervisor;
@property (strong, nonatomic) PTSItem *ptsItem;
@property (nonatomic, strong) NSTimer *ptsTaskTimer;

@end

@implementation PTSListViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void) dealloc{
    [self.ptsTaskTimer invalidate];
    self.ptsTaskTimer = nil;
}

-(void) setPTSDetails:(PTSItem *)ptsItem{
    
    self.ptsItem = ptsItem;
    self.labelFlightName.text = ptsItem.flightNo;
        
    if (ptsItem.flightType == ArrivalType) {
        self.labelFlightArrivalTime.text = [NSString stringWithFormat:@"Arrival at %@", ptsItem.flightTime];
        [self.flightTypeIcon setImage:[UIImage imageNamed:@"arrival_flight"]];
    }else{
        self.labelFlightArrivalTime.text = [NSString stringWithFormat:@"Departure at %@", ptsItem.flightTime];
        [self.flightTypeIcon setImage:[UIImage imageNamed:@"departure_flight"]];
    }
    
    self.labelPTSTime.text = [NSString stringWithFormat:@"PTS Time %d", ptsItem.timeWindow];
    self.labelPTSDay.text = [self getTimeInStringFormat:ptsItem.flightDate];
    
    if (self.ptsItem.isRunning == 2) {
        [self.labelPtsTimer setText:[AppUtility getTimeDifference:self.ptsItem.ptsStartTime toEndTime:self.ptsItem.ptsEndTime]];
        [self.ptsTaskTimer invalidate];
        self.ptsTaskTimer = nil;
    }else if (self.ptsItem.isRunning == 1){
        [self setCallTime: nil];
        [self startPTSTimer];
    }
    else{
        NSDateComponentsFormatter *timeFormatter = [[NSDateComponentsFormatter alloc] init];
        timeFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
        timeFormatter.allowedUnits = NSCalendarUnitMinute|NSCalendarUnitSecond;
        self.labelPtsTimer.text = [NSString stringWithFormat:@"%@",[timeFormatter stringFromTimeInterval:ptsItem.timeWindow * 60]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (ptsItem.isRunning == 1) {
            [self startPTSTimer];
        }else if(ptsItem.isRunning == 2){
            [self.ptsTaskTimer invalidate];
            self.ptsTaskTimer = nil;
        }
    });
    
    if(self.ptsItem.isRunning == 2){
        self.backgroundColor = [UIColor colorWithRed:144/255.0 green:192/255.0 blue:88/255.0 alpha:1];
    }else{
        self.backgroundColor = [UIColor whiteColor];
    }
}

-(NSString *) getTimeInStringFormat:(NSString *) flightDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *flightDateInDateFormat = [dateFormatter dateFromString:flightDate];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    if ([calendar isDateInToday:flightDateInDateFormat]) {
        return @"Today";
    }else if ([calendar isDateInYesterday:flightDateInDateFormat]){
        return @"Yesterday";
    }else if ([calendar isDateInTomorrow:flightDateInDateFormat]){
        return @"Tomorrow";
    }else{
        [dateFormatter setDateFormat:@"dd MMM"];
        return [dateFormatter stringFromDate:flightDateInDateFormat];
    }
}

-(void) startPTSTimer
{
    self.ptsTaskTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setCallTime:) userInfo:nil repeats:YES];
    
}

-(void) setCallTime:(NSTimer *)timer{
//    NSTimeInterval timeInterval = fabs([self.ptsItem.ptsStartTime timeIntervalSinceNow]);
//    int ptsTaskTimeWindow = self.ptsItem.timeWindow * 60;
//    int duration = (int)timeInterval;
//    NSDateComponentsFormatter *timeFormatter = [[NSDateComponentsFormatter alloc] init];
//    timeFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
//    if (duration > 3600) {
//        timeFormatter.allowedUnits = NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
//    }else{
//        timeFormatter.allowedUnits = NSCalendarUnitMinute|NSCalendarUnitSecond;
//    }
//
//    int timeElapsed = ptsTaskTimeWindow - duration;
//
//    [self.labelPtsTimer setText:[NSString stringWithFormat:@"%@",[timeFormatter stringFromTimeInterval:timeElapsed]]];
    
    NSTimeInterval timeInterval = fabs([[NSDate date] timeIntervalSinceDate:self.ptsItem.ptsStartTime]);
    NSDateComponentsFormatter *timeFormatter = [[NSDateComponentsFormatter alloc] init];
    timeFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    if (timeInterval > 3600) {
        timeFormatter.allowedUnits = NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    }else{
        timeFormatter.allowedUnits = NSCalendarUnitMinute|NSCalendarUnitSecond;
    }
    
    NSString *appendZero = @"";
    if (timeInterval > 3600) {
        NSUInteger hours = (((NSUInteger)round(timeInterval))/3600);
        if (hours < 10) {
            appendZero = [appendZero stringByAppendingString:@"0"];
        }
    }else{
        NSUInteger minutes = (((NSUInteger)round(timeInterval))/60) % 60;
        if (minutes < 10) {
            appendZero = [appendZero stringByAppendingString:@"0"];
        }
    }
    
    [self.labelPtsTimer setText:[NSString stringWithFormat:@"%@%@",appendZero, [timeFormatter stringFromTimeInterval:timeInterval]]];

    
    if (self.ptsItem.isRunning == 2) {
        [timer invalidate];
        timer = nil;
    }
}

- (IBAction)showSuperVisor:(id)sender {
    
    [self.delegate showSupervisor];
}
@end
