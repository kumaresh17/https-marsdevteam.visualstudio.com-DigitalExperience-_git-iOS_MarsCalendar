//
//  YBEventDtCalTableViewCell.m
//  Yearbook
//
//  Created by Urmil Setia on 09/01/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//

#import "YBEventDtCalTableViewCell.h"

@implementation YBEventDtCalTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)configureCellWithName:(NSString *)CalendarName{
    self.detailTextLabel.text = CalendarName;
}

@end
