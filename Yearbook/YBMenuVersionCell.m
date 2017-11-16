//
//  YBMenuVersionCell.m
//  Yearbook
//
//  Created by Urmil Setia on 21/03/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//

#import "YBMenuVersionCell.h"
@interface YBMenuVersionCell ()
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation YBMenuVersionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = [NSString stringWithFormat:@"v%@",version];
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
