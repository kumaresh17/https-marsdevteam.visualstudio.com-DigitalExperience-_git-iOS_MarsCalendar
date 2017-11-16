//
//  YBMonthCalendarDateCell.m
//  Yearbook
//
//  Created by Urmil Setia on 07/12/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBMonthCalendarDateCell.h"
#import "YBEvents+CoreDataClass.h"
#import "YBHourTableViewCell.h"

#define factoredResult(Point, percentage) (Point*percentage)
#define defaultBackgroundColor @"#D7E3FD"
#define moreEventsBackgroundColor @"#C0C0C0"
#define eventViewHeight factoredResult(factoredResult(CGRectGetHeight(self.frame),.63),.33)

@interface YBMonthCalendarDateCell ()
@property(nonatomic,strong) NSMutableArray *theEventsForTheDate;

@end

@implementation YBMonthCalendarDateCell

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
    if (self) {
        
    }
    return self;
}

-(void)configureCellWithEvents:(NSMutableArray *)arryOfevents{
    self.theEventsForTheDate = arryOfevents;
    UIView *removeView = [[self contentView] viewWithTag:9];
    [removeView removeFromSuperview];
    [self.contentView addSubview:[self eventsViews]];
}

-(void)setViewEmpty{
    UIView *removeView = [[self contentView] viewWithTag:9];
    [removeView removeFromSuperview];
}

-(UIView *)eventsViews{
    CGRect rect = CGRectMake(factoredResult(CGRectGetWidth(self.frame),.05), factoredResult(CGRectGetHeight(self.frame),.36), factoredResult(CGRectGetWidth(self.frame),.96), factoredResult(CGRectGetHeight(self.frame),.63));
    UIView *blockView = [[UIView alloc] initWithFrame:rect];
    [blockView setTag:9];
    CGFloat fixedHeight = rect.size.height*.33;
    
    NSInteger countOfEvents = [self.theEventsForTheDate count];
    switch (countOfEvents) {
        case 0:
            break;
        case 1:{
            CGRect eventRect = CGRectMake(factoredResult(rect.origin.x,.95), factoredResult((eventViewHeight+1),0), factoredResult(CGRectGetWidth(rect),.90), fixedHeight);
            [blockView addSubview:[self eventView:eventRect WithEvent:self.theEventsForTheDate[0]]];
            break;
        }
        case 2:{
            for (int i = 0; i <2; i++) {
                CGRect eventRect = CGRectMake(factoredResult(rect.origin.x,.95), factoredResult((eventViewHeight+1),i), factoredResult(CGRectGetWidth(rect),.90), fixedHeight);
                [blockView addSubview:[self eventView:eventRect WithEvent:self.theEventsForTheDate[i]]];
            }
            break;
        }
        case 3:{
            for (int i = 0; i <3; i++) {
                CGRect eventRect = CGRectMake(factoredResult(rect.origin.x,.95), factoredResult((eventViewHeight+1),i), factoredResult(CGRectGetWidth(rect),.90), fixedHeight);
                [blockView addSubview:[self eventView:eventRect WithEvent:self.theEventsForTheDate[i]]];
            }
            break;
        }
        default:{
            for (int i = 0; i <2; i++) {
                CGRect eventRect = CGRectMake(factoredResult(rect.origin.x,.95), factoredResult((eventViewHeight+1),i), factoredResult(CGRectGetWidth(rect),.90), fixedHeight);
                [blockView addSubview:[self eventView:eventRect WithEvent:self.theEventsForTheDate[i]]];
            }
            CGRect eventRect = CGRectMake(factoredResult(rect.origin.x,.95), factoredResult((eventViewHeight+1),2), factoredResult(CGRectGetWidth(rect),.90), fixedHeight);
            [blockView addSubview:[self moreEventsView:eventRect AndCount:countOfEvents-2]];
            break;
        }
    }
    return blockView;
}

-(UIView *)eventView:(CGRect)eventRect WithEvent:(YBEvents *)event{
    UIView *eventView = [[UIView alloc] initWithFrame:eventRect];
    [eventView setBackgroundColor:[YBHourTableViewCell colorFromHexString:defaultBackgroundColor]];
    UIView *eventColorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, factoredResult(CGRectGetWidth(eventRect), .1), CGRectGetHeight(eventRect))];
    eventColorView.backgroundColor = [YBHourTableViewCell colorFromHexString:[event color]];
    
    UILabel *eventLbl = [[UILabel alloc] initWithFrame:CGRectMake(factoredResult(CGRectGetWidth(eventRect),.12), factoredResult(CGRectGetWidth(eventRect), 0), factoredResult(CGRectGetWidth(eventRect), .88), CGRectGetHeight(eventRect))];
    [eventLbl setText:[event title]];
    [eventLbl setFont:[UIFont systemFontOfSize:10]];
    //    [eventLbl setMinimumScaleFactor:7.0/[UIFont labelFontSize]];
    //    [eventLbl setAdjustsFontSizeToFitWidth:YES];
    [eventLbl setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
    [eventView addSubview:eventColorView];
    [eventView addSubview:eventLbl];
    
    return eventView;
}

-(UIView *)moreEventsView:(CGRect)eventRect AndCount:(unsigned long)number{
    UIView *eventView = [[UIView alloc] initWithFrame:eventRect];
    [eventView setBackgroundColor:[YBHourTableViewCell colorFromHexString:defaultBackgroundColor]];
    UIView *eventColorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, factoredResult(CGRectGetWidth(eventRect), .1), CGRectGetHeight(eventRect))];
    eventColorView.backgroundColor = [YBHourTableViewCell colorFromHexString:moreEventsBackgroundColor];
    
    UILabel *eventLbl = [[UILabel alloc] initWithFrame:CGRectMake(factoredResult(CGRectGetWidth(eventRect),.12), factoredResult(CGRectGetWidth(eventRect), 0), factoredResult(CGRectGetWidth(eventRect), .88), CGRectGetHeight(eventRect))];
    [eventLbl setText:[NSString stringWithFormat:@"%lu more",number]];
    [eventLbl setFont:[UIFont systemFontOfSize:10]];
    //    [eventLbl setMinimumScaleFactor:7.0/[UIFont labelFontSize]];
    //    [eventLbl setAdjustsFontSizeToFitWidth:YES];
    [eventLbl setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
    [eventView addSubview:eventColorView];
    [eventView addSubview:eventLbl];
    return eventView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //    NSLog(@"Before %@",NSStringFromCGRect(self.shapeLayer.frame));
    CGRect oldFrame =  self.titleLabel.frame;
    self.titleLabel.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, factoredResult(oldFrame.size.height,.4));
    //35% on the top is Selection area.
    self.shapeLayer.frame = CGRectMake(self.shapeLayer.frame.origin.x, factoredResult(self.frame.size.height,0), self.shapeLayer.frame.size.width, self.shapeLayer.frame.size.height);
    //    NSLog(@"After %@",NSStringFromCGRect(self.shapeLayer.frame));
}

#pragma mark - Utility Functions

- (UIColor *) colorFromHexString:(NSString *)hexString {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
