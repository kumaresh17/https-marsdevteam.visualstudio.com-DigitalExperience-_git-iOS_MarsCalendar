//
//  ViewController.m
//  Yearbook
//
//  Created by Urmil Setia on 17/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "ViewController.h"
#import "ADAL/ADAL.h"
#import "ADAL/ADAuthenticationContext.h"
#import "AppDelegate.h"
#import "YBUser+CoreDataClass.h"
#import "YBProfileAPI.h"
#import "YBCalendarsAPI.h"
#import "AFNetworking/AFNetworking.h"
#import "AFNetworking/AFURLSessionManager.h"
#import "YBCalendarsStore.h"
#import "YBCalendars+CoreDataClass.h"
#import "YBCalendarCategoryAPI.h"
#import "YBEventsAPI.h"
#import "YBUserAPI.h"
#import "YBProfileStore.h"
#import "SDWebImage/SDWebImageManager.h"
#import "SDWebImage/SDWebImageDownloader.h"
#import "YBCoachMeVC.h"
#import "YBConstants.h"

@interface ViewController ()
@property(nonatomic, weak) NSManagedObjectContext *managedContext;
@property(nonatomic, strong)ADAuthenticationContext *authContext;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *versionNumber;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.managedContext) {
        self.managedContext = [self returnContext];
    }
    // Do any additional setup after loading the view, typically from a nib.
    [[self.loginButton layer] setCornerRadius:8.0f];
    [[self.loginButton layer] setMasksToBounds:YES];
    [[self.loginButton layer] setBorderWidth:1.0f];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.versionNumber.text = [NSString stringWithFormat:@"v%@",version];
}

-(NSManagedObjectContext *)returnContext{
    AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return appDel.managedObjectContext;
}

//- (IBAction)theUpdate:(id)sender {
//    NSArray *a = @[@"a2adf53e-1267-4af7-b9a5-f42be8738b62",@"e77bfe80-d790-4baf-9fe2-87d35b8e2d33"];
//    YBEventsAPI *api = [[YBEventsAPI alloc] initWithYear:@"2016" withCalendarId:@"abc" forCategories:a];
//    [api startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
//        //        NSLog(@"succeed %@",request.responseJSONObject);
//    } failure:^(YTKBaseRequest *request) {
//        // you can use self here, retain cycle won't happen
//        NSLog(@"failed");
//    }];
//}



//- (IBAction)theresults:(id)sender {
//    //Call web service
//    YBCalendarsStore *store = [[YBCalendarsStore alloc] init];
//    [store fetchAndStoreCalendars:^(NSError *error) {
//        NSLog(@"Error %@",error.localizedDescription);
//    }];
//
//    NSFetchRequest *req = [[NSFetchRequest alloc] initWithEntityName:@"YBCalendars"];
//    NSArray *results = [self.managedContext executeFetchRequest:req error:nil];
//    for (YBCalendars *theUser in results) {
//        NSLog(@"Name: %@ Email: %@ EmailAddressForTechnicalSupport: %@", [theUser calendarid],[theUser calendarname],[theUser color]);
//    }
//}

- (IBAction)theLoginBtn:(id)sender {
    [self.loginButton setHidden:TRUE];
    [self.activityIndicator startAnimating];
    [self getToken];
}

- (void)getToken
{
    ADAuthenticationError *error = nil;
    self.authContext = [ADAuthenticationContext authenticationContextWithAuthority:kLoginAuthority error:&error];
    // Change stage https://stage-yearbook.mars.com
    [self.authContext acquireTokenWithResource:kAuthResourceUri
                                      clientId:kAuthClientId
                                   redirectUri:[NSURL URLWithString:kAuthRedirectUri]
                                        userId:nil
                          extraQueryParameters:@"domain_hint=effem.com" completionBlock:^(ADAuthenticationResult *result){
        if (AD_SUCCEEDED != result.status){
            // display error on the screen
            [self.activityIndicator stopAnimating];
            [self.loginButton setHidden:FALSE];
            NSLog(@"Issue with Profile Picture: %@", result.error.errorDetails);
            [self displayAlertWithMsg:result.error.errorDetails];
        }
        else{
            //             NSLog(@"%@",result.accessToken);
            [self performSelectorOnMainThread:@selector(fetchTeamEFFEM:) withObject:nil waitUntilDone:NO];
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            [def setObject:result.accessToken forKey:@"accessToken"];
            [def synchronize];
            [self performSelectorOnMainThread:@selector(fetchCalendars:) withObject:result.accessToken waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(fetchUserRecordAndStoreWithToken:) withObject:nil waitUntilDone:NO];
        }
    }];
}

-(void)fetchUserRecordAndStoreWithToken:(NSString *)token{
    ADAuthenticationError *error = nil;
    self.authContext = [ADAuthenticationContext authenticationContextWithAuthority:kLoginAuthority error:&error];
    // Change stage https://stage-yearbook.mars.com
    [self.authContext acquireTokenWithResource:kAuthAzureUri clientId:kAuthClientId redirectUri:[NSURL URLWithString:kAuthRedirectUri] completionBlock:^(ADAuthenticationResult *result){
        if (AD_SUCCEEDED != result.status){
            // display error on the screen
            [self.activityIndicator stopAnimating];
            [self.loginButton setHidden:FALSE];
            NSLog(@"Issue with Profile Picture: %@", result.error.errorDetails);
            [self displayAlertWithMsg:result.error.errorDetails];
        }
        else{
            //             NSLog(@"%@",result.accessToken);
            YBProfileStore *profileStore = [[YBProfileStore alloc] init];
            [profileStore fetchAndStoreUserWithToken:result.accessToken AndCompletion:^(NSString *imageURL, NSError *error) {
                NSLog(@"Completed");
            }];
        }
    }];
    
}

-(void)fetchCalendars:(NSString *)token{
    YBCalendarsStore *store = [[YBCalendarsStore alloc] init];
    [store fetchAndStoreCalendarsToken:token AndCompletionHandler:^(NSError *error) {
        [self.activityIndicator stopAnimating];
        [self.loginButton setHidden:FALSE];
        if (!error) {
            [self performSegueWithIdentifier:@"YBCoachMeVC" sender:self];
        }
        else{
            [self displayAlertWithMsg:[error localizedDescription]];
        }
    }];
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

-(void)fetchTeamEFFEM:(NSString *)token{
    [self.authContext acquireTokenWithResource:@"https://team.effem.com" clientId:kAuthClientId  redirectUri:[NSURL URLWithString:@"https://team.effem.com"] completionBlock:^(ADAuthenticationResult *result)
     {
         if (AD_SUCCEEDED != result.status){
             // display error on the screen
             [self.activityIndicator stopAnimating];
             [self.loginButton setHidden:FALSE];
             NSLog(@"Issue with Profile Picture: %@", result.error.errorDetails);
         }
         else{
             //             NSLog(@"%@",result.accessToken);
             NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
             [def setObject:result.accessToken forKey:@"accessTokenForPicture"];
             [def synchronize];
             [[SDWebImageDownloader sharedDownloader] setValue:[NSString stringWithFormat:@"Bearer %@",result.accessToken] forHTTPHeaderField:@"Authorization"];
         }
     }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"YBCoachMeVC"]) {
        YBCoachMeVC *dest = (YBCoachMeVC *)segue.destinationViewController;
        dest.completionHandler = ^{
            [self performSegueWithIdentifier:@"closeLoginScreen" sender:self];
        };
    }
}

@end
