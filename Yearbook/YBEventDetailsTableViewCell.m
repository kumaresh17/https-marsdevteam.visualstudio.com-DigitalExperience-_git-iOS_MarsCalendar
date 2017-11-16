//
//  YBEventDetailsTableViewCell.m
//  Yearbook
//
//  Created by Urmil Setia on 09/01/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//

#import "YBEventDetailsTableViewCell.h"
#import "DateTools.h"

@interface YBEventDetailsTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *eventName;
@property (weak, nonatomic) IBOutlet UILabel *eventDate;
@property (weak, nonatomic) IBOutlet UILabel *eventTime;

@end

@implementation YBEventDetailsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)configureCellWithEvent:(YBEvents *)event{
    self.eventName.text = event.title;
    NSDate *startDate = event.starttime;
    NSDate *endDate = event.endtime;
    NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
    if ([startDate isSameDay:endDate withTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]]) {
        [df1 setDateFormat:@"hh:mma"];
        [df1 setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        NSDateFormatter *dfDate = [[NSDateFormatter alloc] init];
        [dfDate setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dfDate setLocalizedDateFormatFromTemplate:@"yyyy-MM-dd"];
        
        self.eventDate.text = [dfDate stringFromDate:startDate];
        self.eventTime.text = [NSString stringWithFormat:@"from %@ to %@",[df1 stringFromDate:startDate],[df1 stringFromDate:endDate]];
    }
    else{
        [df1 setDateFormat:@"hh:mma"];
        [df1 setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        NSDateFormatter *dfDate = [[NSDateFormatter alloc] init];
        [dfDate setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dfDate setLocalizedDateFormatFromTemplate:@"hh:mma yyyy-MM-dd"];
        
        self.eventDate.text = [NSString stringWithFormat:@"from %@",[dfDate stringFromDate:startDate]];
        self.eventTime.text = [NSString stringWithFormat:@"to %@",[dfDate stringFromDate:endDate]];
    }
}

@end
