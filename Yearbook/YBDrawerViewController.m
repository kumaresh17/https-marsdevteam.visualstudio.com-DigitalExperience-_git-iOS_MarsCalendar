//
//  YBDrawerViewController.m
//  Yearbook
//
//  Created by Urmil Setia on 03/01/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//

#import "YBDrawerViewController.h"
#import "YBEventTableViewCell.h"
#import "YBEventDetailsTableViewController.h"

#define kTopViewHeight 40
#define kBottomSpacerHeight 15

@interface YBDrawerViewController ()
@property (weak, nonatomic) IBOutlet ISHPullUpHandleView *theHandleView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UITableView *eventsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@end

@implementation YBDrawerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *gest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeDrawerPosition:)];
    [self.topView addGestureRecognizer:gest];
    [self.eventsTableView registerNib:[UINib nibWithNibName:@"YBEventTableViewCell" bundle:nil] forCellReuseIdentifier:@"eventstableViewCell"];
    self.eventsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)closeDrawer{
    [self.eventsTableView reloadData];
    [self.pullUpHandleViewController setState:ISHPullUpStateCollapsed animated:YES];
}

-(void)openDrawerFull{
    [self.eventsTableView reloadData];
    [self.pullUpHandleViewController setState:ISHPullUpStateExpanded animated:YES];
}

-(void)openDrawerHalf{
    [self.eventsTableView reloadData];
    [self.pullUpHandleViewController setState:ISHPullUpStateExpanded animated:YES];
    [self.pullUpHandleViewController setBottomHeight:hei/2 animated:YES];
}

-(void)changeDrawerPosition:(UIGestureRecognizer*)gestureRecognizer{
    [self.pullUpHandleViewController toggleStateAnimated:YES];
}

- (void)pullUpViewController:(ISHPullUpViewController *)pullUpViewController didChangeToState:(ISHPullUpState)state{
    [self.theHandleView setState:[ISHPullUpHandleView handleStateForPullUpState:state] animated:YES];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - EventsTableViewDelegates

-(void) reloadTableData{
    [self.eventsTableView reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YBEventTableViewCell *cell = (YBEventTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"eventstableViewCell"];
    [cell configureCellWithEvent:[self.eventsArryForSelectedDate objectAtIndex:indexPath.row]];
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.eventsArryForSelectedDate count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self closeDrawer];
    YBEventDetailsTableViewController *detailVC = (YBEventDetailsTableViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"YBEventDetailsTableViewContID"];
    detailVC.selectedEvent = [self.eventsArryForSelectedDate objectAtIndex:indexPath.row];
    [self.rootControl.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - ISHPullUpSizingDelegate

- (CGFloat)pullUpViewController:(ISHPullUpViewController *)pullUpViewController minimumHeightForBottomViewController:(UIViewController *)bottomVC{
    return 40.f;
}
CGFloat hei;

- (CGFloat)pullUpViewController:(ISHPullUpViewController *)pullUpViewController maximumHeightForBottomViewController:(UIViewController *)bottomVC maximumAvailableHeight:(CGFloat)maximumAvailableHeight{
    UIWindow *window = [[UIApplication sharedApplication] windows][0];
    hei = window.frame.size.height/2;
    return hei;
}

- (CGFloat)pullUpViewController:(ISHPullUpViewController *)pullUpViewController targetHeightForBottomViewController:(UIViewController *)bottomVC fromCurrentHeight:(CGFloat)height{
    if(fabs(height-(hei)) < 30.0){
        return hei;
    }
    else if(fabs(height-(hei/2)) < 30.0){
        return hei/2;
    }
    return height;
}

- (void)pullUpViewController:(ISHPullUpViewController *)pullUpViewController updateEdgeInsets:(UIEdgeInsets)edgeInsets forBottomViewController:(UIViewController *)contentVC{
    [self.tableViewHeightConstraint setConstant:(pullUpViewController.bottomHeight-kTopViewHeight-kBottomSpacerHeight) < 0 ? 0:pullUpViewController.bottomHeight-kTopViewHeight-kBottomSpacerHeight];
    [self.eventsTableView setNeedsUpdateConstraints];
}

@end
