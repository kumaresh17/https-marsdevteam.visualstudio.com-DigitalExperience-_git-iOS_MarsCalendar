//
//  YBCalendarUpdatesTableViewController.m
//  Yearbook
//
//  Created by Urmil Setia on 06/01/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//

#import "YBCalendarUpdatesTableViewController.h"
#import "YBCalUpdatesTableViewCell.h"
#import "YBCalendarUpdates+CoreDataClass.h"
#import "YBCalendars+CoreDataClass.h"
#import "AppDelegate.h"
#import "YBCalendarUpdatesStore.h"
#import <ADAL/ADAL.h>
#import "YBConstants.h"
#define kCalendarNameLabelHeight 21
#define kSpacerHeight 20

@interface YBCalendarUpdatesTableViewController ()

@end

@implementation YBCalendarUpdatesTableViewController
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
                                   entityForName:@"YBCalendarUpdates" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"calendar.calendarname" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:_managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.title = @"Change Logs";
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.estimatedRowHeight = 44.0;
    //    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"YBCalUpdatesTableViewCell" bundle:nil] forCellReuseIdentifier:@"calendarUpdates"];
    [self refreshData];
    [self fetchAndStoreCalenderUpdate];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBtnPressed:)];
    self.navigationItem.rightBarButtonItem = doneBtn;
}
-(void)fetchAndStoreCalenderUpdate
{
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
            
            YBCalendarUpdatesStore *calUpdate = [YBCalendarUpdatesStore sharedInstance];
            [calUpdate fetchAndStoreCalendarUpdatesWithToken:result.accessToken  AndCompletionHandler:^(NSError *error) {
                
            }];
            
        }
    }];
}

-(void)doneBtnPressed:(id)sender {
    [self performSegueWithIdentifier:@"dismissUpdateView" sender:self];
}

-(void)refreshData{
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    if (!error) {
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self getLabelHeightWithText:[(YBCalendarUpdates *)[self.fetchedResultsController objectAtIndexPath:indexPath] updateContent]].size.height + kCalendarNameLabelHeight + kSpacerHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.fetchedResultsController fetchedObjects] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"calendarUpdates" forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    YBCalendarUpdates *update = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [(YBCalUpdatesTableViewCell *)cell configureCellWithCalendarName:[(YBCalendars *)[update calendar] calendarname] andContent:[update updateContent]];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Fetched Controller Delegate

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
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

#pragma mark - DZNEmptyDataSetSource Methods

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    text = [NSString stringWithFormat:@"%@ Updates", kAppName];
    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    text = [NSString stringWithFormat:@"Find updates about changes to the %@", kAppName];
    paragraph.lineSpacing = 2.0;
    if (!text) {
        return nil;
    }
    
    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    if (paragraph) [attributes setObject:paragraph forKey:NSParagraphStyleAttributeName];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    return attributedString;
}

//- (nullable NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state{
//    NSString *text = nil;
//    UIFont *font = nil;
//    UIColor *textColor = [UIColor colorWithRed:21.f/255.f green:52.f/255.f blue:83.f/255.f alpha:1.0];
//    
//    NSMutableDictionary *attributes = [NSMutableDictionary new];
//    text = @"Check for Updates";
//    if (font) [attributes setObject:font forKey:NSFontAttributeName];
//    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
//    
//    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
//}
//
//- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button
//{
//    //Re-fetch Data
//}

- (CGRect)getLabelHeightWithText:(NSString *)content
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat tempwidth = self.view.frame.size.width -40;
    NSMutableArray *array=[[NSMutableArray alloc]initWithObjects: content,nil];
    CGRect newLabelsize = [[array objectAtIndex:0] boundingRectWithSize:CGSizeMake(tempwidth, MAXFLOAT)  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],NSParagraphStyleAttributeName:paragraphStyle} context:nil];
    
//    NSLog(@"New Label Size Width  : %f",newLabelsize.size.width);
//    NSLog(@"New Label Size Height : %f",newLabelsize.size.height);
    
    return newLabelsize;
}

@end
