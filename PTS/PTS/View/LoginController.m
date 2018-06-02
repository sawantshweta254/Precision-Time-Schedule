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
@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.buttonLogin.layer.borderWidth = 1.0f;;
    self.buttonLogin.layer.borderColor = [UIColor whiteColor].CGColor;
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
- (IBAction)loginUser:(id)sender {
    
    [[LoginManager sharedInstance] loginUser:self.textfieldUsername.text withPassword:self.textfieldPassword.text completionHandler:^(BOOL didLogin, User *user, NSString *errorMessage) {
        if (didLogin) {
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }else{
//            NSLog(@"Login Error : %@", errorMessage);
        }
    }];
}

@end
