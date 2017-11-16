// Copyright (c) Microsoft Corporation.
// All rights reserved.
//
// This code is licensed under the MIT License.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ADTelemetry.h"
#import "ADTelemetryAPIEvent.h"
#import "ADUserInformation.h"
#import "ADTelemetryEventStrings.h"
#import "ADHelpers.h"

@implementation ADTelemetryAPIEvent

- (void)setResultStatus:(ADAuthenticationResultStatus)status
{
    NSString* statusStr = nil;
    switch (status) {
        case AD_SUCCEEDED:
            statusStr = AD_TELEMETRY_SUCCEEDED;
            break;
        case AD_FAILED:
            statusStr = AD_TELEMETRY_FAILED;
            break;
        case AD_USER_CANCELLED:
            statusStr = AD_TELEMETRY_USER_CANCELLED;
            [self setProperty:AD_TELEMETRY_USER_CANCEL value:AD_TELEMETRY_YES];
            break;
        default:
            statusStr = AD_TELEMETRY_UNKNOWN;
    }
    
    [self setProperty:AD_TELEMETRY_RESULT_STATUS value:statusStr];
}

- (void)setCorrelationId:(NSUUID *)correlationId
{
    [self setProperty:AD_TELEMETRY_CORRELATION_ID value:[correlationId UUIDString]];
}

- (void)setExtendedExpiresOnSetting:(NSString *)extendedExpiresOnSetting
{
    [self setProperty:AD_TELEMETRY_EXTENDED_EXPIRES_ON_SETTING value:extendedExpiresOnSetting];
}

- (void)setUserInformation:(ADUserInformation *)userInfo
{
    [self setProperty:AD_TELEMETRY_USER_ID value:[[userInfo userId] adComputeSHA256]];
    [self setProperty:AD_TELEMETRY_TENANT_ID value:[[userInfo tenantId] adComputeSHA256]];
    [self setProperty:AD_TELEMETRY_IDP value:[userInfo identityProvider]];
}

- (void)setUserId:(NSString *)userId
{
    [self setProperty:AD_TELEMETRY_USER_ID value:[userId adComputeSHA256]];
}

- (void)setClientId:(NSString *)clientId
{
    [self setProperty:AD_TELEMETRY_CLIENT_ID value:clientId];
}

- (void)setIsExtendedLifeTimeToken:(NSString *)isExtendedLifeToken
{
    [self setProperty:AD_TELEMETRY_IS_EXTENED_LIFE_TIME_TOKEN value:isExtendedLifeToken];
}

- (void)setErrorCode:(NSString *)errorCode
{
    [self setProperty:AD_TELEMETRY_ERROR_CODE value:errorCode];
}

- (void)setProtocolCode:(NSString *)protocolCode
{
    [self setProperty:AD_TELEMETRY_PROTOCOL_CODE value:protocolCode];
}

- (void)setErrorDescription:(NSString *)errorDescription
{
    [self setProperty:AD_TELEMETRY_ERROR_DESCRIPTION value:errorDescription];
}

- (void)setErrorDomain:(NSString *)errorDomain
{
    [self setProperty:AD_TELEMETRY_ERROR_DOMAIN value:errorDomain];
}

- (void)setAuthorityValidationStatus:(NSString *)status
{
    [self setProperty:AD_TELEMETRY_AUTHORITY_VALIDATION_STATUS value:status];
}

- (void)setAuthority:(NSString *)authority
{
    [self setProperty:AD_TELEMETRY_AUTHORITY value:authority];
    
    // set authority type
    NSString* authorityType = AD_TELEMETRY_AUTHORITY_AAD;
    if ([ADHelpers isADFSInstance:authority])
    {
        authorityType = AD_TELEMETRY_AUTHORITY_ADFS;
    }
    [self setProperty:AD_TELEMETRY_AUTHORITY_TYPE value:authorityType];
}

- (void)setGrantType:(NSString *)grantType
{
    [self setProperty:AD_TELEMETRY_GRANT_TYPE value:grantType];
}

- (void)setAPIStatus:(NSString *)status
{
    [self setProperty:AD_TELEMETRY_API_STATUS value:status];
}

- (void)setApiId:(NSString *)apiId
{
    [self setProperty:AD_TELEMETRY_API_ID value:apiId];
}

- (void)setPromptBehavior:(ADPromptBehavior)promptBehavior
{
    NSString* promptBehaviorString = nil;
    switch (promptBehavior) {
        case AD_PROMPT_AUTO:
            promptBehaviorString = @"AD_PROMPT_AUTO";
            break;
        case AD_PROMPT_ALWAYS:
            promptBehaviorString = @"AD_PROMPT_ALWAYS";
            break;
        case AD_PROMPT_REFRESH_SESSION:
            promptBehaviorString = @"AD_PROMPT_REFRESH_SESSION";
            break;
        case AD_FORCE_PROMPT:
            promptBehaviorString = @"AD_FORCE_PROMPT";
            break;
        default:
            promptBehaviorString = AD_TELEMETRY_UNKNOWN;
    }
    
    [self setProperty:AD_TELEMETRY_PROMPT_BEHAVIOR value:promptBehaviorString];
}

- (void)addAggregatedPropertiesToDictionary:(NSMutableDictionary *)eventToBeDispatched
{
    [super addAggregatedPropertiesToDictionary:eventToBeDispatched];
    
    NSArray* properties = [self getProperties];
    for (ADTelemetryProperty* property in properties)
    {
        if ([property.name isEqualToString:AD_TELEMETRY_AUTHORITY_TYPE]
            ||[property.name isEqualToString:AD_TELEMETRY_AUTHORITY_VALIDATION_STATUS]
            ||[property.name isEqualToString:AD_TELEMETRY_EXTENDED_EXPIRES_ON_SETTING]
            ||[property.name isEqualToString:AD_TELEMETRY_PROMPT_BEHAVIOR]
            ||[property.name isEqualToString:AD_TELEMETRY_RESULT_STATUS]
            ||[property.name isEqualToString:AD_TELEMETRY_IDP]
            ||[property.name isEqualToString:AD_TELEMETRY_TENANT_ID]
            ||[property.name isEqualToString:AD_TELEMETRY_USER_ID]
            ||[property.name isEqualToString:AD_TELEMETRY_RESPONSE_TIME]
            ||[property.name isEqualToString:AD_TELEMETRY_CLIENT_ID]
            ||[property.name isEqualToString:AD_TELEMETRY_API_ID]
            ||[property.name isEqualToString:AD_TELEMETRY_USER_CANCEL]
            ||[property.name isEqualToString:AD_TELEMETRY_ERROR_CODE]
            ||[property.name isEqualToString:AD_TELEMETRY_ERROR_DOMAIN]
            ||[property.name isEqualToString:AD_TELEMETRY_PROTOCOL_CODE]
            ||[property.name isEqualToString:AD_TELEMETRY_ERROR_DESCRIPTION])
        {
            [eventToBeDispatched setObject:property.value forKey:property.name];
        }
    }
}

@end