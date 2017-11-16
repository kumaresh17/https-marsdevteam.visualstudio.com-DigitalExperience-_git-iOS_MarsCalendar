//
//  YBEventsAPI.h
//  Yearbook
//
//  Created by Urmil Setia on 27/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import <YTKNetwork/YTKNetwork.h>

@interface YBEventsAPI : YTKRequest
-(id)initWithToken:(NSString*)theToken WithYear:(NSString *)CalendarYear withCalendarId:(NSString *)calendarID forCategories:(NSArray *)CalendarCategories;
-(NSString *)calendarid;
-(NSString *)calendarYear;
-(NSArray *)calendarCategoriesArry;
@end
