//
//  YBDayViewTableViewController.h
//  Yearbook
//
//  Created by Urmil Setia on 18/01/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar/FSCalendar.h"
#import "YBMainScreenViewController.h"
#import "YBHourTableViewCell.h"

@interface YBDayViewTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,FSCalendarDelegateAppearance,YBSelectedCalendarUpdate,DayViewEventTap>
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, weak) YBMainScreenViewController *rootControl;
@end
