//
//  UCNetClient.m
//  UNetAnalysisSDK
//
//  Created by ethan on 26/07/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UCNetClient.h"
#import "UNetAnalysisConst.h"
#import "UCNetInfoReporter.h"
#import "UCServerResponseModel.h"
#import "UCPingService.h"
#import "UCTraceRouteService.h"
#import "UTracertModel.h"
#import "UCDateTool.h"
#import "UNetTools.h"
#include "log4cplus.h"
#import "UNetAppInfo.h"
#import "UCReachability.h"
#import "UNetQueue.h"

/*   define log level  */
int UCLOUD_IOS_FLAG_FATAL = 0x10;
int UCLOUD_IOS_FLAG_ERROR = 0x08;
int UCLOUD_IOS_FLAG_WARN = 0x04;
int UCLOUD_IOS_FLAG_INFO = 0x02;
int UCLOUD_IOS_FLAG_DEBUG = 0x01;
int UCLOUD_IOS_LOG_LEVEL = UCLOUD_IOS_LOG_LEVEL = UCLOUD_IOS_FLAG_FATAL|UCLOUD_IOS_FLAG_ERROR;

@interface UCNetClient()<UCPingServiceDelegate,UCTraceRouteServiceDelegate>
@property (nonatomic,copy) NSString *appName;
@property (nonatomic,copy) NSArray *hostList;

@property (nonatomic) UCReachability *reachability;

@property (readonly) UCNetManualNetDiagCompleteHandler manualNetDiagHandler;
@property (nonatomic,assign) BOOL  isManualNetDiag;

@property (nonatomic,strong) UIpInfoModel *devicePubIpInfo;
@property (nonatomic,strong) UNetIpListBean *uIpListBean;

@property (nonatomic,copy) NSArray *userIpList;
@property (nonatomic,assign) UCNetworkStatus netStatus;
@property (nonatomic,assign) BOOL  shouldDoUserIpPing;
//@property (nonatomic,assign) BOOL  shouldDoUserIpTracert;

@property (nonatomic,strong) NSMutableArray *manualPingRes;


@end

@implementation UCNetClient

static UCNetClient *ucloudNetClient_instance = nil;

+ (instancetype)shareInstance
{
    static dispatch_once_t ucloudNetClient_onceToken;
    dispatch_once(&ucloudNetClient_onceToken, ^{
        ucloudNetClient_instance = [[super allocWithZone:NULL] init];
    });
    return ucloudNetClient_instance;
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    return [UCNetClient shareInstance];
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [UCNetClient shareInstance];
}

- (void)settingSDKLogLevel:(UCSDKLogLevel)logLevel
{
    switch (logLevel) {
        case UCSDKLogLevel_FATAL:
        {
            UCLOUD_IOS_LOG_LEVEL = UCLOUD_IOS_FLAG_FATAL;
            log4cplus_fatal("UNetSDK", "setting UCSDK log level ,UCLOUD_IOS_FLAG_FATAL...\n");
        }
            break;
        case UCSDKLogLevel_ERROR:
        {
            UCLOUD_IOS_LOG_LEVEL = UCLOUD_IOS_FLAG_FATAL|UCLOUD_IOS_FLAG_ERROR;
            log4cplus_error("UNetSDK", "setting UCSDK log level ,UCLOUD_IOS_FLAG_ERROR...\n");
        }
            break;
        case UCSDKLogLevel_WARN:
        {
            UCLOUD_IOS_LOG_LEVEL = UCLOUD_IOS_FLAG_FATAL|UCLOUD_IOS_FLAG_ERROR|UCLOUD_IOS_FLAG_WARN;
            log4cplus_warn("UNetSDK", "setting UCSDK log level ,UCLOUD_IOS_FLAG_WARN...\n");
        }
            break;
        case UCSDKLogLevel_INFO:
        {
            UCLOUD_IOS_LOG_LEVEL = UCLOUD_IOS_FLAG_FATAL|UCLOUD_IOS_FLAG_ERROR|UCLOUD_IOS_FLAG_WARN|UCLOUD_IOS_FLAG_INFO;
            log4cplus_info("UNetSDK", "setting UCSDK log level ,UCLOUD_IOS_FLAG_INFO...\n");
        }
            break;
        case UCSDKLogLevel_DEBUG:
        {
            UCLOUD_IOS_LOG_LEVEL = UCLOUD_IOS_FLAG_FATAL|UCLOUD_IOS_FLAG_ERROR|UCLOUD_IOS_FLAG_WARN|UCLOUD_IOS_FLAG_INFO|UCLOUD_IOS_FLAG_DEBUG;
            log4cplus_debug("UNetSDK", "setting UCSDK log level ,UCNetAnalysisSDKLogLevel_DEBUG...\n");
        }
            break;
            
        default:
            break;
    }
}

- (int)registSdkWithAppKey:(NSString *)appkey publicToken:(NSString *)publicToken optReportField:(NSString * _Nullable)field
{
    self.isManualNetDiag = NO;
    [[UCNetInfoReporter shareInstance] setAppKey:appkey publickToken:publicToken optReportField:field];
    log4cplus_info("UNetSDK", "regist UCNetAnalysis success...\n");
    [UCPingService shareInstance].delegate = self;
    [UCTraceRouteService shareInstance].delegate = self;
    [self registNetStateChangeNoti];
    return 0;
}

- (void)settingCustomerIpList:(NSArray *_Nullable)customerIpList
{
    if (customerIpList == NULL) {
        log4cplus_warn("UNetSDK", "customer ip list is null...\n");
        return;
    }
    
    try {
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0 ; i < customerIpList.count; i++) {
            if ([self isIpAddress:customerIpList[i]]) {
                [array addObject:customerIpList[i]];
            }
        }
        
        if (array.count > 0) {
            int cusIpsCount = 5;
            if (array.count < cusIpsCount) {
                cusIpsCount = (int)array.count;
            }
            self.userIpList = [array subarrayWithRange:NSMakeRange(0, cusIpsCount)];
        }else{
            log4cplus_warn("UNetSDK", "There is no valid ip in the ip list set by the user..\n");
        }
    } catch (NSException *exception) {
        log4cplus_error("UNetSDK", "func: %s, exception info: %s , line: %d",__func__,[exception.description UTF8String],__LINE__);
    }
}

- (BOOL)canStartNetDetection:(UCNetManualNetDiagCompleteHandler)completeHandler
{
    NSString *warnInfo = @"";
    BOOL res = YES;
    if (!self.devicePubIpInfo) {
        warnInfo = @"device public ip info is nil";
        res = NO;
    }
    else if (!self.uIpListBean) {
        warnInfo = @"ucloud ip list is nil";
        res = NO;
    }
    else if (!self.uIpListBean.data.url) {
         warnInfo = @"report address is nil";
         res = NO;
    }
    else if(self.userIpList == NULL || self.userIpList.count == 0){
        warnInfo = @"customer ip list is nil";
        res = NO;
    }
    else if(self.netStatus == Reachable_None){
        warnInfo = @"none network";
        res = NO;
    }else if([[UCPingService shareInstance] uIsPing])
    {
        warnInfo = @"auto diagnosis is in progress, please try again later";
        res = NO;
    }
    if (!res) {
        completeHandler(nil,[UCError sysErrorWithInvalidCondition:warnInfo]);
        log4cplus_warn("UNetSDK", "%s...\n",[warnInfo UTF8String]);
    }
    return res;
}

- (void)manualDiagNetStatus:(UCNetManualNetDiagCompleteHandler _Nonnull)completeHandler
{
    if (self.isManualNetDiag) {
        return;
    }
    _manualPingRes = [NSMutableArray array];
    _manualNetDiagHandler = completeHandler;
    
    if (![self canStartNetDetection:_manualNetDiagHandler]) {
        return;
    }
    UCPingService *pingService = [UCPingService shareInstance];
    if ([pingService uIsPing]) {
        [pingService uStopPing];
    }
    
    UCTraceRouteService *tracertService = [UCTraceRouteService shareInstance];
    if ([tracertService uIsTracert]) {
        [tracertService uStopTracert];
    }
    
    log4cplus_debug("UNetSDK", "ManualDiag , begin mannual diag network...\n");
    self.isManualNetDiag = YES;
    [self startPingHosts:self.userIpList];
    
    [self startTracertWithHosts:self.userIpList isUCloudHosts:NO];
//    self.shouldDoUserIpTracert = NO;
}

- (BOOL)isIpAddress:(NSString *)ipStr
{
    if (nil == ipStr) {
        log4cplus_warn("UNetSDK", "ip address is nil...\n");
        return NO;
    }
    BOOL res = [UNetTools validIPAddress:ipStr];
    if (!res) {
        log4cplus_warn("UNetSDK", "%s is not a invalid ip address , so remove this ip..\n",[ipStr UTF8String]);
    }
    return res;
}

- (void)registNetStateChangeNoti
{
    [UCNotification addObserver:self selector:@selector(networkChange:) name:kUCReachabilityChangedNotification object:nil];
    self.reachability = [UCReachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    [self checkNetworkStatusWithReachability:self.reachability];
}

- (void)networkChange:(NSNotification *)noti
{
    UCReachability *reachability = [noti object];
    [self checkNetworkStatusWithReachability:reachability];
}

- (void)checkNetworkStatusWithReachability:(UCReachability *)reachability
{
    self.devicePubIpInfo = nil;
    self.uIpListBean = nil;
    self.netStatus = [reachability currentReachabilityStatus];
    switch (self.netStatus) {
        case Reachable_None:
        {
            log4cplus_info("UNetSDK", "none network...\n");
        }
            break;
        case Reachable_WiFi:
        {
            log4cplus_info("UNetSDK", "network type is WIFI...\n");
            [self doPingAndTracertUHosts];
        }
            break;
        case Reachable_WWAN:
        {
            log4cplus_info("UNetSDK", "network type is WWAN...\n");
            [self doPingAndTracertUHosts];
        }
            break;
            
        default:
            break;
    }
}

- (void)doPingAndTracertUHosts
{
//    self.shouldDoUserIpTracert = YES;
    __weak typeof(self) weakSelf = self;
    [[UCNetInfoReporter shareInstance] uGetDevicePublicIpInfoWithCompletionHandle:^(UIpInfoModel * _Nullable ipInfoModel,UCError * _Nullable ucError) {
        if ([weakSelf processingErrorWith:ucError responseObject:ipInfoModel module:@"GetDevicePublicIp"]) {
            return;
        }
        weakSelf.devicePubIpInfo = ipInfoModel;
        log4cplus_debug("UNetSDK", "success get the device public ip info , info: %s",[ipInfoModel.description UTF8String]);
        [[UCNetInfoReporter shareInstance] uGetUHostListWithIpInfoModel:ipInfoModel completionHandler:^(UNetIpListBean *_Nullable ipListBean,UCError * _Nullable ucError) {
            if ([weakSelf processingErrorWith:ucError responseObject: ipListBean module:@"GetUHostList"]) {
                return;
            }
            log4cplus_debug("UNetSDK", "success get the ucloud ip list-->%s..\n",[ipListBean.data.description UTF8String]);
            weakSelf.uIpListBean = ipListBean;
            weakSelf.hostList = [weakSelf.uIpListBean.data uGetUHosts];
            // 乱序
            weakSelf.hostList = [weakSelf.hostList sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                int i = arc4random_uniform(2);
                if (i) {
                    return [obj1 compare:obj2];
                }else{
                    return [obj2 compare:obj1];
                }
            }];
            
            if (ipListBean.data.url == NULL) {
                log4cplus_warn("UNetSDK", "have not get ucloud report services , cancel device network info collection...\n");
                return;
            }
            log4cplus_debug("UNetSDK", "success get the ucloud report services...\n");
            [weakSelf startPingHosts:weakSelf.hostList];
            weakSelf.shouldDoUserIpPing = YES;
//            [weakSelf startTracertWithHosts:weakSelf.hostList isUCloudHosts:YES];
            
            if (self.userIpList) {
                [weakSelf startTracertWithHosts:weakSelf.userIpList isUCloudHosts:NO];
            }
           
        }];
        
    }];
}

- (void)startPingHosts:(NSArray *)hosts
{
    UCPingService *uPingService = [UCPingService shareInstance];
    if ([uPingService uIsPing]) {
        [uPingService uStopPing];
    }
    [uPingService startPingAddressList:hosts];
}

- (void)startTracertWithHosts:(NSArray *)hosts isUCloudHosts:(BOOL)isUHosts
{
    UCTraceRouteService *ucTracertService = [UCTraceRouteService shareInstance];
    if (ucTracertService.uIsTracert) {
        [ucTracertService uStopTracert];
    }
    NSArray *tracertHosts =  isUHosts ? self.hostList : self.userIpList;
    [ucTracertService uStartTracerouteAddressList:tracertHosts];
}

- (int)getDestIpType:(NSString *)dstIp
{
    if (self.userIpList && self.userIpList.count > 0) {
        return [self.userIpList containsObject:dstIp];
    }
    return 0;
}

- (void)closePingAndTracert
{
    if([[UCTraceRouteService shareInstance] uIsTracert]){
        [[UCTraceRouteService shareInstance] uStopTracert];
    }
    
    if ([[UCPingService shareInstance] uIsPing]) {
        [[UCPingService shareInstance] uStopPing];
    }
    log4cplus_warn("UNetSDK", "App resign activity , stop collection network data...\n");
}

- (BOOL)processingErrorWith:(UCError *)ucError
             responseObject:(id)obj
                     module:(NSString *)module
{
    if (ucError) {
        if (ucError.type == UCErrorType_Sys)
            log4cplus_warn("UNetSDK", "%s error , error info->%s \n",[module UTF8String],[ucError.error.description UTF8String]);
        else
            log4cplus_warn("UNetSDK", "%s error , error info->%s \n",[module UTF8String],[ucError.serverError.description UTF8String]);
        return YES;
    }
    
    if (!obj) {
        log4cplus_warn("UNetSDK", "%s error , server response obj is nil, cancel device network info collection...\n",[module UTF8String]);
        return YES;
    }
    return NO;
}

#pragma mark- UCPingServiceDelegate
- (void)pingResultWithUCPingService:(UCPingService *)ucPingService pingResult:(UReportPingModel *)uReportPingModel
{
//    log4cplus_info("UNetPing", "%s\n",[uReportPingModel.description UTF8String]);
    
    __weak typeof(self) weakSelf = self;
    [UNetQueue unet_ping_sync:^{
        if (weakSelf.isManualNetDiag) {
            UCIpPingResult *ipPingRes = [[UCIpPingResult alloc] initUIpPingResultWithIp:uReportPingModel.dst_ip loss:uReportPingModel.loss delay:uReportPingModel.delay];
            if ([weakSelf.userIpList containsObject:ipPingRes.ip]) {
                [weakSelf.manualPingRes addObject:ipPingRes];
            }
        }
    }];
    [[UCNetInfoReporter shareInstance] uReportPingResultWithUReportPingModel:uReportPingModel destIpType:[self getDestIpType:uReportPingModel.dst_ip]];
}

- (void)pingFinishedWithUCPingService:(UCPingService *)ucPingService
{
    if (self.userIpList == NULL) {
        return;
    }
    
    // 如果ucloud ip list 完成ping的时候，user ip list 已经成功设置
    if (self.shouldDoUserIpPing && self.isManualNetDiag == NO) {
        [self startPingHosts:self.userIpList];
        self.shouldDoUserIpPing = NO;
    }
    
    // 如果在进行手动诊断
    if (self.isManualNetDiag) {
        __weak typeof(self) weakSelf = self;
        [UNetQueue unet_ping_sync:^{
            UCManualNetDiagResult *diagRes = [UCManualNetDiagResult instanceWithPingRes:weakSelf.manualPingRes];
            weakSelf.manualNetDiagHandler(diagRes,nil);
            weakSelf.isManualNetDiag = NO;
        }];
    }
}

#pragma mark- UCTraceRouteServiceDelegate
- (void)tracerouteResultWithUCTraceRouteService:(UCTraceRouteService *)ucTraceRouteService tracerouteResult:(UReportTracertModel *)uReportTracertModel
{
//    log4cplus_info("UNetTracert", "%s",[uReportTracertModel.description UTF8String]);
    if (uReportTracertModel.routeReplyArray.count == 1) {   // 防止icmp发送时间很久之后的响应,eg: 63.245.208.212
        return;
    }
    
    [[UCNetInfoReporter shareInstance] uReportTracertResultWithUReportTracertModel:uReportTracertModel destIpType:[self getDestIpType:uReportTracertModel.dst_ip]];
}

- (void)tracerouteFinishedWithUCTraceRouteService:(UCTraceRouteService *)ucTraceRouteService
{
//    if (self.userIpList == NULL) {
//        return;
//    }
//    if (self.shouldDoUserIpTracert) {
//        [self startTracertWithHosts:self.userIpList isUCloudHosts:NO];
//        self.shouldDoUserIpTracert = NO;
//    }else{
//    }
    
}
@end
