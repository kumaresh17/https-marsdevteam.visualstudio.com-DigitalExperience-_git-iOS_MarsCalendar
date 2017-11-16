//
//  YBCalendarCategory+CoreDataProperties.m
//  Yearbook
//
//  Created by Urmil Setia on 27/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "YBCalendarCategory+CoreDataProperties.h"

@implementation YBCalendarCategory (CoreDataProperties)

+ (NSFetchRequest<YBCalendarCategory *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"YBCalendarCategory"];
}

@dynamic categoryName;
@dynamic categoryColor;
@dynamic categoryID;
@dynamic categoryGUID;
@dynamic lastUpdated;
@dynamic calendar;
@dynamic event;

@end
