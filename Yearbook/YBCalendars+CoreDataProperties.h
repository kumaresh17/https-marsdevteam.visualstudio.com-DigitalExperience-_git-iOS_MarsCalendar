//
//  YBCalendars+CoreDataProperties.h
//  Yearbook
//
//  Created by Urmil Setia on 27/02/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "YBCalendars+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface YBCalendars (CoreDataProperties)

+ (NSFetchRequest<YBCalendars *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *calendarid;
@property (nullable, nonatomic, copy) NSString *calendarname;
@property (nullable, nonatomic, copy) NSString *color;
@property (nullable, nonatomic, copy) NSDate *lastUpdated;
@property (nullable, nonatomic, copy) NSString *calendarlogo;
@property (nullable, nonatomic, retain) NSOrderedSet<YBCalendarCategory *> *categories;
@property (nullable, nonatomic, retain) NSSet<YBEvents *> *event;
@property (nullable, nonatomic, retain) YBCalendarUpdates *updates;

@end

@interface YBCalendars (CoreDataGeneratedAccessors)

- (void)insertObject:(YBCalendarCategory *)value inCategoriesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCategoriesAtIndex:(NSUInteger)idx;
- (void)insertCategories:(NSArray<YBCalendarCategory *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCategoriesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCategoriesAtIndex:(NSUInteger)idx withObject:(YBCalendarCategory *)value;
- (void)replaceCategoriesAtIndexes:(NSIndexSet *)indexes withCategories:(NSArray<YBCalendarCategory *> *)values;
- (void)addCategoriesObject:(YBCalendarCategory *)value;
- (void)removeCategoriesObject:(YBCalendarCategory *)value;
- (void)addCategories:(NSOrderedSet<YBCalendarCategory *> *)values;
- (void)removeCategories:(NSOrderedSet<YBCalendarCategory *> *)values;

- (void)addEventObject:(YBEvents *)value;
- (void)removeEventObject:(YBEvents *)value;
- (void)addEvent:(NSSet<YBEvents *> *)values;
- (void)removeEvent:(NSSet<YBEvents *> *)values;

@end

NS_ASSUME_NONNULL_END
