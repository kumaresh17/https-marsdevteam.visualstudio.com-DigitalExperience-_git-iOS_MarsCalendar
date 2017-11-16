//
//  YBProfileAPI.m
//  Yearbook
//
//  Created by Urmil Setia on 23/11/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBProfileAPI.h"

@implementation YBProfileAPI {
    NSString *theaccessToken;
}

-(id)initWithToken:(NSString *)theToken{
    self = [super init];
    if (self) {
        theaccessToken = [NSString stringWithFormat:@"Bearer %@",theToken];
    }
    return self;
}

- (NSString *)requestUrl {
    return @"/me?api-version=1.6";
}

-(BOOL)useCDN{
    return YES;
}

- (NSDictionary *)requestHeaderFieldValueDictionary {
    NSDictionary *dict = @{@"Authorization": theaccessToken,@"Content-Type":@"application/json"};
    return dict;
}

@end
