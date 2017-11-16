//
//  YBEventSyncToCalenderService.m
//  Yearbook
//
//  Created by TechMadmin on 11/07/17.
//  Copyright © 2017 Mars IS. All rights reserved.
//
#import "YBEventSyncToCalenderService.h"
#import <UIKit/UIKit.h>
static NSString *CalendarName = @"Mars Calendar";
static NSString *CalanderID = @"com.Yearbook.YBEvents";
static EKEventStore *eventStore;
static EKCalendar *marsCalendar;

@implementation YBEventSyncToCalenderService

+ (id)sharedSyncService {
    static YBEventSyncToCalenderService *sharedContext = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedContext = [[self alloc] init];
        eventStore = [[EKEventStore alloc] init];
        NSLog(@"Mars eventStore is allocated-------------");
    });
    return sharedContext;
}
// Request access to Calendar
-(void)requestPermissionForCalenderAccess:(CalendarRequestAccessCompletionHandler)completionHandler{
    if([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
            if(completionHandler != nil){
                completionHandler(granted);
            }
        }];
    }
}

-(BOOL)isAuthorizedToModifyCalender{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:
                                    EKEntityTypeEvent];
    if(status == EKAuthorizationStatusAuthorized){
        return YES;
    }
    return NO;
}
//Create event
-(void)createEventFor:(YBEvents*)eventFromApp ifUpdate:(BOOL)isUpdate{
    if(![self isAuthorizedToModifyCalender]){
        return;
    }
    if([self checkIfEventExistFromApp:eventFromApp]){
        NSLog(@"checkIfEventExistFromApp -------exists");
        return;
    }
    
    EKEvent *event;
    event = [EKEvent eventWithEventStore:eventStore];
    
    event.title = eventFromApp.title;
    event.timeZone = [NSTimeZone systemTimeZone];
    event.startDate = [[eventFromApp starttime] dateToTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    event.endDate = [[eventFromApp endtime] dateToTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    event.notes = eventFromApp.eventdescription;
    EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:-60.0*15.0];
    event.alarms = [NSArray arrayWithObject:alarm];
    event.calendar = marsCalendar;
    
    NSError *err;
    [eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
    NSLog(@"Cal ID %@--- err ----------%@-ID-- %@-Title %@--EventDate :%@", marsCalendar.calendarIdentifier,err, eventFromApp.eventID,eventFromApp.title,event.startDate);
}

-(BOOL)removeAllThisYearEvent
{
    // Remove event only if app is authorized to do same
    if(![self isAuthorizedToModifyCalender]){
        return NO;
    }
    if([self getMarsCalender]){
        
        NSDate *startDate = [NSDate dateWithTimeInterval:-24*60*60*365 sinceDate:[NSDate date]];
        NSDate *endDate = [NSDate dateWithTimeInterval:24*60*60*365 sinceDate:[NSDate date]];
        NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:[NSArray arrayWithObject:marsCalendar]];
        NSArray *events = [eventStore eventsMatchingPredicate:predicate];
        if(events.count >0){
            for(EKEvent *event in events){
                NSError *error1;
                
                [eventStore removeEvent:event span:EKSpanThisEvent error:&error1];
                NSLog(@"Removing ----------------------- %@ ---%@",error1, marsCalendar.calendarIdentifier);
            }
        }
    }
    /*for (EKSource* source in eventStore.sources){
     for (EKCalendar *cal in source.calendars)     {
     NSLog(@"removeAllThisYearEvent-Calendar-Title---------%@",cal.title);
     if([cal.title containsString:@"Mars Calendar"]){
     [eventStore removeCalendar:cal commit:YES error:&error1];
     NSLog(@"removeAllThisYearEvent--Error--------- %@",error1);
     }
     }
     }
     */
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:CalanderID];
    NSLog(@"removeAllThisYearEvent--Removed calendar---------------");
    if(marsCalendar == nil){
        [self performSelector:@selector(createMarsCalendar) onThread:[NSThread currentThread] withObject:nil waitUntilDone:YES];
    }
    return YES;
}

-(BOOL)checkIfEventExistFromApp:(YBEvents*)eventFromApp{
    BOOL eventExists = NO;
    NSDate *startDate = [[eventFromApp starttime] dateToTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *endDate = [[eventFromApp endtime] dateToTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:[NSArray arrayWithObject:marsCalendar]];
    NSArray *events = [eventStore eventsMatchingPredicate:predicate];
    for(EKEvent *event in events){
        if([event.title isEqualToString:eventFromApp.title]){
            eventExists = YES;
            break;
        }
    }
    return eventExists;
}

- (EKCalendar*) getMarsCalender{
    marsCalendar = nil;
    for (EKSource* source in eventStore.sources){
        for (EKCalendar *cal in source.calendars)
        {
            if([cal.title containsString:@"Mars Calendar"]){
                NSLog(@"get Mars Calendar ---%@",cal.source.title);
                marsCalendar = cal;
            }
        }
    }
    return marsCalendar;
}

// Create calendar
-(void)createMarsCalendar{
    EKSource* marsLocalSource = nil;
    EKSource* localSource = nil;
    EKSource* iCloudSource = nil;
    EKSource* exchangeSource = nil;
    EKSource* mobileMeSource = nil;
    EKSource* subscribeSource = nil;
    
    for (EKSource* source in eventStore.sources){
        if (source.sourceType == EKSourceTypeLocal){
            localSource = source;
        }else if(source.sourceType == EKSourceTypeCalDAV && [source.title isEqualToString:@"iCloud"]){
            iCloudSource = source;
        }else if(source.sourceType == EKSourceTypeExchange){
            exchangeSource = source;
        }else if(source.sourceType == EKSourceTypeMobileMe){
            mobileMeSource = source;
        }else{
            subscribeSource = source;
        }
    }
    
    if (iCloudSource) {
        NSLog(@"Mars Source is %ld-------------",(long)iCloudSource.sourceType);
        marsLocalSource = iCloudSource;
    }else if(exchangeSource != nil && [exchangeSource.calendars count] != 0){
        NSLog(@"Mars Source is exchangeSource-------------");
        marsLocalSource = exchangeSource;
    }else if(localSource != nil){
        NSLog(@"Mars Source is local-------------");
        marsLocalSource = localSource;
    }else if(subscribeSource != nil  && [subscribeSource.calendars count] != 0){
        NSLog(@"Mars Source is subscribeSource-------------");
        marsLocalSource = subscribeSource;
    }else if(mobileMeSource != nil && [mobileMeSource.calendars count] != 0){
        NSLog(@"Mars Source is subscribeSource-------------");
        marsLocalSource = mobileMeSource;
    }else{
        NSLog(@"Mars Source is nil-------------");
    }
    marsCalendar = nil;
    [self saveEventCalendarWithSource:marsLocalSource];
}

- (void) saveEventCalendarWithSource:(EKSource *)source {
    marsCalendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:eventStore];
    
    marsCalendar.title = CalendarName;
    marsCalendar.source = source;
    
    NSString *calendarIdentifier = marsCalendar.calendarIdentifier;
    
    NSError *error = nil;
    [eventStore saveCalendar:marsCalendar commit:YES error:&error];
    
    if (!error) {
        NSLog(@"saveEventCalendarWithSource ---- created, saved, and commited my calendar with id %@", marsCalendar.calendarIdentifier);
        
        [[NSUserDefaults standardUserDefaults] setObject:calendarIdentifier forKey:CalanderID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } else {
        NSLog(@"an error occured when creating the calendar = %@", error.description);
        error = nil;
    }
}

-(void)commitChanges{
    [eventStore commit:nil];
}

@end
