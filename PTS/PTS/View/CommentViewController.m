//
//  CommentViewController.m
//  PTS
//
//  Created by Shweta Sawant on 31/08/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "CommentViewController.h"

@interface CommentViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelComment;
@end

@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.labelComment.text = self.comment;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)okTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
