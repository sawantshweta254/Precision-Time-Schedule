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
@property (strong, nonatomic) PTSItem *ptsItem;
@property (nonatomic, strong) NSTimer *ptsTaskTimer;
@end

@implementation PTSListViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
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
    
    if (self.ptsItem.ptsStartTime != nil) {
        [self setCallTime];
        [self startPTSTimer];
    }else{
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


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) startPTSTimer
{
    self.ptsTaskTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setCallTime) userInfo:nil repeats:YES];
    
}

-(void) setCallTime{
    NSTimeInterval timeInterval = fabs([self.ptsItem.ptsStartTime timeIntervalSinceNow]);
    int ptsTaskTimeWindow = self.ptsItem.timeWindow * 60;
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

@end
