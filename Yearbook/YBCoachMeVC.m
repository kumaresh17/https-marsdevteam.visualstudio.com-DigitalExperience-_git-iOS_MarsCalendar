//
//  YBCoachMeVC.m
//  Yearbook
//
//  Created by Urmil Setia on 23/04/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//

#import "YBCoachMeVC.h"
#import "OnboardingViewController.h"
#import "OnboardingContentViewController.h"
#define SKIPBUTTON_HEIGHT 40

@interface YBCoachMeVC ()
@property (nonatomic, strong) OnboardingViewController *onBoardingVC;
@end

@implementation YBCoachMeVC

- (void)viewDidLoad {
    [super viewDidLoad];

}

-(void)viewWillAppear:(BOOL)animated{
    self.onBoardingVC = [self generateStandardOnboardingVC];
    [self.view addSubview:self.onBoardingVC.view];
    [self.view bringSubviewToFront:self.onBoardingVC.view];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/*
 
 [UIImage imageNamed:@"2_framed"]
 [UIImage imageNamed:@"3_framed"]
 */

#pragma mark - Onboarding

- (OnboardingViewController *)generateStandardOnboardingVC {
    OnboardingContentViewController *firstPage = [OnboardingContentViewController contentWithTitle:nil body:nil image:[UIImage imageNamed:@"1_Tutorial"] imageFrame:self.view.frame buttonText:nil action:^{
        nil;
        
    }];
    
    OnboardingContentViewController *secondPage = [OnboardingContentViewController contentWithTitle:nil body:nil image:[UIImage imageNamed:@"2_Tutorial"] imageFrame:self.view.frame buttonText:nil action:^{
       nil;
    }];
    secondPage.movesToNextViewController = YES;
    
    OnboardingContentViewController *thirdPage = [OnboardingContentViewController contentWithTitle:nil body:nil image:[UIImage imageNamed:@"3_Tutorial"] imageFrame:self.view.frame buttonText:nil action:^{
        nil;
    }];
    thirdPage.movesToNextViewController = YES;
    
    OnboardingContentViewController *fourthPage = [OnboardingContentViewController contentWithTitle:nil body:nil image:[UIImage imageNamed:@"4_Tutorial"] imageFrame:self.view.frame buttonText:nil action:^{
        nil;
    }];
    fourthPage.movesToNextViewController = YES;
    
        OnboardingContentViewController *fifthPage = [OnboardingContentViewController contentWithTitle:nil body:nil image:[UIImage imageNamed:@"5_Tutorial"] imageFrame:self.view.frame buttonText:nil action:^{
            nil;
    }];
    fifthPage.movesToNextViewController = YES;
    
    OnboardingContentViewController *sixthPage = [OnboardingContentViewController contentWithTitle:nil body:nil image:[UIImage imageNamed:@"6_Tutorial"] imageFrame:self.view.frame buttonText:nil action:^{
        nil;
    }];
    
    OnboardingViewController *onboardingVC = [OnboardingViewController onboardWithBackgroundImage:nil contents:@[firstPage, secondPage, thirdPage,fourthPage,fifthPage,sixthPage]];
    onboardingVC.shouldFadeTransitions = YES;
    onboardingVC.fadePageControlOnLastPage = YES;
    onboardingVC.fadeSkipButtonOnLastPage = YES;
    onboardingVC.shouldMaskBackground = NO;
    
    // If you want to allow skipping the onboarding process, enable skipping and set a block to be executed
    // when the user hits the skip button.
    [onboardingVC.view setFrame:self.view.frame];
    onboardingVC.allowSkipping = YES;
//    onboardingVC.skipHandler = ^{
//        [self handleOnboardingCompletion];
//    };
    
    UIButton *skipBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.origin.x + 20,self.view.frame.size.height-SKIPBUTTON_HEIGHT,self.view.frame.size.width - 40,SKIPBUTTON_HEIGHT)];
    [skipBtn setBackgroundColor:[UIColor clearColor]];
    [skipBtn addTarget:self action:@selector(skipTutorialPage) forControlEvents:UIControlEventTouchUpInside];
    [onboardingVC.view addSubview:skipBtn];
    
    return onboardingVC;
}

//Method to Skip the tutorial
   
-(void)skipTutorialPage{

    [self handleOnboardingCompletion];
    
}
                                                  
- (void)handleOnboardingCompletion {
    // set that we have completed onboarding so we only do it once... for demo
    // purposes we don't want to have to set this every time so I'll just leave
    // this here...
    //    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserHasOnboardedKey];
    
    // transition to the main application
    //    [self setupNormalRootViewController];
    
    [self performSegueWithIdentifier:@"getStartedFromLogin" sender:self];
    if (self.completionHandler) {
        self.completionHandler();
    }
}

@end
