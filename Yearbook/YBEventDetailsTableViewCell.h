//
//  YBEventDetailsTableViewCell.h
//  Yearbook
//
//  Created by Urmil Setia on 09/01/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YBEvents+CoreDataClass.h"

@interface YBEventDetailsTableViewCell : UITableViewCell
-(void)configureCellWithEvent:(YBEvents *)event;
@end
