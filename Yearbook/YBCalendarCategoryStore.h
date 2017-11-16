//
//  YBCalendarCategoryStore.h
//  Yearbook
//
//  Created by Urmil Setia on 24/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBStore.h"

@interface YBCalendarCategoryStore : YBStore

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
-(void)fetchAndStoreCalendarCategoryWithCalendars:(NSMutableArray *)theCalendars token:(NSString*)token andCompletionHandler:(void (^)(NSError *))completionHandler;

@end
