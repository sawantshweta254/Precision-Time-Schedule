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
#import "PTSDetailListController.h"
#import "PTSItem+CoreDataProperties.h"
#import "PTSManager.h"
#import "User+CoreDataProperties.h"

#import "LoginManager.h"
#import "TaskTimeUpdatesClient.h"
#import "RedCap+CoreDataProperties.h"

@interface PTSListViewController ()
@property (nonatomic, retain) TaskTimeUpdatesClient *taskUpdateClient;
@property (nonatomic, retain) NSMutableArray *ptsTasks;

@property (weak, nonatomic) IBOutlet UIButton *socketConnectedButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation PTSListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];
    
    if (!loggedInUser) {
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginController *loginView = [mainStoryBoard instantiateViewControllerWithIdentifier:NSStringFromClass([LoginController class])];
        [self.navigationController presentViewController:loginView animated:F_TEST completion:nil];
    }else{
        [[PTSManager sharedInstance] fetchPTSListForUser:loggedInUser completionHandler:^(BOOL fetchComplete, NSArray *ptsTasks, NSError *error) {
            self.ptsTasks = [NSMutableArray arrayWithArray:ptsTasks];
            if (self.ptsTasks.count > 0) {
                [self loadListOnView];
                [self registerFlightsForUpdate];
            }
            if (self.taskUpdateClient == nil) {
                self.taskUpdateClient = [[TaskTimeUpdatesClient alloc] init];
                [self.taskUpdateClient connectToWebSocket:^(BOOL isConnected) {
                    [self.socketConnectedButton setImage:[UIImage imageNamed:@"green"] forState:UIControlStateNormal];
                }];
            }

        }];
        
    }
    
    self.navigationItem.title = [NSString stringWithFormat:@"Welcome %@",loggedInUser.userName];
    UIBarButtonItem *reloadBarButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"sync_data"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(reloadTaskList:)];
    [self.navigationItem setRightBarButtonItem:reloadBarButton];

    if ([self.taskUpdateClient isWebSocketConnected]) {
        [self.socketConnectedButton setImage:[UIImage imageNamed:@"green"] forState:UIControlStateNormal];
    }else{
        [self.socketConnectedButton setImage:[UIImage imageNamed:@"red"] forState:UIControlStateNormal];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChangesForPTS:) name:@"PTSListUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSocketConnectivity:) name:@"SocketConnectionUpdated" object:nil];
}

-(RedCap *) selfRedCap:(NSArray *)redCapsArray{
    User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];
    NSPredicate *selfRedcapPredicate = [NSPredicate predicateWithFormat:@"redCapId == %lf",loggedInUser.userId];
    RedCap *selfRedcap = [[redCapsArray filteredArrayUsingPredicate:selfRedcapPredicate] lastObject];
    
    return selfRedcap;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) loadListOnView{
    if (self.ptsTasks.count > 0) {
        [self.tableView reloadData];
        self.tableView.backgroundView = nil;
    }else{
        UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        [noDataLabel setFont:[UIFont systemFontOfSize:25]];
        noDataLabel.numberOfLines = 2;
        
        UIFont *boldFont = [UIFont boldSystemFontOfSize:25];
        NSString *noFlightString = @"Currently NO FLIGHT is Assigned";
        NSRange boldedRange = [noFlightString rangeOfString:@"NO FLIGHT"];
        
        NSMutableAttributedString *attrNoFlightString = [[NSMutableAttributedString alloc] initWithString:noFlightString];
        
        [attrNoFlightString beginEditing];
        [attrNoFlightString addAttribute:NSFontAttributeName
                           value:boldFont
                           range:boldedRange];
        
        [attrNoFlightString endEditing];
        noDataLabel.attributedText   = attrNoFlightString;
        noDataLabel.textColor        = [UIColor grayColor];
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        self.tableView.backgroundView = noDataLabel;
    }
}

#pragma mark NSNotification methods
-(void) updateChangesForPTS:(NSNotification *) notification
{
    [self.tableView reloadData];
}

-(void) updateSocketConnectivity:(NSNotification *) notification{
    if ([notification.object boolValue]) {
        [self.socketConnectedButton setImage:[UIImage imageNamed:@"green"] forState:UIControlStateNormal];
        User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];
        [[PTSManager sharedInstance] fetchPTSListForUser:loggedInUser completionHandler:^(BOOL fetchComplete, NSArray *ptsTasks, NSError *error) {
            self.ptsTasks = [NSMutableArray arrayWithArray:ptsTasks];
            [self registerFlightsForUpdate];
            [self loadListOnView];
        }];
    }else{
        [self.socketConnectedButton setImage:[UIImage imageNamed:@"red"] forState:UIControlStateNormal];
    }
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
#pragma mark Button Actions
- (IBAction)reloadTaskList:(id)sender {
    [self.taskUpdateClient connectToWebSocket:^(BOOL isConnected) {
        [self.socketConnectedButton setImage:[UIImage imageNamed:@"green"] forState:UIControlStateNormal];
    }];
    
    User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];
    [[PTSManager sharedInstance] fetchPTSListForUser:loggedInUser completionHandler:^(BOOL fetchComplete, NSArray *ptsTasks, NSError *error) {
        self.ptsTasks = [NSMutableArray arrayWithArray:ptsTasks];
        [self loadListOnView];
        
        if (self.taskUpdateClient == nil) {
            self.taskUpdateClient = [[TaskTimeUpdatesClient alloc] init];
            [self.taskUpdateClient connectToWebSocket:^(BOOL isConnected) {
                [self.socketConnectedButton setImage:[UIImage imageNamed:@"green"] forState:UIControlStateNormal];
            }];
        }
        
        [self registerFlightsForUpdate];

    }];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *selectedCell = (UITableViewCell*)sender;
    NSInteger selectedIndex = ((NSIndexPath *)[self.tableView indexPathForCell:selectedCell]).row;
    PTSDetailListController *ptsDetailView = segue.destinationViewController;
    ptsDetailView.taskUpdateClient = self.taskUpdateClient;
    ptsDetailView.ptsTask = [self.ptsTasks objectAtIndex:selectedIndex];
}

#pragma mark Utility methods
- (void) registerFlightsForUpdate{
    NSArray *ptsIdsArray = [self.ptsTasks valueForKey:@"flightId"];
    NSMutableDictionary *redCapDetailsDic = [[NSMutableDictionary alloc] init];
    for (PTSItem *ptsItem in self.ptsTasks) {
        RedCap *selfRedcap = [self selfRedCap:[ptsItem.redCaps allObjects]];
        [redCapDetailsDic setObject:[NSNumber numberWithBool:selfRedcap.masterRedCap] forKey:[NSNumber numberWithInt:ptsItem.flightId]];
    }
    [self.taskUpdateClient updateUserForFlight:ptsIdsArray masterRedCapDetails:redCapDetailsDic];
}

@end
