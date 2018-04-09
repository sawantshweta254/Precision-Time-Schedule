//
//  AddRemarkViewController.m
//  PTS
//
//  Created by Shweta Sawant on 30/03/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "AddRemarkViewController.h"
#import "PTSManager.h"

@interface AddRemarkViewController ()
@property (weak, nonatomic) IBOutlet UITextView *remarkTextView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation AddRemarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.remarkTextView.text = self.subTask.userSubActFeedback;
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
- (IBAction)submitRemark:(id)sender {
    self.subTask.userSubActFeedback = self.remarkTextView.text;
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    NSError *error;
    [moc save:&error];
    
    [[PTSManager sharedInstance] updateRemarkForSubtask:self.subTask forFlight:self.flightId completionHandler:^(BOOL isSuccessfull) {
        if (isSuccessfull) {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }];
}

- (IBAction)dismissAddRemarkView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
