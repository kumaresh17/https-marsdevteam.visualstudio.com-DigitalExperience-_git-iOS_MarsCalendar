//
//  YBUserAPI.h
//  Yearbook
//
//  Created by Urmil Setia on 07/12/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import <YTKNetwork/YTKNetwork.h>

@interface YBUserAPI : YTKRequest
-(id)initWithToken:(NSString*)theToken WithYear:(NSString *)theYear andCalendarID:(NSString *)theCalID;
@end
