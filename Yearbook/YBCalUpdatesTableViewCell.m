//
//  YBCalUpdatesTableViewCell.m
//  Yearbook
//
//  Created by Urmil Setia on 12/01/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//

#import "YBCalUpdatesTableViewCell.h"

@interface YBCalUpdatesTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *calendarName;
@property (weak, nonatomic) IBOutlet UILabel *updateContent;

@end

@implementation YBCalUpdatesTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureCellWithCalendarName:(NSString *)CalendarName andContent:(NSString *)content{
    self.calendarName.text = CalendarName;
    self.updateContent.text = content;
//    NSLog(@"Height: %f", [self getLabelHeight:self.updateContent]);
}

#pragma mark - Utility Functions

- (CGFloat)getLabelHeight:(UILabel*)label
{
    CGSize constraint = CGSizeMake(label.frame.size.width, CGFLOAT_MAX);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [label.text boundingRectWithSize:constraint
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:label.font}
                                                  context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}

@end
