//
//  YBCalendarsStore.h
//  Yearbook
//
//  Created by Urmil Setia on 24/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YBStore.h"

@interface YBCalendarsStore : YBStore
{
    NSString *theaccessToken;
}
/**
 Fetch data from web services and store in the Core Data
 for get Calendars API

 @param completionHandler completionHandler to be sent back to the caller
 */
-(void)fetchAndStoreCalendarsToken:(NSString*)token AndCompletionHandler:(void (^)(NSError *error))completionHandler;
@end
