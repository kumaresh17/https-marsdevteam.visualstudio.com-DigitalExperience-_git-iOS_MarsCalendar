//
//  YBDismissSegue.m
//  Yearbook
//
//  Created by Urmil Setia on 27/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBDismissSegue.h"

@implementation YBDismissSegue

-(void)perform{
    UIViewController *sourceViewController = self.sourceViewController;
    [sourceViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];

}
@end
