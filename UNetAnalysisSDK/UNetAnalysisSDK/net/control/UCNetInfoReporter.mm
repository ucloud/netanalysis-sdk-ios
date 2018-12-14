//
//  UCNetInfoReporter.m
//  UCNetDiagnosisDemo
//
//  Created by ethan on 13/08/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UCNetInfoReporter.h"
#import "UCNetworkService.h"
#import "UNetAnalysisConst.h"
#include "log4cplus.h"
#import "UNetIpListBean.h"
#import "UNetMetaBean.h"
#import "UNetReportResponseBean.h"
#import "UCDateTool.h"


@interface UCNetInfoReporter()

@property (nonatomic,strong) UIpInfoModel *ipInfoModel;
@property (nonatomic,copy) NSArray *reportServiceArray;

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

#pragma mark- The device public ip info
- (void)uGetDevicePublicIpInfoWithCompletionHandle:(UNetGetDevicePublicIpInfoHandler)handler
{
    [UCNetworkService uHttpGetRequestWithUrl:U_Get_Public_Ip_Url functionModule:@"GetDevicePublicIpInfo" timeout:10.0 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        
        
        try {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (error || dict == nil) {
                log4cplus_warn("UCSDK", "get public ip error , content is nil..\n");
                handler(NULL);
            }else{
                UIpInfoModel *ipModel = [UIpInfoModel uIpInfoModelWithDict:dict];
                self.ipInfoModel = ipModel;
                handler(ipModel);
            }
        } catch (NSException *exception) {
            log4cplus_warn("UNetSDK", "func: %s, exception info:%s,  line: %d",__func__,[exception.description UTF8String],__LINE__);
        }
        
    }];
}

- (UIpInfoModel *)ipInfoModel
{
    return _ipInfoModel;
}

#pragma mark- Get ucloud ip list
- (void)uGetUHostListWithCompletionHandler:(UNetGetUHostListHandler)handler
{
    NSDictionary *requestParam = @{@"token":@"7946ad5d2b60438a96a57c7aa77f96f7a4d8c09f2ebf237d8ea5527ccd6b7b58"};
    NSString *requestParamStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:requestParam options:0 error:nil] encoding:NSUTF8StringEncoding];
    [UCNetworkService uHttpPostRequestWithUrl:U_Get_UCloud_iplist_URL param:requestParamStr paramType:UNetHTTPRequestParamType_JSON functionModule:@"GetUCLoudIpList" timeout:10.0 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        
        try {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (error || dict == nil) {
                log4cplus_warn("UNetSDK", "get ucloud ip list error , content is nil...\n");
                handler(NULL);
            }else{
                UNetIpListBean *ipListBean = [UNetIpListBean ipListBeanWithDict:dict];
                if (ipListBean.meta.code != 200) {
                    log4cplus_warn("UNetSDK", "get ulcoud ip list error , meta code:%ld ,error info:%s \n",(long)ipListBean.meta.code ,[ipListBean.meta.error UTF8String]);
                    return;
                }
                self.reportServiceArray = ipListBean.data.url;
                handler(ipListBean);
            }
            
        } catch (NSException *exception) {
             log4cplus_warn("UNetSDK", "func: %s, exception info:%s,  line: %d",__func__,[exception.description UTF8String],__LINE__);
        }
        
        
        
    }];
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
        NSDictionary *param = @{
                  @"token":@"7946ad5d2b60438a96a57c7aa77f96f7a4d8c09f2ebf237d8ea5527ccd6b7b58",
                  @"action":@"ping",
                  @"ip_info":[self.ipInfoModel objConvertToDict],
                  @"ping_data":[uReportPingModel objConvertToDict],
                  @"timestamp":[NSNumber numberWithInt:[UCDateTool currentTimestamp]]
                  };
        paramJson = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:param options:0 error:nil] encoding:NSUTF8StringEncoding];
        log4cplus_debug("UNetSDK", "ReportPing , param is : %s",[paramJson UTF8String]);
    } catch (NSException *exception) {
        log4cplus_warn("UNetSDK", "func: %s, exception info:%s,  line: %d",__func__,[exception.description UTF8String],__LINE__);
    }

    [UCNetworkService uHttpPostRequestWithUrl:self.reportServiceArray[reportPingIndex] param:paramJson paramType:UNetHTTPRequestParamType_JSON functionModule:@"ReportPing" timeout:10.0 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        
        try {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (error || dict == nil) {
                
                if (self.reportServiceArray.count-1 > reportPingIndex) {
                    log4cplus_warn("UNetSDK", "ReportPing , %d time report failed , report the next service...\n",reportPingIndex);
                    reportPingIndex++;
                    [self uReportPingResultWithUReportPingModel:uReportPingModel];
                }else{
                    log4cplus_warn("UNetSDK", "ReportPing, report failed , result is nil...\n");
                }
                
            }else{
                UNetReportResponseBean *reportResponseBean = [UNetReportResponseBean reportResponseWithDict:dict];
                if (reportResponseBean.meta.code == 200) {
                    log4cplus_debug("UNetSDK", "ReportPing , report success, dst_ip:%s, meta code:%ld , message:%s",[uReportPingModel.dst_ip UTF8String],(long)reportResponseBean.meta.code,[reportResponseBean.data.message UTF8String]);
                    reportPingIndex = 0;
                    return;
                }
                
                log4cplus_warn("UNetSDK", "ReportPing , meta code:%ld ,error info:%s \n",(long)reportResponseBean.meta.code ,[reportResponseBean.meta.error UTF8String]);
                if (self.reportServiceArray.count-1 > reportPingIndex) {
                    log4cplus_warn("UNetSDK", "ReportPing , %d time report failed , report the next service...\n",reportPingIndex);
                    reportPingIndex++;
                    [self uReportPingResultWithUReportPingModel:uReportPingModel];
                }else{
                    log4cplus_warn("UNetSDK", "ReportPing, report failed , result is nil...\n");
                }
                
            }
            
        } catch (NSException *exception) {
             log4cplus_warn("UNetSDK", "func: %s, exception info:%s,  line: %d",__func__,[exception.description UTF8String],__LINE__);
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
        NSDictionary *param = @{
                                @"token":@"7946ad5d2b60438a96a57c7aa77f96f7a4d8c09f2ebf237d8ea5527ccd6b7b58",
                                @"action":@"traceroute",
                                @"ip_info":[self.ipInfoModel objConvertToDict],
                                @"traceroute_data":[uReportTracertModel objConvertToDict],
                                @"timestamp":[NSNumber numberWithInt:[UCDateTool currentTimestamp]]
                                };
        paramJson = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:param options:0 error:nil] encoding:NSUTF8StringEncoding];
        
        log4cplus_debug("UNetSDK", "ReportTracert , param is : %s",[paramJson UTF8String]);
    } catch (NSException *exception) {
         log4cplus_warn("UNetSDK", "func: %s, exception info:%s,  line: %d",__func__,[exception.description UTF8String],__LINE__);
    }
    
    [UCNetworkService uHttpPostRequestWithUrl:self.reportServiceArray[reportTracertIndex] param:paramJson paramType:UNetHTTPRequestParamType_JSON functionModule:@"ReportTracert" timeout:10.0 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        
        try {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (error || dict == nil) {
                
                if (self.reportServiceArray.count-1 > reportTracertIndex) {
                    log4cplus_warn("UNetSDK", "ReportTracert , %d time report failed , report the next service...\n",reportTracertIndex);
                    reportTracertIndex++;
                    [self uReportTracertResultWithUReportTracertModel:uReportTracertModel];
                }else{
                    log4cplus_warn("UNetSDK", "ReportTracert, report failed , result is nil...\n");
                }
                
            }else{
                
                UNetReportResponseBean *reportResponseBean = [UNetReportResponseBean reportResponseWithDict:dict];
                if (reportResponseBean.meta.code == 200) {
                    log4cplus_debug("UNetSDK", "ReportTracert , report success, dst_ip:%s , meta code:%ld , message:%s",[uReportTracertModel.dst_ip UTF8String],(long)reportResponseBean.meta.code,[reportResponseBean.data.message UTF8String]);
                    reportTracertIndex = 0;
                    return;
                }
                
                log4cplus_warn("UNetSDK", "ReportTracert , meta code:%ld ,error info:%s \n",(long)reportResponseBean.meta.code ,[reportResponseBean.meta.error UTF8String]);
                if (self.reportServiceArray.count-1 > reportTracertIndex) {
                    log4cplus_warn("UNetSDK", "ReportTracert , %d time report failed , report the next service...\n",reportTracertIndex);
                    reportTracertIndex++;
                    [self uReportTracertResultWithUReportTracertModel:uReportTracertModel];
                }else{
                    log4cplus_warn("UNetSDK", "ReportTracert, report failed , result is nil...\n");
                }
                
            }
        } catch (NSException *exception) {
             log4cplus_warn("UNetSDK", "func: %s, exception info:%s,  line: %d",__func__,[exception.description UTF8String],__LINE__);
        }
        
        
    }];
}

@end
