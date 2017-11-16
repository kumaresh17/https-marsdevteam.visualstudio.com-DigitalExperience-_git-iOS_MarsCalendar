//
//  YBUser+CoreDataProperties.m
//  Yearbook
//
//  Created by Urmil Setia on 24/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "YBUser+CoreDataProperties.h"

@implementation YBUser (CoreDataProperties)

+ (NSFetchRequest<YBUser *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"YBUser"];
}

@dynamic delveMyDriveURLString;
@dynamic emailAddressForFeedback;
@dynamic emailAddressForTechnicalSupport;
@dynamic lastRefresh;
@dynamic loginName;
@dynamic loginEmail;

@end
