//
//  YBDrawerViewController.h
//  Yearbook
//
//  Created by Urmil Setia on 03/01/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISHPullUp/ISHPullUpHandleView.h"
#import "ISHPullUp/ISHPullUpRoundedView.h"
#import "ISHPullUp/ISHPullUpViewController.h"
#import "YBMainScreenViewController.h"

@interface YBDrawerViewController : UIViewController <ISHPullUpStateDelegate, ISHPullUpSizingDelegate, UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) ISHPullUpViewController *pullUpHandleViewController;
@property (strong, nonatomic) NSMutableArray *eventsArryForSelectedDate;
@property (nonatomic, weak) YBMainScreenViewController *rootControl;
-(void) closeDrawer;
-(void) openDrawerFull;
-(void) openDrawerHalf;
-(void) reloadTableData;
@end
