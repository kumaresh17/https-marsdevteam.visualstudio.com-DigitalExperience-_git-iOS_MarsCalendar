//
//  YBConstants.m
//  Yearbook
//
//  Created by preeti on 08/06/17.
//  Copyright © 2017 Mars IS. All rights reserved.
//

#import "YBConstants.h"

#define STAGE 0
NSString *const kAppName = @"Mars Calendar";
#if STAGE

NSString *const kLoginAuthority = @"https://login.microsoftonline.com/effem.com/";
NSString *const kAuthClientId = @"691010cd-07f6-44b1-9669-283d250d72ac";
NSString *const kAuthRedirectUri= @"https://preprod.calendar.mars.com";//@"yearbook://yearbook.mars.com";
NSString *const kAuthResourceUri = @"https://stage-calendar.mars.com";//@"https://stage-yearbook.mars.com/";
NSString *const kAuthAzureUri = @"https://graph.windows.net";
NSString *const kCDNUrl = @"https://graph.windows.net/";
NSString *const kBaseUrl = @"https://stage-calendar.mars.com";//@"https://stage-yearbook.mars.com/";
 
#else
NSString *const kLoginAuthority = @"https://login.microsoftonline.com/effem.com/";
NSString *const kAuthClientId = @"ebada356-62a9-42fb-a5fe-1be3e0bd86b7";//@"691010cd-07f6-44b1-9669-283d250d72ac";
NSString *const kAuthRedirectUri = @"https://calendar.mars.com/";//@"https://preprod.calendar.mars.com";
NSString *const kAuthResourceUri = @"https://calendar.mars.com/";//@"https://graph.windows.net";
NSString *const kAuthAzureUri = @"https://graph.windows.net";
NSString *const kCDNUrl = @"https://graph.windows.net/";
NSString *const kBaseUrl = @"https://calendar.mars.com/";
#endif


/*
 CalendarAPI
 Sign-on URL     https://calendar.mars.com
 App ID URI      https://calendar.mars.com/CalendarAPI/
 */

/*
 CalendarAPI
 Sign-on URL     https://stage-calendar.mars.com
 App ID URI      https://calendar.mars.com/CalendarAPI/
 */
