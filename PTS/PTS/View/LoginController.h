//
//  LoginController.h
//  PTS
//
//  Created by Shweta Sawant on 15/02/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LoginViewDelegate
-(void) userDidLogin;
@end

@interface LoginController : UIViewController

@property (nonatomic, weak) id <LoginViewDelegate> delegate;

@end
