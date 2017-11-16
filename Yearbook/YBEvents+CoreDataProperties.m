//
//  YBEvents+CoreDataProperties.m
//  Yearbook
//
//  Created by Urmil Setia on 14/12/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "YBEvents+CoreDataProperties.h"

@implementation YBEvents (CoreDataProperties)

+ (NSFetchRequest<YBEvents *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"YBEvents"];
}

@dynamic calendarname;
@dynamic calendarYear;
@dynamic categoryname;
@dynamic classname;
@dynamic color;
@dynamic endtime;
@dynamic eventDate;
@dynamic eventdescription;
@dynamic eventID;
@dynamic eventtypeid;
@dynamic eventtypename;
@dynamic fullday;
@dynamic lastUpdated;
@dynamic notes;
@dynamic starttime;
@dynamic timezone;
@dynamic title;
@dynamic calendar;
@dynamic category;

@end
