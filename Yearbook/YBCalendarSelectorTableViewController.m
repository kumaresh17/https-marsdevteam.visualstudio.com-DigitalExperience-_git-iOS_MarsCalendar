//
//  YBCalendarSelectorTableViewController.m
//  Yearbook
//
//  Created by Urmil Setia on 25/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBCalendarSelectorTableViewController.h"
#import "AppDelegate.h"
#import "YBCategoryTableViewCell.h"
#import "YBCalendarTableViewCell.h"
#import "YBCalendars+CoreDataClass.h"
#import "YBCalendarCategory+CoreDataClass.h"
#import "YBDismissSegue.h"
#import "YBEventSyncToCalenderService.h"
#import <SDWebImage/SDImageCache.h>

@class NSArray;

@interface YBCalendarSelectorTableViewController ()
@property(nonatomic, strong) NSMutableArray *arryOfSelectedCalendarsAndCategories;
@property (nonatomic, strong) NSMutableArray *receivedSelectedEvents;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation YBCalendarSelectorTableViewController
@synthesize fetchedResultsController = _fetchedResultsController,managedObjectContext = _managedObjectContext;

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    if (!_managedObjectContext) {
        AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
        _managedObjectContext = appDel.managedObjectContext;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"YBCalendars" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"calendarname" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:_managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:@"calendarcategories"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

- (void)viewDidAppear:(BOOL)animated{
    //    NSLog(@"viewDidAppear");
    //This is where the magic should happen
    NSMutableArray *arryOfIndexPathsToBeSelected = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < [[self.fetchedResultsController fetchedObjects] count]; i++) {
        YBCalendars *cal = [[self.fetchedResultsController fetchedObjects] objectAtIndex:i];
        NSArray *tempA = [self.receivedSelectedEvents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.calendarID == %@",[cal calendarid]]];
        if ([tempA count] > 0 ) {
            BOOL areAllSelected = ([[tempA[0] objectForKey:@"isAllSelected"] isEqual:[NSNumber numberWithBool:TRUE]])?TRUE:FALSE;
            if (areAllSelected == TRUE) {
                //Loop all the rows for this section
                for (int y = 0; y < [[cal categories] count]+1; y++) {
                    [arryOfIndexPathsToBeSelected addObject:[NSIndexPath indexPathForRow:y inSection:i]];
                }
            }
            else{
                for (int y = 0; y < [[cal categories] count]; y++) {
                    NSArray *tempB = [[tempA[0] objectForKey:@"categories"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == %@",[(YBCalendarCategory *)[[cal categories] objectAtIndex:y] categoryGUID]]];
                    if ([tempB count]>0) {
                        [arryOfIndexPathsToBeSelected addObject:[NSIndexPath indexPathForRow:y+1 inSection:i]];
                    }
                }
            }
        }
    }
    for (NSIndexPath *path in arryOfIndexPathsToBeSelected) {
        //        NSLog(@"IndexPath Row: %ld Section: %ld",(long)path.row, (long)path.section);
        [self.tableView selectRowAtIndexPath:path animated:FALSE scrollPosition:UITableViewScrollPositionNone];
    }
    if (self.receivedSelectedEvents != nil) {
        self.arryOfSelectedCalendarsAndCategories = self.receivedSelectedEvents;
    }
    self.receivedSelectedEvents = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self allowsAccessDeviceCalendar];
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.frame = CGRectMake(50, 80, 100, 100);
    _activityIndicator.color = [UIColor blueColor];
    _activityIndicator.center = self.view.center;
    [self.tableView addSubview:_activityIndicator];
    [self.tableView bringSubviewToFront:_activityIndicator];
    [self.tableView registerNib:[UINib nibWithNibName:@"YBCategoryTableViewCell" bundle:nil] forCellReuseIdentifier:@"CategoryCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YBCalendarTableViewCell" bundle:nil] forCellReuseIdentifier:@"CalendarCell"];
    if (!self.arryOfSelectedCalendarsAndCategories) {
        self.arryOfSelectedCalendarsAndCategories = [NSMutableArray arrayWithCapacity:0];
    }
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);
    }
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBtnPressed:)];
    self.navigationItem.rightBarButtonItem = doneBtn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)startAnimating:(UIBarButtonItem*)sender
{
    if(!_activityIndicator.isAnimating){
        [_activityIndicator startAnimating];
        [self.view setUserInteractionEnabled:NO];
        [sender setEnabled:NO];
    }
}
- (void)stopAnimating:(UIBarButtonItem*)sender
{
    if(_activityIndicator.isAnimating){
        [_activityIndicator stopAnimating];
        [self.view setUserInteractionEnabled:YES];
        [sender setEnabled:YES];
        
    }
}

-(void)allowsAccessDeviceCalendar
{
    [[YBEventSyncToCalenderService sharedSyncService] requestPermissionForCalenderAccess:nil];
}

-(void)doneBtnPressed:(id)sender {
    __weak YBCalendarSelectorTableViewController *weakSelf = self;
    [self startAnimating:sender];
    if ([self.delegate respondsToSelector:@selector(CalendarAndSelectedCategories:completion:)]) {
        [self.delegate CalendarAndSelectedCategories:self.arryOfSelectedCalendarsAndCategories completion:^{
            [weakSelf startAnimating:sender];
                [weakSelf.navigationController performSegueWithIdentifier:@"dismissSegueForCategories" sender:weakSelf];
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController fetchedObjects] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    YBCalendars *cal = (YBCalendars *)[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:section inSection:0]];
    return [[cal categories] count]+1;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [[[self.fetchedResultsController fetchedObjects] objectAtIndex:section] calendarname];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIndentifier = (indexPath.row == 0) ?@"CalendarCell":@"CategoryCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    YBCalendars *cal = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.section];
    if ([cell isKindOfClass:[YBCalendarTableViewCell class]]) {
        [(YBCalendarTableViewCell *)cell configureCellWithName:[cal calendarname] andColor:nil];
    }
    else{
        YBCalendarCategory *cat = [[cal categories] objectAtIndex:indexPath.row-1];
        [(YBCategoryTableViewCell *)cell configureCellWithName:[cat categoryName] andColor:[cat categoryColor] andGuid:[cat categoryGUID]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *dictOfCalendar =[NSMutableDictionary dictionaryWithCapacity:3];
    if (indexPath.row == 0) {
        NSInteger rows = [tableView numberOfRowsInSection:indexPath.section] - 1;
        for (int i = 1; i<=rows; i++) {
            NSIndexPath *indpth = [NSIndexPath indexPathForRow:(NSInteger)i  inSection:indexPath.section];
            [tableView selectRowAtIndexPath:indpth animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
        YBCalendars *cal = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.section];
        NSMutableArray *arryOfCategories =[NSMutableArray arrayWithCapacity:0];
        for (NSMutableDictionary *dict in self.arryOfSelectedCalendarsAndCategories) {
            if ([[dict objectForKey:@"calendarID"] isEqual:cal.calendarid]) {
                [self.arryOfSelectedCalendarsAndCategories removeObject:dict];
                break;
            }
        }
        for (YBCalendarCategory *cat in cal.categories) {
            [arryOfCategories addObject:cat.categoryGUID];
        }
        [dictOfCalendar setObject:cal.calendarid forKey:@"calendarID"];
        [dictOfCalendar setObject:cal.calendarname forKey:@"calendarName"];
        [dictOfCalendar setObject:arryOfCategories forKey:@"categories"];
        [dictOfCalendar setObject:[NSNumber numberWithBool:TRUE] forKey:@"isAllSelected"];
        [self.arryOfSelectedCalendarsAndCategories addObject:dictOfCalendar];
    }
    else{
        YBCalendars *cal = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.section];
        YBCategoryTableViewCell *catCell = (YBCategoryTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        NSMutableArray *arryOfCategories = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *dict in self.arryOfSelectedCalendarsAndCategories) {
            if ([[dict objectForKey:@"calendarID"] isEqual:cal.calendarid]) {
                arryOfCategories = [[dict objectForKey:@"categories"] mutableCopy];
                dictOfCalendar = [dict mutableCopy];
                [self.arryOfSelectedCalendarsAndCategories removeObject:dict];
                break;
            }
        }
        [dictOfCalendar setObject:cal.calendarid forKey:@"calendarID"];
        [dictOfCalendar setObject:cal.calendarname forKey:@"calendarName"];
        [dictOfCalendar setObject:[NSNumber numberWithBool:FALSE] forKey:@"isAllSelected"];
        [arryOfCategories addObject:catCell.CategoryGuid];
        [dictOfCalendar setObject:arryOfCategories forKey:@"categories"];
        if ([arryOfCategories count] == [cal.categories count]) {
            NSIndexPath *indpth = [NSIndexPath indexPathForRow:0  inSection:indexPath.section];
            [tableView selectRowAtIndexPath:indpth animated:YES scrollPosition:UITableViewScrollPositionNone];
            [dictOfCalendar setObject:[NSNumber numberWithBool:TRUE] forKey:@"isAllSelected"];
        }
        [self.arryOfSelectedCalendarsAndCategories addObject:dictOfCalendar];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *dictOfCalendar =[NSMutableDictionary dictionaryWithCapacity:0];
    if (indexPath.row == 0) {
        NSInteger rows = [tableView numberOfRowsInSection:indexPath.section] - 1;
        for (int i = 1; i<=rows; i++) {
            NSIndexPath *indpth = [NSIndexPath indexPathForRow:(NSInteger)i  inSection:indexPath.section];
            [tableView deselectRowAtIndexPath:indpth animated:YES];
        }
        YBCalendars *cal = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.section];
        [dictOfCalendar setObject:cal.calendarid forKey:@"calendarID"];
        [dictOfCalendar setObject:cal.calendarname forKey:@"calendarName"];
        [dictOfCalendar setObject:[NSNumber numberWithBool:TRUE] forKey:@"isAllSelected"];
        NSMutableArray *arryOfCategories =[NSMutableArray arrayWithCapacity:0];
        for (YBCalendarCategory *cat in cal.categories) {
            [arryOfCategories addObject:cat.categoryGUID];
        }
        [dictOfCalendar setObject:arryOfCategories forKey:@"categories"];
        [self.arryOfSelectedCalendarsAndCategories removeObject:dictOfCalendar];
    }
    else{
        YBCalendars *cal = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.section];
        YBCategoryTableViewCell *catCell = (YBCategoryTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        NSMutableArray *arryOfCategories = [NSMutableArray arrayWithCapacity:0];
        for (NSMutableDictionary *dict in self.arryOfSelectedCalendarsAndCategories) {
            if ([[dict objectForKey:@"calendarID"] isEqual:cal.calendarid]) {
                [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section] animated:NO];
                NSMutableDictionary *mDict = [dict mutableCopy];
                arryOfCategories = [[mDict objectForKey:@"categories"] mutableCopy];
                [arryOfCategories removeObject:catCell.CategoryGuid];
                
                [self.arryOfSelectedCalendarsAndCategories removeObject:dict];
                if ([arryOfCategories count] > 0) {
                    [mDict setObject:arryOfCategories forKey:@"categories"];
                    [mDict setObject:[NSNumber numberWithBool:FALSE] forKey:@"isAllSelected"];
                    [self.arryOfSelectedCalendarsAndCategories addObject:mDict];
                }
                break;
            }
        }
    }
}

-(void)reloadSelectedCalendarAndCategories:(NSMutableArray *)arrySelectedCalsAndCats{
    self.receivedSelectedEvents = [arrySelectedCalsAndCats mutableCopy];
}

//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView beginUpdates];
//}
//
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
//    UITableView *tableView = self.tableView;
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//            break;
//        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:[NSArray
//                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:[NSArray
//                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//        default:
//            break;
//    }
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView endUpdates];
//}

@end
