//
//  UCServerResponseModel.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/12/26.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/* 获取ip列表相关的model */
@interface UNetMetaBean : NSObject
@property (nonatomic,assign) NSInteger code;
@property (nonatomic,copy) NSString *error;

+ (instancetype)metaBeanWithDict:(NSDictionary *)dict;
@end


@interface UNetDataBean : NSObject
@property (nonatomic,copy) NSArray *info;
@property (nonatomic,copy) NSArray *url;
@property (nonatomic,copy) NSString *domain;

- (NSArray *)uGetUHosts;
- (NSMutableArray *)uGetTracertHosts;
+ (instancetype)dataBeanWithDict:(NSDictionary *)dict;
@end

@interface UNetIpBean : NSObject
@property (nonatomic,copy) NSString *location;
@property (nonatomic,copy) NSString *ip;
@property (nonatomic,assign) NSInteger type;

+ (instancetype)ipBeanWithDict:(NSDictionary *)dict;
@end

@interface UNetIpListBean : NSObject
@property (nonatomic,strong) UNetMetaBean *meta;
@property (nonatomic,strong) UNetDataBean *data;

+ (instancetype)ipListBeanWithDict:(NSDictionary *)dict;
@end

/* 手机公网信息model */
@interface UIpInfoModel : NSObject

@property (nonatomic,readonly) NSString *addr;
@property (nonatomic,readonly) NSString *city_name;
@property (nonatomic,readonly) NSString *continent_code;
@property (nonatomic,readonly) NSString *country_code;
@property (nonatomic,readonly) NSString *country_name;
@property (nonatomic,readonly) NSString *isp_domain;
@property (nonatomic,readonly) NSString *latitude;
@property (nonatomic,readonly) NSString *longitude;
@property (nonatomic,readonly) NSString *owner_domain;
@property (nonatomic,readonly) NSString *region_name;
@property (nonatomic,readonly) NSString *timezone;
@property (nonatomic,readonly) NSString *utc_offset;



+ (instancetype)uIpInfoModelWithDict:(NSDictionary *)dict;
- (NSString *)objConvertToReportStr;

@end


/* 上报ping&tracert时服务器返回信息的model */
@interface UNetReportResponseDataBean: NSObject
@property (nonatomic,copy) NSString *message;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)reportResponseDataWithDict:(NSDictionary *)dict;
@end

@interface UNetReportResponseBean : NSObject
@property (nonatomic,strong) UNetMetaBean *meta;
@property (nonatomic,strong) UNetReportResponseDataBean *data;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)reportResponseWithDict:(NSDictionary *)dict;
@end
NS_ASSUME_NONNULL_END
