//
//  YBCalendarCategory+CoreDataProperties.h
//  Yearbook
//
//  Created by Urmil Setia on 27/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "YBCalendarCategory+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface YBCalendarCategory (CoreDataProperties)

+ (NSFetchRequest<YBCalendarCategory *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *categoryName;
@property (nullable, nonatomic, copy) NSString *categoryColor;
@property (nullable, nonatomic, copy) NSString *categoryID;
@property (nullable, nonatomic, copy) NSString *categoryGUID;
@property (nullable, nonatomic, copy) NSDate *lastUpdated;
@property (nullable, nonatomic, retain) YBCalendars *calendar;
@property (nullable, nonatomic, retain) NSSet<YBEvents *> *event;

@end

@interface YBCalendarCategory (CoreDataGeneratedAccessors)

- (void)addEventObject:(YBEvents *)value;
- (void)removeEventObject:(YBEvents *)value;
- (void)addEvent:(NSSet<YBEvents *> *)values;
- (void)removeEvent:(NSSet<YBEvents *> *)values;

@end

NS_ASSUME_NONNULL_END
