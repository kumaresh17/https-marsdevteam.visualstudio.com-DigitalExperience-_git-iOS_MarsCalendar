//
//  YBCalendarTableViewCell.m
//  Yearbook
//
//  Created by Urmil Setia on 25/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBCalendarTableViewCell.h"

@interface YBCalendarTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *CalendarName;
@end

@implementation YBCalendarTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)configureCellWithName:(NSString *)CategoryName andColor:(NSString *)color{
    self.CalendarName.text = [NSString stringWithFormat:@"All %@",CategoryName];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else if (selected == FALSE){
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

@end
