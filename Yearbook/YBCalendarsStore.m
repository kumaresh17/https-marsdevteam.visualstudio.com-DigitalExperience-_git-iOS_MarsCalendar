//
//  YBCalendarsStore.m
//  Yearbook
//
//  Created by Urmil Setia on 24/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBCalendarsStore.h"
#import "YBCalendarsAPI.h"
#import "YBCalendars+CoreDataClass.h"
#import "YBCalendarCategoryAPI.h"
#import <ADAL/ADAL.h>
#import "YBConstants.h"
#import "YBCalendarCategoryStore.h"

@interface YBCalendarsStore ()
@property(nonatomic, weak) NSManagedObjectContext *managedContext;
@property(nonatomic, strong) NSMutableArray *calendarsFetchedArray;
@end

@implementation YBCalendarsStore

-(id)init{
    self = [super init];
    if (self) {
        self.managedContext = [self returnContext];
        self.calendarsFetchedArray = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

-(void)fetchAndStoreCalendarsToken:(NSString*)token AndCompletionHandler:(void (^)(NSError *error))completionHandler{
    
    [self fetchCalendarsWithToken:token completionHandler:completionHandler];
}

/**
 Fetch data from webservices for Get Calendars API
 
 @param completionHandler completionHandler to be sent back to the caller
 */
-(void)fetchCalendarsWithToken:(NSString *)token completionHandler:(void (^)(NSError *error))completionHandler{
    YBCalendarsAPI *api = [[YBCalendarsAPI alloc] initWithToken:token WithEmail:@"" andCalendarID:@""];
    [api startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
//        NSLog(@"succeed %@",request.responseJSONObject);
        [self storeCalendars:request.responseJSONObject andWithCompletionHandler:completionHandler];
    } failure:^(YTKBaseRequest *request) {
        NSLog(@"Calendar Request Failed: %@",request.error);
        if (completionHandler) {
            completionHandler(request.error);
        }
    }];
}


/**
 Store Calendar data into Core Data
 
 @param responseJsonObject The JSON response from the server
 @param completionHandler completionHandler to be sent back to the caller
 */
-(void)storeCalendars:(id)responseJsonObject andWithCompletionHandler:(void (^)(NSError *))completionHandler{
    NSError *e = nil;
    NSPredicate *predForDeletion = [NSPredicate predicateWithFormat:@"lastUpdated < %@",[NSDate date]];
    if ([responseJsonObject isKindOfClass:[NSArray class]]) {
        for (id theRow in responseJsonObject) {
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"calendarid == %@",[NSString stringWithFormat:@"%@",[theRow objectForKey:@"Id"]]];
            id theEntity = [self checkAndReturnIfExistWithClass:@"YBCalendars" andPredicate:pred];
            e = [self insertOrUpdateCalendar:(YBCalendars *)theEntity withDict:theRow];
            if (e) {
                completionHandler(e);
                break;
            }
        }
    }
    else if ([responseJsonObject isKindOfClass:[NSDictionary class]]) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"calendarid == %@",[NSString stringWithFormat:@"%@",[responseJsonObject objectForKey:@"Id"]]];
        id theEntity = [self checkAndReturnIfExistWithClass:@"YBCalendars" andPredicate:pred];
        e = [self insertOrUpdateCalendar:theEntity withDict:responseJsonObject];
    }
    if (e) {
        completionHandler(e);
    }
    else{
        //Delete everything else
        id deletionArry = [self deleteEverythingElse:@"YBCalendars" andPredicate:predForDeletion];
        e = [self deleteOldObjects:deletionArry];
        
        ADAuthenticationError *error = nil;
        ADAuthenticationContext *authContext = [ADAuthenticationContext authenticationContextWithAuthority:kLoginAuthority error:&error];
        
        [authContext acquireTokenWithResource:kAuthResourceUri
                                      clientId:kAuthClientId
                                   redirectUri:[NSURL URLWithString:kAuthRedirectUri]
                                        userId:nil
                          extraQueryParameters:@"domain_hint=effem.com" completionBlock:^(ADAuthenticationResult *result){
            if (AD_SUCCEEDED != result.status){
                // display error on the screen
                NSLog(@"Issue with Profile Picture: %@", result.error.errorDetails);
            }
            else{
                NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                [def setObject:result.accessToken forKey:@"accessToken"];
                [def synchronize];
                NSError *error = nil;
                //Send completion Handler and requests to CategoryStore
                if ([self.calendarsFetchedArray count]>0) {
                    YBCalendarCategoryStore *category = [YBCalendarCategoryStore sharedInstance];
                    [category fetchAndStoreCalendarCategoryWithCalendars:self.calendarsFetchedArray token:result.accessToken andCompletionHandler:completionHandler];
                }
                [self saveContext:error];
            }
        }];
    }
}

/**
 Insert or update the response from the server
 
 @param theCalEntity nil or existing record
 @param theCal The calendar data from webservice
 @return If any error return it else return nil.
 */
-(NSError *)insertOrUpdateCalendar:(YBCalendars *)theCalEntity withDict:(NSDictionary *)theCal{
    @try
    {
        if (!theCalEntity) {
            theCalEntity = [NSEntityDescription insertNewObjectForEntityForName:@"YBCalendars" inManagedObjectContext:self.managedContext];
        }
        [self.calendarsFetchedArray addObject:[NSString stringWithFormat:@"%@",[theCal objectForKey:@"Id"]]];
        [theCalEntity setColor:[theCal objectForKey:@"Color"]];
        [theCalEntity setCalendarid:[NSString stringWithFormat:@"%@",[theCal objectForKey:@"Id"]]];
        [theCalEntity setCalendarname:[theCal objectForKey:@"Name"]];
        [theCalEntity setLastUpdated:[NSDate date]];
        [theCalEntity setCalendarlogo:[theCal objectForKey:@"CalendarIcon"]];
    }
    @catch(NSException *exception){
        NSError *err = [NSError errorWithDomain:@"Unable to write data to store" code:1000 userInfo:nil];
        return err;
    }
    return nil;
}

@end
