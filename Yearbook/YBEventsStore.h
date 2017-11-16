//
//  YBEventsStore.h
//  Yearbook
//
//  Created by Urmil Setia on 28/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBStore.h"
#import "YBConstants.h"
@interface YBEventsStore : YBStore
/**
 Shared Instance of YBCalendarCategory to do batch processing
 
 @return Shared Instance
 */
+ (instancetype)sharedInstance;

/**
 Fetch data from web services and store in the Core Data
 for get Calendars API
 
 @param completionHandler completionHandler to be sent back to the caller
 */
-(void)fetchAndStoreEventsWithCalendarsAndCategories:(NSMutableArray *)arryOfCalanderCategories forYear:(long)calendarYear token:(NSString*)token andCompletionHandler:(void (^)(NSError *error))completionHandler;
@end
