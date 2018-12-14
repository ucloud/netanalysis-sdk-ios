//
//  UNetReportResponseBean.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/10/18.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UNetReportResponseBean.h"

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
        NSDictionary *metaDict  = [dict objectForKey:@"meta"];
        NSDictionary *dataDict  = [dict objectForKey:@"data"];
        if (metaDict != NULL && [metaDict isKindOfClass:[NSDictionary class]]) {
            self.meta = [UNetMetaBean metaBeanWithDict:metaDict];
        }
        if (dataDict != NULL && [dataDict isKindOfClass:[NSDictionary class]]) {
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
