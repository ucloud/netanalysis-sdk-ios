//
//  UCNetInfoReporter.m
//  UCNetDiagnosisDemo
//
//  Created by ethan on 13/08/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UCNetInfoReporter.h"
#import "UNetAnalysisConst.h"
#include "log4cplus.h"
#import "UCServerResponseModel.h"
#import "UCDateTool.h"
#import "UCURLSessionManager.h"
#import "UNetAppInfo.h"
#import "UCRSA.h"
#import "UCModel.h"
#import "UNetTools.h"


/**
 @brief 枚举定义，定义网路请求的类型

 - UCNetOperateType_GetIpInfo: 获取设备公网信息
 - UCNetOperateType_GetIpList: 获取ucloud ip列表
 - UCNetOperateType_DoReport: 对网络状况上报
 */
typedef NS_ENUM(NSUInteger,UCNetOperateType)
{
    UCNetOperateType_GetIpInfo,
    UCNetOperateType_GetIpList,
    UCNetOperateType_DoReport
};

const NSTimeInterval uNetSDKTimeOut =  60.0;

@interface UCNetInfoReporter()

@property (nonatomic,strong) UIpInfoModel *ipInfoModel;
@property (nonatomic,copy) NSArray *reportServiceArray;
@property (nonatomic,strong) UCURLSessionManager *urlSessionManager;
@property (nonatomic,strong) NSString *appKey; // api-key
@property (nonatomic,strong) NSString *appSecret; // rsa public secret key
@property (nonatomic,strong) NSString *userOptField;  // user opt report field

@end


@implementation UCNetInfoReporter

static UCNetInfoReporter *ucNetInfoReporter  = NULL;

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (instancetype)shareInstance
{
    if (ucNetInfoReporter == NULL) {
        ucNetInfoReporter = [[UCNetInfoReporter alloc] init];
    }
    return ucNetInfoReporter;
}

- (void)setAppKey:(NSString *)appKey publickToken:(NSString *)publicToken optReportField:(NSString * _Nullable)field
{
    _appKey = appKey;
    _appSecret = publicToken;
    if (!field) {
        log4cplus_debug("UNetSDK", "user opt field is nil..\n");
        return;
    }
    self.userOptField = [NSString stringWithFormat:@"opt_key=%@",field];
    log4cplus_debug("UNetSDK", "user opt field is: %s",[self.userOptField UTF8String]);
}

- (UCURLSessionManager *)urlSessionManager
{
    if (!_urlSessionManager) {
        _urlSessionManager = [[UCURLSessionManager alloc] init];
    }
    return _urlSessionManager;
}

- (NSString *)deviceLocalTimeZone
{
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    if (zone.abbreviation) {
        return [UNetTools formartTimeZone:zone.abbreviation];
    }
    return @"";
}

#pragma mark- post http request
- (void)doHttpRequest:(NSURLRequest *)request type:(UCNetOperateType)type handler:(UNetOperationGetInfoHandler _Nullable)handler
{
    NSURLSessionDataTask *dataTask = [self.urlSessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            handler(nil,[UCError sysErrorWithError:error]);
            return;
        }
        
        NSError *jsonError  = nil;
        NSDictionary *dict = nil;
        try {
            dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
            if (jsonError) {
                handler(nil,[UCError sysErrorWithError:jsonError]);
                return;
            }
        } catch (NSException *exception) {
            handler(nil,[UCError sysErrorWithInvalidElements:@"json convert to object error"]);
            return;
        }
        
        if(!dict){
            handler(nil,[UCError sysErrorWithInvalidCondition:@"http response is nil"]);
            return;
        }
        
        if (type == UCNetOperateType_GetIpInfo) {
            if ([[dict objectForKey:@"ret"] isKindOfClass:[NSString class]] && ![[dict objectForKey:@"ret"] isEqualToString:@"ok"]) {
                NSString *ret = [dict objectForKey:@"ret"];
                handler(nil,[UCError httpErrorWithServerError:[UCServerError instanceWithCode:-1000 errMsg:ret]]);
                return;
            }
            
        }else{
            UNetIpListBean *uResponsBean = [UNetIpListBean ipListBeanWithDict:dict];
            if (uResponsBean.meta.code != 200) {
                UCServerError *serverError = [UCServerError instanceWithCode:uResponsBean.meta.code errMsg:uResponsBean.meta.error];
                handler(nil,[UCError httpErrorWithServerError:serverError]);
                return;
            }
        }

        try {
            switch (type) {
                case UCNetOperateType_GetIpInfo:
                {
                    if (dict[@"data"] == nil) {
                        handler(nil,[UCError sysErrorWithInvalidCondition:@"http response data is nil"]);
                        return;
                    }
                    UIpInfoModel *ipModel = [UIpInfoModel uIpInfoModelWithDict:dict[@"data"]];
                    self.ipInfoModel = ipModel;
                    handler(ipModel,nil);
                }
                    break;
                case UCNetOperateType_GetIpList:
                {
                    UNetIpListBean *ipListBean = [UNetIpListBean ipListBeanWithDict:dict];
                    self.reportServiceArray = ipListBean.data.url;
                    handler(ipListBean,nil);
                }
                    break;
                case UCNetOperateType_DoReport:
                {
                    UNetReportResponseBean *reportResponseBean = [UNetReportResponseBean reportResponseWithDict:dict];
                    handler(reportResponseBean,nil);
                }
                    break;
            }
        } catch (NSException *exception) {
            log4cplus_warn("UNetSDK", "func: %s, exception info:%s,  line: %d",__func__,[exception.description UTF8String],__LINE__);
            handler(nil,[UCError sysErrorWithInvalidElements:@"construct response bean error"]);
            return;
        }
        
    }];
    
     [dataTask resume];
}

+ (NSMutableURLRequest *)constructRequestWithHttpMethod:(NSString *)method
                                              urlstring:(NSString *)urlStr
                                           jsonParamStr:(NSString *)paramJsonStr
                                                timeOut:(NSTimeInterval)timeOut
{
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:method];
    [request setTimeoutInterval:timeOut];
    [request setValue:[NSString stringWithFormat:@"ios/%@",KSDKVERSION] forHTTPHeaderField:@"User-Agent"];
    if ([method isEqualToString:@"GET"]) {
        return request;
    }
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = [paramJsonStr dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

#pragma mark- The device public ip info
- (void)uGetDevicePublicIpInfoWithCompletionHandle:(UNetGetDevicePublicIpInfoHandler)handler
{
    [self doHttpRequest:[[self class] constructRequestWithHttpMethod:@"GET" urlstring:U_Get_Public_Ip_Url jsonParamStr:nil timeOut:uNetSDKTimeOut] type:UCNetOperateType_GetIpInfo handler:handler];
}

- (UIpInfoModel *)ipInfoModel
{
    return _ipInfoModel;
}

#pragma mark- Get ucloud ip list
- (void)uGetUHostListWithIpInfoModel:(UIpInfoModel * _Nonnull)ipInfoModel completionHandler:(UNetGetUHostListHandler _Nonnull)handler
{
    NSString *paramStr = nil;
    try {
        NSString *lat = ipInfoModel.latitude == nil ? @"" : ipInfoModel.latitude;
        NSString *lon = ipInfoModel.longitude == nil ? @"" : ipInfoModel.longitude;
        NSDictionary *requestParam = @{@"app_key":self.appKey,@"latitude":lat,@"longitude":lon};
        paramStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:requestParam options:0 error:nil] encoding:NSUTF8StringEncoding];
    } catch (NSException *exception) {
        log4cplus_warn("UNetSDK", "func: %s, exception info:%s,  line: %d",__func__,[exception.description UTF8String],__LINE__);
        handler(nil,[UCError sysErrorWithInvalidElements:@"construct request param error"]);
    }
    if (paramStr) {
        [self doHttpRequest:[[self class] constructRequestWithHttpMethod:@"POST" urlstring:U_Get_UCloud_iplist_URL jsonParamStr:paramStr timeOut:uNetSDKTimeOut] type:UCNetOperateType_GetIpList handler:handler];
    }
    
}

#pragma mark- report ping results
- (void)uReportPingResultWithUReportPingModel:(UReportPingModel * _Nonnull)uReportPingModel destIpType:(int)type
{
    if (self.ipInfoModel == NULL) {
        log4cplus_warn("UNetSDK", "reportPing, the device public ip info is null..\n");
        return;
    }
    NSString *paramJson = NULL;
    try {
        NSString *tagStr = [NSString stringWithFormat:@"app_id=%@,platform=1,dst_ip=%@,TTL=%d,s_ver=ios/%@,cus=%d,tz=%@",[UNetAppInfo uGetAppBundleId],uReportPingModel.dst_ip,uReportPingModel.ttl,KSDKVERSION,type,[self deviceLocalTimeZone]];
        
        if (self.userOptField) {
            tagStr = [NSString stringWithFormat:@"%@,%@",tagStr,self.userOptField];
        }
        NSString *tagStr_rsa = [UCRSA encryptString:tagStr publicKey:self.appSecret];
        NSString *report_ip_info = [NSString stringWithFormat:@"%@,net_type=%@",[self.ipInfoModel objConvertToReportStr],[UNetAppInfo uGetNetworkType]];
        NSString *ip_info_rsa = [UCRSA encryptString:report_ip_info publicKey:self.appSecret];
        NSDictionary *dict_data = @{@"action":@"ping",
                                    @"app_key":self.appKey,
                                    @"ping_data":[uReportPingModel objConvertToReportDict],
                                    @"ip_info":ip_info_rsa,
                                    @"tag":tagStr_rsa,
                                    @"timestamp":[NSNumber numberWithInteger:uReportPingModel.beginTime]
                                    };
        NSString *dataJson = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dict_data options:0 error:nil] encoding:NSUTF8StringEncoding];
        NSData *data = [dataJson dataUsingEncoding:NSUTF8StringEncoding];
        NSString *strBase64 = [data base64EncodedStringWithOptions:0];
        NSDictionary *param = @{@"data":strBase64};
        paramJson = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:param options:0 error:nil] encoding:NSUTF8StringEncoding];
        log4cplus_debug("UNetSDK", "ReportPing, tag: %s | ip_info: %s",[tagStr UTF8String],[report_ip_info UTF8String]);
        log4cplus_debug("UNetSDK", "ReportPing , param is : %s",[dataJson UTF8String]);
    } catch (NSException *exception) {
        log4cplus_warn("UNetSDK", "func: %s, exception info:%s,  line: %d",__func__,[exception.description UTF8String],__LINE__);
    }
    __weak typeof(self) weakSelf = self;
    [self doHttpRequest:[[self class] constructRequestWithHttpMethod:@"POST" urlstring:self.reportServiceArray[0] jsonParamStr:paramJson timeOut:uNetSDKTimeOut] type:UCNetOperateType_DoReport handler:^(id  _Nullable obj, UCError * _Nullable ucError) {
        if ([weakSelf processingErrorWith:ucError responseObj:obj reportBean:uReportPingModel module:@"ReportPing"]) {
            return;
        }
        if (weakSelf.reportServiceArray.count > 1 ) {
            log4cplus_warn("UNetSDK", "ReportPing , 1 time report failed , report the next service..\n");
            [weakSelf doHttpRequest:[[self class] constructRequestWithHttpMethod:@"POST" urlstring:self.reportServiceArray[1] jsonParamStr:paramJson timeOut:uNetSDKTimeOut] type:UCNetOperateType_DoReport handler:^(id  _Nullable obj, UCError * _Nullable ucError) {
                if ([weakSelf processingErrorWith:ucError responseObj:obj reportBean:uReportPingModel module:@"ReportPing"]) {
                    return;
                }
                
                if (weakSelf.reportServiceArray.count > 2) {
                    log4cplus_warn("UNetSDK", "ReportPing , 2 time report failed , report the next service..\n");
                    [weakSelf doHttpRequest:[[self class] constructRequestWithHttpMethod:@"POST" urlstring:self.reportServiceArray[2] jsonParamStr:paramJson timeOut:uNetSDKTimeOut] type:UCNetOperateType_DoReport handler:^(id  _Nullable obj, UCError * _Nullable ucError) {
                        if ([weakSelf processingErrorWith:ucError responseObj:obj reportBean:uReportPingModel module:@"ReportPing"]) {
                            return;
                        }
                         log4cplus_warn("UNetSDK", "ReportPing, http request error..\n");
                    }];
                }
               
            }];
        }

    }];
}

#pragma mark- report tracert results
- (void)uReportTracertResultWithUReportTracertModel:(UReportTracertModel *)uReportTracertModel destIpType:(int)type
{
    if (self.ipInfoModel == NULL) {
        log4cplus_warn("UNetSDK", "reportTracert, the device public ip info is null..\n");
        return;
    }
    NSString *paramJson = NULL;
    try {
        NSString *tagStr = [NSString stringWithFormat:@"app_id=%@,platform=1,dst_ip=%@,s_ver=ios/%@,cus=%d,tz=%@",[UNetAppInfo uGetAppBundleId],uReportTracertModel.dst_ip,KSDKVERSION,type,[self deviceLocalTimeZone]];
        if (self.userOptField) {
            tagStr = [NSString stringWithFormat:@"%@,%@",tagStr,self.userOptField];
        }
        NSString *tagStr_rsa = [UCRSA encryptString:tagStr publicKey:self.appSecret];
        
        NSString *report_ip_info = [NSString stringWithFormat:@"%@,net_type=%@",[self.ipInfoModel objConvertToReportStr],[UNetAppInfo uGetNetworkType]];
        NSString *ip_info_rsa = [UCRSA encryptString:report_ip_info publicKey:self.appSecret];
        NSDictionary *dict_data = @{@"action":@"traceroute",
                                    @"app_key":self.appKey,
                                    @"traceroute_data":[uReportTracertModel objConvertToReportDict],
                                    @"ip_info":ip_info_rsa,
                                    @"tag":tagStr_rsa,
                                    @"timestamp":[NSNumber numberWithInteger:uReportTracertModel.beginTime]};
        NSString *dataJson = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dict_data options:0 error:nil] encoding:NSUTF8StringEncoding];
        log4cplus_debug("UNetSDK", "ReportTracert, tag: %s | ip_info: %s",[tagStr UTF8String],[report_ip_info UTF8String]);
        log4cplus_debug("UNetSDK", "ReportTracert , paramJson is : %s",[dataJson UTF8String]);
        NSData *data = [dataJson dataUsingEncoding:NSUTF8StringEncoding];
        NSString *strBase64 = [data base64EncodedStringWithOptions:0];
        NSDictionary *param = @{@"data":strBase64};
        paramJson = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:param options:0 error:nil] encoding:NSUTF8StringEncoding];
//        log4cplus_debug("UNetSDK", "ReportTracert , param is : %s",[paramJson UTF8String]);
    } catch (NSException *exception) {
         log4cplus_warn("UNetSDK", "func: %s, exception info:%s,  line: %d",__func__,[exception.description UTF8String],__LINE__);
    }
    __weak typeof(self) weakSelf = self;
    [self doHttpRequest:[[self class] constructRequestWithHttpMethod:@"POST" urlstring:self.reportServiceArray[0] jsonParamStr:paramJson timeOut:uNetSDKTimeOut] type:UCNetOperateType_DoReport handler:^(id  _Nullable obj, UCError * _Nullable ucError) {
        if ([weakSelf processingErrorWith:ucError responseObj:obj reportBean:uReportTracertModel  module:@"ReportTracert"]) {
            return;
        }
        
        if (weakSelf.reportServiceArray.count > 1) {
            log4cplus_warn("UNetSDK", "ReportTracert , 1 time report failed , report the next service...\n");
            [weakSelf doHttpRequest:[[self class] constructRequestWithHttpMethod:@"POST" urlstring:self.reportServiceArray[1] jsonParamStr:paramJson timeOut:uNetSDKTimeOut]  type:UCNetOperateType_DoReport handler:^(id  _Nullable obj, UCError * _Nullable ucError) {
                if ([weakSelf processingErrorWith:ucError responseObj:obj reportBean:uReportTracertModel module:@"ReportTracert"]) {
                    return;
                }
                
                if (weakSelf.reportServiceArray.count > 2) {
                    log4cplus_warn("UNetSDK", "ReportTracert , 2 time report failed , report the next service...\n");
                    [weakSelf doHttpRequest:[[self class] constructRequestWithHttpMethod:@"POST" urlstring:self.reportServiceArray[2] jsonParamStr:paramJson timeOut:uNetSDKTimeOut]  type:UCNetOperateType_DoReport handler:^(id  _Nullable obj, UCError * _Nullable ucError) {
                        if ([weakSelf processingErrorWith:ucError responseObj:obj reportBean:uReportTracertModel module:@"ReportTracert"]) {
                            return;
                        }
                        log4cplus_warn("UNetSDK", "ReportTracert, http request error..\n");
                    }];
                }
                
            }];
        }
        
    }];
}

- (BOOL)processingErrorWith:(UCError *)ucError responseObj:(id)respObj reportBean:(id)reportBean module:(NSString *)module
{
    if (ucError) {
        if (ucError.type == UCErrorType_Sys)
            log4cplus_warn("UNetSDK", "%s error , error info->%s \n",[module UTF8String],[ucError.error.description UTF8String]);
        else
            log4cplus_warn("UNetSDK", "%s error , error info->%s \n",[module UTF8String],[ucError.serverError.description UTF8String]);
        return NO;
    }
    
    if (respObj) {
        UNetReportResponseBean *reportResponseBean = (UNetReportResponseBean *)respObj;
        if ([module isEqualToString:@"ReportPing"]) {
             UReportPingModel *uReportPingModel = (UReportPingModel *)reportBean;
             log4cplus_debug("UNetSDK", "ReportPing , report success, dst_ip:%s, meta code:%ld , message:%s , line:%d \n",[uReportPingModel.dst_ip UTF8String],(long)reportResponseBean.meta.code,[reportResponseBean.data.message UTF8String],__LINE__);
        }else if([module isEqualToString:@"ReportTracert"])
        {
            UReportTracertModel *uReportTracertModel = (UReportTracertModel *)reportBean;
            log4cplus_debug("UNetSDK", "ReportTracert , report success, dst_ip:%s , meta code:%ld , message:%s ,line:%d \n",[uReportTracertModel.dst_ip UTF8String],(long)reportResponseBean.meta.code,[reportResponseBean.data.message UTF8String],__LINE__);
        }
        return YES;
    }
    
    return NO;
}

@end
