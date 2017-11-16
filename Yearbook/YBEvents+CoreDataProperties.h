//
//  YBEvents+CoreDataProperties.h
//  Yearbook
//
//  Created by Urmil Setia on 14/12/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "YBEvents+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface YBEvents (CoreDataProperties)

+ (NSFetchRequest<YBEvents *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *calendarname;
@property (nonatomic) double calendarYear;
@property (nullable, nonatomic, copy) NSString *categoryname;
@property (nullable, nonatomic, copy) NSString *classname;
@property (nullable, nonatomic, copy) NSString *color;
@property (nullable, nonatomic, copy) NSDate *endtime;
@property (nullable, nonatomic, copy) NSDate *eventDate;
@property (nullable, nonatomic, copy) NSString *eventdescription;
@property (nullable, nonatomic, copy) NSString *eventID;
@property (nullable, nonatomic, copy) NSString *eventtypeid;
@property (nullable, nonatomic, copy) NSString *eventtypename;
@property (nonatomic) BOOL fullday;
@property (nullable, nonatomic, copy) NSDate *lastUpdated;
@property (nullable, nonatomic, copy) NSString *notes;
@property (nullable, nonatomic, copy) NSDate *starttime;
@property (nullable, nonatomic, copy) NSString *timezone;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, retain) YBCalendars *calendar;
@property (nullable, nonatomic, retain) YBCalendarCategory *category;

@end

NS_ASSUME_NONNULL_END
