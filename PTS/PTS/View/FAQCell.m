//
//  FAQCell.m
//  PTS
//
//  Created by Shweta Sawant on 01/10/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "FAQCell.h"

@interface FAQCell()
@property (weak, nonatomic) IBOutlet UILabel *labelNum;
@property (weak, nonatomic) IBOutlet UILabel *labelQuestion;
@property (weak, nonatomic) IBOutlet UILabel *labelAnswer;

@end

@implementation FAQCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setData:(FAQ *)faq{
    self.labelNum.text = [NSString stringWithFormat:@"%d.", faq.faqId];
    self.labelQuestion.text = faq.faq_q;
    self.labelAnswer.text = faq.faq_a;
}

@end
