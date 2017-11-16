//
//  YBCalendarUpdatesStore.m
//  Yearbook
//
//  Created by Urmil Setia on 06/01/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//

#import "YBCalendarUpdatesStore.h"
#import "YBCalendarUpdatesAPI.h"
#import "YBCalendarUpdates+CoreDataClass.h"

@interface YBCalendarUpdatesStore ()
@property(nonatomic, weak) NSManagedObjectContext *managedContext;
@property(nonatomic, strong) NSMutableArray *CalendarCategoryToLoad;
@property (nonatomic, copy) void (^completionHandler)(NSError *);

@end

@implementation YBCalendarUpdatesStore

+ (instancetype)sharedInstance
{
    static YBCalendarUpdatesStore *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YBCalendarUpdatesStore alloc] init];
        // Do any other initialisation stuff here
        
    });
    return sharedInstance;
}

-(id)init{
    self = [super init];
    if (self) {
        self.managedContext = [self returnContext];
    }
    return self;
}


/**
 Fetch data from web services and store in the Core Data
 for get Calendar Category API
 
 @param completionHandler handler
 */
-(void)fetchAndStoreCalendarUpdatesWithToken:(NSString*)token AndCompletionHandler:(void (^)(NSError *))completionHandler{
    //Fetch results from web service and process and store them in core data and finally return completionHandler
    
    NSArray *calendarIDs = [self getAllCalendarIDs];
    
    if(!([calendarIDs count]>0)){
        if (completionHandler)
            completionHandler([NSError errorWithDomain:@"nil" code:9999 userInfo:nil]);
    }
    self.CalendarCategoryToLoad = [calendarIDs mutableCopy];
    self.completionHandler = completionHandler;
    NSMutableArray *requestArry = [NSMutableArray arrayWithCapacity:0];
    for (NSString *theCal in calendarIDs) {
        YBCalendarUpdatesAPI *theReq = [[YBCalendarUpdatesAPI alloc] initWithToken:token WithCalendarID:theCal andCalendarName:nil];
        [requestArry addObject:theReq];
    }
    
    YTKBatchRequest *batchRequest = [[YTKBatchRequest alloc] initWithRequestArray:requestArry];
    [batchRequest startWithCompletionBlockWithSuccess:^(YTKBatchRequest *request) {
        //        NSLog(@"succeed %@",request.requestArray[0].responseJSONObject);
        NSArray *responseArry = request.requestArray;
        for (int i=0; i<responseArry.count; i++) {
            YBCalendarUpdatesAPI *tempCat = responseArry[i];
            if ([tempCat.responseJSONObject objectForKey:@"Contents"] != (id)[NSNull null]){
                if ([[tempCat.responseJSONObject objectForKey:@"Contents"] objectForKey:@"Contents"] != (id)[NSNull null]){
                    id responseJSON = [[tempCat.responseJSONObject objectForKey:@"Contents"] objectForKey:@"Contents"];
                    [self storeCalendarUpdates:responseJSON forCalendar:[tempCat calendarid] andWithCompletionHandler:completionHandler];
                }
            } else{
                [self deleteOldUpdatesForCalendar:[tempCat calendarid]];
            }
        }
        if (self.completionHandler) {
            NSError *err = nil;
            [self saveContext:err];
            self.completionHandler(err);
        }
    } failure:^(YTKBatchRequest *request) {
        // you can use self here, retain cycle won't happen
        NSLog(@"Calendar Category failure: %@",request.failedRequest.error);
        if (self.completionHandler) {
            self.completionHandler(request.failedRequest.error);
        }
    }];
}

/**
 Store Calendar Categories
 
 @param responseJsonObject raw JSON response ID can be array or Dict
 @param CalendarID To add relationship
 @param completionHandler To return.
 */
-(void)storeCalendarUpdates:(id)responseJsonObject forCalendar:(NSString *)CalendarID andWithCompletionHandler:(void (^)(NSError *))completionHandler{
    NSError *e = nil;
    e= [self deleteOldUpdatesForCalendar:CalendarID];
    if ([responseJsonObject isKindOfClass:[NSString class]]) {
        e = [self insertOrUpdateCalendar:nil withContents:responseJsonObject forCalendar:CalendarID];
        if (e) {
            completionHandler(e);
            self.completionHandler = nil;
        }
    }
    else{
        if (self.completionHandler) {
            completionHandler([NSError errorWithDomain:NSPOSIXErrorDomain code:77 userInfo:@{@"error": @"Unable to parse"}]);
            self.completionHandler = nil;
        }
    }
}

/**
 Insert or Update the Category Entity
 
 @param theCalEntity nil or updatable Entity
 @param theUpdate String contents
 @param CalendarID To add relationship
 @return if any error
 */
-(NSError *)insertOrUpdateCalendar:(YBCalendarUpdates *)theCalEntity withContents:(NSString *)theUpdate forCalendar:(NSString *)CalendarID{
    @try
    {
        if (!theCalEntity) {
            theCalEntity = [NSEntityDescription insertNewObjectForEntityForName:@"YBCalendarUpdates" inManagedObjectContext:self.managedContext];
        }
        NSString *str = [[[[[theUpdate stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"] stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"] stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "] stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
        NSString *NewStr = [self convertHTML:[self stringByDecodingURLFormat:str]];

        [theCalEntity setUpdateContent:NewStr];
        [theCalEntity setCalendar:[self getCalendarWithID:CalendarID]];
        [theCalEntity setLastUpdated:[NSDate date]];
    }
    @catch(NSException *exception){
        NSError *err = [NSError errorWithDomain:@"Unable to write data to store" code:1000 userInfo:nil];
        return err;
    }
    return nil;
}

-(NSString *)convertHTML:(NSString *)html {
    
    NSScanner *myScanner;
    NSString *text = nil;
    myScanner = [NSScanner scannerWithString:html];
    
    while ([myScanner isAtEnd] == NO) {
        
        [myScanner scanUpToString:@"<" intoString:NULL] ;
        
        [myScanner scanUpToString:@">" intoString:&text] ;
        
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    //
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return html;
}

- (NSString *)stringByDecodingURLFormat:(NSString *)str
{
    NSString *result = [str stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByRemovingPercentEncoding];
    return result;
}

@end


