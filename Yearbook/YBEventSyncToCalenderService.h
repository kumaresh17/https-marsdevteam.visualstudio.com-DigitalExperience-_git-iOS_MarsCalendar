//
//  YBEventSyncToCalenderService.h
//  Yearbook
//
//  Created by TechMadmin on 11/07/17.
//  Copyright © 2017 Mars IS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "YBEvents+CoreDataClass.h"
#import "NSDate+timezones.h"

typedef void(^CalendarRequestAccessCompletionHandler)(BOOL granted);
@interface YBEventSyncToCalenderService : NSObject

@property(nonatomic,assign) BOOL canModifyCalendar;
+ (id)sharedSyncService;
-(void)requestPermissionForCalenderAccess:(CalendarRequestAccessCompletionHandler)completionHandler;

-(void)createEventFor:(YBEvents*)eventFromApp ifUpdate:(BOOL)isUpdate;
-(BOOL)removeAllThisYearEvent;
-(BOOL)isAuthorizedToModifyCalender;
-(void)commitChanges;
@end
