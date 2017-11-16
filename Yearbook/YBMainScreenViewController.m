//
//  mainScreenViewController.m
//  Yearbook
//
//  Created by Urmil Setia on 17/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBMainScreenViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CAPSPageMenu.h"
#import "YBEventsTableViewController.h"
#import "AppDelegate.h"
#import "YBEventsStore.h"
#import <QuartzCore/QuartzCore.h>
#import "YBMonthCalendarViewController.h"
#import "YBDayViewTableViewController.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "ADAL/ADAL.h"
#import "YBProfileStore.h"
#import "YBEventDetailsTableViewController.h"

@import CoreData;

@interface YBMainScreenViewController ()
@property (nonatomic) CAPSPageMenu *pageMenu;
@property (weak, nonatomic) IBOutlet UIView *theContainerView;
@property (strong, nonatomic) UIButton *theUserProfile;
@property (weak, nonatomic) IBOutlet UIScrollView *selectedEventsView;
@property (nonatomic, strong) NSMutableArray *selectedEvents;
@property (nonatomic) BOOL openLoginScreen;
@property (nonatomic) BOOL firstLoadWithData;
@property (nonatomic) BOOL waitingForData;
@property (nonatomic) BOOL menuOPEN;

@end

@implementation YBMainScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //    self.selectedEvents = [NSMutableArray arrayWithCapacity:0];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    self.selectedEvents = [[def objectForKey:@"selectedEvents"] mutableCopy];
    self.menuOPEN = false;
    
    [self checkIfLoginScreenIsRequired];
    [self prepareNavigationBar];
    [self preparePageMenu];
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.barTintColor = [YBHourTableViewCell colorFromHexString:@"#276092"];
}

-(void)viewDidAppear:(BOOL)animated{
    if (self.openLoginScreen == true) {
        self.openLoginScreen = false;
        [self.navigationController performSegueWithIdentifier:@"loginScreen" sender:self];
        [self.selectedEvents removeAllObjects];
        [self updateUserDefaultsForSelectedEvents];
    }
    else {
        //        if ([self.selectedEvents count] == 0) {
        //Open Events selector Screen.
        if (self.firstLoadWithData == true) {
            //Just a small delay to ensure user realizes what happened.
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            [self.theUserProfile sd_setImageWithURL:[NSURL URLWithString:[def objectForKey:@"profilePictureURL"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"Profile_placeholder"] options:SDWebImageRetryFailed];
            if ([self.selectedEvents count] <= 0) {
                [self performSelector:@selector(selectEvents:) withObject:self afterDelay:0.5f];
            }
        }
        if (self.detailScreen == FALSE) {
            [self updateSelectedEvents:1];
        }
        
        
        //        else
        //        {
        //            [self updateSelectedEvents];
        //        }
        //        }
    }
    if (self.menuOPEN == TRUE) {
        self.menuOPEN = FALSE;
    }
}

-(void)prepareNavigationBar{
    self.theUserProfile = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33.0, 33.0)];//[UIButton buttonWithType:0];
    
   /* [self.theUserProfile addConstraint:[NSLayoutConstraint constraintWithItem:self.theUserProfile
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                                     constant:200]];*/
    
    if (!(self.openLoginScreen == true)) {
    ADAuthenticationError *error = nil;
    ADAuthenticationContext *authContext = [ADAuthenticationContext authenticationContextWithAuthority:kLoginAuthority error:&error];
    
    [authContext acquireTokenWithResource:kAuthAzureUri clientId:kAuthClientId redirectUri:[NSURL URLWithString:kAuthRedirectUri] completionBlock:^(ADAuthenticationResult *result){
        if (AD_SUCCEEDED != result.status){
            // display error on the screen
            NSLog(@"Issue with Profile Picture: %@", result.error.errorDetails);
        }
        else{
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            [def setObject:result.accessToken forKey:@"accessToken"];
            [def synchronize];
            [[SDWebImageManager sharedManager].imageDownloader setValue:[NSString stringWithFormat:@"Bearer %@",result.accessToken] forHTTPHeaderField:@"Authorization"];
//            NSString *profileURL = [def objectForKey:@"profilePictureURL"];
//            if ([profileURL length] <= 0) {
//                
//            }
//            else{
//            [self.theUserProfile sd_setImageWithURL:[NSURL URLWithString:[def objectForKey:@"profilePictureURL"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"Profile_placeholder"] options:SDWebImageRetryFailed];
            //Fetch the record again
            [self performSelector:@selector(fetchUserRecordAndStoreWithToken:) withObject:result.accessToken afterDelay:0.1];
        }
    }];
    }
//    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
//    NSString *token = [def objectForKey:@"accessTokenForPicture"];
    self.theUserProfile.layer.masksToBounds = YES;
    self.theUserProfile.layer.cornerRadius = 33.0/2.0;;
    [self.theUserProfile setFrame:CGRectMake(0, 0, 33.f, 33.f)];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.theUserProfile
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:32];
    
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.theUserProfile
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:32];
    
    [self.theUserProfile addConstraint:heightConstraint];
    [self.theUserProfile addConstraint:widthConstraint];
    
    //self.theUserProfile.clipsToBounds = YES;
    [self.theUserProfile addTarget:self action:@selector(userProfilePictureTap:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *leftBtn = [UIButton buttonWithType:0];
    [leftBtn setFrame:CGRectMake(0, 0, 45.f, 33.f)];
    [leftBtn setTitle:@"More" forState:UIControlStateNormal];
    leftBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(userProfilePictureTap:) forControlEvents:UIControlEventTouchUpInside];
    
    //UIBarButtonItem *theUserProfileBtn = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    UIBarButtonItem *theUserProfileBtn = [[UIBarButtonItem alloc] initWithCustomView:_theUserProfile];
    
    self.navigationItem.leftBarButtonItem = theUserProfileBtn;
    
    UILabel *lblTitle = [[UILabel alloc] init];
    lblTitle.text = kAppName;
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
    [lblTitle sizeToFit];
    self.navigationItem.titleView = lblTitle;
    
    UIButton *btn = [UIButton buttonWithType:0];
    [btn setFrame:CGRectMake(0, 0, 33.f, 33.f)];
    [btn setImage:[UIImage imageNamed:@"EventsListIcon"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(selectEvents:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = doneBtn;
    [self setNeedsStatusBarAppearanceUpdate];
    self.theContainerView.frame = self.view.frame;
}

-(void)fetchUserRecordAndStoreWithToken:(NSString *)token{
    YBProfileStore *profileStore = [[YBProfileStore alloc] init];
    [profileStore fetchAndStoreUserWithToken:token AndCompletion:^(NSString *imageURL, NSError *error) {
//        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        [self.theUserProfile sd_setImageWithURL:[NSURL URLWithString:imageURL] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"Profile_placeholder"] options:SDWebImageRetryFailed];
    }];
}

-(void)userProfilePictureTap:(id)sender{
    [self performSegueWithIdentifier:@"MenuSegue" sender:self];
    self.menuOPEN = TRUE;
}

-(void)preparePageMenu{
    NSMutableArray *controllerArray = [NSMutableArray array];
    YBEventsTableViewController *eventsTableView = [[YBEventsTableViewController alloc] initWithNibName:@"YBEventsTableViewController" bundle:[NSBundle mainBundle]];
    eventsTableView.title = @"Items";
    eventsTableView.rootControl = self;
    self.delegateForTableView = eventsTableView;
    [controllerArray addObject:eventsTableView];
    
    YBMonthCalendarViewController *monthViewCont = [[YBMonthCalendarViewController alloc] initWithNibName:@"YBMonthCalendarViewController" bundle:[NSBundle mainBundle]];
    monthViewCont.title = @"Month";
    monthViewCont.rootControl = self;
    self.delegateForMonthView = monthViewCont;
    [controllerArray addObject:monthViewCont];
    
    YBDayViewTableViewController *dayViewCont = [[YBDayViewTableViewController alloc] initWithNibName:@"YBDayViewTableViewController" bundle:[NSBundle mainBundle]];
    dayViewCont.title = @"Day";
    dayViewCont.rootControl = self;
    self.delegateForDayView = dayViewCont;
    [controllerArray addObject:dayViewCont];
    
    NSDictionary *parameters = @{CAPSPageMenuOptionMenuItemSeparatorWidth: @(4.3),
                                 CAPSPageMenuOptionUseMenuLikeSegmentedControl: @(YES),
                                 CAPSPageMenuOptionMenuItemSeparatorPercentageHeight: @(0.1),
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor whiteColor],
                                 CAPSPageMenuOptionSelectionIndicatorColor: [UIColor redColor],
                                 CAPSPageMenuOptionMenuItemSeparatorColor: [UIColor blackColor],
                                 CAPSPageMenuOptionSelectedMenuItemLabelColor: [UIColor blackColor]
                                 };
    
    _pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray frame:CGRectMake(0.0, 0.0, self.theContainerView.frame.size.width, self.theContainerView.frame.size.height) options:parameters];
    
    [self.theContainerView addSubview:_pageMenu.view];
}

-(void)checkIfLoginScreenIsRequired{
    AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDel managedObjectContext];
#warning Both flags should be FALSE for PROD release
    self.openLoginScreen = FALSE;
    self.firstLoadWithData = FALSE;
    self.waitingForData = FALSE;
    NSFetchRequest *fetchReq = [[NSFetchRequest alloc] initWithEntityName:@"YBCalendars"];
    NSError *error = nil;
    NSArray *results1 = [context executeFetchRequest:fetchReq error:&error];
    if (error) {
        //Raise Exception and Take to Login Screen
        self.openLoginScreen = true;
    }
    if([results1 count]<=0){
        //No data found call Login.
        self.openLoginScreen = true;
    }
    self.firstLoadWithData = true;
}

-(void)displayAlertWithMsg:(NSString *)errorDesc{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Error"
                                  message:errorDesc
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

-(void)updateSelectedEvents:(NSInteger)mode{
    //  Clean out the whole area.
    for (id view in [self.selectedEventsView subviews]) {
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    float startPoint = 10.f;
    for (NSDictionary *dict in self.selectedEvents) {
        UIButton *btn = [UIButton buttonWithType:1];
        [btn setTag:[[dict objectForKey:@"calendarID"] integerValue]];
        [btn setFrame:CGRectMake(startPoint, 15.f, 100.f, 48.f)];//Size to fit will be called next
        [btn setTitle:[dict objectForKey:@"calendarName"] forState:0];
        [btn setImage:[UIImage imageNamed:@"crossMark"] forState:UIControlStateNormal];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0.0, 0, 4.f)];
        btn.layer.cornerRadius = 5.f;
        [btn setTintColor:[UIColor blackColor]];
        btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        btn.layer.borderWidth = 1.f;
        [btn addTarget:self action:@selector(calenadBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [btn sizeToFit];
        [btn setFrame:CGRectMake(btn.frame.origin.x, btn.frame.origin.y, btn.frame.size.width+4.f, btn.frame.size.height)];
        startPoint = startPoint+btn.frame.size.width+5.f;
        [self.selectedEventsView addSubview:btn];
    }
    [self.selectedEventsView setContentSize:CGSizeMake(startPoint+5.0, 54.f)];
    [self.selectedEventsView setNeedsDisplay];
    if (self.waitingForData == FALSE && self.menuOPEN == FALSE) {
        [self sendUpdateToCalendarViews:mode];
    }
}

-(void)sendUpdateToCalendarViews:(NSInteger)mode{
    if ([self.delegateForMonthView respondsToSelector:@selector(updateSelectedCalendars:andMode:)]) {
        [self.delegateForMonthView updateSelectedCalendars:self.selectedEvents andMode:mode];
    }
    if ([self.delegateForTableView respondsToSelector:@selector(updateSelectedCalendars:andMode:)]) {
        [self.delegateForTableView updateSelectedCalendars:self.selectedEvents andMode:mode];
    }
    if ([self.delegateForDayView respondsToSelector:@selector(updateSelectedCalendars:andMode:)]) {
        [self.delegateForDayView updateSelectedCalendars:self.selectedEvents andMode:mode];
    }
}

-(void)calenadBtnTapped:(id)sender{
    //Update selected Events
    NSArray *tempA = [self.selectedEvents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.calendarID == %@",[NSString stringWithFormat:@"%ld",(long)[sender tag]]]];
    [self.selectedEvents removeObject:tempA[0]];
    [self updateUserDefaultsForSelectedEvents];
    [self updateSelectedEvents:0];
    [sender removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.detailScreen = TRUE;
    if ([segue.identifier isEqualToString:@"categoryselection"]) {
        UINavigationController *dvc = (UINavigationController *)[segue destinationViewController];
        YBCalendarSelectorTableViewController *sel = (YBCalendarSelectorTableViewController *)[[dvc viewControllers]objectAtIndex:0];
        [sel reloadSelectedCalendarAndCategories:self.selectedEvents];
        sel.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"MenuSegue"]) {
        UINavigationController *dvc = (UINavigationController *)[segue destinationViewController];
        YBMenuTableViewController *sel = (YBMenuTableViewController *)[[dvc viewControllers]objectAtIndex:0];
        sel.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"eventsDetailFromMainScreen"]) {
        //        UINavigationController *dvc = (UINavigationController *)[segue destinationViewController];
        //        YBEventDetailsTableViewController *sel = (YBEventDetailsTableViewController *)[[dvc viewControllers]objectAtIndex:0];
        YBEventDetailsTableViewController *sel = (YBEventDetailsTableViewController *)[segue destinationViewController];
        
        sel.selectedEvent = sender;
        sender = self;
    }
}

-(void)selectEvents:(id)sender {
    [self performSegueWithIdentifier:@"categoryselection" sender:self];
}

-(void)CalendarAndSelectedCategories:(NSMutableArray *)calCategoryies completion:(void(^)(void))callback
{
    self.selectedEvents = nil;
    self.selectedEvents = [calCategoryies mutableCopy];
    [self updateUserDefaultsForSelectedEvents];
    void (^tempHandler)(NSError *error) = ^void(NSError *error){
        if (error) {
            if (error.code != 9999) {
                [self displayAlertWithMsg:[error localizedDescription]];
            }
        }
        else{
            self.waitingForData = FALSE;
            [self updateSelectedEvents:1];
//            [self sendUpdateToCalendarViews:1];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LASTEVENTSFETCHED" object:@[[NSNumber numberWithLong:[self.pageMenu currentPageIndex]],[NSDate date]]];
        }
    };
    
    
    if (self.firstLoadWithData == TRUE) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WAITFORDATALOAD" object:nil];
        self.waitingForData = TRUE;
        [self performSelector:@selector(fetchAndStoreEventsWithSelectedCategories:) withObject:tempHandler afterDelay:1.0];
        self.firstLoadWithData = false;
    }
    else{
        self.waitingForData = FALSE;
        [self updateSelectedEvents:1];
        [self performSelector:@selector(fetchAndStoreEventsWithSelectedCategories:) withObject:^{
            //            [self sendUpdateToCalendarViews:1];
        } afterDelay:0];
    }
    [self performSelector:@selector(finishLoad:) withObject:callback afterDelay:4.0];

}
-(void)finishLoad:(void(^)(void))callback{
    dispatch_async(dispatch_get_main_queue(), ^{
        callback();
    });
}
-(void)updateUserDefaultsForSelectedEvents{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:self.selectedEvents forKey:@"selectedEvents"];
    [def synchronize];
}

-(void)fetchAndStoreEventsWithSelectedCategories:(void (^)(NSError *error))completionBlock{
    ADAuthenticationError *error = nil;
    ADAuthenticationContext *authContext = [ADAuthenticationContext authenticationContextWithAuthority:kLoginAuthority error:&error];
    
    [authContext acquireTokenWithResource:kAuthResourceUri
                                 clientId:kAuthClientId
                              redirectUri:[NSURL URLWithString:kAuthRedirectUri]
                                   userId:nil
                     extraQueryParameters:@"domain_hint=effem.com" completionBlock:^(ADAuthenticationResult *result){
        if (AD_SUCCEEDED != result.status){
            // display error on the screen
            NSLog(@"Issue with Profile Picture: %@", result.error.errorDetails);
        }
        else{
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            [def setObject:result.accessToken forKey:@"accessToken"];
            [def synchronize];
            YBEventsStore *store = [YBEventsStore sharedInstance];
            [store fetchAndStoreEventsWithCalendarsAndCategories:self.selectedEvents forYear:nil token:result.accessToken andCompletionHandler:^(NSError *error) {
                //        NSLog(@"fetchAndStoreEventsWithCalendarsAndCategories");
                if (completionBlock) {
                    completionBlock(error);
                }
            }];
        }
    }];


}

-(void)UserSignedOut{
    NSLog(@"SignOUT");
    [self.selectedEvents removeAllObjects];
    [self updateUserDefaultsForSelectedEvents];
    [self sendUpdateToCalendarViews:0];
    self.firstLoadWithData = TRUE;
    self.openLoginScreen = TRUE;
    
    ADKeychainTokenCache *tokenCache = [[ADKeychainTokenCache alloc] init];
    [tokenCache removeAllForClientId:kAuthClientId  error:nil];
    NSHTTPCookie *cookie;
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
}

@end
