//
//  YBMonthCalendarViewController.h
//  Yearbook
//
//  Created by Urmil Setia on 07/12/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar/FSCalendar.h"
#import "YBMainScreenViewController.h"
#import <LTHMonthYearPickerView/LTHMonthYearPickerView.h>
#import "ISHPullUp/ISHPullUpHandleView.h"
#import "ISHPullUp/ISHPullUpRoundedView.h"
#import "ISHPullUp/ISHPullUpViewController.h"

@interface YBMonthCalendarViewController : ISHPullUpViewController<FSCalendarDelegate, FSCalendarDataSource,FSCalendarDelegateAppearance,NSFetchedResultsControllerDelegate,YBSelectedCalendarUpdate,LTHMonthYearPickerViewDelegate>
@property (weak, nonatomic) IBOutlet id<FSCalendarDelegate> delegate1;
@property (weak, nonatomic) IBOutlet id<FSCalendarDataSource> dataSource;
@property (assign, nonatomic) FSCalendarScrollDirection flow;
@property (weak , nonatomic) IBOutlet FSCalendar *calendar;
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, weak) YBMainScreenViewController *rootControl;
@end
