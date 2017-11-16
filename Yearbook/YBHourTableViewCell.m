//
//  YBHourTableViewCell.m
//  Yearbook
//
//  Created by Urmil Setia on 18/01/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//

#import "YBHourTableViewCell.h"
#import "YBViewWithEvent.h"

typedef NS_ENUM(NSInteger,kHourCellType) {
    HourCellStartNode,
    HourCellContinuingNode,
    HourCellStartandEndNode,
    HourCellEndNode
};
@interface YBHourTableViewCell ()
@property (weak, nonatomic) IBOutlet UIView *topSeparator;
@property (nonatomic, strong) NSMutableArray *eventsForTimeSlotArry;
//- (void)AddStartEvent:(YBEvents *)event withStartingTime:(NSInteger)time atPosition:(CGFloat)position;
//- (void)AddContinuingEvent:(YBEvents *)event atPosition:(CGFloat)position;
//- (void)AddEndEvent:(YBEvents *)event withEndingTime:(NSInteger)time atPosition:(CGFloat)position;
@end

@implementation YBHourTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)configureCellWithPositions:(NSMutableArray *)eventsArry{
    self.eventsForTimeSlotArry = eventsArry;
    
    //Clear out all the old Views except the Label and 1px TopBar.
    for (id uielement in [self.contentView subviews]) {
        if (([uielement class] == [YBViewWithEvent class]) && ([uielement tag] != 99)) {
            [uielement removeFromSuperview];
        }
    }
    //If no result then return.
    if ([eventsArry count] <= 0) {
        return;
    }
    NSUInteger indentFactor = 0;
    //Continuing Node Magic
    NSArray *allElementsForContinuingMode = [self.eventsForTimeSlotArry filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@" (SELF.startingMinutes == nil) AND (SELF.endingMinutes == nil)"]];
    if ([allElementsForContinuingMode count] > 0) {
//        NSLog(@"Setting a ContinuingCell");
        indentFactor++; //= [allElementsForContinuingMode count];
        [self plotViewsWithContinuingEvents:[allElementsForContinuingMode mutableCopy]];
    }
    
    //Ending NodeMagic
    NSArray *allElementsForEndingMode = [self.eventsForTimeSlotArry filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF.startingMinutes == nil) AND (SELF.endingMinutes != nil)"]];
    if ([allElementsForEndingMode count] > 0) {
//        NSLog(@"Setting a EndingCell");
        [self plotViewsWithEndingEvents:[allElementsForEndingMode mutableCopy]];
    }
    
    //Starting Nodes Magic
    NSMutableDictionary *fiveMinSlotDict = [NSMutableDictionary dictionaryWithCapacity:0];
    for (int i = 0; i < 60; i = i+5) {
        NSArray *allElementsOnTimeSlot = [self.eventsForTimeSlotArry filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.startingMinutes == %ld", i]];
        if ([allElementsOnTimeSlot count] >0) {
            [fiveMinSlotDict setObject:[allElementsOnTimeSlot mutableCopy] forKey:[NSNumber numberWithInt:i]];
        }
    }
    
    [fiveMinSlotDict enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
//        NSLog(@"Setting a StartingCell");
        [self plotViewsOnSlotWithStartEvents:obj withStartingTime:[key integerValue] withIndentation:indentFactor];
    }];
    
    
    //    if ([allElementsOnTimeSlot count] >0) {
    //        fiveMinSlotDict = [NSMutableDictionary dictionaryWithObject:[allElementsOnTimeSlot mutableCopy] forKey:[NSNumber numberWithInt:i]];
    //        //                    [fiveMinSlotDict setObject:[NSNumber numberWithUnsignedInteger:[allElementsOnTimeSlot count]] forKey:@"TotalObjects"];
    //
    //    }
    
    
    
    
    //    for (NSMutableDictionary *dict in self.eventsForTimeSlotArry) {
    //        //StartingNode
    //
    //        //EndingNode
    //        if ([dict objectForKey:@"endingMinutes"]) {
    //            //            id a= [self addEvent:[dict objectForKey:@"event"] withTimeMarker1:[[dict objectForKey:@"endingMinutes"] integerValue] andTimeMarker2:0 atPosition:0 AndCellType:HourCellEndNode];
    //        }
    //        //StartingNode and EndingNode in Same Hour
    //        else if ([dict objectForKey:@"startingMinutes"] && [dict objectForKey:@"endingMinutes"]) {
    //            //            [self addEvent:[dict objectForKey:@"event"] withTimeMarker1:[[dict objectForKey:@"startingMinutes"] integerValue] andTimeMarker2:[[dict objectForKey:@"endingMinutes"] integerValue] atPosition:0 AndCellType:HourCellStartandEndNode];
    //        }
    //        //ContinuingNode
    //        else{
    //            //            [self addEvent:[dict objectForKey:@"event"] withTimeMarker1:0 andTimeMarker2:0 atPosition:0 AndCellType:HourCellContinuingNode];
    //        }
    //    }
}

-(void)plotViewsOnSlotWithStartEvents:(NSMutableArray *)events withStartingTime:(NSInteger)time withIndentation:(CGFloat)indent{
    
    NSUInteger totalNumberOfItemsOnSlot = [events count];
    CGFloat eventWidth = (self.frame.size.width-54-10-(indent*10))/totalNumberOfItemsOnSlot;
    //Loop the Array
    for (int i = 0; i <[events count]; i++) {
        int spacer = 0.f;
        if (i != 0) {
            spacer = 1.f;
        }
        
        if ([[events objectAtIndex:i] objectForKey:@"endingMinutes"] != nil) {
            //The event has an ending here.
            [self AddEndEvent:[[events objectAtIndex:i] objectForKey:@"event"] havingEndingTime:[[events objectAtIndex:i] objectForKey:@"endingMinutes"] withIndentation:(indent*10)+(i*eventWidth)+spacer andWidth:eventWidth-spacer hasStartingTime:TRUE];
        }
        else{
            [self AddStartEvent:[[events objectAtIndex:i] objectForKey:@"event"] withStartingTime:[[[events objectAtIndex:i] objectForKey:@"startingMinutes"] integerValue] withIndentation:(indent*10)+(i*eventWidth)+spacer andWidth:eventWidth-spacer];
            [self saveIndentationForEventID:[(YBEvents *)[[events objectAtIndex:i] objectForKey:@"event"] eventID] WithHIndent:[NSNumber numberWithFloat:(indent*10)+(i*eventWidth)+spacer] andWithVInden:[NSNumber numberWithFloat:0.f] andWidth:[NSNumber numberWithFloat:eventWidth-spacer]];
        }
    }
}

-(void)plotViewsWithContinuingEvents:(NSMutableArray *)events{
    //Loop the Array
    for (int i = 0; i <[events count]; i++) {
        YBEvents *ev = (YBEvents *)[[events objectAtIndex:i] objectForKey:@"event"];
        [self AddContinuingEvent:ev withIndentation:[[self getHorIndentationForEventID:[ev eventID]] floatValue] andWidth:[[self getWidthForEventID:[ev eventID]] floatValue]];
    }
}

-(void)plotViewsWithEndingEvents:(NSMutableArray *)events{
    //Loop the Array
    for (int i = 0; i <[events count]; i++) {
        YBEvents *ev = (YBEvents *)[[events objectAtIndex:i] objectForKey:@"event"];
        int spacer = 0.f;
        if (i != 0) {
            spacer = 1.f;
        }
        [self AddEndEvent:ev havingEndingTime:[[events objectAtIndex:i] objectForKey:@"endingMinutes"] withIndentation:[[self getHorIndentationForEventID:[ev eventID]] floatValue] andWidth:[[self getWidthForEventID:[ev eventID]] floatValue] hasStartingTime:FALSE];
    }
}

//-(int)addEvent:(YBEvents *)event withTimeMarker1:(NSInteger)time1 andTimeMarker2:(NSInteger)time2 withIndentation:(CGFloat)indent AndCellType:(kHourCellType)type{
//    switch (type) {
//        case HourCellStartNode:{
//            //          id a =  [self AddStartEvent:event withStartingTime:time1 withIndentation:indent];
//
//            return 0;
//            break;
//        }
//        case HourCellContinuingNode:{
////            [self AddContinuingEvent:event withIndentation:indent];
//            return 0;
//            break;
//        }
//        case HourCellStartandEndNode:{
//            [self AddStartEvent:event withStartingTime:time1 andEndingTime:time2 withIndentation:indent];
//            return 0;
//            break;
//        }
//        case HourCellEndNode:{
////            [self AddEndEvent:event withEndingTime:time1 withIndentation:indent];
//            return 0;
//            break;
//        }
//        default:
//            break;
//    }
//    return 0;
//}

-(void)AddStartEvent:(YBEvents *)event withStartingTime:(NSInteger)time withIndentation:(CGFloat)indent andWidth:(CGFloat)eventWidth{
    YBViewWithEvent *eventView = [self getViewWithGestures];
    [eventView setBackgroundColor:[[YBHourTableViewCell colorFromHexString:[event color]] colorWithAlphaComponent:0.2]];
    [eventView setEventID:[event eventID]];
    [self.contentView addSubview:eventView];
    //    CGFloat inset = 10.f * (float)position;
    CGFloat multipler = (self.contentView.frame.size.height-1.f)/60;
    CGFloat timefactor = time * multipler;
    //    CGFloat widthFactor = time * multipler;
    //Trailing Constraint between view and Content View
    //    NSLayoutConstraint *trailing =[NSLayoutConstraint
    //                                   constraintWithItem:eventView
    //                                   attribute:NSLayoutAttributeTrailing
    //                                   relatedBy:NSLayoutRelationEqual
    //                                   toItem:self.contentView
    //                                   attribute:NSLayoutAttributeTrailing
    //                                   multiplier:1.0f
    //                                   constant:0.f];
    
    //Leading Constraint between view and Top separator
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:eventView
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.topSeparator
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:0.f+indent];
    
    //Bottom Constraint between view and Content View
    NSLayoutConstraint *bottom =[NSLayoutConstraint
                                 constraintWithItem:eventView
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self.contentView
                                 attribute:NSLayoutAttributeBottom
                                 multiplier:1.0f
                                 constant:0.f];
    
    //Top Constraint between view and Top separator
    NSLayoutConstraint *top = [NSLayoutConstraint
                               constraintWithItem:eventView
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.topSeparator
                               attribute:NSLayoutAttributeBottom
                               multiplier:1.f
                               constant:0.f+timefactor];//-8.f//+inset
    
    //Top Constraint between view and Top separator
    NSLayoutConstraint *width = [NSLayoutConstraint
                                 constraintWithItem:eventView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.f
                                 constant:0.f+eventWidth];//-8.f//+inset
    
    
    //    [self.contentView addConstraint:trailing];
    [self.contentView addConstraint:bottom];
    [self.contentView addConstraint:leading];
    [self.contentView addConstraint:top];
    [eventView addConstraint:width];
    
    //Left Hand Border
    UIView *borderView = [[UIView alloc] init];
    borderView.translatesAutoresizingMaskIntoConstraints = NO;
    [borderView setBackgroundColor:[YBHourTableViewCell colorFromHexString:[event color]]];
    
    [eventView addSubview:borderView];
    //Leading Constraint between view and Top separator
    NSLayoutConstraint *leadingBor = [NSLayoutConstraint constraintWithItem:borderView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:eventView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0];
    
    //Bottom Constraint between view and Content View
    NSLayoutConstraint *bottomBor =[NSLayoutConstraint constraintWithItem:borderView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:eventView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
    
    //Top Constraint between view and Top separator
    NSLayoutConstraint *topBor = [NSLayoutConstraint constraintWithItem:borderView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:eventView attribute:NSLayoutAttributeTop multiplier:1.f constant:0];
    
    //Top Constraint between view and Top separator
    NSLayoutConstraint *widthBor = [NSLayoutConstraint constraintWithItem:borderView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:2];
    
    [eventView addConstraint:bottomBor];
    [eventView addConstraint:leadingBor];
    [eventView addConstraint:topBor];
    [borderView addConstraint:widthBor];
    
    //Label with Event Description
    UILabel *eventTitle = [[UILabel alloc] init];
    eventTitle.translatesAutoresizingMaskIntoConstraints = NO;
    eventTitle.numberOfLines = 2;
    [eventTitle setFont:[UIFont boldSystemFontOfSize:17.f]];
    eventTitle.adjustsFontSizeToFitWidth = YES;
    
    eventTitle.minimumScaleFactor = 0.3;
    //    [eventTitle setShadowColor:[UIColor blackColor]];
    //    [eventTitle setShadowOffset:CGSizeMake(1, -2)];
    [eventTitle setTextColor:[YBHourTableViewCell colorFromHexString:[event color]]];
    eventTitle.text = [event title];
    [eventView addSubview:eventTitle];
    
    //Constraints
    NSLayoutConstraint *leadingLabel = [NSLayoutConstraint constraintWithItem:eventTitle attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:borderView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:5.f];
    
    //Top Constraint between view and Top separator
    NSLayoutConstraint *topLabel = [NSLayoutConstraint constraintWithItem:eventTitle attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:eventView attribute:NSLayoutAttributeTop multiplier:1.f constant:1.f];
    [topLabel setPriority:UILayoutPriorityRequired];
    
    NSLayoutConstraint *trailingLabel =[NSLayoutConstraint constraintWithItem:eventTitle attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:eventView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:2.f];
    
    //Bottom Constraint between view and Top separator
    NSLayoutConstraint *bottomLabel = [NSLayoutConstraint constraintWithItem:eventTitle attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:eventView attribute:NSLayoutAttributeBottom multiplier:1.f constant:1.f];
    
    [bottomLabel setPriority:UILayoutPriorityDefaultHigh];
    
    [eventView addConstraint:leadingLabel];
    [eventView addConstraint:trailingLabel];
    [eventView addConstraint:topLabel];
    [eventView addConstraint:bottomLabel];
    
}

-(void)AddStartEvent:(YBEvents *)event withStartingTime:(NSInteger)time1 andEndingTime:(NSInteger)time2 withIndentation:(CGFloat)indent{
    YBViewWithEvent *eventView = [self getViewWithGestures];
    [eventView setBackgroundColor:[YBHourTableViewCell colorFromHexString:[event color]]];
    eventView.layer.borderColor = [YBHourTableViewCell colorFromHexString:[event color]].CGColor;
    eventView.layer.borderWidth = 1;
    [eventView setEventID:[event eventID]];
    [eventView setTag:8];
    [self.contentView addSubview:eventView];
#warning need to work on this as well
    CGFloat inset = 10.f * (float)indent;
    CGFloat multipler = (self.contentView.frame.size.height-1.f)/60;
    CGFloat timefactor1 = time1 * multipler;
    CGFloat timefactor2 = time2 * multipler;
    //Trailing Constraint between view and Content View
    NSLayoutConstraint *trailing =[NSLayoutConstraint
                                   constraintWithItem:eventView
                                   attribute:NSLayoutAttributeTrailing
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.contentView
                                   attribute:NSLayoutAttributeTrailing
                                   multiplier:1.0f
                                   constant:0.f];
    
    //Leading Constraint between view and Top separator
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:eventView
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.topSeparator
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:0.f+inset];
    
    //Bottom Constraint between view and Content View
    NSLayoutConstraint *bottom =[NSLayoutConstraint
                                 constraintWithItem:eventView
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self.contentView
                                 attribute:NSLayoutAttributeBottom
                                 multiplier:1.0f
                                 constant:0.f+timefactor2];
    
    //Top Constraint between view and Top separator
    NSLayoutConstraint *top = [NSLayoutConstraint
                               constraintWithItem:eventView
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.topSeparator
                               attribute:NSLayoutAttributeBottom
                               multiplier:1.f
                               constant:0.f+timefactor1];//-8.f//+inset
    
    
    [self.contentView addConstraint:trailing];
    [self.contentView addConstraint:bottom];
    [self.contentView addConstraint:leading];
    [self.contentView addConstraint:top];
    
}


-(void)AddContinuingEvent:(YBEvents *)event withIndentation:(CGFloat)indent andWidth:(CGFloat)eventWidth{
    YBViewWithEvent *eventView = [self getViewWithGestures];
    [eventView setEventID:[event eventID]];
    [eventView setBackgroundColor:[[YBHourTableViewCell colorFromHexString:[event color]] colorWithAlphaComponent:0.2]];
    [self.contentView addSubview:eventView];
    
    //    CGFloat inset = 10.f * indent;
    
    //Trailing Constraint between view and Content View
    NSLayoutConstraint *trailing =[NSLayoutConstraint
                                   constraintWithItem:eventView
                                   attribute:NSLayoutAttributeTrailing
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.contentView
                                   attribute:NSLayoutAttributeTrailing
                                   multiplier:1.0f
                                   constant:0.f];
    
    //Leading Constraint between view and Top separator
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:eventView
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.topSeparator
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:0.f+indent];
    
    //Bottom Constraint between view and Content View
    NSLayoutConstraint *bottom =[NSLayoutConstraint
                                 constraintWithItem:eventView
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self.contentView
                                 attribute:NSLayoutAttributeBottom
                                 multiplier:1.0f
                                 constant:0.f];
    
    //Top Constraint between view and Top separator
    NSLayoutConstraint *top = [NSLayoutConstraint
                               constraintWithItem:eventView
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.topSeparator
                               attribute:NSLayoutAttributeBottom
                               multiplier:1.f
                               constant:0.f];//-8.f//+inset
    //Top Constraint between view and Top separator
    NSLayoutConstraint *width = [NSLayoutConstraint
                                 constraintWithItem:eventView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.f
                                 constant:0.f+eventWidth];
    
    //    [self.contentView addConstraint:trailing];
    [self.contentView addConstraint:bottom];
    [self.contentView addConstraint:leading];
    [self.contentView addConstraint:top];
    [eventView addConstraint:width];
    
    //Left Hand Border
    UIView *borderView = [[UIView alloc] init];
    borderView.translatesAutoresizingMaskIntoConstraints = NO;
    [borderView setBackgroundColor:[YBHourTableViewCell colorFromHexString:[event color]]];
    
    [eventView addSubview:borderView];
    //Leading Constraint between view and Top separator
    NSLayoutConstraint *leadingBor = [NSLayoutConstraint constraintWithItem:borderView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:eventView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0];
    
    //Bottom Constraint between view and Content View
    NSLayoutConstraint *bottomBor =[NSLayoutConstraint constraintWithItem:borderView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:eventView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
    
    //Top Constraint between view and Top separator
    NSLayoutConstraint *topBor = [NSLayoutConstraint constraintWithItem:borderView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:eventView attribute:NSLayoutAttributeTop multiplier:1.f constant:0];
    
    //Top Constraint between view and Top separator
    NSLayoutConstraint *widthBor = [NSLayoutConstraint constraintWithItem:borderView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:2];
    
    [eventView addConstraint:bottomBor];
    [eventView addConstraint:leadingBor];
    [eventView addConstraint:topBor];
    [borderView addConstraint:widthBor];
}

-(void)AddEndEvent:(YBEvents *)event havingEndingTime:(NSNumber *)endingTime withIndentation:(CGFloat)indent andWidth:(CGFloat)eventWidth hasStartingTime:(BOOL)startingTime{
    YBViewWithEvent *eventView = [self getViewWithGestures];
    [eventView setTag:10];
    [eventView setEventID:[event eventID]];
    [eventView setBackgroundColor:[[YBHourTableViewCell colorFromHexString:[event color]] colorWithAlphaComponent:0.2]];
    [self.contentView addSubview:eventView];
    
    CGFloat multipler = (self.contentView.frame.size.height-1.f)/60;
    CGFloat endTimeFactor = (60.f - (([endingTime floatValue] == 0)?60.f:[endingTime floatValue])) * multipler;
    
    //Trailing Constraint between view and Content View
    //    NSLayoutConstraint *trailing =[NSLayoutConstraint
    //                                   constraintWithItem:eventView
    //                                   attribute:NSLayoutAttributeTrailing
    //                                   relatedBy:NSLayoutRelationEqual
    //                                   toItem:self.contentView
    //                                   attribute:NSLayoutAttributeTrailing
    //                                   multiplier:1.0f
    //                                   constant:0.f];
    
    //Leading Constraint between view and Top separator
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:eventView
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.topSeparator
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:0.f+indent];
    
    //Bottom Constraint between view and Content View
    NSLayoutConstraint *bottom =[NSLayoutConstraint
                                 constraintWithItem:self.contentView
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:eventView
                                 attribute:NSLayoutAttributeBottom
                                 multiplier:1.0f
                                 constant:endTimeFactor+5.f];
    
    //Top Constraint between view and Top separator
    NSLayoutConstraint *top = [NSLayoutConstraint
                               constraintWithItem:eventView
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.topSeparator
                               attribute:NSLayoutAttributeBottom
                               multiplier:1.f
                               constant:0.f];//-8.f//+inset
    //Top Constraint between view and Top separator
    NSLayoutConstraint *width = [NSLayoutConstraint
                                 constraintWithItem:eventView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.f
                                 constant:0.f+eventWidth];
    
    [self.contentView addConstraint:bottom];
    [self.contentView addConstraint:leading];
    [self.contentView addConstraint:top];
    [eventView addConstraint:width];
    
    //Left Hand Border
    UIView *borderView = [[UIView alloc] init];
    borderView.translatesAutoresizingMaskIntoConstraints = NO;
    [borderView setBackgroundColor:[YBHourTableViewCell colorFromHexString:[event color]]];
    
    [eventView addSubview:borderView];
    //Leading Constraint between view and Top separator
    NSLayoutConstraint *leadingBor = [NSLayoutConstraint constraintWithItem:borderView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:eventView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0];
    
    //Bottom Constraint between view and Content View
    NSLayoutConstraint *bottomBor =[NSLayoutConstraint constraintWithItem:borderView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:eventView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
    
    //Top Constraint between view and Top separator
    NSLayoutConstraint *topBor = [NSLayoutConstraint constraintWithItem:borderView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:eventView attribute:NSLayoutAttributeTop multiplier:1.f constant:0];
    
    //Top Constraint between view and Top separator
    NSLayoutConstraint *widthBor = [NSLayoutConstraint constraintWithItem:borderView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:2];
    
    [eventView addConstraint:bottomBor];
    [eventView addConstraint:leadingBor];
    [eventView addConstraint:topBor];
    [borderView addConstraint:widthBor];
    
    //Special case of Starting and ending time.
    if (startingTime == TRUE) {
        //Label with Event Description
        UILabel *eventTitle = [[UILabel alloc] init];
        eventTitle.translatesAutoresizingMaskIntoConstraints = NO;
        eventTitle.numberOfLines = 2;
        [eventTitle setFont:[UIFont boldSystemFontOfSize:17.f]];
        eventTitle.adjustsFontSizeToFitWidth = YES;
        
        eventTitle.minimumScaleFactor = 0.3;
        //    [eventTitle setShadowColor:[UIColor blackColor]];
        //    [eventTitle setShadowOffset:CGSizeMake(1, -2)];
        [eventTitle setTextColor:[YBHourTableViewCell colorFromHexString:[event color]]];
        eventTitle.text = [event title];
        [eventView addSubview:eventTitle];
        
        //Constraints
        NSLayoutConstraint *leadingLabel = [NSLayoutConstraint constraintWithItem:eventTitle attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:borderView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:5.f];
        
        //Top Constraint between view and Top separator
        NSLayoutConstraint *topLabel = [NSLayoutConstraint constraintWithItem:eventTitle attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:eventView attribute:NSLayoutAttributeTop multiplier:1.f constant:1.f];
        [topLabel setPriority:UILayoutPriorityRequired];
        
        NSLayoutConstraint *trailingLabel =[NSLayoutConstraint constraintWithItem:eventTitle attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:eventView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:2.f];
        
        //Bottom Constraint between view and Top separator
        NSLayoutConstraint *bottomLabel = [NSLayoutConstraint constraintWithItem:eventTitle attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:eventView attribute:NSLayoutAttributeBottom multiplier:1.f constant:1.f];
        
        [bottomLabel setPriority:UILayoutPriorityDefaultHigh];
        
        [eventView addConstraint:leadingLabel];
        [eventView addConstraint:trailingLabel];
        [eventView addConstraint:topLabel];
        [eventView addConstraint:bottomLabel];
    }
}

#pragma mark - Event Tap

-(void)eventViewTapped:(id)sender{
    if ([self.delgate respondsToSelector:@selector(dayEventTappedWithEventID:)]) {
        [self.delgate dayEventTappedWithEventID:[(YBViewWithEvent *)[sender view] eventID]];
    }
}

#pragma mark - Utility Functions

-(YBViewWithEvent *)getViewWithGestures{
    YBViewWithEvent *eventView = [[YBViewWithEvent alloc] init];
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventViewTapped:)];
    eventView.translatesAutoresizingMaskIntoConstraints = NO;
    [eventView addGestureRecognizer:tapGest];
    return eventView;
}

+ (UIColor *) colorFromHexString:(NSString *)hexString{
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

- (void) saveIndentationForEventID:(NSString *)eventID WithHIndent:(NSNumber *)hIndent andWithVInden:(NSNumber *)vIndent andWidth:(NSNumber *)width{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableArray *indents = [[def objectForKey:@"dayViewIndents"] mutableCopy];
    if (!indents) {
        indents = [NSMutableArray arrayWithCapacity:10];
        [def setObject:indents forKey:@"dayViewIndents"];
    }
    NSArray *indentItem  = [indents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.eventID == %@",eventID]];
    if ([indentItem count] > 0) {
        [indents removeObjectsInArray:indentItem];
    }
    NSDictionary *indentDict = @{@"eventID": eventID,@"H.INDENT":hIndent,@"V.INDENT":vIndent,@"Width":width};
    [indents addObject:indentDict];
    [def setObject:indents forKey:@"dayViewIndents"];
    [def synchronize];
}

- (NSNumber *) getHorIndentationForEventID:(NSString *)eventID{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSArray *arry = [def objectForKey:@"dayViewIndents"];
    NSArray *filt = [arry filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.eventID == %@",eventID]];
    if ([filt count]>0) {
        return [filt[0] objectForKey:@"H.INDENT"];
    }
    return 0;
}

- (NSNumber *) getVerIndentationForEventID:(NSString *)eventID{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSArray *arry = [def objectForKey:@"dayViewIndents"];
    NSArray *filt = [arry filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.eventID == %@",eventID]];
    if ([filt count]>0) {
        return [filt[0] objectForKey:@"V.INDENT"];
    }
    return 0;
}

- (NSNumber *) getWidthForEventID:(NSString *)eventID{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSArray *arry = [def objectForKey:@"dayViewIndents"];
    NSArray *filt = [arry filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.eventID == %@",eventID]];
    if ([filt count]>0) {
        return [filt[0] objectForKey:@"Width"];
    }
    return 0;
}

+ (CGFloat)heightOfCellWithIngredientLine:(NSString *)ingredientLine
                       withSuperviewWidth:(CGFloat)superviewWidth
{
    CGFloat labelWidth                  = superviewWidth - 30.0f;
    //    use the known label width with a maximum height of 100 points
    CGSize labelContraints              = CGSizeMake(labelWidth, 100.0f);
    
    NSStringDrawingContext *context     = [[NSStringDrawingContext alloc] init];
    
    CGRect labelRect                    = [ingredientLine boundingRectWithSize:labelContraints
                                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                                    attributes:nil
                                                                       context:context];
    
    //    return the calculated required height of the cell considering the label
    return labelRect.size.height;
}

@end
