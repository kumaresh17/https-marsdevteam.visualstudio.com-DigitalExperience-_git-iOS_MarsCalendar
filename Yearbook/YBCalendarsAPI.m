//
//  YBCalendars.m
//  Yearbook
//
//  Created by Urmil Setia on 23/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBCalendarsAPI.h"
#import "YBConstants.h"
@implementation YBCalendarsAPI
{
    NSString *theaccessToken;
}
/**
 Init API call
 
 @param theEmail The user's Email Address, not being used right now.
 @param theCalID the Calendar ID, not being used right now.
 @return ID Self.
 */
-(id)initWithToken:(NSString*)theToken WithEmail:(NSString *)theEmail andCalendarID:(NSString *)theCalID{
    self = [super init];
    if (self) {
        theaccessToken = [NSString stringWithFormat:@"Bearer %@",theToken];
    }
    return self;
}

/**
 Specific Request URLpath only.

 @return URL path to be added to the base URL.
 */
- (NSString *)requestUrl {

   // return @"/petcareservice/api/Events/GetCalendars?ID=0&TokenValue=ODZjZWUxMGItY2MxOC00MTE5LTlkYzEtZWEyOWFmYjUwMTc1";

    return @"/CalendarAPI/api/Events/GetCalendars?ID=0";

    
}

- (NSDictionary *)requestHeaderFieldValueDictionary {
    NSDictionary *dict = @{@"Authorization": theaccessToken,@"Content-Type":@"application/json"};
    return dict;
}

//- (NSDictionary *)requestHeaderFieldValueDictionary{
//    return @{@"Content-Type": @"application/json; charset=utf-8"};
//}

//-(id) requestArgument{
//    return @"ID";
//}

//-(id)responseJSONObject{
//    NSLog(@"Response: %@",self.responseJSONObject);
//    return self.responseJSONObject;
//}
//
//- (void)requestCompletePreprocessor{
//    NSLog(@"Request completed");
//}

@end
