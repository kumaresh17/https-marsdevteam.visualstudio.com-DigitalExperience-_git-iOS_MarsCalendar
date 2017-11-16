//
//  YBMonthCalendarDateCell.h
//  Yearbook
//
//  Created by Urmil Setia on 07/12/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import <FSCalendar/FSCalendar.h>

@interface YBMonthCalendarDateCell : FSCalendarCell
-(void)configureCellWithEvents:(NSMutableArray *)arryOfevents;
-(void)setViewEmpty;
@end
