//
//  PTSListTableTableViewController.h
//  PTS
//
//  Created by Shweta Sawant on 14/02/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginController.h"
#import "PTSListViewCell.h"

@interface PTSListViewController : UIViewController <LoginViewDelegate, PTSListViewCellDelegate, UISearchResultsUpdating, UISearchControllerDelegate, UIPopoverPresentationControllerDelegate>

@end
