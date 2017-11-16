//
//  YBEventsAPI.m
//  Yearbook
//
//  Created by Urmil Setia on 27/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBEventsAPI.h"

@interface YBEventsAPI ()
@property(nonatomic, strong) NSString *calendarYear;
@property(nonatomic, strong) NSArray *calendarCategoriesArry;
@property(nonatomic, strong) NSString *calendarid;

@end

@implementation YBEventsAPI
{
    NSString *theaccessToken;
}

/**
 Init API call
 https://stage-yearbook.mars.com//petcareservice/api/Events/GetEvents?Id=["a2adf53e-1267-4af7-b9a5-f42be8738b62","e77bfe80-d790-4baf-9fe2-87d35b8e2d33"]emailID:unknown;multiCalendarChecked:false;year:2017
 @param CalendarYear The user's Email Address, not being used right now.
 @param CalendarCategories the Calendar ID, not being used right now.
 @return ID Self.
 */
-(id)initWithToken:(NSString*)theToken WithYear:(NSString *)CalendarYear withCalendarId:(NSString *)calendarID forCategories:(NSArray *)CalendarCategories{
    self = [super init];
    if (self) {
        self.calendarYear = CalendarYear;
        self.calendarCategoriesArry = CalendarCategories;
        self.calendarid = calendarID;
        theaccessToken = [NSString stringWithFormat:@"Bearer %@",theToken];
    }
    return self;
}

/**
 Specific Request URLpath only.
 
 @return URL path to be added to the base URL.
 */
- (NSString *)requestUrl {
    NSString *categoryStr = @"[";
    for (int i = 0; i < [self.calendarCategoriesArry count]; i++) {
        categoryStr = [categoryStr stringByAppendingFormat:@"\"%@\"",[self.calendarCategoriesArry objectAtIndex:i]];
        if (i < [self.calendarCategoriesArry count]-1) {
            categoryStr = [categoryStr stringByAppendingFormat:@","];
        }
    }
    categoryStr = [categoryStr stringByAppendingFormat:@"]"];
    NSString *str = [self URLEncodedString:[NSString stringWithFormat:@"%@emailID:unknown;multiCalendarChecked:false;year:%@",categoryStr,self.calendarYear]];
   // return [NSString stringWithFormat:@"%@%@&TokenValue=ODZjZWUxMGItY2MxOC00MTE5LTlkYzEtZWEyOWFmYjUwMTc1",@"/petcareservice/api/Events/GetEvents?Id=",str];
    
    
     return [NSString stringWithFormat:@"%@%@",@"/CalendarAPI/api/Events/GetEvents?Id=",str];
    
    
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

//- (void)requestCompletePreprocessor{
//    NSLog(@"Request completed");
//    //Load to the store.
//}

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

- (NSDictionary *)requestHeaderFieldValueDictionary {
    NSDictionary *dict = @{@"Authorization": theaccessToken,@"Content-Type":@"application/json"};
    return dict;
}

@end
