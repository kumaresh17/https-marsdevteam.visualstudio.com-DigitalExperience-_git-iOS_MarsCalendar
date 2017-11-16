//
//  YBCalendarUpdatesAPI.h
//  Yearbook
//
//  Created by Urmil Setia on 06/01/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//

#import <YTKNetwork/YTKNetwork.h>

@interface YBCalendarUpdatesAPI : YTKRequest<YTKBatchRequestDelegate>

/**
 Init with Calendar ID and Name to ensure mapping
 
 @param theCalID Calendar ID
 @param theCalName Calendar Name
 @return instance
 */
-(id)initWithToken:(NSString*)theToken WithCalendarID:(NSString *)theCalID andCalendarName:(NSString *)theCalName;
-(NSString *)calendarid;
@end
