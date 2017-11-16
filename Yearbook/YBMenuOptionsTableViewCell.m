//
//  YBMenuOptionsTableViewCell.m
//  Yearbook
//
//  Created by Urmil Setia on 14/12/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBMenuOptionsTableViewCell.h"


@interface YBMenuOptionsTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *Label;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@end

@implementation YBMenuOptionsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)configureCellWithName:(NSString *)name andImageName: (NSString*)iconImage{
    self.Label.text = name;
    self.iconImage.image = nil;
    if(![iconImage isEqualToString:@""]){
        self.iconImage.image = [UIImage imageNamed:iconImage];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
