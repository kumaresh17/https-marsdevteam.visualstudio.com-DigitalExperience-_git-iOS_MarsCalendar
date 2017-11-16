//
//  YBEventsTableViewController.m
//  Yearbook
//
//  Created by Urmil Setia on 28/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBEventsTableViewController.h"
#import "YBEventTableViewCell.h"
#import "AppDelegate.h"
#import "YBEvents+CoreDataClass.h"
#import "YBLoadMoreTableViewCell.h"
#import "YBEventsStore.h"
#import "YBEventDetailsTableViewController.h"
#import <ADAL/ADAL.h>

@interface YBEventsTableViewController ()
@property(nonatomic, strong) NSMutableArray *selectedEventsArry;
@property(nonatomic, strong) NSCompoundPredicate *selectionPredicate;
@property(nonatomic) long currentSelectedYear;
@property(nonatomic) long originalSelectedYear;
@property(nonatomic, strong) NSDate *lastUpdatedEvents;
@property(nonatomic) BOOL refreshDataOnLoad;
@end

@implementation YBEventsTableViewController
@synthesize fetchedResultsController = _fetchedResultsController,managedObjectContext = _managedObjectContext;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateLastUpdatedEventsDate:)
                                                     name:@"LASTEVENTSFETCHED"
                                                   object:nil];
    }
    return self;
}

-(void)updateLastUpdatedEventsDate:(NSNotification *)notification{
    if ([[notification name] isEqualToString:@"LASTEVENTSFETCHED"]) {
        self.lastUpdatedEvents = [notification object][1];
        self.refreshDataOnLoad = TRUE;
        if ([[notification object][0] isEqual:[NSNumber numberWithLong:0.0]]) {
            //Load view userself;
            [self refreshListMode:1];
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
    NSSortDescriptor *eventDateSorter = [[NSSortDescriptor alloc]
                                         initWithKey:@"eventDate" ascending:YES];
    NSSortDescriptor *startimeSorter = [[NSSortDescriptor alloc]
                                        initWithKey:@"starttime" ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:eventDateSorter,startimeSorter,nil]];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:_managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:@"eventsTableView"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self scrollTableViewToEventItemForToday];
    [self.tableView registerNib:[UINib nibWithNibName:@"YBEventTableViewCell" bundle:nil] forCellReuseIdentifier:@"eventstableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YBLoadMoreTableViewCell" bundle:nil] forCellReuseIdentifier:@"loadMoreTableViewCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.delegate = self;
    [self refreshListMode:0];
}

/*
- (void)viewDidLayoutSubviews{
    [super viewWillLayoutSubviews];
    if([self.fetchedResultsController fetchedObjects] > 0){
       // CGFloat h = ([[self.fetchedResultsController fetchedObjects] count]* 44.0) + 100.0;
        self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height+1);
        [self.view layoutIfNeeded];
    }
}
 */


- (void)viewDidAppear:(BOOL)animated{
    //15 minutes
    BOOL needsUpdate = ([[NSDate date] timeIntervalSinceDate:self.lastUpdatedEvents] > 900)?TRUE:FALSE;
    if (self.refreshDataOnLoad == TRUE) {
        [self refreshListMode:1];
        self.refreshDataOnLoad = FALSE;
    }
    else {
        if (needsUpdate == TRUE) {
            [self fetchAndStoreEventsWithSelectedCategories:^(NSError *error){
                if (error) {
                    //                  [self displayAlertWithMsg:[error localizedDescription]];
                }
                else{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LASTEVENTSFETCHED" object:@[[NSNumber numberWithLong:0.0],[NSDate date]]];
                }
            }];
        }
    }

    /*
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never;
    }
     */
    
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
        else {
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

-(void)refreshListMode:(NSInteger)mode{
    if ([self.selectedEventsArry count]>0) {
        //Set new predicate
        NSMutableArray *predArry = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *dict in self.selectedEventsArry) {
            NSString *calID = [dict objectForKey:@"calendarID"];
            NSPredicate *calendarIDPred = [NSPredicate predicateWithFormat:@"calendar.calendarid == %@",calID];
            NSMutableArray *subPredicatesArry =[NSMutableArray arrayWithCapacity:0];
            for (NSString *str in [dict objectForKey:@"categories"]) {
                NSPredicate *p = [NSPredicate predicateWithFormat:@"category.categoryGUID == %@",str];
                [subPredicatesArry addObject:p];
            }
            NSCompoundPredicate *categoriesPred = [NSCompoundPredicate orPredicateWithSubpredicates:subPredicatesArry];
            NSCompoundPredicate *pred = [NSCompoundPredicate andPredicateWithSubpredicates:@[calendarIDPred, categoriesPred]];
            [predArry addObject:pred];
        }
        self.selectionPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predArry];
    }
    else{
        self.selectionPredicate = [NSCompoundPredicate notPredicateWithSubpredicate:[NSPredicate predicateWithValue:TRUE]];
    }
    if (mode == 0) {
        [NSFetchedResultsController deleteCacheWithName:@"eventsTableView"];
    }
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    YBEvents *lastObj = (YBEvents *)[[self.fetchedResultsController fetchedObjects] lastObject];
    long currentYr = (lastObj)?[[[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[lastObj eventDate]] year]:0;
    if (!(self.currentSelectedYear)) {
        if (currentYr >0) {
            self.currentSelectedYear = currentYr;
            self.originalSelectedYear = currentYr;
        }
    }
    __weak YBEventsTableViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (mode == 0) {
            [weakSelf.tableView reloadData];
        }
        [weakSelf scrollTableViewToEventItemForToday];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ([[self.fetchedResultsController fetchedObjects] count]>0)?[[self.fetchedResultsController fetchedObjects] count]+1:0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath *indexPathForLoadMoreCell = [NSIndexPath indexPathForRow:[[self.fetchedResultsController fetchedObjects] count] inSection:0];
    if ([indexPath isEqual:indexPathForLoadMoreCell]) {
        return 44.f;
    }
    else
        return 80.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *iden = ([indexPath isEqual:[NSIndexPath indexPathForRow:[[self.fetchedResultsController fetchedObjects] count] inSection:0]])?@"loadMoreTableViewCell":@"eventstableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(void)updateSelectedCalendars:(NSMutableArray *)selectedCalendarAndCategories andMode:(NSInteger)mode{
    self.selectedEventsArry = nil;
    self.selectedEventsArry = [selectedCalendarAndCategories mutableCopy];
    [self refreshListMode:0];
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath *indexPathForLoadMoreCell = [NSIndexPath indexPathForRow:[[self.fetchedResultsController fetchedObjects] count] inSection:0];
    if ([indexPath isEqual:indexPathForLoadMoreCell]) {
        [(YBLoadMoreTableViewCell *)cell configureCellWithYear:[NSString stringWithFormat:@"%ld",self.currentSelectedYear+1]];
        [(YBLoadMoreTableViewCell *)cell setDelegate:self];
    }else{
        YBEvents *event = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.row];
        [(YBEventTableViewCell *)cell configureCellWithEvent:event];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath *indexPathForLoadMoreCell = [NSIndexPath indexPathWithIndex:[[self.fetchedResultsController fetchedObjects] count]+1];
    if ([indexPath isEqual:indexPathForLoadMoreCell]) {
        //Load More request for next year
    }
    else{
        YBEventDetailsTableViewController *detailVC = (YBEventDetailsTableViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"YBEventDetailsTableViewContID"];
        detailVC.selectedEvent = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.rootControl.navigationController pushViewController:detailVC animated:YES];
        
    }
}

#pragma mark -

-(void)loadMoreButtonTapped:(id)sender{
    self.currentSelectedYear++;
    [self fetchAndStoreEventsWithSelectedCategories:^(NSError *error){
        if (error) {
            [self displayAlertWithMsg:[error localizedDescription]];
            self.currentSelectedYear--;
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LASTEVENTSFETCHED" object:@[[NSNumber numberWithLong:0.0],[NSDate date]]];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self scrollTableViewToEventItemForToday];
}

-(void)scrollTableViewToEventItemForToday{
    NSArray *tempArry = [self.fetchedResultsController fetchedObjects];
    if(self.originalSelectedYear == self.currentSelectedYear){
        NSArray *filterArry = [tempArry filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.starttime >= %@",[NSDate dateWithTimeIntervalSinceNow:0]]];
        if ([filterArry count]>0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[tempArry indexOfObject:[filterArry objectAtIndex:0]] inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:TRUE];
        }
    }
}

@end
