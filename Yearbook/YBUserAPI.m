//
//  YBUserAPI.m
//  Yearbook
//
//  Created by Urmil Setia on 07/12/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBUserAPI.h"

@interface YBUserAPI ()
@property(strong, nonatomic) NSString *strTobeRenamed;
@end

@implementation YBUserAPI
{
    NSString *theaccessToken;
}
/**
 Init API call
 
 @param theYear The user's Email Address, not being used right now.
 @param theCalID the Calendar ID, not being used right now.
 @return ID Self.
 */
-(id)initWithToken:(NSString*)theToken WithYear:(NSString *)theYear andCalendarID:(NSString *)theCalID{
    self = [super init];
    if (self) {
        self.strTobeRenamed = theYear;
        theaccessToken = [NSString stringWithFormat:@"Bearer %@",theToken];
//        self.calendarid = theCalID;
    }
    return self;
}

/**
 Specific Request URLpath only.
 
 @return URL path to be added to the base URL.
 */
- (NSString *)requestUrl {
//    NSString *str = [self URLEncodedString:[NSString stringWithFormat:@"{\"year\":\"%@\",\"CalendarId\":%@}",self.calendarYear, self.calendarid]];
//    https://graph.microsoft.com/
    https://graph.windows.net/myorganization/users/garthf%40a830edad9050849NDA1.onmicrosoft.com?api-version=1.6
    return [NSString stringWithFormat:@"/myorganization/users/urmil.x.setia@effem.com?api-version=1.6"];
}

-(BOOL)useCDN{
    return true;
}

- (NSDictionary *)requestHeaderFieldValueDictionary {
    NSDictionary *dict = @{@"Authorization": theaccessToken,@"Content-Type":@"application/json"};
    return dict;
}
@end
