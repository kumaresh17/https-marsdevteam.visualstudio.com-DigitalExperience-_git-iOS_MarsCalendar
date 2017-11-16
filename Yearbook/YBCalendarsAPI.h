//
//  YBCalendars.h
//  Yearbook
//
//  Created by Urmil Setia on 23/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import <YTKNetwork/YTKNetwork.h>

@interface YBCalendarsAPI : YTKRequest
/**
 Init API call

 @param theEmail The user's Email Address, not being used right now.
 @param theCalID the Calendar ID, not being used right now.
 @return ID Self.
 */
-(id)initWithToken:(NSString*)theToken WithEmail:(NSString *)theEmail andCalendarID:(NSString *)theCalID;
@end
