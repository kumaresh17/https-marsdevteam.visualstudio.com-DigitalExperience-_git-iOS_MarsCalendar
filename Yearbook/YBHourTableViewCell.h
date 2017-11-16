//
//  YBHourTableViewCell.h
//  Yearbook
//
//  Created by Urmil Setia on 18/01/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YBEvents+CoreDataClass.h"

@protocol DayViewEventTap;

@interface YBHourTableViewCell : UITableViewCell

- (void)configureCellWithPositions:(NSMutableArray *)eventsArry;

@property (weak, nonatomic) IBOutlet UILabel *TimeLabel;
@property(nonatomic,assign) id<DayViewEventTap> delgate;
+ (UIColor *) colorFromHexString:(NSString *)hexString;
@end

@protocol DayViewEventTap <NSObject>

- (void)dayEventTappedWithEventID:(NSString *)eventID;
@end
