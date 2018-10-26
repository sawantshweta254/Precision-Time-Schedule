//
//  AddRemarkViewController.m
//  PTS
//
//  Created by Shweta Sawant on 30/03/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "AddRemarkViewController.h"
#import "PTSManager.h"
#import "LoginManager.h"

@interface AddRemarkViewController ()
@property (weak, nonatomic) IBOutlet UITextView *remarkTextView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIScrollView *remarkPageScrollView;
@property (weak, nonatomic) IBOutlet UIView *remarkView;

@end

@implementation AddRemarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.remarkTextView.text = self.subTask.userSubActFeedback;
    
    [[self.remarkTextView layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[self.remarkTextView layer] setBorderWidth:1];
    [[self.remarkTextView layer] setCornerRadius:10];
    [self.remarkTextView setClipsToBounds: YES];
    
    User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];
    if (loggedInUser.empType != 3 || !self.subTask.shouldBeActive) {
        [self.remarkTextView setEditable:FALSE];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Notification methods
-(void)keyboardWillShow:(NSNotification*)notify
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 100, 0.0);
    self.remarkPageScrollView.contentInset = contentInsets;
    self.remarkPageScrollView.scrollIndicatorInsets = contentInsets;
}

-(void)keyboardWillHide:(NSNotification*)notify
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.remarkPageScrollView.contentInset = contentInsets;
    self.remarkPageScrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark Button Actions
- (IBAction)submitRemark:(id)sender {
    self.subTask.userSubActFeedback = self.remarkTextView.text;
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    NSError *error;
    [moc save:&error];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate updateSubTaskWithRemark];
    }];
        
//    [[PTSManager sharedInstance] updateRemarkForSubtask:self.subTask forFlight:self.flightId completionHandler:^(BOOL isSuccessfull) {
//        if (isSuccessfull) {
//            [self dismissViewControllerAnimated:YES completion:^{
//
//            }];
//        }
//    }];
}

- (IBAction)dismissAddRemarkView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
