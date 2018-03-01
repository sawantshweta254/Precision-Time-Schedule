//
//  PTSListTableTableViewController.m
//  PTS
//
//  Created by Shweta Sawant on 14/02/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "PTSListViewController.h"
#import "LoginController.h"
#import "PTSListViewCell.h"
#import "PTSItem+CoreDataProperties.h"
#import "PTSManager.h"
#import "User+CoreDataProperties.h"

#import "LoginManager.h"

@interface PTSListViewController ()
@property (nonatomic, retain) NSMutableArray *ptsTasks;
@end

@implementation PTSListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];
    
    if (!loggedInUser) {
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginController *loginView = [mainStoryBoard instantiateViewControllerWithIdentifier:NSStringFromClass([LoginController class])];
        [self.navigationController presentViewController:loginView animated:F_TEST completion:nil];
    }else{
        [[PTSManager sharedInstance] fetchPTSListForUser:loggedInUser completionHandler:^(BOOL fetchComplete, NSArray *ptsTasks, NSError *error) {
            self.ptsTasks = [NSMutableArray arrayWithArray:ptsTasks];
            [self.tableView reloadData];
        }];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.ptsTasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PTSListViewCell *ptsCell = [tableView dequeueReusableCellWithIdentifier:@"PTSItemCell" forIndexPath:indexPath];
    PTSItem *pts = [self.ptsTasks objectAtIndex:indexPath.row];
    [ptsCell setPTSDetails:pts];
    return ptsCell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
