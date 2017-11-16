//
//  YBMenuTableViewController.m
//  Yearbook
//
//  Created by Urmil Setia on 14/12/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBMenuTableViewController.h"
#import "YBUserProfileTableViewCell.h"
#import "YBMenuOptionsTableViewCell.h"
#import "YBWebViewViewController.h"
#import "YBUser+CoreDataClass.h"
#import "AppDelegate.h"
#import "YBProfileStore.h"
#import "YBCalendarUpdatesStore.h"
#import "YBCalendarUpdatesTableViewController.h"
#import "ADAL/ADAL.h"
#import "ADAL/ADAuthenticationContext.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "YBConstants.h"

@import CoreData;


@interface YBMenuTableViewController ()
@property(strong, nonatomic) NSArray *arryOfActions;
@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, strong) NSString *userName;
@property(nonatomic, strong) NSURL *profilePicture;

@end
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen]nativeScale]) == 568.0f)
@implementation YBMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBtnPressed:)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.rightBarButtonItem = doneBtn;
    [self.tableView registerNib:[UINib nibWithNibName:@"YBUserProfileTableViewCell" bundle:nil] forCellReuseIdentifier:@"userNameAndPic"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YBMenuOptionsTableViewCell" bundle:nil] forCellReuseIdentifier:@"OptionsTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YBFooterTableViewCell" bundle:nil] forCellReuseIdentifier:@"FooterTable"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YBMenuVersionCell" bundle:nil] forCellReuseIdentifier:@"Version"];
    
    self.arryOfActions = @[@{@"Name": @"About Me",@"Action":[NSURL URLWithString:@"https://mydrive.effem.com/_layouts/15/me.aspx"], @"ImageIcon":@"About"},@{@"Name": @"Change Logs",@"Action":@"Speech", @"ImageIcon":@""},@{@"Name": @"Report a problem",@"Action":@"", @"ImageIcon":@"Reportissue"},@{@"Name": @"Coach me",@"Action":@"", @"ImageIcon":@""},@{@"Name": @"Recommend this App",@"Action":@"", @"ImageIcon":@"Recommend"},@{@"Name": @"Logout",@"Action":@"", @"ImageIcon":@"profile-icon"}];
    self.navigationItem.title = @"More";
    
    
    
    AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDel.managedObjectContext;
    NSFetchRequest *req = [[NSFetchRequest alloc] initWithEntityName:@"YBUser"];
    NSError *error;
    NSArray *result = [self.managedObjectContext executeFetchRequest:req error:&error];
    if(!(error)){
        if ([result count]>0) {
            self.userName = [result[0] loginName];
        }
    }
    else
        abort();
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    self.profilePicture = [def objectForKey:@"profilePictureURL"];
    
    YBProfileStore *store = [[YBProfileStore alloc] init];
    [self getTokenWithCompletion:^(NSString *token, NSError *error) {
        if (error == nil) {
            [[SDWebImageManager sharedManager].imageDownloader setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
            //            [store fetchAndStoreUserWithToken:token AndCompletion:^(NSString *imageURL, NSError *error) {
            //                if (error == nil) {
            //                    self.profilePicture = [NSURL URLWithString:imageURL];
            //                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            //                }
            //            }];
        }
    }];
}

//-(void)updateUserName{
//    NSFetchRequest *req = [[NSFetchRequest alloc] initWithEntityName:@"YBUser"];
//    NSError *error;
//    NSArray *result = [self.managedObjectContext executeFetchRequest:req error:&error];
//    if(!(error)){
//        if ([result count]>0) {
//            self.userName = [result[0] loginName];
//            //            self.profilePicture = [result[0] tobeDecided];
//        }
//        else{
//            //Don't worry about it.
//        }
//    }
//}

-(void)doneBtnPressed:(id)sender {
    [self.navigationController performSegueWithIdentifier:@"dismissSegueForMenu" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return self.arryOfActions.count;
    }
    else if (section == 2){
        return 1;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if(IS_IPHONE_5){
        return 190;
        }
        return 220;
    }else if (indexPath.section == 2) {
        if(IS_IPHONE_5){
            return 50;
        }
        return 60;
    }else{
        if(IS_IPHONE_5){
            return 44;
        }
        return 54;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identify;
    if (indexPath.section == 0)
        identify = @"userNameAndPic";
    else if (indexPath.section == 1)
        identify = @"OptionsTableViewCell";
    else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            identify = @"FooterTable";
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [(YBUserProfileTableViewCell *)cell configureCellWithProfileURL:self.profilePicture version:[NSString stringWithFormat:@"Version %@",version] andName:(self.userName)?self.userName:@"Unknown"];
        
        [[((YBUserProfileTableViewCell *)cell) UserProfilePictureButton] addTarget:self action:@selector(loadMarsProfileAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if (indexPath.section == 1) {
        [(YBMenuOptionsTableViewCell *)cell configureCellWithName:[[self.arryOfActions objectAtIndex:indexPath.row] objectForKey:@"Name"] andImageName:[[self.arryOfActions objectAtIndex:indexPath.row] objectForKey:@"ImageIcon"]];
    }
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                [self openProfile];
                break;
            case 1:
                [self openCalendarUpdates];
                break;
            case 2:
                [self reportIssue];
                break;
            case 3:
                [self coachMeMessage];
                break;
            case 4:
                [self shareAppEmail];
                break;
            case 5:
                [self cleanEverythingAndSignOut];
                break;
            default:
                break;
        }
    }
    else if (indexPath.section == 2){
        [self openDigitalWorkplace];
    }
}

#pragma mark - Menu actions
-(void) openDigitalWorkplace{
    NSURL *DigiURL = [NSURL URLWithString:@"https://digitalworkplace.mars.com"];
    if([[UIApplication sharedApplication] canOpenURL:DigiURL]){
        [[UIApplication sharedApplication] openURL:DigiURL];
    }else{
        [self displayAlertViewWithTitle:@"Error" andMsg:@"Could not open digital workplace. Please try again later."];
    }
}
-(void)openProfile{
    YBWebViewViewController *dvc = (YBWebViewViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"WebViewActionVC"];
    [dvc loadAction:[[self.arryOfActions objectAtIndex:0] objectForKey:@"Action"]];
    [self.navigationController pushViewController:dvc animated:YES];
}

-(void)openCalendarUpdates{
    //
    YBCalendarUpdatesTableViewController *dvc = (YBCalendarUpdatesTableViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"YBCalendarUpdatesID"];
    //    [dvc loadAction:[[self.arryOfActions objectAtIndex:0] objectForKey:@"Action"]];
    [self.navigationController pushViewController:dvc animated:YES];
}

-(void)reportIssue{
    NSString* kReportIssueMailID = @"mars.service.desk@effem.com";
    NSString* kReportIssueSubject = @"MobileApps issue/question - Mars calendar";
    NSString*  kVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString*  kAppVersion = [NSString stringWithFormat:@"Version \%@", kVersion];
    NSString*  kDeviceInfo = [NSString stringWithFormat:@"Model : %@ version : %@", [[UIDevice currentDevice] localizedModel],[[UIDevice currentDevice] systemVersion]];
    NSString* kReportIssueMessageBody = [NSString stringWithFormat:@"Facing an issue or have a question on %@?\nPlease provide a description of the issue or question with screenshots (if needed):\n \n \n \n \n \n \n Impact (please write the Impact if single user 'S' or multiple users 'M'):\n Activity (please write if Application fault 'F', Application unavailable 'U' or Request setup access 'A'):\n \n Please do not remove the technical information below.\n-----------------------------------------------------\n Application: %@\nApp version: v%@ \nDevice Model and OS: %@\n Date:  %@", kAppName, kAppName, kAppVersion, kDeviceInfo,[NSDate date]];
    NSString *emailContent = [NSMutableString stringWithFormat:@"mailto:%@?subject=%@&body=%@",kReportIssueMailID,kReportIssueSubject,kReportIssueMessageBody];
    emailContent = [emailContent stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:emailContent];
    if(![[UIApplication sharedApplication] canOpenURL:url]){
        [self displayAlertViewWithTitle:@"Mail" andMsg:@"Please login to your mail account from 'Settings'."];
    }else{
        [[UIApplication sharedApplication] openURL:url];
    }
}

-(void)coachMeMessage{
//    [self displayAlertViewWithTitle:@"" andMsg:@"This feature is not available yet. Stay tuned to see it coming in future releases"];
    [self performSegueWithIdentifier:@"YBCoachMeFromMenu" sender:self];
}

-(void)shareAppEmail{
    NSString* kShareAppSubject = [NSString stringWithFormat:@"%@ app – Try it!", kAppName];
    NSString* kShareAppMessageBody = [NSString stringWithFormat:@"Hi!\nI’m using %@ mobile app and I love it! You can download it on the Mars App Store in the ‘Corporate’ category, you should try it!",kAppName];
    NSString *emailContent = [NSMutableString stringWithFormat:@"mailto:someone@expample.com?subject=%@&body=%@",kShareAppSubject,kShareAppMessageBody];
    emailContent = [emailContent stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:emailContent];
    if(![[UIApplication sharedApplication] canOpenURL:url]){
        [self displayAlertViewWithTitle:@"Mail" andMsg:@"Please login to your mail account from 'Settings'."];
    }else{
        [[UIApplication sharedApplication] openURL:url];
    }

    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Utilities
-(void)loadMarsProfileAction :(id)sender{
    //TBD :
}
-(void)displayAlertViewWithTitle:(NSString *)title andMsg:(NSString *)msg{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:msg
                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)cleanEverythingAndSignOut{
    if ([self.delegate respondsToSelector:@selector(UserSignedOut)]) {
        [self.delegate UserSignedOut];
    }
    YBStore *store = [[YBStore alloc] init];
    NSError *err = [store deleteEverything];
    if (err) {
        abort();
    }
    [self.navigationController performSegueWithIdentifier:@"dismissSegueForMenu" sender:self];
}

-(void)getTokenWithCompletion:(void(^)(NSString *token, NSError *error))completionHandler{
    ADAuthenticationError *error = nil;
    ADAuthenticationContext *authContext = [ADAuthenticationContext authenticationContextWithAuthority:kLoginAuthority error:&error];
    [authContext acquireTokenWithResource:kAuthAzureUri clientId:kAuthClientId redirectUri:[NSURL URLWithString:kAuthRedirectUri] completionBlock:^(ADAuthenticationResult *result){
        if (AD_SUCCEEDED != result.status){
            // display error on the screen
            NSLog(@"Issue with Profile Picture: %@", result.error.errorDetails);
            if (completionHandler) {
                completionHandler(nil,result.error);
            }
        }
        else{
            if (completionHandler) {
                completionHandler(result.accessToken,nil);
            }
        }
        
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"actionsegueForMenu"]) {
        YBWebViewViewController *dvc = (YBWebViewViewController *)[segue destinationViewController];
        [dvc loadAction:[[self.arryOfActions objectAtIndex:0] objectForKey:@"Action"]];
    }
}

@end
