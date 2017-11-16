//
//  YBLoadMoreTableViewCell.m
//  Yearbook
//
//  Created by Urmil Setia on 12/12/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBLoadMoreTableViewCell.h"

@interface YBLoadMoreTableViewCell ()
@property (weak, nonatomic) IBOutlet UIButton *loadMoreButton;
@property(nonnull, strong) NSString *year;
@end

@implementation YBLoadMoreTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureCellWithYear:(NSString *)nextYear{
    self.year = nextYear;
    [self.loadMoreButton setTitle:[NSString stringWithFormat:@"Show events For %@",nextYear] forState:0];
}

- (IBAction)LoadMoreButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(loadMoreButtonTapped:)]) {
        [self.delegate loadMoreButtonTapped:sender];
    }
}

@end
