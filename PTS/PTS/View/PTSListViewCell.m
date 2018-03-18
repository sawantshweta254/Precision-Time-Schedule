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

@end

@implementation PTSListViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void) setPTSDetails:(PTSItem *)ptsItem{
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

@end
