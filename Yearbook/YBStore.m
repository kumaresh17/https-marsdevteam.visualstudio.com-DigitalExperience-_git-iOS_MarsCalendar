//
//  YBStore.m
//  Yearbook
//
//  Created by Urmil Setia on 24/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBStore.h"
#import "AppDelegate.h"

@interface YBStore ()
@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation YBStore

- (instancetype)init
{
    self = [super init];
    if (self) {
        AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
        self.managedObjectContext = appDel.managedObjectContext;
    }
    return self;
}

-(NSManagedObjectContext *)returnContext{
    return self.managedObjectContext;
}

//Check If exist and return Object
-(id)checkAndReturnIfExistWithClass:(NSString *)theClass andPredicate:(NSPredicate *)Predicate{
    NSFetchRequest *req = [[NSFetchRequest alloc] initWithEntityName:theClass];
    if (Predicate) {
        req.predicate = Predicate;
    }
    NSArray *arry = [self.managedObjectContext executeFetchRequest:req error:nil];
    if (arry.count > 0) {
        return arry[0];
    }
    else
        return nil;
}

//Check If exist and return Object
-(id)deleteEverythingElse:(NSString *)theClass andPredicate:(NSPredicate *)Predicate{
    NSFetchRequest *req = [[NSFetchRequest alloc] initWithEntityName:theClass];
    if (Predicate) {
        req.predicate = Predicate;
    }
    NSArray *arry = [self.managedObjectContext executeFetchRequest:req error:nil];
    if (arry.count > 0) {
        return arry;
    }
    else
        return nil;
}


-(NSError *)saveContext:(NSError *)err{
    AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDel saveContext:err];
    return err;
}

-(id)getCalendarWithID:(NSString *)calendarID{
    NSFetchRequest *req = [[NSFetchRequest alloc] initWithEntityName:@"YBCalendars"];
    req.predicate = [NSPredicate predicateWithFormat:@"calendarid == %@",[NSString stringWithFormat:@"%@",calendarID]];
    NSArray *arry = [self.managedObjectContext executeFetchRequest:req error:nil];
    if (arry.count > 0) {
        return arry[0];
    }
    else
        return nil;
}

-(id)getAllCalendarIDs{
    NSFetchRequest *req = [[NSFetchRequest alloc] initWithEntityName:@"YBCalendars"];
    [req setPropertiesToFetch:@[@"calendarid"]];
    NSArray *arry = [self.managedObjectContext executeFetchRequest:req error:nil];
    if (arry.count > 0) {
        return [arry valueForKey:@"calendarid"];
    }
    else
        return nil;
}

-(id)getCategoryWithID:(NSString *)categoryID forCalendar:(NSString *)calendarID{
    NSFetchRequest *req = [[NSFetchRequest alloc] initWithEntityName:@"YBCalendarCategory"];
    req.predicate = [NSPredicate predicateWithFormat:@"(categoryGUID == %@) AND (calendar.calendarid == %@)",[NSString stringWithFormat:@"%@",categoryID], [NSString stringWithFormat:@"%@",calendarID]];
    NSArray *arry = [self.managedObjectContext executeFetchRequest:req error:nil];
    if (arry.count > 0) {
        return arry[0];
    }
    else
        return nil;
}

-(NSError *)deleteOldObjects:(id)deletionArry{
    @try
    {
        for (NSManagedObject *obj in deletionArry) {
            [self.managedObjectContext deleteObject:obj];
        }
    }
    @catch(NSException *exception){
        NSError *err = [NSError errorWithDomain:@"Unable to delete data to store" code:1001 userInfo:nil];
        return err;
    }
    return nil;
}

-(NSError *)deleteOldUpdatesForCalendar:(NSString *)calendarID {
    NSPredicate *pred = nil;
    if (calendarID) {
        pred = [NSPredicate predicateWithFormat:@"calendar.calendarid == %@", [NSString stringWithFormat:@"%@",calendarID]];
    }
    NSArray *a = [self deleteEverythingElse:@"YBCalendarUpdates" andPredicate:pred];
    
    NSError *err;
    err = [self deleteOldObjects:a];
    
    [self saveContext:err];
    return err;
}

-(NSError *)deleteOldEventsWithPred:(NSPredicate *)pred {
    NSArray *a = [self deleteEverythingElse:@"YBEvents" andPredicate:pred];
    
    NSError *err;
    err = [self deleteOldObjects:a];
    [NSFetchedResultsController deleteCacheWithName:@"eventsTableView"];
    [NSFetchedResultsController deleteCacheWithName:@"monthViewEvents"];
    [self saveContext:err];
    return err;
}

-(NSError *)deleteEverything{
    NSArray *a = [self deleteEverythingElse:@"YBEvents" andPredicate:nil];
    NSArray *b = [self deleteEverythingElse:@"YBCalendars" andPredicate:nil];
    NSArray *c = [self deleteEverythingElse:@"YBCalendarCategory" andPredicate:nil];
    NSArray *d = [self deleteEverythingElse:@"YBUser" andPredicate:nil];
    
    NSError *err;
    err = [self deleteOldObjects:a];
    err = [self deleteOldObjects:b];
    err = [self deleteOldObjects:c];
    err = [self deleteOldObjects:d];
    [NSFetchedResultsController deleteCacheWithName:@"calendarcategories"];
    [NSFetchedResultsController deleteCacheWithName:@"eventsTableView"];
    [NSFetchedResultsController deleteCacheWithName:@"monthViewEvents"];

    [self saveContext:err];
    return err;
}

@end
