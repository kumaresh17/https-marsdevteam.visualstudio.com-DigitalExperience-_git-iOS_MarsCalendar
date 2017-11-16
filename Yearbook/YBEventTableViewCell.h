//
//  YBEventTableViewCell.h
//  Yearbook
//
//  Created by Urmil Setia on 28/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YBEvents;

@interface YBEventTableViewCell : UITableViewCell
-(void)configureCellWithEvent:(YBEvents *)event;
@end
