//
//  YBWebViewViewController.h
//  Yearbook
//
//  Created by Urmil Setia on 15/12/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YBWebViewViewController : UIViewController<UIWebViewDelegate>
-(void)loadAction:(NSURL *)URL;
@end
