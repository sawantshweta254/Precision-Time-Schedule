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

@interface LoginController ()
@property (weak, nonatomic) IBOutlet UITextField *textfieldUsername;
@property (weak, nonatomic) IBOutlet UITextField *textfieldPassword;
@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
            [[PTSManager sharedInstance] fetchPTSListForUser:user completionHandler:^(BOOL fetchComplete, NSArray *ptsTasks, NSError *error) {
                [self dismissViewControllerAnimated:YES completion:^{
                    if (fetchComplete) {
                        
                    }
                }];
            }];
        }else{
            NSLog(@"Login Error : %@", errorMessage);
        }
    }];
}

@end
