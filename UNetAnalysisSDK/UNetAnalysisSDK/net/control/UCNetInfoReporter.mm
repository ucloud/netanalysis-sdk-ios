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

typedef enum UCNetOperateType
{
    UCNetOperateType_GetIpInfo = 0,
    UCNetOperateType_GetIpList,
    UCNetOperateType_DoReport
}UFBucketOperateType;

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

- (void)setAppKey:(NSString *)appKey publickToken:(NSString *)publicToken optReportField:(UCOptReportField * _Nullable)field
{
    _appKey = appKey;
    _appSecret = publicToken;
    if (!field) {
        log4cplus_debug("UNetSDK", "user opt field is nil..\n");
        return;
    }
    self.userOptField = [field convertToKeyValueStr];
    log4cplus_debug("UNetSDK", "user opt field is: %s",[self.userOptField UTF8String]);
}

- (UCURLSessionManager *)urlSessionManager
{
    if (!_urlSessionManager) {
        _urlSessionManager = [[UCURLSessionManager alloc] init];
    }
    return _urlSessionManager;
}

#pragma mark- post http request
- (void)doHttpRequest:(NSURLRequest *)request type:(UCNetOperateType)type handler:(UNetOperationGetInfoHandler _Nullable)handler
{
    NSURLSessionDataTask *dataTask = [self.urlSessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            log4cplus_warn("UNetSDK", "http request error ,error info->%s",[error.description UTF8String]);
            return;
        }
        
        NSError *jsonError  = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
        if (jsonError) {
            log4cplus_warn("UNetSDK", "http response error , error info->%s\n",[jsonError.description UTF8String]);
            handler(nil);
            return;
        }
        if(!dict){
            log4cplus_warn("UNetSDK", "http response error , response is nil..\n");
            handler(nil);
            return;
        }
        
        switch (type) {
            case UCNetOperateType_GetIpInfo:
                {
                    if (dict[@"data"] == nil) {
                        handler(nil);
                        return;
                    }
                    UIpInfoModel *ipModel = [UIpInfoModel uIpInfoModelWithDict:dict[@"data"]];
                    self.ipInfoModel = ipModel;
                    handler(ipModel);
                }
                    break;
            case UCNetOperateType_GetIpList:
            {
                UNetIpListBean *ipListBean = [UNetIpListBean ipListBeanWithDict:dict];
                if (ipListBean.meta.code != 200) {
                    log4cplus_warn("UNetSDK", "get ulcoud ip list error , meta code:%ld ,error info:%s \n",(long)ipListBean.meta.code ,[ipListBean.meta.error UTF8String]);
                    return;
                }
                self.reportServiceArray = ipListBean.data.url;
                handler(ipListBean);
            }
                break;
            case UCNetOperateType_DoReport:
            {
                UNetReportResponseBean *reportResponseBean = [UNetReportResponseBean reportResponseWithDict:dict];
                if (reportResponseBean.meta.code == 200) {
                    handler(reportResponseBean);
                    return;
                }
                handler(nil);
            }
                break;
                    
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
    [self doHttpRequest:[[self class] constructRequestWithHttpMethod:@"GET" urlstring:U_Get_Public_Ip_Url jsonParamStr:nil timeOut:10.0] type:UCNetOperateType_GetIpInfo handler:handler];
}

- (UIpInfoModel *)ipInfoModel
{
    return _ipInfoModel;
}

#pragma mark- Get ucloud ip list
- (void)uGetUHostListWithCompletionHandler:(UNetGetUHostListHandler)handler
{
    NSDictionary *requestParam = @{@"app_key":self.appKey};
    NSString *paramStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:requestParam options:0 error:nil] encoding:NSUTF8StringEncoding];
    [self doHttpRequest:[[self class] constructRequestWithHttpMethod:@"POST" urlstring:U_Get_UCloud_iplist_URL jsonParamStr:paramStr timeOut:10.0] type:UCNetOperateType_GetIpList handler:handler];
}

#pragma mark- report ping results
- (void)uReportPingResultWithUReportPingModel:(UReportPingModel *)uReportPingModel
{
    if (self.ipInfoModel == NULL) {
        log4cplus_warn("UNetSDK", "reportPing, the device public ip info is null..\n");
        return;
    }
    static int reportPingIndex = 0;
    NSString *paramJson = NULL;
    try {
        NSString *tagStr = [NSString stringWithFormat:@"app_id=%@,platform=1,dst_ip=%@,TTL=%d,s_ver=ios/%@",[UNetAppInfo uGetAppBundleId],uReportPingModel.dst_ip,uReportPingModel.ttl,KSDKVERSION];
        
        if (self.userOptField) {
            tagStr = [NSString stringWithFormat:@"%@,%@",tagStr,self.userOptField];
        }
        
        NSString *tagStr_rsa = [UCRSA encryptString:tagStr publicKey:self.appSecret];
        NSString *ip_info_rsa = [UCRSA encryptString:[self.ipInfoModel objConvertToReportStr] publicKey:self.appSecret];
        NSDictionary *dict_data = @{@"action":@"ping",
                                    @"app_key":self.appKey,
                                    @"ping_data":[uReportPingModel objConvertToReportDict],
                                    @"ip_info":ip_info_rsa,
                                    @"tag":tagStr_rsa,
                                    @"timestamp":[NSNumber numberWithInteger:[UCDateTool currentTimestamp]]
                                    };
        NSString *dataJson = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dict_data options:0 error:nil] encoding:NSUTF8StringEncoding];
//        log4cplus_debug("UNetSDK", "ReportPing , paramJson is : %s",[dataJson UTF8String]);
        NSData *data = [dataJson dataUsingEncoding:NSUTF8StringEncoding];
        NSString *strBase64 = [data base64EncodedStringWithOptions:0];
        NSDictionary *param = @{@"data":strBase64};
        paramJson = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:param options:0 error:nil] encoding:NSUTF8StringEncoding];
        log4cplus_debug("UNetSDK", "ReportPing , param is : %s",[paramJson UTF8String]);
    } catch (NSException *exception) {
        log4cplus_warn("UNetSDK", "func: %s, exception info:%s,  line: %d",__func__,[exception.description UTF8String],__LINE__);
    }
    [self doHttpRequest:[[self class] constructRequestWithHttpMethod:@"POST" urlstring:self.reportServiceArray[reportPingIndex] jsonParamStr:paramJson timeOut:10.0] type:UCNetOperateType_DoReport handler:^(id  _Nullable obj) {
        if (obj) {
            UNetReportResponseBean *reportResponseBean = (UNetReportResponseBean *)obj;
            log4cplus_debug("UNetSDK", "ReportPing , report success, dst_ip:%s, meta code:%ld , message:%s",[uReportPingModel.dst_ip UTF8String],(long)reportResponseBean.meta.code,[reportResponseBean.data.message UTF8String]);
            reportPingIndex = 0;
            return;
        }
        log4cplus_warn("UNetSDK", "ReportPing, http request error..\n");
        if (self.reportServiceArray.count-1 > reportPingIndex) {
            log4cplus_warn("UNetSDK", "ReportPing , %d time report failed , report the next service..\n",reportPingIndex);
            reportPingIndex++;
            [self doHttpRequest:[[self class] constructRequestWithHttpMethod:@"POST" urlstring:self.reportServiceArray[reportPingIndex] jsonParamStr:paramJson timeOut:10.0] type:UCNetOperateType_DoReport handler:^(id  _Nullable obj) {
                if (obj) {
                    UNetReportResponseBean *reportResponseBean = (UNetReportResponseBean *)obj;
                    log4cplus_debug("UNetSDK", "ReportPing , report success, dst_ip:%s, meta code:%ld , message:%s",[uReportPingModel.dst_ip UTF8String],(long)reportResponseBean.meta.code,[reportResponseBean.data.message UTF8String]);
                    reportPingIndex = 0;
                    return;
                }
                log4cplus_warn("UNetSDK", "ReportPing, http request error..\n");
                reportPingIndex = 0;
            }];
        }
    }];
}

#pragma mark- report tracert results
- (void)uReportTracertResultWithUReportTracertModel:(UReportTracertModel *)uReportTracertModel
{
    if (self.ipInfoModel == NULL) {
        log4cplus_warn("UNetSDK", "reportTracert, the device public ip info is null..\n");
        return;
    }
    static int reportTracertIndex = 0;
    NSString *paramJson = NULL;
    try {
        NSString *tagStr = [NSString stringWithFormat:@"app_id=%@,platform=1,dst_ip=%@,s_ver=ios/%@",[UNetAppInfo uGetAppBundleId],uReportTracertModel.dst_ip,KSDKVERSION];
        if (self.userOptField) {
            tagStr = [NSString stringWithFormat:@"%@,%@",tagStr,self.userOptField];
        }
        NSString *tagStr_rsa = [UCRSA encryptString:tagStr publicKey:self.appSecret];
        NSString *ip_info_rsa = [UCRSA encryptString:[self.ipInfoModel objConvertToReportStr] publicKey:self.appSecret];
        NSDictionary *dict_data = @{@"action":@"traceroute",
                                    @"app_key":self.appKey,
                                    @"traceroute_data":[uReportTracertModel objConvertToReportDict],
                                    @"ip_info":ip_info_rsa,
                                    @"tag":tagStr_rsa,
                                    @"timestamp":[NSNumber numberWithInteger:[UCDateTool currentTimestamp]]};
        NSString *dataJson = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dict_data options:0 error:nil] encoding:NSUTF8StringEncoding];
//        log4cplus_debug("UNetSDK", "ReportTracert , paramJson is : %s",[dataJson UTF8String]);
        NSData *data = [dataJson dataUsingEncoding:NSUTF8StringEncoding];
        NSString *strBase64 = [data base64EncodedStringWithOptions:0];
        NSDictionary *param = @{@"data":strBase64};
        paramJson = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:param options:0 error:nil] encoding:NSUTF8StringEncoding];
        log4cplus_debug("UNetSDK", "ReportTracert , param is : %s",[paramJson UTF8String]);
    } catch (NSException *exception) {
         log4cplus_warn("UNetSDK", "func: %s, exception info:%s,  line: %d",__func__,[exception.description UTF8String],__LINE__);
    }

    [self doHttpRequest:[[self class] constructRequestWithHttpMethod:@"POST" urlstring:self.reportServiceArray[reportTracertIndex] jsonParamStr:paramJson timeOut:10.0] type:UCNetOperateType_DoReport handler:^(id  _Nullable obj) {
        if (obj) {
            UNetReportResponseBean *reportResponseBean = (UNetReportResponseBean *)obj;
            log4cplus_debug("UNetSDK", "ReportTracert , report success, dst_ip:%s , meta code:%ld , message:%s",[uReportTracertModel.dst_ip UTF8String],(long)reportResponseBean.meta.code,[reportResponseBean.data.message UTF8String]);
            reportTracertIndex = 0;
            return;
        }
        log4cplus_warn("UNetSDK", "ReportTracert, http request error..\n");
        
        if (self.reportServiceArray.count-1 > reportTracertIndex) {
            log4cplus_warn("UNetSDK", "ReportTracert , %d time report failed , report the next service...\n",reportTracertIndex);
            reportTracertIndex++;
            [self doHttpRequest:[[self class] constructRequestWithHttpMethod:@"POST" urlstring:self.reportServiceArray[reportTracertIndex] jsonParamStr:paramJson timeOut:10.0]  type:UCNetOperateType_DoReport handler:^(id  _Nullable obj) {
                if (obj) {
                    UNetReportResponseBean *reportResponseBean = (UNetReportResponseBean *)obj;
                    log4cplus_debug("UNetSDK", "ReportTracert , report success, dst_ip:%s , meta code:%ld , message:%s",[uReportTracertModel.dst_ip UTF8String],(long)reportResponseBean.meta.code,[reportResponseBean.data.message UTF8String]);
                    reportTracertIndex = 0;
                    return;
                }
                log4cplus_warn("UNetSDK", "ReportTracert, http request error..\n");
                reportTracertIndex = 0;
            }];
        }
        
    }];
}

@end
