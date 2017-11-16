//
//  YBMenuTableViewController.h
//  Yearbook
//
//  Created by Urmil Setia on 14/12/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YBMenu;
@import MessageUI;

@interface YBMenuTableViewController : UITableViewController <MFMailComposeViewControllerDelegate>
@property(assign, nonatomic) id<YBMenu> delegate;
@end

@protocol YBMenu <NSObject>
-(void)UserSignedOut;
@end
