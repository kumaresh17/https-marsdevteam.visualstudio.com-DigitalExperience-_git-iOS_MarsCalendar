//
//  YBEventDetailsTableViewController.h
//  Yearbook
//
//  Created by Urmil Setia on 06/01/2017.
//  Copyright © 2017 Mars IS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YBEvents+CoreDataClass.h"
@import EventKitUI;

@interface YBEventDetailsTableViewController : UITableViewController<EKEventEditViewDelegate>
@property(nonatomic, strong) YBEvents *selectedEvent;
@end
