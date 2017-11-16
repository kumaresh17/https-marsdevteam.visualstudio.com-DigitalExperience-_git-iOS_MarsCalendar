//
//  YBCalendarUpdatesStore.h
//  Yearbook
//
//  Created by Urmil Setia on 06/01/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//

#import "YBStore.h"

@interface YBCalendarUpdatesStore : YBStore
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
-(void)fetchAndStoreCalendarUpdatesWithToken:(NSString*)token AndCompletionHandler:(void (^)(NSError *))completionHandler;
@end
