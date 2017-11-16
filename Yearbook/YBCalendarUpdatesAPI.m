//
//  YBCalendarUpdatesAPI.m
//  Yearbook
//
//  Created by Urmil Setia on 06/01/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//

#import "YBCalendarUpdatesAPI.h"

@interface YBCalendarUpdatesAPI ()
@property(nonatomic, strong) NSString *calendarid;
@property(nonatomic, strong) NSString *calendarName;
@end

@implementation YBCalendarUpdatesAPI
{
    NSString *theaccessToken;
}
/**
 Init with Calendar ID and Name to ensure mapping
 
 @param theCalID Calendar ID
 @param theCalName Calendar Name
 @return instance
 */
-(id)initWithToken:(NSString*)theToken WithCalendarID:(NSString *)theCalID andCalendarName:(NSString *)theCalName{
    self = [super init];
    if (self) {
        self.calendarName = theCalName;
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
//    NSString *str = [self URLEncodedString:[NSString stringWithFormat:@"{\"year\":\"%@\",\"CalendarId\":%@}",self.calendarYear, self.calendarid]];
   // return [NSString stringWithFormat:@"%@%@&TokenValue=ODZjZWUxMGItY2MxOC00MTE5LTlkYzEtZWEyOWFmYjUwMTc1",@"/petcareservice/api/Utility/GetUpdateContents/",self.calendarid];
    
    
    // return [NSString stringWithFormat:@"%@%@",@"/petcareservice/api/Utility/GetUpdateContents/",self.calendarid];
    
    return [NSString stringWithFormat:@"%@%@",@"/CalendarAPI/api/Utility/GetUpdateContents/",self.calendarid];
    
    
    
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
