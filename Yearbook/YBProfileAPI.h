//
//  YBProfileAPI.h
//  Yearbook
//
//  Created by Urmil Setia on 23/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import <YTKNetwork/YTKNetwork.h>

@interface YBProfileAPI : YTKRequest
-(id)initWithToken:(NSString *)theToken;
@end
