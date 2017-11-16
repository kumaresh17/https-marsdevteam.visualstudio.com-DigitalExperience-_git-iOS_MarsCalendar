//
//  YBProfileStore.m
//  Yearbook
//
//  Created by Urmil Setia on 18/12/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBProfileStore.h"
#import "YBProfileAPI.h"
#import "YBUser+CoreDataClass.h"

@interface YBProfileStore ()
@property(nonatomic, weak) NSManagedObjectContext *managedContext;
@end

@implementation YBProfileStore

-(id)init{
    self = [super init];
    if (self) {
        self.managedContext = [self returnContext];
    }
    return self;
}

-(void)fetchAndStoreUserWithToken:(NSString *)token AndCompletion:(void (^)(NSString *imageURL, NSError *error))completionHandler{
    //Fetch results from web service and process and store them in core data and finally return completionHandler
    [self fetchUserWithToken:(NSString *)token AndCompletion:completionHandler];
}

/**
 Fetch data from webservices for Get Calendars API
 
 @param completionHander completionHandler to be sent back to the caller
 */
-(void)fetchUserWithToken:(NSString *)token AndCompletion:(void (^)(NSString *imageURL, NSError *error))completionHander{
    YBProfileAPI *api = [[YBProfileAPI alloc] initWithToken:token];
    [api startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [self storeUser:request.responseJSONObject andWithCompletionHandler:completionHander];
    } failure:^(YTKBaseRequest *request) {
        NSLog(@"Failed to load User Profile %@",request.error);
        if (completionHander) {
            completionHander(nil, request.error);
        }
    }];
}

/**
 Store Calendar data into Core Data
 
 @param responseJsonObject The JSON response from the server
 @param completionHandler completionHandler to be sent back to the caller
 */
-(void)storeUser:(id)responseJsonObject andWithCompletionHandler:(void (^)(NSString *imageURL, NSError *error))completionHandler{
    NSError *e = nil;
    //Delete Old Entry
    id deletionArry = [self deleteEverythingElse:@"YBUser" andPredicate:nil];
    e = [self deleteOldObjects:deletionArry];
    if ([responseJsonObject isKindOfClass:[NSArray class]]) {
        for (id theRow in responseJsonObject) {
            [self insertUser:nil withDict:theRow andWithCompletionHandler:completionHandler];
        }
    }
    else if ([responseJsonObject isKindOfClass:[NSDictionary class]]) {
        [self insertUser:nil withDict:responseJsonObject andWithCompletionHandler:completionHandler
         ];
    }
    if (e) {
        completionHandler(nil,e);
    }
    else{
        NSError *error = nil;
        [self saveContext:error];
        if (completionHandler) {
            completionHandler(nil,error);
        }
    }
}

/**
 Insert or update the response from the server
 
 @param theUserEntity nil or existing record
 @param theCal The calendar data from webservice

 */
-(void)insertUser:(YBUser *)theUserEntity withDict:(NSDictionary *)theCal andWithCompletionHandler:(void (^)(NSString *imageURL, NSError *error))completionHandler{
    @try
    {
        if (!theUserEntity) {
            theUserEntity = [NSEntityDescription insertNewObjectForEntityForName:@"YBUser" inManagedObjectContext:self.managedContext];
        }
        [theUserEntity setLoginEmail:[theCal objectForKey:@"userPrincipalName"]];
        [theUserEntity setLoginName:[theCal objectForKey:@"displayName"]];
        [theUserEntity setLastRefresh:[NSDate date]];
        
        NSString *str = @"https://team.effem.com:443/_layouts/15/userphoto.aspx?URL=https://mydrive.effem.com:443/User%20Photos/Profile%20Pictures/";
        str = [str stringByAppendingString:[NSString stringWithFormat:@"%@_LThumb.jpg", [[[theCal objectForKey:@"userPrincipalName"] stringByReplacingOccurrencesOfString:@"." withString:@"_"] stringByReplacingOccurrencesOfString:@"@" withString:@"_"]]];
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        [def setObject:str forKey:@"profilePictureURL"];
        [def synchronize];
        if (completionHandler) {
            completionHandler(str,nil);
        }
    }
    @catch(NSException *exception){
        NSError *err = [NSError errorWithDomain:@"Unable to write data to store" code:1000 userInfo:nil];
        if (completionHandler) {
            completionHandler(nil,err);
        }
    }
}
@end
