//
//  YBProfileStore.h
//  Yearbook
//
//  Created by Urmil Setia on 18/12/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBStore.h"

@interface YBProfileStore : YBStore
/**
 Fetch data from web services and store in the Core Data
 for get Calendars API
 
 @param completionHandler completionHandler to be sent back to the caller
 */
-(void)fetchAndStoreUserWithToken:(NSString *)token AndCompletion:(void (^)(NSString *imageURL, NSError *error))completionHandler;
@end
