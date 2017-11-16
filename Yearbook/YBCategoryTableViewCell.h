//
//  YBCategoryTableViewCell.h
//  Yearbook
//
//  Created by Urmil Setia on 25/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YBCategoryTableViewCell : UITableViewCell
-(void)configureCellWithName:(NSString *)CategoryName andColor:(NSString *)color andGuid:(NSString *)categoryguid;
@property (strong, nonatomic) NSString *CategoryGuid;
@end
