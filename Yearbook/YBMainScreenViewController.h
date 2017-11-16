//
//  mainScreenViewController.h
//  Yearbook
//
//  Created by Urmil Setia on 17/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YBCalendarSelectorTableViewController.h"
#import "YBMenuTableViewController.h"

@protocol YBSelectedCalendarUpdate;

@interface YBMainScreenViewController : UIViewController<YBCalendarSelectorUpdateEvents,UIScrollViewDelegate,YBMenu>
@property (nonatomic, assign) id<YBSelectedCalendarUpdate> delegateForTableView;
@property (nonatomic, assign) id<YBSelectedCalendarUpdate> delegateForMonthView;
@property (nonatomic, assign) id<YBSelectedCalendarUpdate> delegateForDayView;
@property (nonatomic) BOOL detailScreen;
@end

@protocol YBSelectedCalendarUpdate <NSObject>

-(void)updateSelectedCalendars:(NSMutableArray *)selectedCalendarAndCategories andMode:(NSInteger)mode;
//-(void)sendSegue;
@end
