//
//  FAQViewController.m
//  PTS
//
//  Created by Shweta Sawant on 01/10/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "FAQViewController.h"
#import "WebApiManager.h"
#import "ApiRequestData.h"
#import "FAQCell.h"
#import "FAQ+CoreDataProperties.h"

@interface FAQViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableViewFAQs;
@property (nonatomic, retain) NSArray *faqQuestions;
@end

@implementation FAQViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableViewFAQs.rowHeight = UITableViewAutomaticDimension;
    self.tableViewFAQs.estimatedRowHeight = 150;
    self.tableViewFAQs.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.faqQuestions = [[NSArray alloc] init];
    self.faqQuestions = [[NSMutableArray alloc] init];
    NSManagedObjectContext *moc = theAppDelegate.persistentContainer.viewContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([FAQ class])];
    NSError *error;
    self.faqQuestions = [moc executeFetchRequest:fetchRequest error:&error];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"faqId" ascending:YES];
    self.faqQuestions = [self.faqQuestions sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [self.tableViewFAQs reloadData];
    
    self.navigationItem.title = @"FAQ";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

}

-(NSDictionary *) getDataForLoginRequest{
    NSMutableDictionary *loginDataDic = [[NSMutableDictionary alloc] init];
    
    UIDevice *device = [UIDevice currentDevice];
    NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
    [loginDataDic setObject:currentDeviceId forKey:@"deviceid"];
//    [loginDataDic setObject:@"1.0" forKey:@"appversion"];
//    [loginDataDic setObject:@"Apple" forKey:@"phonemanuf"];
//    [loginDataDic setObject:[UIDevice currentDevice].systemVersion forKey:@"osversion"];
    
    return loginDataDic;
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

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FAQCell *faq = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FAQCell class])];
    
    FAQ *faqItem = [self.faqQuestions objectAtIndex:indexPath.row];
    [faq setData:faqItem];
    return faq;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.faqQuestions count];
}



@end
