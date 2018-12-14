//
//  UNetIpListBean.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/10/18.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UNetIpListBean.h"

@implementation UNetDataBean:NSObject
- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        if (dict == NULL) {
            return self;
        }
        
        NSArray *infoArray = [dict objectForKey:@"info"];
        if (infoArray == NULL || ![infoArray isKindOfClass:[NSArray class]]) {
            return self;
        }
        NSMutableArray *ipArray = [NSMutableArray array];
        for (NSDictionary *eleDict in infoArray) {
            
            if ([eleDict isKindOfClass:[NSDictionary class]]) {
                UNetIpBean *ipBean = [UNetIpBean ipBeanWithDict:eleDict];
                [ipArray addObject:ipBean];
            }
            
        }
        self.info = ipArray;
        self.url = [dict objectForKey:@"url"];
    }
    return self;
}

+ (instancetype)dataBeanWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (NSArray *)uGetUHosts
{
    NSMutableArray *uhosts = [NSMutableArray array];
    for (UNetIpBean *ipBean in self.info) {
        [uhosts addObject:ipBean.ip];
    }
    return uhosts;
}

- (NSString *)description
{
    NSMutableString *info = [NSMutableString stringWithString:@"{"];
    for (UNetIpBean *ipBean in self.info) {
        [info appendString:ipBean.description];
        [info appendString:@"\n"];
    }
    [info appendString:@"},\n"];
    
    for (NSString *eleURL in self.url) {
        [info appendString:eleURL];
        [info appendString:@"\n"];
    }
    [info appendString:@"},\n"];
    return info;
}

@end

@implementation UNetIpBean:NSObject

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.location = [dict objectForKey:@"location"];
        self.ip = [dict objectForKey:@"ip"];
    }
    return self;
}

+ (instancetype)ipBeanWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (NSString *)description
{
    return  [NSString stringWithFormat:@"location:%@ , ip:%@",self.location,self.ip];
}
@end

@implementation UNetIpListBean

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        NSDictionary *metaDict = [dict objectForKey:@"meta"];
        NSDictionary *dataDict = [dict objectForKey:@"data"];
        if (metaDict != NULL && [metaDict isKindOfClass:[NSDictionary class]]) {
             self.meta = [UNetMetaBean metaBeanWithDict:metaDict];
        }
        if (dataDict != NULL && [metaDict isKindOfClass:[NSDictionary class]]) {
            self.data = [UNetDataBean dataBeanWithDict:dataDict];
        }
        
    }
    return self;
}

+ (instancetype)ipListBeanWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

@end

