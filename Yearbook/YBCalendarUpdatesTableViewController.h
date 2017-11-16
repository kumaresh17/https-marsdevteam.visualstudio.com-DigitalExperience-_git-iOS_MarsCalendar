//
//  YBCalendarUpdatesTableViewController.h
//  Yearbook
//
//  Created by Urmil Setia on 06/01/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DZNEmptyDataSet/UIScrollView+EmptyDataSet.h"
@import CoreData;
@interface YBCalendarUpdatesTableViewController : UITableViewController <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate,NSFetchedResultsControllerDelegate>
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@end
