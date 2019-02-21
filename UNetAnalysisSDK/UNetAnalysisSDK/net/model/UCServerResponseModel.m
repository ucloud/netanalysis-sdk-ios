//
//  UCServerResponseModel.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/12/26.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UCServerResponseModel.h"

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

@implementation UNetDataBean:NSObject
- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        if (dict == NULL) {
            return self;
        }
        
        NSArray *infoArray = nil;
        if ([[dict objectForKey:@"info"] isKindOfClass:[NSArray class]]) {
            infoArray = [dict objectForKey:@"info"];
        }
        if (!infoArray) {
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
        if ([[dict objectForKey:@"meta"] isKindOfClass:[NSDictionary class]]) {
             NSDictionary *metaDict = [dict objectForKey:@"meta"];
            self.meta = [UNetMetaBean metaBeanWithDict:metaDict];
        }
        if ([[dict objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = [dict objectForKey:@"data"];
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

@implementation UIpInfoModel

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        _addr = dict[@"addr"] == NULL ? @"" : dict[@"addr"];
        _city_name = dict[@"city_name"] == NULL ? @"" : dict[@"city_name"];
        _continent_code = dict[@"continent_code"] == NULL ? @"" : dict[@"continent_code"];
        _country_code = dict[@"country_code"] == NULL ? @"" : dict[@"country_code"];
        _country_name = dict[@"country_name"] == NULL ? @"" : dict[@"country_name"];
        _isp_domain = dict[@"isp_domain"] == NULL ? @"" : dict[@"isp_domain"];
        _latitude = dict[@"latitude"] == NULL ? @"" : dict[@"latitude"];
        _longitude = dict[@"longitude"] == NULL ? @"" : dict[@"longitude"];
        _owner_domain = dict[@"owner_domain"] == NULL ? @"" : dict[@"owner_domain"];
        _region_name = dict[@"region_name"] == NULL ? @"" : dict[@"region_name"];
        _timezone = dict[@"timezone"] == NULL ? @"" : dict[@"timezone"];
        _utc_offset = dict[@"utc_offset"] == NULL ? @"" : dict[@"utc_offset"];
    }
    return self;
}

+ (instancetype)uIpInfoModelWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (NSDictionary *)objConvertToDict
{
    return @{@"addr":self.addr,@"city_name":self.city_name,@"continent_code":self.continent_code,@"country_code":self.country_code,@"isp_domain":self.isp_domain,@"latitude":self.latitude,@"longitude":self.longitude,@"owner_domain":self.owner_domain,@"region_name":self.region_name,@"timezone":self.timezone,@"utc_offset":self.utc_offset};
}

- (NSString *)objConvertToReportStr
{
    return [NSString stringWithFormat:@"ip=%@,city=%@,country=%@,isp=%@,lat=%@,lon=%@,owner=%@,region=%@",self.addr,self.city_name,
            self.country_name,self.isp_domain,self.latitude,self.longitude,self.owner_domain,self.region_name];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"addr:%@ , city_name:%@ , continent_code:%@ , country_code:%@ , isp_domain:%@ , latitude:%@ , longitude:%@ , owner_domain:%@ , region_name:%@ , timezone:%@ , utc_offset:%@",self.addr,self.city_name,self.continent_code,self.country_code,self.isp_domain,self.latitude,self.longitude,self.owner_domain,self.region_name,self.timezone,self.utc_offset];
}


@end


@implementation UNetReportResponseDataBean
- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.message = [dict objectForKey:@"message"];
    }
    return self;
}

+ (instancetype)reportResponseDataWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

@end

@implementation UNetReportResponseBean
- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        
        if ([[dict objectForKey:@"meta"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *metaDict = [dict objectForKey:@"meta"];
            self.meta = [UNetMetaBean metaBeanWithDict:metaDict];
        }
        if ([[dict objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = [dict objectForKey:@"data"];
            self.data = [UNetReportResponseDataBean reportResponseDataWithDict:dataDict];
        }
    }
    return self;
}

+ (instancetype)reportResponseWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}
@end
