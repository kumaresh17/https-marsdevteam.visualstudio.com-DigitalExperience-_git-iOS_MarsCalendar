//
//  YBUser+CoreDataProperties.h
//  Yearbook
//
//  Created by Urmil Setia on 24/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "YBUser+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface YBUser (CoreDataProperties)

+ (NSFetchRequest<YBUser *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *delveMyDriveURLString;
@property (nullable, nonatomic, copy) NSString *emailAddressForFeedback;
@property (nullable, nonatomic, copy) NSString *emailAddressForTechnicalSupport;
@property (nullable, nonatomic, copy) NSDate *lastRefresh;
@property (nullable, nonatomic, copy) NSString *loginName;
@property (nullable, nonatomic, copy) NSString *loginEmail;

@end

NS_ASSUME_NONNULL_END
