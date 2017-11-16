//
//  YBEventsTableViewController.h
//  Yearbook
//
//  Created by Urmil Setia on 28/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YBMainScreenViewController.h"
#import "YBLoadMoreTableViewCell.h"

@interface YBEventsTableViewController : UITableViewController<YBSelectedCalendarUpdate, UITableViewDataSource, UITableViewDelegate,NSFetchedResultsControllerDelegate,YBLoadMoreButton>
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, weak) YBMainScreenViewController *rootControl;
@end
