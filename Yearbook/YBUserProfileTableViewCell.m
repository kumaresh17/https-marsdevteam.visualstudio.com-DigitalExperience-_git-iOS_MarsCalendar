//
//  YBUserProfileTableViewCell.m
//  Yearbook
//
//  Created by Urmil Setia on 14/12/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBUserProfileTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface YBUserProfileTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *UserProfilePicture;
@property (weak, nonatomic) IBOutlet UILabel *UserName;
@property (weak, nonatomic) IBOutlet UILabel *AppVersionLabel;
@end


@implementation YBUserProfileTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

-(void)configureCellWithProfileURL:(NSURL *)URL version:(NSString*)appVersion andName:(NSString *)name{
    
    //Get URL
    //Get Token
    //Hit Webservice
    //Get URL back
    //Set URL and token to Image
    
    if (URL) {
        [self.UserProfilePicture sd_setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"filled_Profile_placeholder"] options:SDWebImageRetryFailed];
    }
    self.UserName.text = name;
    self.AppVersionLabel.text = appVersion;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
