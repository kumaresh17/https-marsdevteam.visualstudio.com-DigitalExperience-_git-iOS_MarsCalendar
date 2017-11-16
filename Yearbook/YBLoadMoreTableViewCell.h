//
//  YBLoadMoreTableViewCell.h
//  Yearbook
//
//  Created by Urmil Setia on 12/12/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YBLoadMoreButton;

@interface YBLoadMoreTableViewCell : UITableViewCell
@property (nonatomic, assign) id<YBLoadMoreButton> delegate;
-(void)configureCellWithYear:(NSString *)nextYear;
@end

@protocol YBLoadMoreButton <NSObject>

-(void)loadMoreButtonTapped:(id)sender;

@end
