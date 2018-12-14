//
//  UNetMetaBean.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/10/18.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UNetMetaBean.h"

@implementation UNetMetaBean
- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.code = [[dict objectForKey:@"code"] integerValue];
        self.error = [dict objectForKey:@"error"];
    }
    return self;
}

+ (instancetype)metaBeanWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"code:%d ,error:%@",(int)self.code,self.error];
}

@end
