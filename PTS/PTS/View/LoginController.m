//
//  LoginController.m
//  PTS
//
//  Created by Shweta Sawant on 15/02/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "LoginController.h"
#import "LoginManager.h"
#import "PTSManager.h"
#import <QuartzCore/QuartzCore.h>

@interface LoginController ()
@property (weak, nonatomic) IBOutlet UITextField *textfieldUsername;
@property (weak, nonatomic) IBOutlet UITextField *textfieldPassword;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;
@property (weak, nonatomic) IBOutlet UIScrollView *loginViewScrollview;
@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.buttonLogin.layer.borderWidth = 1.0f;;
    self.buttonLogin.layer.borderColor = [UIColor whiteColor].CGColor;
    
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

- (IBAction)loginUser:(id)sender {
    
    [[LoginManager sharedInstance] loginUser:self.textfieldUsername.text withPassword:self.textfieldPassword.text completionHandler:^(BOOL didLogin, User *user, NSString *errorMessage) {
        if (didLogin) {
            [self dismissViewControllerAnimated:YES completion:^{
                [self.delegate userDidLogin];
            }];
        }else{
            NSString *message = [NSString stringWithFormat:@"Username or Password invalid"];
            UIAlertController *invalidLoginError = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            
            [invalidLoginError addAction:actionOk];
            
            [self presentViewController:invalidLoginError animated:YES completion:nil];
        }
    }];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.textfieldUsername) {
        [self.textfieldPassword becomeFirstResponder];
    }else{
        [self loginUser:nil];
    }
    
    [textField resignFirstResponder];
    return true;
}

#pragma mark Notification methods
-(void)keyboardWillShow:(NSNotification*)notify
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.buttonLogin.frame.origin.y - 20, 0.0);
    self.loginViewScrollview.contentInset = contentInsets;
    self.loginViewScrollview.scrollIndicatorInsets = contentInsets;
}

-(void)keyboardWillHide:(NSNotification*)notify
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.loginViewScrollview.contentInset = contentInsets;
    self.loginViewScrollview.scrollIndicatorInsets = contentInsets;
}

@end
