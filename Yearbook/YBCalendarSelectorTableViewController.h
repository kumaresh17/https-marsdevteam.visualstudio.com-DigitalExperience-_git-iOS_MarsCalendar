//
//  YBCalendarSelectorTableViewController.h
//  Yearbook
//
//  Created by Urmil Setia on 25/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreData;

@protocol YBCalendarSelectorUpdateEvents;

@interface YBCalendarSelectorTableViewController : UITableViewController <NSFetchedResultsControllerDelegate,UITableViewDataSource, UITableViewDelegate>
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) id<YBCalendarSelectorUpdateEvents> delegate;
-(void)reloadSelectedCalendarAndCategories:(NSMutableArray *)arrySelectedCalsAndCats;
@end

@protocol YBCalendarSelectorUpdateEvents <NSObject>

-(void)CalendarAndSelectedCategories:(NSMutableArray *)calCategoryies completion:(void(^)(void))callback;

@end
