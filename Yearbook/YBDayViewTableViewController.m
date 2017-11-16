//
//  YBDayViewTableViewController.m
//  Yearbook
//
//  Created by Urmil Setia on 18/01/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//

#import "YBDayViewTableViewController.h"
#import "AppDelegate.h"
#import "DateTools.h"
#import "YBEventsStore.h"
#import "YBEventDetailsTableViewController.h"
#import <ADAL/ADAL.h>

typedef NS_ENUM(NSInteger,kRefreshDataMode) {
    //Default, first load
    RefreshDataModeDefault,
    //Full Mode
    RefreshDataModeFull,
    //Delta Changes, not yet decided when to use
    RefreshDataModeDelta
};

typedef NS_ENUM(NSInteger,kHourCellType) {
    HourCellStartNode,
    HourCellContinuingNode,
    HourCellStartandEndNode,
    HourCellEndNode
};
@interface YBDayViewTableViewController ()
@property (weak, nonatomic) IBOutlet FSCalendar *calendar;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property(nonatomic) BOOL refreshDataOnLoad;
@property(nonatomic, strong) NSMutableArray *selectedEventsArry;
@property(nonatomic, strong) NSCompoundPredicate *selectionPredicate;
@property(nonatomic, strong) NSDate *lastUpdatedEvents;
@property(nonatomic, strong) NSMutableArray *timeLabels;
@property(nonatomic, strong) NSArray *theEvents;
@property(nonatomic, strong) NSMutableArray *timeSlotArry;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarHeight;
@property (strong, nonatomic) NSDate *holdOldDate;
@end

@implementation YBDayViewTableViewController
@synthesize managedObjectContext = _managedObjectContext;
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateLastUpdatedEventsDate:)
                                                 name:@"LASTEVENTSFETCHED"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateLastUpdatedEventsDate:)
                                                 name:@"WAITFORDATALOAD"
                                               object:nil];
    self.calendar.scope = FSCalendarScopeWeek;
    self.calendar.appearance.headerTitleColor = [UIColor colorWithRed:21.0/255.0 green:52.0/255.0 blue:83.0/255.0 alpha:1.0];
    self.calendar.appearance.weekdayTextColor = [UIColor colorWithRed:21.0/255.0 green:52.0/255.0 blue:83.0/255.0 alpha:1.0];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.tableview registerNib:[UINib nibWithNibName:@"YBHourTableViewCell" bundle:nil] forCellReuseIdentifier:@"hourCell"];
    [self.calendar registerClass:[FSCalendarCell class] forCellReuseIdentifier:@"weekday"];

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocalizedDateFormatFromTemplate:@"hh:mma"];
    
    self.timeLabels = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i <= 24; i++) {
        [self.timeLabels addObject:[df stringFromDate:[[df dateFromString:@"12:00 AM"] dateByAddingTimeInterval:60*60*i]]];
    }
    
    [self performSelector:@selector(scrollTo9am) withObject:nil afterDelay:1];
    if (!self.managedObjectContext) {
        AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
        self.managedObjectContext = appDel.managedObjectContext;
    }
    self.holdOldDate = self.calendar.today;
    NSDateComponents *comp = [[NSCalendar currentCalendar] componentsInTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0] fromDate:self.calendar.today];
    [self fetchEventsForDate:[NSDate dateWithYear:comp.year month:comp.month day:comp.day inTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]] andNeedRefresh:FALSE];
   
}

-(NSManagedObjectContext *)managedObjectContext{
    if (!_managedObjectContext) {
        AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
        self.managedObjectContext = appDel.managedObjectContext;
    }
    return _managedObjectContext;
}

-(void)viewDidAppear:(BOOL)animated{
    self.calendarHeight.constant = 108.5;
    [self.view updateConstraints];
}

- (__kindof FSCalendarCell *)calendar:(FSCalendar *)calendar cellForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position{
    FSCalendarCell *cell = [calendar dequeueReusableCellWithIdentifier:@"weekday" forDate:date atMonthPosition:position];
    [cell setPreferredBorderWidthPercentage:1.0];
    return cell;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition{
    //Pass the date
    CGRect frame = self.tableview.frame;
    if ([self.holdOldDate isLaterThan:date]) {
        frame.origin.x = -frame.size.width;
    }
    else if ([self.holdOldDate isSameDay:date]){
        frame.origin.x = 0;
    }
    else{
        frame.origin.x = frame.size.width;
    }
    self.holdOldDate = date;
    self.tableview.frame = frame;
    [UIView animateWithDuration:0.3f
                     animations:^ {
                         CGRect frame = self.tableview.frame;
                         frame.origin.x = 0;
                         self.tableview.frame = frame;
                         self.tableview.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                     }
                     completion:^(BOOL finished) {
                         
                         [UIView beginAnimations:nil context:nil];
                         [UIView setAnimationDuration:0.3];
                         [UIView commitAnimations];
                     }];
    NSDateComponents *comp = [[NSCalendar currentCalendar] componentsInTimeZone:[NSTimeZone systemTimeZone] fromDate:date];
    
//    NSLog(@"A: %@",[NSDate dateWithYear:comp.year month:comp.month day:comp.day inTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]]);
    [self fetchEventsForDate:[NSDate dateWithYear:comp.year month:comp.month day:comp.day inTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]] andNeedRefresh:TRUE];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)scrollTo9am{
    [self.tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:9 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 25;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath isEqual:[NSIndexPath indexPathForRow:24 inSection:0]]) {
        return 15.f;
    }
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YBHourTableViewCell *cell = (YBHourTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"hourCell" forIndexPath:indexPath];
    cell.delgate = self;
    cell.TimeLabel.text = [self.timeLabels objectAtIndex:indexPath.row];
    
    if (indexPath.row  == 24) {
        [cell configureCellWithPositions:nil];
        return cell;
    }
    
    NSArray *theIndexElement = [self.timeSlotArry filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.IndPath == %@", indexPath]];
    if ([theIndexElement count] > 0) {
        [cell configureCellWithPositions:[theIndexElement[0] objectForKey:@"Positions"]];
    }
    else{
        [cell configureCellWithPositions:nil];
    }
    return cell;
}

-(void)dayEventTappedWithEventID:(NSString *)eventID{
    YBEventsStore *store = [YBEventsStore sharedInstance];
    YBEvents *TappedEvent = [store checkAndReturnIfExistWithClass:@"YBEvents" andPredicate:[NSPredicate predicateWithFormat:@"eventID == %@",eventID]];
    
    YBEventDetailsTableViewController *detailVC = (YBEventDetailsTableViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"YBEventDetailsTableViewContID"];
    detailVC.selectedEvent = TappedEvent;
    self.rootControl.detailScreen = TRUE;
    [self.rootControl.navigationController pushViewController:detailVC animated:YES];
}



#pragma mark - CoreData fetch and process

-(void)updateLastUpdatedEventsDate:(NSNotification *)notification{
    if ([[notification name] isEqualToString:@"LASTEVENTSFETCHED"]) {
        self.lastUpdatedEvents = [notification object][1];
        self.refreshDataOnLoad = TRUE;
        if ([[notification object][0] isEqual:[NSNumber numberWithLong:1.0]]) {
            [self fetchEventsForDate:self.holdOldDate andNeedRefresh:YES];
        }
    }
    else if ([[notification name] isEqualToString:@"WAITFORDATALOAD"]){
        self.refreshDataOnLoad = FALSE;
    }
}

-(void)updateSelectedCalendars:(NSMutableArray *)selectedCalendarAndCategories andMode:(NSInteger)mode{
    //    NSLog(@"Selected Cat:%@",selectedCalendarAndCategories);
    self.selectedEventsArry = nil;
    self.selectedEventsArry = [selectedCalendarAndCategories mutableCopy];
    //    if (mode == 0) {
    NSDate *selectionDate = self.calendar.today;
    NSDateComponents *comp;
    if (self.calendar.today == nil) {
        comp = [[NSCalendar currentCalendar] componentsInTimeZone:[NSTimeZone systemTimeZone] fromDate:[NSDate date]];
    }
    else{
        comp = [[NSCalendar currentCalendar] componentsInTimeZone:[NSTimeZone systemTimeZone] fromDate:self.calendar.today];
    }
    selectionDate = [NSDate dateWithYear:comp.year month:comp.month day:comp.day inTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [self fetchEventsForDate:selectionDate andNeedRefresh:YES];
    [self.calendar setCurrentPage:selectionDate animated:YES];
    //    }
    //    self.refreshDataOnLoad = TRUE;
    //    [self refreshData:RefreshDataModeDefault];
}

-(void)fetchEventsForDate:(NSDate *)date andNeedRefresh:(BOOL)refresh{
    NSDate *endDateTime = [date dateByAddingMinutes:(24*60)-1];
    if ([self.selectedEventsArry count]>0) {
        NSMutableArray *predArry = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *dict in self.selectedEventsArry) {
            NSString *calID = [dict objectForKey:@"calendarID"];
            NSPredicate *p1 = [NSPredicate predicateWithFormat:@"calendar.calendarid == %@",calID];
            NSMutableArray *subPredicatesArry =[NSMutableArray arrayWithCapacity:0];
            NSArray *arry = [dict objectForKey:@"categories"];
            for (NSString *str in arry) {
                NSPredicate *p = [NSPredicate predicateWithFormat:@"category.categoryGUID == %@",str];
                [subPredicatesArry addObject:p];
            }
            NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
            [df1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [df1 setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
//            NSLog(@"Hours: %ld and Min: %ld NewDate: %@",(long)[date hour], (long)[date minute],[[date dateBySubtractingHours:[date hour]] dateBySubtractingMinutes:[date minute]]);
            NSPredicate *startDatePred = [NSPredicate predicateWithFormat:@"(self.starttime >= %@) AND (self.starttime <= %@)",date,endDateTime];
            NSPredicate *endDatePred = [NSPredicate predicateWithFormat:@"(self.endtime >= %@) AND (self.endtime <= %@)",date,endDateTime];
            NSCompoundPredicate *orPredDate = [NSCompoundPredicate orPredicateWithSubpredicates:@[startDatePred,endDatePred]];
            NSCompoundPredicate *comPred = [NSCompoundPredicate orPredicateWithSubpredicates:subPredicatesArry];
            NSCompoundPredicate *pred = [NSCompoundPredicate andPredicateWithSubpredicates:@[p1, comPred,orPredDate]];
            [predArry addObject:pred];
        }
        self.selectionPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predArry];
    }
    else{
        self.selectionPredicate = [NSCompoundPredicate notPredicateWithSubpredicate:[NSPredicate predicateWithValue:TRUE]];
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"YBEvents" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
#pragma Testing
//    NSPredicate *startDatePred = [NSPredicate predicateWithFormat:@"(self.starttime >= %@) AND (self.starttime <= %@)",[df1 dateFromString:@"2017-01-25 00:00:00"],[df1 dateFromString:@"2017-01-25 23:59:59"]];
//    
//    NSPredicate *endDatePred = [NSPredicate predicateWithFormat:@"(self.endtime >= %@) AND (self.endtime <= %@)",[df1 dateFromString:@"2017-01-25 00:00:00"],[df1 dateFromString:@"2017-01-25 23:59:59"]];
    
//    NSCompoundPredicate *pred = [NSCompoundPredicate orPredicateWithSubpredicates:@[startDatePred,endDatePred]];
//    self.selectionPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[[self.selectionPredicate subpredicates],pred]];
#pragma
    fetchRequest.predicate = self.selectionPredicate;
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"starttime" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSError *err;
    if ([self.theEvents count]>0) {
        self.theEvents = nil;
    }
    self.theEvents = [self.managedObjectContext executeFetchRequest:fetchRequest error:&err];
//Doesn't make sense to do this. Check later.
//    if (!([self.theEvents count] > 0) && ([self.selectedEventsArry count] > 0)) {
//        [self fetchAndStoreEventsWithSelectedCategories:^(NSError *error){
//            if (error) {
//                NSLog(@"Loading Events Error: %@",error);
//                [self displayAlertWithMsg:[error localizedDescription]];
//            }
//            else
//                [self refreshData:RefreshDataModeDefault];//error
//        }];
//    }
    [self.timeSlotArry removeAllObjects];
    [self processDataWithDate:date andNeedRefresh:refresh];
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
            [store fetchAndStoreEventsWithCalendarsAndCategories:self.selectedEventsArry forYear:([self.holdOldDate year])?[self.holdOldDate year]:[[NSDate date] year] token:result.accessToken andCompletionHandler:^(NSError *error) {
                if (completionBlock) {
                    completionBlock(error);
                }
            }];
        }
    }];

}

-(void)processDataWithDate:(NSDate *)date andNeedRefresh:(BOOL)refresh{
//    NSDate *endDateTime = [date dateByAddingMinutes:(24*60)-1];
    if (!self.timeSlotArry){
        self.timeSlotArry = [NSMutableArray arrayWithCapacity:0];
    }
    //Step 1: Sorted into Assending TimeSlots.
    DTTimePeriodCollection *collection = [DTTimePeriodCollection collection];
    for (int i = 0; i < [self.theEvents count]; i++) {
        YBEvents *event = [self.theEvents objectAtIndex:i];
        DTTimePeriod *tp = [[DTTimePeriod alloc] initWithStartDate:event.starttime endDate:event.endtime andRefenceObject:event];
        [collection addTimePeriod:tp];
    }
    [collection sortByStartAscending];
    //    NSLog(@"Collection results: %@", [collection[0] StartDate]);
    
    for (int i = 0; i < [collection count]; i++) {
        DTTimePeriod *tp = collection[i];
        YBEvents *event = (YBEvents *)[tp refenceObject];
        double startingHour = (double)[[tp StartDate] hourWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
        double nonRelvantHours = 0;
        [df1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [df1 setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        if ([[tp StartDate] isEarlierThan:date]) {
            nonRelvantHours = [[tp StartDate] hoursEarlierThan:date];
            startingHour = -1;
        }
        
//        int startingMin = (int)[[tp StartDate] minuteWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
//        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//        [formatter setMaximumFractionDigits:0];
//        int hours = [[formatter stringFromNumber:[NSNumber numberWithDouble:[tp durationInHours]]] intValue];
        double hours = [tp durationInHours];
//        int minutes = [[formatter stringFromNumber:[NSNumber numberWithDouble:[tp durationInMinutes]]] intValue];
        double minutes = [tp durationInMinutes];
        if ((hours - floorf(hours)) > 0) {
//            hours++;
        }
        else{
            if (hours !=1) {
//                hours--;
            }
        }
        if (hours != 0) {
            int newStartingHour = startingHour;
            if (startingHour == -1) {
                newStartingHour = 0;
            }
#warning NO this is not correct.
            int numberOfSlots = floorl(hours - nonRelvantHours);
            long startingMin = [[tp StartDate] minuteWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            long endingMin = [[tp EndDate] minuteWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            if ((startingMin > 0 || endingMin >0) && ![[tp EndDate] isEqual:date]) {
                numberOfSlots++;
            }
            for (int y = 0; y < numberOfSlots; y++) {
                //Fill the Slot
                
                NSIndexPath *destPath = [NSIndexPath indexPathForRow:newStartingHour+y inSection:0];
                if (newStartingHour + y >= 24) {
                    break;
                }
                NSMutableDictionary *dict = [[[self.timeSlotArry filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.IndPath = %@",destPath]] firstObject] copy];
                if (!dict) {
                    dict = [NSMutableDictionary dictionaryWithCapacity:5];
                    [dict setObject:destPath forKey:@"IndPath"];
                    [dict setObject:[NSMutableArray arrayWithCapacity:0] forKey:@"Positions"];
                }
                else{
                    [self.timeSlotArry removeObject:dict];
                }
                NSMutableArray *positionArry = [dict objectForKey:@"Positions"];
                NSMutableDictionary *theSlotEvent = [NSMutableDictionary dictionaryWithCapacity:0];
                [theSlotEvent setObject:event forKey:@"event"];
                if (y == 0 ) { //&& startingHour != -1
                    if (startingHour != -1) {
                        [theSlotEvent setObject:[NSNumber numberWithLong:[[tp StartDate] minuteWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]]] forKey:@"startingMinutes"];
                    }
                    else{
                        [theSlotEvent setObject:[NSNumber numberWithLong:0] forKey:@"startingMinutes"];
                    }
                }
                if (numberOfSlots-1 == y){
                    //Last Hour
                    
                    //                    [theSlotEvent setObject:[NSNumber numberWithLong:20] forKey:@"endingMinutes"];
                    
                    
                    [theSlotEvent setObject:[NSNumber numberWithLong:[[tp EndDate] minuteWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]]] forKey:@"endingMinutes"];
                    
                }
                [positionArry addObject:theSlotEvent];
                [self.timeSlotArry addObject:dict];
                //                NSLog(@"IndexPath: %@",[NSIndexPath indexPathForRow:startingHour+y inSection:0]);
            }
        }
        else if (minutes < 60){
            NSIndexPath *destPath = [NSIndexPath indexPathForRow:startingHour inSection:0];
            NSMutableDictionary *dict = [[[self.timeSlotArry filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.IndPath = %@",destPath]] firstObject] copy];
            if (!dict) {
                dict = [NSMutableDictionary dictionaryWithCapacity:5];
                [dict setObject:destPath forKey:@"IndPath"];
                [dict setObject:[NSMutableArray arrayWithCapacity:0] forKey:@"Positions"];
            }
            else{
                [self.timeSlotArry removeObject:dict];
            }
            NSMutableArray *positionArry = [dict objectForKey:@"Positions"];
            NSMutableDictionary *theSlotEvent = [NSMutableDictionary dictionaryWithCapacity:0];
            [theSlotEvent setObject:event forKey:@"event"];
            [theSlotEvent setObject:[NSNumber numberWithLong:[[tp StartDate] minuteWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]]] forKey:@"minutes"];
            [positionArry addObject:theSlotEvent];
            [self.timeSlotArry addObject:dict];
        }
    }
    if (refresh == TRUE) {
        [self.tableview reloadData];
        if ([self.timeSlotArry count] > 0) {
            NSIndexPath *indPath = [self.tableview indexPathsForVisibleRows][0];
            [self.timeSlotArry sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"IndPath" ascending:YES],nil]];
            [self.tableview scrollToRowAtIndexPath:[[self.timeSlotArry objectAtIndex:0] objectForKey:@"IndPath"] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            [self performSelector:@selector(scrollToPostion:) withObject:indPath afterDelay:0.001];
        }
        
    }
}

-(void)scrollToPostion:(NSIndexPath *)indPath{
    [self.tableview scrollToRowAtIndexPath:indPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
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

/*
 #pragma mark - Table view delegate
 
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 // Navigation logic may go here, for example:
 // Create the next view controller.
 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
 
 // Pass the selected object to the new view controller.
 
 // Push the view controller.
 [self.navigationController pushViewController:detailViewController animated:YES];
 }
 */


@end
