//
//  UCModel.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/12/17.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UCModel.h"
#import "UNetAppInfo.h"
#import "UNetTools.h"
#import <objc/runtime.h>

@implementation UCIpPingResult

- (instancetype)initUIpPingResultWithIp:(NSString *)ip loss:(int)loss delay:(float)delay
{
    if (self = [super init]) {
        _ip = ip;
        _loss = loss;
        _delay = delay;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"ip:%@, loss:%d, delay:%d",_ip,_loss,_delay];
}
@end

@implementation UCManualNetDiagResult

- (instancetype)initWithPingRes:(NSMutableArray *)pingRes
{
    if (self = [super init]) {
        _networkType = [UNetAppInfo uGetNetworkType];
        _pingInfo = pingRes;
    }
    return self;
}

+ (instancetype)instanceWithPingRes:(NSMutableArray *)pingRes
{
    return [[self alloc] initWithPingRes:pingRes];
}

@end


@implementation UCServerError

- (instancetype)initWithCode:(NSInteger)code
                      errMsg:(NSString *)errMsg
{
    if (self = [super init]) {
        _code = code;
        _errMsg = errMsg;
    }
    return self;
}

+ (instancetype)instanceWithCode:(NSInteger)code
                                 errMsg:(NSString *)errMsg
{
    return [[self alloc] initWithCode:code errMsg:errMsg];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"code: %ld , errMsg:%@",(long)self.code,self.errMsg];
}

@end



static NSString * domain = @"ucloud.cn";
static const int KUCInvalidArguments = -2;
static const int KUCInvalidElements = -3; // instance array or dictionary error
static const int KUCInvalidCondition = -4;

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

- (instancetype)init:(UCErrorType)type
            sysError:(NSError *)error
         serverError:(UCServerError *)serverError
{
    if (self  = [self init:type sysError:error]) {
        _serverError = serverError;
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

+ (instancetype)sysErrorWithInvalidCondition:(NSString *)desc
{
    NSError *error = [[NSError alloc] initWithDomain:domain code:KUCInvalidCondition userInfo:@{@"error":desc}];
    return [[self alloc] init:UCErrorType_Sys sysError:error];
}

+ (instancetype)sysErrorWithError:(NSError *)error
{
    return [[self alloc] init:UCErrorType_Sys sysError:error];
}

+ (instancetype)httpErrorWithServerError:(UCServerError *)serverError
{
    return [[self alloc] init:UCErrorType_Server sysError:nil serverError:serverError];
}

@end




