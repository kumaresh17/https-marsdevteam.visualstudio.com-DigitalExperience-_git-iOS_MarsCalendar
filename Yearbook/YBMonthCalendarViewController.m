//
//  YBMonthCalendarViewController.m
//  Yearbook
//
//  Created by Urmil Setia on 07/12/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBMonthCalendarViewController.h"
#import "YBMonthCalendarDateCell.h"
#import "AppDelegate.h"
#import "YBEventsStore.h"
#import "YBDrawerViewController.h"
#import "DateTools.h"
#import <ADAL/ADAL.h>

#define kCalendarDate @"calendarDate"
#define kEventsForDate @"eventsForDate"

typedef NS_ENUM(NSInteger,kRefreshDataMode) {
    //Default, first load
    RefreshDataModeDefault,
    //Full Mode
    RefreshDataModeFull,
    //Delta Changes, not yet decided when to use
    RefreshDataModeDelta
};

@interface YBMonthCalendarViewController ()
@property(nonatomic, strong) NSMutableArray *selectedEventsArry;
@property(nonatomic, strong) NSCompoundPredicate *selectionPredicate;
@property(nonatomic, strong) NSMutableArray *arryEventsForMonthView;
@property(nonatomic) BOOL refreshDataOnLoad;
@property(nonatomic) long currentSelectedYear;
@property(nonatomic, strong) NSDate *lastUpdatedEvents;
@property (weak, nonatomic) IBOutlet UIButton *currentMonth;
@property (nonatomic, strong) LTHMonthYearPickerView *monthYearPicker;
@end

@implementation YBMonthCalendarViewController
@synthesize fetchedResultsController = _fetchedResultsController,managedObjectContext = _managedObjectContext;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateLastUpdatedEventsDate:)
                                                     name:@"LASTEVENTSFETCHED"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateLastUpdatedEventsDate:)
                                                     name:@"WAITFORDATALOAD"
                                                   object:nil];
    }
    return self;
}



-(void)updateLastUpdatedEventsDate:(NSNotification *)notification{
    if ([[notification name] isEqualToString:@"LASTEVENTSFETCHED"]) {
        self.lastUpdatedEvents = [notification object][1];
        self.refreshDataOnLoad = TRUE;
        if ([[notification object][0] isEqual:[NSNumber numberWithLong:1.0]]) {
            //Load view userself;
            [self refreshData:RefreshDataModeDefault];
        }
    }
    else if ([[notification name] isEqualToString:@"WAITFORDATALOAD"]){
        self.refreshDataOnLoad = FALSE;
    }
}



- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        _fetchedResultsController.fetchRequest.predicate = self.selectionPredicate;
        return _fetchedResultsController;
    }
    if (!_managedObjectContext) {
        AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
        _managedObjectContext = appDel.managedObjectContext;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"YBEvents" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    fetchRequest.predicate = self.selectionPredicate;
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"eventDate" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:_managedObjectContext sectionNameKeyPath:@"eventDate"
                                                   cacheName:@"monthViewEvents"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    YBDrawerViewController *drawer = (YBDrawerViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"YBDrawerViewControllerID"];
    [drawer.view setHidden:TRUE];
    drawer.rootControl = self.rootControl;
    self.bottomViewController = drawer;
    self.bottomViewController.hidesBottomBarWhenPushed = TRUE;
    drawer.pullUpHandleViewController = (ISHPullUpViewController *)self;
    self.stateDelegate = drawer;
    self.sizingDelegate = drawer;
    self.calendar.scrollDirection = FSCalendarScrollDirectionVertical;
    self.calendar.appearance.weekdayTextColor = [UIColor colorWithRed:21.0/255.0 green:52.0/255.0 blue:83.0/255.0 alpha:1.0];
    [self.calendar registerClass:[YBMonthCalendarDateCell class] forCellReuseIdentifier:@"dateCell"];
    self.calendar.headerHeight = 0.0;
    if (!self.arryEventsForMonthView) {
        self.arryEventsForMonthView = [NSMutableArray arrayWithCapacity:0];
    }
    self.currentSelectedYear = [[[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]] year];
    //    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    //    [dateFormatter setDateFormat:@"MM / yyyy"];
    //    NSDate *initialDate = [dateFormatter dateFromString:[NSString stringWithFormat: @"%i / %i", 3, 2015]];
    //    NSDate *maxDate = [dateFormatter dateFromString:[NSString stringWithFormat: @"%i / %i", 3, 2115]];
    //
    //    self.monthYearPicker = [[LTHMonthYearPickerView alloc]
    //                        initWithDate: initialDate
    //                        shortMonths: NO
    //                        numberedMonths: NO
    //                        andToolbar: YES
    //                        minDate:[NSDate date]
    //                        andMaxDate:maxDate];
    //    self.monthYearPicker.delegate = self;
    //    [self.monthYearPicker setHidden:TRUE];
    //    CGRect windowRect = [UIScreen mainScreen].bounds;
#warning this is broken
    //    [self.monthYearPicker setFrame:CGRectMake(0,windowRect.size.height*.4, windowRect.size.width, windowRect.size.height*.3)];
    //    [self.monthYearPicker setBackgroundColor:[UIColor greenColor]];
    //    [self.view addSubview:self.monthYearPicker];
}

- (void)updateCurrentDate{
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[self.calendar currentPage]];
    
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"MM yyyy"];
    
    NSDate *dat = [formatter1 dateFromString:[NSString stringWithFormat:@"%ld %ld",[comps month],[comps year]]];
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"MMMM yyyy"];
    [self.currentMonth setTitle:[formatter2 stringFromDate:dat] forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated{
    //15 minutes
    [self updateCurrentDate];
    [self.bottomViewController.view setHidden:FALSE];
    BOOL needsUpdate = ([[NSDate date] timeIntervalSinceDate:self.lastUpdatedEvents] > 900)?TRUE:FALSE;
    if (self.refreshDataOnLoad == TRUE) {
        [self refreshData:RefreshDataModeFull];
        self.refreshDataOnLoad = FALSE;
    }
    else {
        if (needsUpdate == TRUE) {
            [self fetchAndStoreEventsWithSelectedCategories:^(NSError *error){
                if (error) {
                    NSLog(@"Loading Events Error: %@",error);
                    //                    [self displayAlertWithMsg:[error localizedDescription]];
                }
                else{
                    [self refreshData:RefreshDataModeDefault];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LASTEVENTSFETCHED" object:@[[NSNumber numberWithLong:1.0],[NSDate date]]];
                }
            }];
        }
        else
            [self refreshData:RefreshDataModeDefault];
    }
}

-(void)fetchAndStoreEventsWithSelectedCategories:(void (^)(NSError* error))completionBlock{
    
    
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
            [store fetchAndStoreEventsWithCalendarsAndCategories:self.selectedEventsArry forYear:self.currentSelectedYear token:result.accessToken andCompletionHandler:^(NSError *error) {
                if (completionBlock) {
                    completionBlock(error);
                }
            }];
        }
    }];
    

}

-(void)refreshData:(kRefreshDataMode)mode{
    if ([self.selectedEventsArry count]>0) {
        NSMutableArray *predArry = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *dict in self.selectedEventsArry) {
            NSString *calID = [dict objectForKey:@"calendarID"];
            //            NSPredicate *p1 = [NSPredicate predicateWithFormat:@"(calendar.calendarid == %@) AND (starttime > %@)",calID,[NSDate dateWithTimeIntervalSinceNow:0]];
            NSPredicate *p1 = [NSPredicate predicateWithFormat:@"calendar.calendarid == %@",calID];
            NSMutableArray *subPredicatesArry =[NSMutableArray arrayWithCapacity:0];
            NSArray *arry = [dict objectForKey:@"categories"];
            for (NSString *str in arry) {
                NSPredicate *p = [NSPredicate predicateWithFormat:@"category.categoryGUID == %@",str];
                [subPredicatesArry addObject:p];
            }
            NSCompoundPredicate *comPred = [NSCompoundPredicate orPredicateWithSubpredicates:subPredicatesArry];
            NSCompoundPredicate *pred = [NSCompoundPredicate andPredicateWithSubpredicates:@[p1, comPred]];
            [predArry addObject:pred];
        }
        self.selectionPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predArry];
    }
    else{
        self.selectionPredicate = [NSCompoundPredicate notPredicateWithSubpredicate:[NSPredicate predicateWithValue:TRUE]];
    }
    [NSFetchedResultsController deleteCacheWithName:@"monthViewEvents"];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    if (!([[self.fetchedResultsController fetchedObjects] count] > 0) && ([self.selectedEventsArry count] > 0)) {
        [self fetchAndStoreEventsWithSelectedCategories:^(NSError *error){
            if (error) {
                NSLog(@"Loading Events Error: %@",error);
                [self displayAlertWithMsg:[error localizedDescription]];
            }
            else
                [self refreshData:RefreshDataModeDefault];
        }];
    }
    [self factorizeFetchedResults:mode];
    if (mode != RefreshDataModeDelta) {
        [self.calendar reloadData];
    }
}

-(void)factorizeFetchedResults:(kRefreshDataMode)refreshMode{
    self.arryEventsForMonthView = nil;
    self.arryEventsForMonthView = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < [[self.fetchedResultsController sections] count]; i++) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:i];
        NSMutableDictionary *dateDict = [NSMutableDictionary dictionaryWithCapacity:0];
        [dateDict setObject:[[sectionInfo name] componentsSeparatedByString:@" "][0] forKey:kCalendarDate];
        //        NSLog(@"Number of Objects: %lu, in Section %@",(unsigned long)[sectionInfo numberOfObjects],[sectionInfo name]);
        NSMutableArray *eventsArry = [NSMutableArray arrayWithCapacity:0];
        for (int y = 0; y < [sectionInfo numberOfObjects]; y++) {
            [eventsArry addObject:[[sectionInfo objects] objectAtIndex:y]];
        };
        [dateDict setObject:eventsArry forKey:kEventsForDate];
        [self.arryEventsForMonthView addObject:dateDict];
    }
    
//    [self.calendar monthPositionForCell:[self.calendar cellForDate:[NSDate date] atMonthPosition:<#(FSCalendarMonthPosition)#>]]
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSArray *arry = [self.arryEventsForMonthView filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.calendarDate ==%@",[df stringFromDate:[NSDate date]]]];
    
    if ([arry count]>0) {
        NSMutableArray *eventsArray = [arry[0] objectForKey:kEventsForDate];
        YBDrawerViewController *drawer = (YBDrawerViewController *)self.bottomViewController;
        drawer.eventsArryForSelectedDate = eventsArray;
        [drawer reloadTableData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)currentMonthButtonTapped:(id)sender {
    //Open Year/Month Selector
    //    [self.monthYearPicker setHidden:false];
}
- (IBAction)todayButtonTapped:(id)sender {
    [self.calendar setCurrentPage:[NSDate date] animated:YES];
}

#pragma mark - FSCalendar DataSource

/**
 * Asks the data source for a cell to insert in a particular data of the calendar.
 */
- (__kindof FSCalendarCell *)calendar:(FSCalendar *)calendar cellForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position{
    YBMonthCalendarDateCell *cell = [calendar dequeueReusableCellWithIdentifier:@"dateCell" forDate:date atMonthPosition:position];
    return cell;
}

- (void)calendar:(FSCalendar *)calendar willDisplayCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    [cell setPreferredBorderWidthPercentage:0.35];
    NSArray *arry = [self.arryEventsForMonthView filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.calendarDate ==%@",[df stringFromDate:date]]];
    [self configureCell:cell forDate:date atMonthPosition:monthPosition withEvents:[arry mutableCopy]];
    
}

- (void)configureCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition withEvents:(NSMutableArray *)selectedEvent
{
    YBMonthCalendarDateCell *theCell = (YBMonthCalendarDateCell *)cell;
    if (monthPosition == FSCalendarMonthPositionCurrent) {
        if ([selectedEvent count]>0) {
            NSMutableArray *arry = [selectedEvent[0] objectForKey:kEventsForDate];
            if (arry) {
                [theCell configureCellWithEvents:arry];
            }
            else{
                [theCell setViewEmpty];
            }
        }
        else{
            [theCell setViewEmpty];
        }
    } else if (monthPosition == FSCalendarMonthPositionNext || monthPosition == FSCalendarMonthPositionPrevious) {
        //Do nothing.
        [theCell setViewEmpty];
    }
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar{
    YBDrawerViewController *drawer = (YBDrawerViewController *)self.bottomViewController;
    [drawer setEventsArryForSelectedDate:nil];
    [drawer reloadTableData];
    [drawer closeDrawer];
    long yearMovingTo = [[[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[calendar currentPage]] year];
    [self updateCurrentDate];
    if (self.currentSelectedYear != yearMovingTo) {
        self.currentSelectedYear = yearMovingTo;
        [self fetchAndStoreEventsWithSelectedCategories:^(NSError *error){
            if (error) {
                NSLog(@"Loading Events: %@",error);
                [self displayAlertWithMsg:[error localizedDescription]];
            }
            else
                [self refreshData:RefreshDataModeDefault];
        }];
    }
}

-(void)updateSelectedCalendars:(NSMutableArray *)selectedCalendarAndCategories andMode:(NSInteger)mode{
    //    NSLog(@"Selected Cat:%@",selectedCalendarAndCategories);
    self.selectedEventsArry = nil;
    self.selectedEventsArry = [selectedCalendarAndCategories mutableCopy];
//    if (mode == 0) {
        [self refreshData:RefreshDataModeDefault];
        [self todayButtonTapped:nil];
//    }
    //    self.refreshDataOnLoad = TRUE;
    //    [self refreshData:RefreshDataModeDefault];
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSArray *arry = [self.arryEventsForMonthView filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.calendarDate ==%@",[df stringFromDate:date]]];
    if (monthPosition == FSCalendarMonthPositionCurrent) {
        if ([arry count]>0) {
            NSMutableArray *eventsArray = [arry[0] objectForKey:kEventsForDate];
            YBDrawerViewController *drawer = (YBDrawerViewController *)self.bottomViewController;
            drawer.eventsArryForSelectedDate = eventsArray;
            if (eventsArray) {
                //Open Drawer and send Events Array
                if ([eventsArray count] > 1) {
                    [drawer openDrawerFull];
                } else {
                    [drawer openDrawerHalf];
                }
            }
            else{
                //No events for this date.
                //Close Drawer and remove all events array
                [drawer closeDrawer];
            }
        }
        else{
            //Close Drawer and remove all events array
            //No events for this date.
            [(YBDrawerViewController *)self.bottomViewController setEventsArryForSelectedDate:nil];
            [(YBDrawerViewController *)self.bottomViewController closeDrawer];
        }
    } else if (monthPosition == FSCalendarMonthPositionNext || monthPosition == FSCalendarMonthPositionPrevious) {
        //Close Drawer
        [(YBDrawerViewController *)self.bottomViewController closeDrawer];
    }
}

#pragma mark - LTHMonthYearPickerView Delegate
- (void)pickerDidPressCancelWithInitialValues:(NSDictionary *)initialValues {
    //    _dateTextField.text = [NSString stringWithFormat:
    //                           @"%@ / %@",
    //                           initialValues[@"month"],
    //                           initialValues[@"year"]];
    //    [_dateTextField resignFirstResponder];
}


- (void)pickerDidPressDoneWithMonth:(NSString *)month andYear:(NSString *)year {
    //    _dateTextField.text = [NSString stringWithFormat: @"%@ / %@", month, year];
}


- (void)pickerDidPressCancel {
    //    [_dateTextField resignFirstResponder];
}


- (void)pickerDidSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"row: %zd in component: %zd", row, component);
}


- (void)pickerDidSelectMonth:(NSString *)month {
    NSLog(@"month: %@ ", month);
}


- (void)pickerDidSelectYear:(NSString *)year {
    NSLog(@"year: %@ ", year);
}


- (void)pickerDidSelectMonth:(NSString *)month andYear:(NSString *)year {
    //    _dateTextField.text = [NSString stringWithFormat: @"%@ / %@", month, year];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

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

@end
