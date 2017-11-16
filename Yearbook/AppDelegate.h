//
//  AppDelegate.h
//  Yearbook
//
//  Created by Urmil Setia on 17/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

#pragma mark - Core Data Stack
///-----------------------
/// @group Core Data Stack
///-----------------------

/*!
 @abstract The main managed object context
 */
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

/*!
 @abstract The managed object model
 */
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

/*!
 @abstract The persistent store coordinator
 */
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/*!
 @abstract Save the main managed object context
 */
- (void)saveContext:(NSError *)error;

/*!
 @abstract Return the application document directory needed to save and retrieve local files
 @return The URL of the application's document directory
 */
- (NSURL *)applicationDocumentsDirectory;


@end

