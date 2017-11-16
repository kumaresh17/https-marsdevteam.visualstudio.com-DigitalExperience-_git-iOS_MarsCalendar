
//
//  YBEventsStore.m
//  Yearbook
//
//  Created by Urmil Setia on 28/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBEventsStore.h"
#import "YBEventsAPI.h"
#import "YBEvents+CoreDataClass.h"
#import "YBCalendarCategory+CoreDataClass.h"
#import "YBCalendars+CoreDataClass.h"
#import "NSDate+timezones.h"
#import "DateTools.h"
#import "YBEventSyncToCalenderService.h"
@interface YBEventsStore ()
@property(nonatomic, weak) NSManagedObjectContext *managedContext;
@property(nonatomic, strong) NSMutableArray *ArrayOfCalandCategories;
@property (nonatomic, copy) void (^completionHandler)(NSError *);

@end

@implementation YBEventsStore
+ (instancetype)sharedInstance
{
    static YBEventsStore *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YBEventsStore alloc] init];
        // Do any other initialisation stuff here
        
    });
    return sharedInstance;
}

-(id)init{
    self = [super init];
    if (self) {
        self.managedContext = [self returnContext];
    }
    return self;
}

/**
 Fetch data from web services and store in the Core Data
 for get Calendar Category API
 
 @param arryOfCalanderCategories Array of Calendar and Categories
 @param calendarYear Calendar Year to fetch for
 @param completionHandler to return
 */
-(void)fetchAndStoreEventsWithCalendarsAndCategories:(NSMutableArray *)arryOfCalanderCategories forYear:(long)calendarYear token:(NSString*)token andCompletionHandler:(void (^)(NSError *error))completionHandler{
    //Fetch results from web service and process and store them in core data and finally return completionHandler
    if(!([arryOfCalanderCategories count]>0)){
        if(![[YBEventSyncToCalenderService sharedSyncService] isAuthorizedToModifyCalender]){
            [self authorizeToSaveInCalendar];
        }else{
            [[YBEventSyncToCalenderService sharedSyncService] removeAllThisYearEvent];
        }
        completionHandler([NSError errorWithDomain:@"nil" code:9999 userInfo:nil]);
    }
    self.ArrayOfCalandCategories = arryOfCalanderCategories;
    self.completionHandler = completionHandler;
    NSMutableArray *requestArry = [NSMutableArray arrayWithCapacity:0];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSString *currentYr = [NSString stringWithFormat:@"%ld",(long)[components year]];

    for (NSDictionary *dict in arryOfCalanderCategories) {
        YBEventsAPI *theReq = [[YBEventsAPI alloc] initWithToken:token WithYear:(calendarYear)?[NSString stringWithFormat:@"%ld",calendarYear]:currentYr withCalendarId:[dict objectForKey:@"calendarID"] forCategories:[dict objectForKey:@"categories"]];
        [requestArry addObject:theReq];
    }
    if(![[YBEventSyncToCalenderService sharedSyncService] isAuthorizedToModifyCalender]){
        [self authorizeToSaveInCalendar];
    }else{
        [self performSelector:@selector(removeEventsFromStore) onThread:[NSThread currentThread] withObject:nil waitUntilDone:YES];
    }
    
    YTKBatchRequest *batchRequest = [[YTKBatchRequest alloc] initWithRequestArray:requestArry];
    [batchRequest startWithCompletionBlockWithSuccess:^(YTKBatchRequest *request) {
        //        NSLog(@"succeed %@",request.requestArray[0].responseJSONObject)
       
        NSArray *responseArry = request.requestArray;
        NSError *err = nil;
        for (int i=0; i<responseArry.count; i++) {
            YBEventsAPI *tempCat = responseArry[i];
            id responseJSON = [tempCat.responseJSONObject objectForKey:@"OutputCalendarEvent"];
            //            if([[responseJSON objectForKey:@"Code"] isEqual:@"100"]){
            [self storeEvent:responseJSON forCalendar:[tempCat calendarid] withCalendarYear:[tempCat calendarYear] andCategories:[tempCat calendarCategoriesArry] andWithCompletionHandler:completionHandler];
            //            }
            //            else
            //                err = [NSError errorWithDomain:@"Webservice" code:900 userInfo:[responseJSON objectForKey:@"Message"]];
        }
        [self saveContext:err];
        if (self.completionHandler) {
            //            if (err) {
            //                self.completionHandler(err);
            //            }
            //            else{
            self.completionHandler(err);
            //            }
        }
    } failure:^(YTKBatchRequest *request) {
        NSLog(@"Event Request Failed: %@",request.failedRequest.error);
        if (self.completionHandler) {
            self.completionHandler(request.failedRequest.error);
        }
    }];
}
-(void)removeEventsFromStore{
    [[YBEventSyncToCalenderService sharedSyncService] removeAllThisYearEvent];
}
/**
 Store Calendar Categories
 
 @param responseJsonObject raw JSON response ID can be array or Dict
 @param CalendarID CalendarID To add relationship
 @param calendarYear Relevant to delete old records
 @param calendarCategoriesArry Relevant to delete old records
 @param completionHandler To return
 */
-(void)storeEvent:(id)responseJsonObject forCalendar:(NSString *)CalendarID withCalendarYear:(NSString *)calendarYear andCategories:(NSArray *) calendarCategoriesArry andWithCompletionHandler:(void (^)(NSError *))completionHandler{
    NSError *e = nil;
    NSMutableArray *predArry = [NSMutableArray arrayWithCapacity:0];
    NSPredicate *calendarPred = [NSPredicate predicateWithFormat:@"calendar.calendarid == %@",CalendarID];
    NSPredicate *calendarYearPred = [NSPredicate predicateWithFormat:@"calendarYear == %@",calendarYear];
    NSMutableArray *subPredicatesArry =[NSMutableArray arrayWithCapacity:0];
    
    for (NSString *str in calendarCategoriesArry) {
        NSPredicate *p = [NSPredicate predicateWithFormat:@"category.categoryGUID == %@",str];
        [subPredicatesArry addObject:p];
    }
    NSCompoundPredicate *comPred = [NSCompoundPredicate orPredicateWithSubpredicates:subPredicatesArry];
    NSPredicate *lastUpdated = [NSPredicate predicateWithFormat:@"lastUpdated < %@",[NSDate date]];
    NSCompoundPredicate *pred = [NSCompoundPredicate andPredicateWithSubpredicates:@[calendarPred,calendarYearPred, comPred,lastUpdated]];
    [predArry addObject:pred];
    NSPredicate *predForDeletion = [NSCompoundPredicate orPredicateWithSubpredicates:predArry];
    if ([responseJsonObject isKindOfClass:[NSArray class]]) {
        for (id theRow in responseJsonObject) {
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"eventID == %@",[NSString stringWithFormat:@"%@",[theRow objectForKey:@"EventId"]]];
            id theEntity = [self checkAndReturnIfExistWithClass:@"YBEvents" andPredicate:pred];
            e = [self insertOrUpdateEvent:(YBEvents *)theEntity withDict:theRow forCalendar:CalendarID];
            if (e) {
                completionHandler(e);
                self.completionHandler = nil;
                break;
            }
        }
    }
    else if ([responseJsonObject isKindOfClass:[NSDictionary class]]) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"eventID == %@",[NSString stringWithFormat:@"%@",[responseJsonObject objectForKey:@"EventId"]]];
        id theEntity = [self checkAndReturnIfExistWithClass:@"YBEvents" andPredicate:pred];
        e = [self insertOrUpdateEvent:(YBEvents *)theEntity withDict:responseJsonObject forCalendar:CalendarID];
    }
    if (e) {
        completionHandler(e);
        self.completionHandler = nil;
    }
    else {
        e= [self deleteOldEventsWithPred:predForDeletion];
    }
}

/**
 Insert or Update the Category Entity
 
 @param theCalEntity nil or updatable Entity
 @param theCal Dict response
 @param CalendarID To add relationship
 @return if any error
 */
-(NSError *)insertOrUpdateEvent:(YBEvents *)theCalEntity withDict:(NSDictionary *)theCal forCalendar:(NSString *)CalendarID{
    @try
    {
        BOOL isUpdate = YES;
        if (!theCalEntity) {
            theCalEntity = [NSEntityDescription insertNewObjectForEntityForName:@"YBEvents" inManagedObjectContext:self.managedContext];
            isUpdate = NO;
        }
        /*
         {
         CalendarYear = "";
         EventDate = "2016-08-11T00:00:00";
         EventId = "4efeffe4-476c-4293-bbe2-bff735fa5257";
         EventTypeId = "56ca1ffc-d65b-497b-a9b4-38675d2f8926";
         EventTypeName = "";
         calendarname = "Corporate Calendar";
         category = "Reminder events";
         className = "";
         color = "#00b050";
         desc = "Reminder event";
         end = "2016-08-11T23:00:00";
         endtime = "23:00";
         fullday = 1;
         notes = "This is a test event to make sure the reminder feature is effectively working";
         start = "2016-08-11T00:00:00";
         starttime = "00:00";
         timezone = "(UTC-05:00) Eastern Time (US & Canada)";
         title = "Reminder event";
         }
         */
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
        NSString *timeZ = [theCal objectForKey:@"timezone"];
        NSRange rangeOfEndofUTCNumber = [timeZ rangeOfString:@")"];
        NSString *tempStr = [timeZ substringWithRange:NSMakeRange(0,rangeOfEndofUTCNumber.location)];
        tempStr = [tempStr stringByReplacingOccurrencesOfString:@"(" withString:@""];
        NSInteger secondsFromGmt;
        NSString *tz;
        switch (tempStr.length) {
            case 3:{
                //UTC
                secondsFromGmt = 0;
                tz = @"+0000";
                break;
            }
            case 9:
            case 11:{
                NSString *operator = @"-";
                NSRange hasPlusSign = [tempStr rangeOfString:@"+"];
                if (hasPlusSign.location != NSNotFound) {
                    operator = @"+";
                }
                NSString *anotherTempStr = [tempStr substringWithRange:NSMakeRange([tempStr rangeOfString:operator].location, 6)];
                anotherTempStr = [anotherTempStr stringByReplacingOccurrencesOfString:@":" withString:@""];
//                NSRange change30 = [anotherTempStr rangeOfString:@"3"];
//                if (change30.location == 3) {
//                    anotherTempStr = [anotherTempStr stringByReplacingCharactersInRange:NSMakeRange(3, 1) withString:@"5"];
//                }
                tz = anotherTempStr;
                secondsFromGmt = [anotherTempStr integerValue]*36;
                break;
            }
            default:{
                secondsFromGmt = 0;
                tz = @"+0000";
                break;
            }
        }
//        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        //        NSLog(@"Seconds from GMT: %ld and detected TimeZone: %@", secondsFromGmt, [df timeZone]);
        [theCalEntity setColor:[theCal objectForKey:@"color"]];
        
        
        NSDateComponents *comp = [[NSCalendar currentCalendar] componentsInTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0] fromDate:[[df dateFromString:[NSString stringWithFormat:@"%@%@",[theCal objectForKey:@"start"],tz]] dateToTimeZone:[NSTimeZone systemTimeZone] fromTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]]];
       
        NSDate *endDate = [[df dateFromString:[NSString
                                               stringWithFormat:@"%@%@",[theCal objectForKey:@"end"],tz]] dateToTimeZone:[NSTimeZone systemTimeZone] fromTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        NSDate *startDate = [[df dateFromString:[NSString
                                                 stringWithFormat:@"%@%@",[theCal objectForKey:@"start"],tz]] dateToTimeZone:[NSTimeZone systemTimeZone] fromTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        NSDate *newEventDate = [NSDate dateWithYear:comp.year month:comp.month day:comp.day inTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

        
        BOOL dst = [[[NSCalendar currentCalendar] timeZone] isDaylightSavingTimeForDate:startDate];
        // BOOL dst = [[[NSCalendar currentCalendar] timeZone] isDaylightSavingTime];
        
        NSLog(@"dst --- %d", dst);
        if(dst){
            //newEventDate = [newEventDate dateByAddingHours:-1.0];
            startDate = [startDate dateByAddingHours:-1.0];
            endDate = [endDate dateByAddingHours:-1.0];
        }
        [theCalEntity setEventDate:newEventDate];
//        NSLog(@"Date Locialized: %@",[NSDateFormatter localizedStringFromDate:[theCalEntity eventDate] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle]);
        [theCalEntity setEventID:[theCal objectForKey:@"EventId"]];
        [theCalEntity setEventtypeid:[theCal objectForKey:@"EventTypeId"]];
        [theCalEntity setCategory:[self getCategoryWithID:[theCal objectForKey:@"EventTypeId"] forCalendar:CalendarID]];
        [theCalEntity setCalendarname:[theCal objectForKey:@"calendarname"]];
        [theCalEntity setCategoryname:[theCal objectForKey:@"category"]];
        [theCalEntity setClassname:[theCal objectForKey:@"className"]];
        [theCalEntity setEndtime:endDate];
        [theCalEntity setFullday:[[theCal objectForKey:@"fullday"] boolValue]];
        [theCalEntity setNotes:[theCal objectForKey:@"notes"]];
        [theCalEntity setStarttime:startDate];
        [theCalEntity setTitle:[theCal objectForKey:@"title"]];
        [theCalEntity setTimezone:tz];
        [theCalEntity setCalendar:[self getCalendarWithID:CalendarID]];
        [theCalEntity setLastUpdated:[NSDate date]];
        [theCalEntity setEventdescription:[theCal objectForKey:@"desc"]];
        [theCalEntity setEventtypename:[theCal objectForKey:@"EventTypeName"]];
        [theCalEntity setCalendarYear:[[[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[theCalEntity starttime]] year]];
        @try {
            YBEventSyncToCalenderService *service = [YBEventSyncToCalenderService sharedSyncService];
            [service createEventFor:theCalEntity ifUpdate:isUpdate];
        } @catch (NSException *exception) {
            NSError *err = [NSError errorWithDomain:@"Unable to write data to native calander store" code:2000 userInfo:nil];
            return err;
        }
        
    }
    @catch(NSException *exception){
        NSError *err = [NSError errorWithDomain:@"Unable to write data to store" code:1000 userInfo:nil];
        return err;
    }
    return nil;
}

-(void)authorizeToSaveInCalendar{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self displayAlertViewWithTitle:@"Calendar" andMsg:@"Please authorize the application to access your calendar to save events on your phone."];
    });
}
-(void)displayAlertViewWithTitle:(NSString *)title andMsg:(NSString *)msg{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:msg
                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    [alert addAction:ok];
    [((UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController]).topViewController presentViewController:alert animated:YES completion:nil];
}

@end

/*
 >(UTC-12:00) International Date Line West
 >(UTC-11:00) Midway Island, Samoa
 3">(UTC-10:00) Hawaii
 4">(UTC-09:00) Alaska (Anchorage)
 5">(UTC-08:00) Pacific Time (US &amp; Canada)
 6">(UTC-08:00) Tijuana, Baja California
 7">(UTC-07:00) Chihuahua, La Paz, Mazatlan - Old
 8">(UTC-07:00) Mountain Time (US &amp; Canada)
 9">(UTC-07:00) Chihuahua, La Paz, Mazatlan - New
 10">(UTC-07:00) Arizona
 11">(UTC-06:00) Central Time (US &amp; Canada)
 12">(UTC-06:00) Saskatchewan
 13">(UTC-06:00) Guadalajara, Mexico City, Monterrey - New
 14">(UTC-06:00) Guadalajara, Mexico City, Monterrey - Old
 15">(UTC-06:00) Central America
 16">(UTC-05:00) Indiana (East)
 17">(UTC-05:00) Eastern Time (US &amp; Canada)
 18">(UTC-05:00) Bogota, Lima, Quito, Rio Branco
 19">(UTC-04:00) Atlantic Time (Canada)
 20">(UTC-04:00) Manaus
 21">(UTC-04:00) Caracas, La Paz
 22">(UTC-04:00) Santiago
 23">(UTC-03:30) Newfoundland
 24">(UTC-03:00) Brasilia
 25">(UTC-03:00) Buenos Aires, Georgetown
 26">(UTC-03:00) Greenland
 27">(UTC-03:00) Montevideo
 28">(UTC-02:00) Mid-Atlantic
 29">(UTC-01:00) Cape Verde Is.
 30">(UTC-01:00) Azores
 31">(UTC) Casablanca, Monrovia, Reykjavik
 32">(UTC) Greenwich Mean Time : Dublin, Edinburgh, Lisbon, London
 33">(UTC+01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague
 34">(UTC+01:00) Sarajevo, Skopje, Warsaw, Zagreb
 35">(UTC+01:00) West Central Africa
 36">(UTC+01:00) Brussels, Copenhagen, Madrid, Paris
 37">(UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna
 38">(UTC+02:00) Minsk
 39">(UTC+02:00) Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius
 40">(UTC+02:00) Athens, Bucharest, Istanbul
 41">(UTC+02:00) Cairo
 42">(UTC+02:00) Jerusalem
 43">(UTC+02:00) Beirut
 44">(UTCCC+02:00) Amman
 45">(UTC+02:00) Windhoek
 46">(UTC+02:00) Harare, Pretoria
 47">(UTC+03:00) Moscow, St. Petersburg, Volgograd
 48">(UTC+03:00) Tbilisi
 49">(UTC+03:00) Nairobi
 50">(UTC+03:00) Baghdad
 51">(UTC+03:00) Kuwait, Riyadh
 52">(UTC+03:30) Tehran
 53">(UTC+04:00) Abu Dhabi, Muscat
 54">(UTC+04:00) Yerevan
 55">(UTC+04:00) Baku
 56">(UTC+04:30) Kabul
 57">(UTC+05:00) Islamabad, Karachi, Tashkent
 58">(UTC+05:00) Ekaterinburg
 59">(UTC+05:30) Chennai, Kolkata, Mumbai, New Delhi
 60">(UTC+05:30) Sri Jayawardenepura
 61">(UTC+05:45) Kathmandu
 62">(UTC+06:00) Almaty, Novosibirsk
 63">(UTC+06:00) Astana, Dhaka
 64">(UTC+06:30) Yangon (Rangoon)
 65">(UTC+07:00) Krasnoyarsk
 66">(UTC+07:00) Bangkok, Hanoi, Jakarta
 67">(UTC+08:00) Kuala Lumpur, Singapore
 68">(UTC+08:00) Irkutsk, Ulaan Bataar
 69">(UTC+08:00) Perth
 70">(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi
 71">(UTC+08:00) Taipei
 72">(UTC+09:00) Osaka, Sapporo, Tokyo
 73">(UTC+09:00) Yakutsk
 74">(UTC+09:00) Seoul
 75">(UTC+09:30) Darwin
 76">(UTC+09:30) Adelaide
 77">(UTC+10:00) Hobart
 78">(UTC+10:00) Brisbane
 79">(UTC+10:00) Canberra, Melbourne, Sydney
 80">(UTC+10:00) Guam, Port Moresby
 81">(UTC+10:00) Vladivostok
 99">(UTC+11:00) Magadan, Solomon Is., New Caledonia
 83">(UTC+12:00) Auckland, Wellington
 84">(UTC+12:00) Fiji, Kamchatka, Marshall Is.
 85">(UTC+13:00) Nukualofa
 */
