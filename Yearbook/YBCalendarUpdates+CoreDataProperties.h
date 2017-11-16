//
//  YBCalendarUpdates+CoreDataProperties.h
//  Yearbook
//
//  Created by Urmil Setia on 06/01/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "YBCalendarUpdates+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface YBCalendarUpdates (CoreDataProperties)

+ (NSFetchRequest<YBCalendarUpdates *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *lastUpdated;
@property (nullable, nonatomic, copy) NSString *updateContent;
@property (nullable, nonatomic, retain) YBCalendars *calendar;

@end

NS_ASSUME_NONNULL_END
