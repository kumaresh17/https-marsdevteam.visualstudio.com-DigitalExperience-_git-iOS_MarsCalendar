//
//  YBCalendarCategoryAPI.h
//  Yearbook
//
//  Created by Urmil Setia on 24/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import <YTKNetwork/YTKNetwork.h>

@interface YBCalendarCategoryAPI : YTKRequest<YTKBatchRequestDelegate>
/**
 Init API call
 
 @param theYear The user's Email Address, not being used right now.
 @param theCalID the Calendar ID, not being used right now.
 @return ID Self.
 */
-(id)initWithToken:(NSString*)theToken WithYear:(NSString *)theYear andCalendarID:(NSString *)theCalID;
-(NSString *)calendarid;
@end
