//
//  UNetIpListBean.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/10/18.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UNetMetaBean.h"

@interface UNetDataBean : NSObject
@property (nonatomic,copy) NSArray *info;
@property (nonatomic,copy) NSArray *url;

- (NSArray *)uGetUHosts;
+ (instancetype)dataBeanWithDict:(NSDictionary *)dict;
@end

@interface UNetIpBean : NSObject
@property (nonatomic,copy) NSString *location;
@property (nonatomic,copy) NSString *ip;

+ (instancetype)ipBeanWithDict:(NSDictionary *)dict;
@end

@interface UNetIpListBean : NSObject
@property (nonatomic,strong) UNetMetaBean *meta;
@property (nonatomic,strong) UNetDataBean *data;

+ (instancetype)ipListBeanWithDict:(NSDictionary *)dict;
@end
