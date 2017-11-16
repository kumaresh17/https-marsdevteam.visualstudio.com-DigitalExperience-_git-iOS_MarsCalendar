//
//  YBCalendarUpdates+CoreDataProperties.m
//  Yearbook
//
//  Created by Urmil Setia on 06/01/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "YBCalendarUpdates+CoreDataProperties.h"

@implementation YBCalendarUpdates (CoreDataProperties)

+ (NSFetchRequest<YBCalendarUpdates *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"YBCalendarUpdates"];
}

@dynamic lastUpdated;
@dynamic updateContent;
@dynamic calendar;

@end
