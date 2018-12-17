//
//  UCErrorModel.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/12/17.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UCErrorModel.h"

static NSString * domain = @"ucloud.cn";
static const int KUCInvalidArguments = -2;
static const int KUCInvalidElements = -3; // instance array or dictionary error

@implementation UCError

- (instancetype)init:(UCErrorType)type
            sysError:(NSError *)error
{
    if (self = [super init]) {
        _type = type;
        _error = error;
    }
    return self;
}

+ (instancetype)sysErrorWithInvalidArgument:(NSString *)desc
{
    NSError *error = [[NSError alloc] initWithDomain:domain code:KUCInvalidArguments userInfo:@{@"error":desc}];
    return [[self alloc] init:UCErrorType_Sys sysError:error];
}

+ (instancetype)sysErrorWithInvalidElements:(NSString *)desc
{
    NSError *error = [[NSError alloc] initWithDomain:domain code:KUCInvalidElements userInfo:@{@"error":desc}];
    return [[self alloc] init:UCErrorType_Sys sysError:error];
}

+ (instancetype)sysErrorWithError:(NSError *)error
{
    return [[self alloc] init:UCErrorType_Sys sysError:error];
}

@end
