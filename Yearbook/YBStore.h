//
//  YBStore.h
//  Yearbook
//
//  Created by Urmil Setia on 24/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;

@interface YBStore : NSObject

/**
 Returns the ManagedObjectContext from AppDelagate.
 Helper utility.

 @return Singleton ManagedObjectContext.
 */
-(NSManagedObjectContext *)returnContext;

-(id)getCalendarWithID:(NSString *)calendarID;
-(id)getCategoryWithID:(NSString *)categoryID forCalendar:(NSString *)calendarID;

/**
 Save Managed Context in AppDelagate

 @param err Error Pointer
 @return Any error generated.
 */
-(NSError *)saveContext:(NSError *)err;

/**
 Check and return the record if it exists to Update.

 @param theClass Entity Class
 @param Predicate To lock for the unique object
 @return ID if any record with the ID is found which will be updated.
 */
-(id)checkAndReturnIfExistWithClass:(NSString *)theClass andPredicate:(NSPredicate *)Predicate;

-(id)deleteEverythingElse:(NSString *)theClass andPredicate:(NSPredicate *)Predicate;

-(NSError *)deleteOldObjects:(id)deletionArry;

-(NSError *)deleteEverything;

-(id)getAllCalendarIDs;
-(NSError *)deleteOldUpdatesForCalendar:(NSString *)calendarID;
-(NSError *)deleteOldEventsWithPred:(NSPredicate *)pred;
@end
