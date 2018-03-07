//
//  PTSListViewCell.m
//  PTS
//
//  Created by Shweta Sawant on 20/02/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "PTSListViewCell.h"

@interface PTSListViewCell()
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
    self.labelFlightArrivalTime.text = ptsItem.flightTime;
//    self.labelPTSDay.text = [ptsItem flightArrivalDateInString];
//    self.labelPTSTime.text = [ptsItem ptsDurationInString];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
