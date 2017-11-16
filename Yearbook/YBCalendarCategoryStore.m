//
//  YBCalendarCategoryStore.m
//  Yearbook
//
//  Created by Urmil Setia on 24/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBCalendarCategoryStore.h"
#import "YBCalendars+CoreDataClass.h"
#import "YBCalendarCategoryAPI.h"
#import "YBCalendarCategory+CoreDataClass.h"

@interface YBCalendarCategoryStore ()
@property(nonatomic, weak) NSManagedObjectContext *managedContext;
@property(nonatomic, strong) NSMutableArray *CalendarCategoryToLoad;
@property (nonatomic, copy) void (^completionHandler)(NSError *);

@end

@implementation YBCalendarCategoryStore

+ (instancetype)sharedInstance
{
    static YBCalendarCategoryStore *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YBCalendarCategoryStore alloc] init];
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
 
 @param theCalendars Find categories for these calendars
 @param completionHandler to return
 */
-(void)fetchAndStoreCalendarCategoryWithCalendars:(NSMutableArray *)theCalendars token:(NSString*)token andCompletionHandler:(void (^)(NSError *))completionHandler{
    //Fetch results from web service and process and store them in core data and finally return completionHandler
    if(!([theCalendars count]>0)){
        if (completionHandler)
            completionHandler([NSError errorWithDomain:@"nil" code:9999 userInfo:nil]);
    }
    self.CalendarCategoryToLoad = theCalendars;
    self.completionHandler = completionHandler;
    NSMutableArray *requestArry = [NSMutableArray arrayWithCapacity:0];
#warning Check with Adrien on importance of year in Calendars and categories
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSString *currentYr = [NSString stringWithFormat:@"%ld",(long)[components year]];
    for (NSString *theCal in theCalendars) {
        YBCalendarCategoryAPI *theReq = [[YBCalendarCategoryAPI alloc] initWithToken:token WithYear:currentYr andCalendarID:theCal];
        [requestArry addObject:theReq];
    }
    
    YTKBatchRequest *batchRequest = [[YTKBatchRequest alloc] initWithRequestArray:requestArry];
    [batchRequest startWithCompletionBlockWithSuccess:^(YTKBatchRequest *request) {
        //        NSLog(@"succeed %@",request.requestArray[0].responseJSONObject);
        NSArray *responseArry = request.requestArray;
        for (int i=0; i<responseArry.count; i++) {
            YBCalendarCategoryAPI *tempCat = responseArry[i];
            id responseJSON = [[tempCat.responseJSONObject objectForKey:@"Output"] objectForKey:@"eventtypelist"];
            [self storeCalendarCategorys:responseJSON forCalendar:[tempCat calendarid] andWithCompletionHandler:completionHandler];
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
-(void)storeCalendarCategorys:(id)responseJsonObject forCalendar:(NSString *)CalendarID andWithCompletionHandler:(void (^)(NSError *))completionHandler{
    NSError *e = nil;
    NSPredicate *predForDeletion = [NSPredicate predicateWithFormat:@"lastUpdated < %@ and calendar.calendarid = %@",[NSDate date], CalendarID];
    if ([responseJsonObject isKindOfClass:[NSArray class]]) {
        for (id theRow in responseJsonObject) {
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"categoryID == %@",[NSString stringWithFormat:@"%@",[theRow objectForKey:@"Id"]]];
            id theEntity = [self checkAndReturnIfExistWithClass:@"YBCalendarCategory" andPredicate:pred];
            e = [self insertOrUpdateCalendar:(YBCalendarCategory *)theEntity withDict:theRow forCalendar:CalendarID];
            if (e) {
                completionHandler(e);
                self.completionHandler = nil;
                break;
            }
        }
    }
    else if ([responseJsonObject isKindOfClass:[NSDictionary class]]) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"categoryID == %@",[NSString stringWithFormat:@"%@",[responseJsonObject objectForKey:@"Id"]]];
        id theEntity = [self checkAndReturnIfExistWithClass:@"YBCalendarCategory" andPredicate:pred];
        e = [self insertOrUpdateCalendar:theEntity withDict:responseJsonObject forCalendar:CalendarID];
    }
    if (e) {
        completionHandler(e);
        self.completionHandler = nil;
    }
    else
        e= [self deleteEverythingElse:@"YBCalendarCategory" andPredicate:predForDeletion];
}

/**
 Insert or Update the Category Entity
 
 @param theCalEntity nil or updatable Entity
 @param theCal Dict response
 @param CalendarID To add relationship
 @return if any error
 */
-(NSError *)insertOrUpdateCalendar:(YBCalendarCategory *)theCalEntity withDict:(NSDictionary *)theCal forCalendar:(NSString *)CalendarID{
    @try
    {
        if (!theCalEntity) {
            theCalEntity = [NSEntityDescription insertNewObjectForEntityForName:@"YBCalendarCategory" inManagedObjectContext:self.managedContext];
        }
        
        [theCalEntity setCategoryColor:[theCal objectForKey:@"Color"]];
        [theCalEntity setCategoryID:[NSString stringWithFormat:@"%@",[theCal objectForKey:@"Id"]]];
        [theCalEntity setCategoryName:[theCal objectForKey:@"Name"]];
        [theCalEntity setCategoryGUID:[theCal objectForKey:@"Guid"]];
        [theCalEntity setCalendar:[self getCalendarWithID:CalendarID]];
        [theCalEntity setLastUpdated:[NSDate date]];
    }
    @catch(NSException *exception){
        NSError *err = [NSError errorWithDomain:@"Unable to write data to store" code:1000 userInfo:nil];
        return err;
    }
    return nil;
}
@end
