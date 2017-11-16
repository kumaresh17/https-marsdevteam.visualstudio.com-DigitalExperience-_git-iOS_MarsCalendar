//
//  YBDayCalendarViewController.m
//  Yearbook
//
//  Created by Urmil Setia on 03/01/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//

#import "YBDayCalendarViewController.h"
#import "YBDrawerViewController.h"
@interface YBDayCalendarViewController ()

@end

@implementation YBDayCalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    YBDrawerViewController *drawer = (YBDrawerViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"YBDrawerViewControllerID"];
    [drawer.view setHidden:TRUE];
    self.bottomViewController = drawer;
    self.bottomViewController.hidesBottomBarWhenPushed = TRUE;
    drawer.pullUpHandleViewController = (ISHPullUpViewController *)self;
    self.stateDelegate = drawer;
    self.sizingDelegate = drawer;
}

- (void)viewDidAppear:(BOOL)animated{
    [self.bottomViewController.view setHidden:FALSE];
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

@end
