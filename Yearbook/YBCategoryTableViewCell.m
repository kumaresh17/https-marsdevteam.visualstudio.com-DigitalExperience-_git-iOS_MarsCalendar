//
//  YBCategoryTableViewCell.m
//  Yearbook
//
//  Created by Urmil Setia on 25/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBCategoryTableViewCell.h"
#import "YBHourTableViewCell.h"
@interface YBCategoryTableViewCell ()
@property (weak, nonatomic) IBOutlet UIView *categoryColor;
@property (weak, nonatomic) IBOutlet UILabel *CategoryName;
@end

@implementation YBCategoryTableViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

-(void)configureCellWithName:(NSString *)CategoryName andColor:(NSString *)color andGuid:(NSString *)categoryguid{
    self.CategoryName.text = CategoryName;
    self.categoryColor.backgroundColor = [YBHourTableViewCell colorFromHexString:color];
    self.CategoryGuid = categoryguid;
//    [self setSelected:isSelected animated:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

#pragma mark - Utility Functions

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


