//
//  YBCalendarCategoryAPI.m
//  Yearbook
//
//  Created by Urmil Setia on 24/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBCalendarCategoryAPI.h"

@interface YBCalendarCategoryAPI ()
@property(nonatomic, strong) NSString *calendarYear;
@property(nonatomic, strong) NSString *calendarid;
@end

@implementation YBCalendarCategoryAPI
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
        self.calendarYear = theYear;
        self.calendarid = theCalID;
        theaccessToken = [NSString stringWithFormat:@"Bearer %@",theToken];
    }
    return self;
}

- (NSString *) URLEncodedString:(NSString *)str {
    NSMutableString * output = [NSMutableString string];
    const char * source = [str UTF8String];
    int sourceLen = strlen(source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = (const unsigned char)source[i];
        if (false && thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

/**
 Specific Request URLpath only.
 
 @return URL path to be added to the base URL.
 */
- (NSString *)requestUrl {
    NSString *str = [self URLEncodedString:[NSString stringWithFormat:@"{\"year\":\"%@\",\"CalendarId\":%@}",self.calendarYear, self.calendarid]];
    //return [NSString stringWithFormat:@"%@%@&TokenValue=ODZjZWUxMGItY2MxOC00MTE5LTlkYzEtZWEyOWFmYjUwMTc1",@"/petcareservice/api/Events/GetEventGroup?Id=",str];
    return [NSString stringWithFormat:@"%@%@",@"/CalendarAPI/api/Events/GetEventGroup?Id=",str];

}

- (NSDictionary *)requestHeaderFieldValueDictionary {
    NSDictionary *dict = @{@"Authorization": theaccessToken,@"Content-Type":@"application/json"};
    return dict;
}

//-(id) requestArgument{
//    return @"ID";
//}


//-(id)responseJSONObject{
//    NSLog(@"Response: %@",self.responseJSONObject);
//    return self.responseJSONObject;
//}

//- (void)requestCompletePreprocessor{
//    NSLog(@"Request completed");
//    //Load to the store.
//}

@end
