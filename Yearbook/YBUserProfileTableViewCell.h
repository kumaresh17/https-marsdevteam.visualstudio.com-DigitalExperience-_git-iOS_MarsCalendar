//
//  YBUserProfileTableViewCell.h
//  Yearbook
//
//  Created by Urmil Setia on 14/12/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YBUserProfileTableViewCell : UITableViewCell
-(void)configureCellWithProfileURL:(NSURL *)URL version:(NSString*)appVersion andName:(NSString *)name;
@property (weak, nonatomic) IBOutlet UIButton *UserProfilePictureButton;
@end
