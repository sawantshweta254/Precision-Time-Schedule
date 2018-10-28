//
//  PTSListTableTableViewController.m
//  PTS
//
//  Created by Shweta Sawant on 14/02/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "PTSListViewController.h"
#import "LoginController.h"
#import "PTSDetailListController.h"
#import "PTSItem+CoreDataProperties.h"
#import "PTSManager.h"
#import "User+CoreDataProperties.h"

#import "LoginManager.h"
#import "TaskTimeUpdatesClient.h"
#import "RedCap+CoreDataProperties.h"
#import "RedCap+CoreDataProperties.h"
#import "RedCapSubtask+CoreDataProperties.h"

#import "SupervisorTableViewController.h"
#import "CommentViewController.h"

#import "FAQViewController.h"
#import "AFNetworkReachabilityManager.h"

@interface PTSListViewController ()
@property (nonatomic, retain) TaskTimeUpdatesClient *taskUpdateClient;
@property (nonatomic, retain) NSMutableArray *ptsTasks;
@property (nonatomic, retain) NSArray *ptsTasksToLoad;

@property (weak, nonatomic) IBOutlet UIButton *socketConnectedButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, strong) PTSItem *selectedPTSItem;
@end

@implementation PTSListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];
    
    if (!loggedInUser) {
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginController *loginView = [mainStoryBoard instantiateViewControllerWithIdentifier:NSStringFromClass([LoginController class])];
        loginView.delegate = self;
        [self.navigationController presentViewController:loginView animated:F_TEST completion:nil];
    }else{
        [self setSearchBar];
        [self showLoadingView];
        [[PTSManager sharedInstance] fetchPTSListForUser:loggedInUser forLogin:false completionHandler:^(BOOL fetchComplete, NSArray *ptsTasks, NSError *error) {
            self.ptsTasks = [NSMutableArray arrayWithArray:ptsTasks];
            if (self.ptsTasks.count > 0) {
                self.ptsTasksToLoad = self.ptsTasks;
                [self loadListOnView];
                [self registerFlightsForUpdate];
            }
        }];
        
        [self setUpTaskClient];
    }
    
    [self setViewTitle:loggedInUser.userName];
    UIBarButtonItem *reloadBarButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"sync_data"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(reloadTaskList:)];
    UIBarButtonItem *logoutBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutUser)];
    [logoutBarButton setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *faqBarButton = [[UIBarButtonItem alloc] initWithTitle:@"FAQ" style:UIBarButtonItemStylePlain target:self action:@selector(loadFAQ)];
    [faqBarButton setTintColor:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:reloadBarButton, logoutBarButton, faqBarButton, nil]];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         switch (status) {
             case AFNetworkReachabilityStatusReachableViaWWAN:
             case AFNetworkReachabilityStatusReachableViaWiFi:
                 NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
                 [self networkConnected];
                 break;
             case AFNetworkReachabilityStatusUnknown:
             case AFNetworkReachabilityStatusNotReachable:
                 NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
             default:
                 break;
         }
     }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self.tableView reloadData];
    
    if ([self.taskUpdateClient isWebSocketConnected]) {
        [self.socketConnectedButton setImage:[UIImage imageNamed:@"green"] forState:UIControlStateNormal];
    }else{
        [self.socketConnectedButton setImage:[UIImage imageNamed:@"red"] forState:UIControlStateNormal];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChangesForPTS:) name:@"PTSListUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSocketConnectivity:) name:@"SocketConnectionUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAnyPendingTasks) name:@"SendFlightDataToServerAgain" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

-(void) setViewTitle: (NSString *) userName{
    self.navigationItem.title = [NSString stringWithFormat:@"Welcome %@",userName];
}

- (void)setUpTaskClient {
    if (self.taskUpdateClient == nil) {
        self.taskUpdateClient = [[TaskTimeUpdatesClient alloc] init];
        [self.taskUpdateClient connectToWebSocket:^(BOOL isConnected) {
            [self.socketConnectedButton setImage:[UIImage imageNamed:@"green"] forState:UIControlStateNormal];
        }];
    }else if(![self.taskUpdateClient isWebSocketConnected]){
        [self.taskUpdateClient connectToWebSocket:^(BOOL isConnected) {
            [self.socketConnectedButton setImage:[UIImage imageNamed:@"green"] forState:UIControlStateNormal];
        }];
    }
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
    [self.tableView reloadData];
    if (self.ptsTasksToLoad.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tableView.backgroundView = nil;
        });
    }else if(!self.searchController.isActive){
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

-(void) showLoadingView{
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
    [loadingLabel setFont:[UIFont systemFontOfSize:25]];
    loadingLabel.text = @"Loading Flights ...";
    loadingLabel.textColor        = [UIColor grayColor];
    loadingLabel.textAlignment    = NSTextAlignmentCenter;
    self.tableView.backgroundView = loadingLabel;
}

#pragma mark NSNotification methods
-(void)appDidBecomeActive:(NSNotification*)note
{
    [self setUpTaskClient];
}

-(void)networkConnected
{
    [self setUpTaskClient];
}

-(void) updateChangesForPTS:(NSNotification *) notification
{
    [self.tableView reloadData];
}

-(void) updateSocketConnectivity:(NSNotification *) notification{
    if ([notification.object boolValue]) {
        [self.socketConnectedButton setImage:[UIImage imageNamed:@"green"] forState:UIControlStateNormal];
        User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];
        [self showLoadingView];
        [self updateAnyPendingTasks];
        [[PTSManager sharedInstance] fetchPTSListForUser:loggedInUser forLogin:false completionHandler:^(BOOL fetchComplete, NSArray *ptsTasks, NSError *error) {
            self.ptsTasks = [NSMutableArray arrayWithArray:ptsTasks];
            self.ptsTasksToLoad = self.ptsTasks;
            [self registerFlightsForUpdate];
            [self setSearchBar];
            [self loadListOnView];
        }];
    }else{
        [self.socketConnectedButton setImage:[UIImage imageNamed:@"red"] forState:UIControlStateNormal];
    }
}

-(void) updateAnyPendingTasks{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *pendingTaskIds = [defaults objectForKey:@"PendingTasks"];
    NSMutableArray *arrayToSave = [[NSMutableArray alloc] initWithArray:pendingTaskIds];
    for (PTSItem *itemToUpdate in self.ptsTasks) {
        if ([arrayToSave containsObject:[NSNumber numberWithInteger:itemToUpdate.flightId]]) {
            NSLog(@"Shweta sent request for %d", itemToUpdate.flightId);
            [self.taskUpdateClient updateFlightTask:itemToUpdate];
            [arrayToSave removeObject:[NSNumber numberWithInteger:itemToUpdate.flightId]];
        }
    }
    
    [defaults setObject:[arrayToSave copy] forKey:@"PendingTasks"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.ptsTasksToLoad.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PTSListViewCell *ptsCell = [tableView dequeueReusableCellWithIdentifier:@"PTSItemCell" forIndexPath:indexPath];
    PTSItem *pts = [self.ptsTasksToLoad objectAtIndex:indexPath.row];
    ptsCell.delegate = self;
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
    [self fetchPTSListAfterCall: FALSE];
}

-(void) fetchPTSListAfterCall: (BOOL)initialLogin {
    [self.taskUpdateClient connectToWebSocket:^(BOOL isConnected) {
        [self.socketConnectedButton setImage:[UIImage imageNamed:@"green"] forState:UIControlStateNormal];
        User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];
        [self setViewTitle:loggedInUser.userName];
        [self showLoadingView];
        [self updateAnyPendingTasks];
        [[PTSManager sharedInstance] fetchPTSListForUser:loggedInUser forLogin: initialLogin completionHandler:^(BOOL fetchComplete, NSArray *ptsTasks, NSError *error) {
            self.ptsTasks = [NSMutableArray arrayWithArray:ptsTasks];
            self.ptsTasksToLoad = self.ptsTasks;
            [self loadListOnView];
            [self setSearchBar];
            if (self.taskUpdateClient == nil) {
                self.taskUpdateClient = [[TaskTimeUpdatesClient alloc] init];
                [self.taskUpdateClient connectToWebSocket:^(BOOL isConnected) {
                    [self.socketConnectedButton setImage:[UIImage imageNamed:@"green"] forState:UIControlStateNormal];
                }];
            }
            
            [self registerFlightsForUpdate];
            
        }];
    }];
}

#pragma mark - Navigation
- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"SupervisorSegue"]) {
        
        CGPoint center= ((UIButton *)sender).center;
        CGPoint rootViewPoint = [((UIButton *)sender).superview convertPoint:center toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:rootViewPoint];
        if ([[self personDetailsArray:[self.ptsTasksToLoad objectAtIndex:indexPath.row]] count] == 0) {
            UIAlertController *notAssignedAlert = [UIAlertController alertControllerWithTitle:nil message:@"Not Assigned" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            
            [notAssignedAlert addAction:actionOk];
            [self presentViewController:notAssignedAlert animated:YES completion:nil];
            return FALSE;
        }
        return TRUE;
    }else{
        UITableViewCell *selectedCell = (UITableViewCell*)sender;
        NSInteger selectedIndex = ((NSIndexPath *)[self.tableView indexPathForCell:selectedCell]).row;
        self.selectedPTSItem = [self.ptsTasksToLoad objectAtIndex:selectedIndex];
        
        if (self.searchController.isActive) {
            [self.searchController.searchBar setText:@""];
            [self.searchController resignFirstResponder];
            [self.searchController dismissViewControllerAnimated:YES completion:^{
                [self performSegueWithIdentifier:identifier sender:sender];
            }];
            return FALSE;
        }else{
            return TRUE;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SupervisorSegue"]) {
        SupervisorTableViewController *supervisorVew = segue.destinationViewController;
        supervisorVew.modalPresentationStyle = UIModalPresentationPopover;
        supervisorVew.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        CGPoint center= ((UIButton *)sender).center;
        CGPoint rootViewPoint = [((UIButton *)sender).superview convertPoint:center toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:rootViewPoint];
        
        supervisorVew.personDetailsToDisplay = [self personDetailsArray:[self.ptsTasksToLoad objectAtIndex:indexPath.row]];
        supervisorVew.preferredContentSize = CGSizeMake(200, supervisorVew.personDetailsToDisplay.count * 52);
        
        UIPopoverPresentationController *popOverController = [supervisorVew popoverPresentationController];
        popOverController.sourceRect = CGRectMake(rootViewPoint.x, rootViewPoint.y - ((UIButton *)sender).frame.size.height/2, ((UIButton *)sender).frame.size.width, ((UIButton *)sender).frame.size.height) ;
        popOverController.sourceView = self.tableView;
        popOverController.delegate = self;
        popOverController.backgroundColor = [UIColor whiteColor];
        popOverController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }else{
        PTSDetailListController *ptsDetailView = segue.destinationViewController;
        ptsDetailView.taskUpdateClient = self.taskUpdateClient;
        ptsDetailView.ptsTask = self.selectedPTSItem;
    }
    
}

#pragma mark Utility methods
-(NSArray *) personDetailsArray:(PTSItem *) selectedItem{
    NSMutableArray *namesArray = [[NSMutableArray alloc] init];
    User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];
    if (loggedInUser.empType == 3) {
        if (selectedItem.supervisorName.length > 0) {
            [namesArray addObject:[[NSString stringWithFormat:@"S - %@",selectedItem.supervisorName] uppercaseString]];
        }
    }else{
        if (selectedItem.dutyManagerName.length > 0 && ![selectedItem.dutyManagerName isEqualToString:loggedInUser.userName]) {
            [namesArray addObject:[[NSString stringWithFormat:@"DM - %@",selectedItem.dutyManagerName] uppercaseString]];
        }
        if (selectedItem.supervisorName.length > 0 && ![selectedItem.supervisorName isEqualToString:loggedInUser.userName]) {
            [namesArray addObject:[[NSString stringWithFormat:@"S - %@",selectedItem.supervisorName] uppercaseString]];
        }
        for (RedCap *redCap in selectedItem.redCaps.allObjects) {
            [namesArray addObject:[[NSString stringWithFormat:@"RC - %@",redCap.redcapName] uppercaseString]];
        }
    }
    
    namesArray = [namesArray valueForKeyPath:@"@distinctUnionOfObjects.self"];
    return namesArray;
}

- (void) registerFlightsForUpdate{
    NSArray *ptsIdsArray = [self.ptsTasks valueForKey:@"flightId"];
    NSMutableDictionary *redCapDetailsDic = [[NSMutableDictionary alloc] init];
    for (PTSItem *ptsItem in self.ptsTasks) {
        RedCap *selfRedcap = [self selfRedCap:[ptsItem.redCaps allObjects]];
        [redCapDetailsDic setObject:[NSNumber numberWithBool:selfRedcap.masterRedCap] forKey:[NSNumber numberWithInt:ptsItem.flightId]];
    }
    [self.taskUpdateClient updateUserForFlight:ptsIdsArray masterRedCapDetails:redCapDetailsDic];
}

- (void) logoutUser{
    
    if (![self.taskUpdateClient isWebSocketConnected]) {
        [self showComment:@"Please connect to internet and sync offline data"];
        return;
    }

    [self updateAnyPendingTasks];
    UIAlertController *logoutConfirmationAlert = [UIAlertController alertControllerWithTitle:@"Message" message:@"Are you sure ?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionYes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.ptsTasks = nil;
        self.ptsTasksToLoad = nil;
        [self loadListOnView];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([User class])];
        request.includesPropertyValues = TRUE;
        NSBatchDeleteRequest *deleteUser = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
        
        NSFetchRequest *request1 = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([PTSItem class])];
        request1.includesPropertyValues = TRUE;
        NSBatchDeleteRequest *deletePTSItem = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request1];
        
        NSFetchRequest *request2 = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([PTSSubTask class])];
        request2.includesPropertyValues = TRUE;
        NSBatchDeleteRequest *deleteSubtasks = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request2];
        
        NSFetchRequest *request3 = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([RedCap class])];
        request3.includesPropertyValues = TRUE;
        NSBatchDeleteRequest *deleteRedCap = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request3];
        
        NSFetchRequest *request4 = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([RedCapSubtask class])];
        request4.includesPropertyValues = TRUE;
        NSBatchDeleteRequest *deleteRedCapSubtasks = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request4];
        
        
        NSError *deleteError = nil;
        [theAppDelegate.persistentContainer.viewContext executeRequest:deleteUser error:&deleteError];
        [theAppDelegate.persistentContainer.viewContext executeRequest:deletePTSItem error:&deleteError];
        [theAppDelegate.persistentContainer.viewContext executeRequest:deleteSubtasks error:&deleteError];
        [theAppDelegate.persistentContainer.viewContext executeRequest:deleteRedCap error:&deleteError];
        [theAppDelegate.persistentContainer.viewContext executeRequest:deleteRedCapSubtasks error:&deleteError];
        
        NSError *error;
        //    [theAppDelegate.persistentContainer.viewContext save:&error];
        [theAppDelegate.persistentContainer.viewContext reset];
        
        //    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
        //    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PTSItem"];
        //    NSArray *ptsArray = [moc executeFetchRequest:fetchRequest error:&error];
        //
        //    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PTSItem"];
        //    ptsArray = [moc executeFetchRequest:fetchRequest error:&error];
        
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginController *loginView = [mainStoryBoard instantiateViewControllerWithIdentifier:NSStringFromClass([LoginController class])];
        loginView.delegate = self;
        [self.navigationController presentViewController:loginView animated:F_TEST completion:nil];
    }];
    
    UIAlertAction *actionNo = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [logoutConfirmationAlert addAction:actionNo];
    [logoutConfirmationAlert addAction:actionYes];
    [self presentViewController:logoutConfirmationAlert animated:YES completion:nil];

}

-(void) loadFAQ{
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FAQViewController *loginView = [mainStoryBoard instantiateViewControllerWithIdentifier:NSStringFromClass([FAQViewController class])];
    self.navigationItem.backBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];//UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    self.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
    [self.navigationController pushViewController:loginView animated:YES];
}

#pragma mark Login delegate methods
-(void) userDidLogin{
    [self setSearchBar];
    [self fetchPTSListAfterCall:YES];
}


#pragma mark UI Model Popover
-(UIModalPresentationStyle ) adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}

-(UIModalPresentationStyle ) adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection{
    return UIModalPresentationNone;
}

#pragma mark Cell Delegate
- (void)showComment:(NSString *)comment {
    
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    CommentViewController *commentViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:NSStringFromClass([CommentViewController class])];
    commentViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    commentViewController.comment = comment;
    
    self.searchController.active = NO;
    [self.navigationController presentViewController:commentViewController animated:YES completion:nil];
}

#pragma mark searchbar methods
-(void) setSearchBar{
    
    User *loggedInUser = [[LoginManager sharedInstance] getLoggedInUser];
    if (loggedInUser.empType != 3) {
        self.definesPresentationContext = YES;
        self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        self.searchController.searchResultsUpdater = self;
        self.searchController.delegate = self;
        self.searchController.searchBar.tintColor = UIColor.whiteColor;
        self.searchController.obscuresBackgroundDuringPresentation = FALSE;
        self.searchController.searchBar.placeholder = @"Search Flight";
        
        self.tableView.tableHeaderView = self.searchController.searchBar;
//        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }else{
        self.tableView.tableHeaderView = nil;
    }
    
    
    
}

-(void) updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *flightNumber = self.searchController.searchBar.text;
    if (flightNumber.length > 0) {
        self.ptsTasksToLoad = [self getFilteredFlightArray:flightNumber];
    }else{
        self.ptsTasksToLoad = self.ptsTasks;
    }
    
    [self loadListOnView];
}

-(NSArray *) getFilteredFlightArray:(NSString *)searchString{
    NSPredicate *predicateForPTSWithId = [NSPredicate predicateWithFormat:@"flightNo CONTAINS[c] %@", searchString];
    NSArray *filteredArray = [self.ptsTasks filteredArrayUsingPredicate:predicateForPTSWithId];
    return filteredArray;
}

-(void) willDismissSearchController:(UISearchController *)searchController{
    
}

#pragma mark button Actions
- (IBAction)socketButtonTapped:(id)sender {
    if ([self.taskUpdateClient isWebSocketConnected]) {
        [self showComment:@"You are connected."];
    }else{
        [self showComment:@"You are not connected."];
    }
}
@end
