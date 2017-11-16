//
//  YBEventDetailsTableViewController.m
//  Yearbook
//
//  Created by Urmil Setia on 06/01/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//

#import "YBEventDetailsTableViewController.h"
#import "YBEventDtCateTableViewCell.h"
#import "YBEventDtCalTableViewCell.h"
#import "YBCalendars+CoreDataClass.h"
#import "YBCalendarCategory+CoreDataClass.h"
#import "YBEventDetailsTableViewCell.h"
@import EventKit;
#import "NSDate+timezones.h"
#import "YBCalUpdatesTableViewCell.h"

#define kCalendarNameLabelHeight 21
#define kSpacerHeight 20
#define kEventDetailSpacer_Time_Height 67.f

@interface YBEventDetailsTableViewController ()
@property(nonatomic, strong) EKEventStore *calendarStore;
@end

@implementation YBEventDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    UIBarButtonItem *addToCalendar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(addToCalendarAction:)];
    self.navigationItem.rightBarButtonItem = addToCalendar;
    self.navigationItem.title = @"Event Details";
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.tableView registerNib:[UINib nibWithNibName:@"YBEventDtCateTableViewCell" bundle:nil] forCellReuseIdentifier:@"detailCategorycell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YBEventDtCalTableViewCell" bundle:nil] forCellReuseIdentifier:@"detailCalendarcell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YBEventDetailsTableViewCell" bundle:nil] forCellReuseIdentifier:@"eventDetailcell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YBCalUpdatesTableViewCell" bundle:nil] forCellReuseIdentifier:@"calendarUpdates"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Add to Calendar

-(void)addToCalendarAction:(id)sender{
//    NSLog(@"Add to Calendar Button");
    if (!self.calendarStore) {
        self.calendarStore = [EKEventStore new];
    }
    [self.calendarStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) { return; }
        EKEvent *event = [EKEvent eventWithEventStore:self.calendarStore];
        event.title = self.selectedEvent.title;
        event.timeZone = [NSTimeZone systemTimeZone];
        event.startDate = [[self.selectedEvent starttime] dateToTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        event.endDate = [[self.selectedEvent endtime] dateToTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        event.notes = self.selectedEvent.eventdescription;
        EKEventEditViewController *editController = [[EKEventEditViewController alloc] init];
        
        editController.event = event;
        editController.eventStore = self.calendarStore;
        editController.editViewDelegate = self;
        
        [self.navigationController presentViewController:editController animated:YES completion:nil];
    }];
}

#pragma mark - EKEventUIKit

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction: (EKEventEditViewAction)action
{
    EKEvent *theEvent = controller.event;
    [self.navigationController dismissViewControllerAnimated:NO completion:^
     {
         switch (action)
         {
             case EKEventEditViewActionCanceled:
                 break;
             case EKEventEditViewActionSaved:{
                 [self.calendarStore saveEvent:theEvent span:EKSpanThisEvent error:nil];
                 break;}
             case EKEventEditViewActionDeleted:
                 break;
             default:
                 break;
         }
     }];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:{
            return [self getLabelHeightWithText:[self.selectedEvent title]].size.height + kEventDetailSpacer_Time_Height;
            break;
        }
        case 3:{
            return [self getLabelHeightWithText:[self.selectedEvent eventdescription]].size.height + kCalendarNameLabelHeight + kSpacerHeight;
            break;
        }
        default:
            return 44.f;
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier;
    switch (indexPath.row) {
        case 0:
            identifier = @"eventDetailcell";
            break;
        case 1:
            identifier = @"detailCalendarcell";
            break;
        case 2:
            identifier = @"detailCategorycell";
            break;
        case 3:
            identifier = @"calendarUpdates";
            break;
        default:
            break;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCellWithCell:cell atIndexPath:indexPath];
    return cell;
}

-(void)configureCellWithCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            [(YBEventDetailsTableViewCell *)cell configureCellWithEvent:self.selectedEvent];
            break;
        case 1:
            [(YBEventDtCalTableViewCell *)cell configureCellWithName:[(YBCalendars *)[self.selectedEvent calendar] calendarname]];
            break;
        case 2:
            [(YBEventDtCateTableViewCell *)cell configureCellWithName:[(YBCalendarCategory *)[self.selectedEvent category] categoryName] andColor:[(YBCalendarCategory *)[self.selectedEvent category] categoryColor]];
            break;
        case 3:
            [(YBCalUpdatesTableViewCell *)cell configureCellWithCalendarName:@"Event Notes" andContent:[self.selectedEvent eventdescription]];
            break;
        default:
            break;
    }
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

#pragma mark - Utility Functions

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
