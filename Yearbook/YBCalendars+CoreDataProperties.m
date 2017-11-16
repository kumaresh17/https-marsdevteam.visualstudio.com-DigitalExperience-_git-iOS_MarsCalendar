//
//  YBCalendars+CoreDataProperties.m
//  Yearbook
//
//  Created by Urmil Setia on 27/02/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "YBCalendars+CoreDataProperties.h"

@implementation YBCalendars (CoreDataProperties)

+ (NSFetchRequest<YBCalendars *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"YBCalendars"];
}

@dynamic calendarid;
@dynamic calendarname;
@dynamic color;
@dynamic lastUpdated;
@dynamic calendarlogo;
@dynamic categories;
@dynamic event;
@dynamic updates;

@end
