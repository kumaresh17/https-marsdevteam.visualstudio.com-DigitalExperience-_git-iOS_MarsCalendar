//
//  YBEventTableViewCell.m
//  Yearbook
//
//  Created by Urmil Setia on 28/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBEventTableViewCell.h"
#import "YBEvents+CoreDataClass.h"
#import "YBCalendars+CoreDataClass.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "YBHourTableViewCell.h"

@interface YBEventTableViewCell ()
@property(nonatomic, strong) YBEvents *event;
@property (weak, nonatomic) IBOutlet UIView *eventColor;
@property (weak, nonatomic) IBOutlet UILabel *eventDateTime;
@property (weak, nonatomic) IBOutlet UILabel *eventName;
@property (weak, nonatomic) IBOutlet UIImageView *calendarIcon;
@property (weak, nonatomic) IBOutlet UILabel *eventCategory;
@end

@implementation YBEventTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureCellWithEvent:(YBEvents *)event{
    self.event = event;
    self.eventColor.backgroundColor = [YBHourTableViewCell colorFromHexString:event.color];
    self.eventName.text = event.title;
    self.eventCategory.text = event.categoryname;
    self.eventDateTime.text = [self timeToDisplay];
    [self.calendarIcon sd_setImageWithURL:[NSURL URLWithString:([[(YBCalendars *)event.calendar calendarlogo] length] > 0)?[(YBCalendars *)event.calendar calendarlogo]:nil] placeholderImage:[UIImage imageNamed:@"placeholder_yearbook"] options:SDWebImageRetryFailed];
}

#pragma mark - Utility Functions

-(NSString *)timeToDisplay{
    NSDate *startDate = self.event.starttime;
    NSDate *endDate = self.event.endtime;
//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
//    [df setDateFormat:@"dd/MM/yyyy"];
    NSDateFormatter *dfDate = [[NSDateFormatter alloc] init];
    NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
    [df1 setDateFormat:@"hh:mma"];
    [df1 setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dfDate setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dfDate setLocalizedDateFormatFromTemplate:@"yyyy-MM-dd"];
//    [df1 setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:[[NSTimeZone systemTimeZone] secondsFromGMT]]];
//    NSLog(@"TimeZone: %@",[NSString stringWithFormat:@"start: %@, end: %@ and zone: %@ dftime: %@ time: %@",startDate,endDate,self.event.timezone,[df stringFromDate:startDate],[df1 stringFromDate:startDate]]);
//    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
//    NSLog(@"Str: %ld",(long)[[[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitMinute | NSCalendarUnitHour fromDate:startDate] hour]);
    
    return [NSString stringWithFormat:@"%@ - %@ to %@",[dfDate stringFromDate:startDate],[df1 stringFromDate:startDate],[df1 stringFromDate:endDate]];
}

- (UIColor *) colorFromHexString:(NSString *)hexString {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
/*
 -(NSString *)timeToDisplay{
 NSDate *startDate = self.event.starttime;
 NSDate *endDate = self.event.endtime;
 NSDateFormatter *df = [[NSDateFormatter alloc] init];
 [df setDateFormat:@"dd/MM/yyyy"];
 [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
 NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
 [df1 setDateFormat:@"hha"];
 [df1 setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
 [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
 NSArray *arrytz = [self.event.timezone componentsSeparatedByString:@" "];
 NSTimeZone *tz = [[NSTimeZone alloc] initWithName:[NSString stringWithFormat:@"%@ %@",arrytz[1],arrytz[2]]];
 [tz localizedName:NSTimeZoneNameStyleGeneric locale:nil];
 NSTimeZone *eventTimeZone = [NSTimeZone timeZoneWithName:self.event.timezone];
 NSLog(@"TimeZone: %@",[NSString stringWithFormat:@"start: %@, end: %@ and zone: %@ dftime: %@ time: %@",startDate,endDate,self.event.timezone,[df stringFromDate:startDate],[df1 stringFromDate:startDate]]);
 //    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
 return [NSString stringWithFormat:@"%@ - %@ to %@",[df stringFromDate:startDate],[df1 stringFromDate:startDate],[df1 stringFromDate:endDate]];
 }
 */
