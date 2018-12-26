//
//  UCNetAnalysis.m
//  UNetAnalysisSDK
//
//  Created by ethan on 26/07/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UCNetAnalysis.h"
#import "UNetAnalysisConst.h"
#import "UCNetInfoReporter.h"
#import "UCServerResponseModel.h"
#import "UCPingService.h"
#import "UCTraceRouteService.h"
#import "UTracertModel.h"
#import "UCDateTool.h"
#include "log4cplus.h"
#import "UNetAppInfo.h"
#import "Reachability.h"

/*   define log level  */
int UCLOUD_IOS_FLAG_FATAL = 0x10;
int UCLOUD_IOS_FLAG_ERROR = 0x08;
int UCLOUD_IOS_FLAG_WARN = 0x04;
int UCLOUD_IOS_FLAG_INFO = 0x02;
int UCLOUD_IOS_FLAG_DEBUG = 0x01;
int UCLOUD_IOS_LOG_LEVEL = UCLOUD_IOS_LOG_LEVEL = UCLOUD_IOS_FLAG_FATAL|UCLOUD_IOS_FLAG_ERROR;

@interface UCNetAnalysis()<UCPingServiceDelegate,UCTraceRouteServiceDelegate>
@property (nonatomic,copy) NSString *appName;
@property (nonatomic,copy) NSArray *hostList;

@property (nonatomic) Reachability *reachability;

@property (readonly) UCNetManualNetDiagCompleteHandler manualNetDiagHandler;
@property (nonatomic,strong) UCManualNetDiagResult *manualNetDialogResult;
@property (nonatomic,assign) BOOL  isManualNetDiag;
@property (nonatomic,strong) NSString *devicePublicIp;

@property (nonatomic,copy) NSArray *userIpList;
@property (nonatomic,assign) NetworkStatus netStatus;
@property (nonatomic,assign) BOOL  shouldDoUserIpPing;

@property (nonatomic,assign) BOOL  shouldDoTracert;

@property (nonatomic,assign) BOOL  isDoingUHostIpTracert;
@property (nonatomic,assign) BOOL  shouldDoUserIpTracert;

/** for SDK demo **/
@property (nonatomic,assign) BOOL isCloseAutoAnalysis;
@property (nonatomic,copy,readonly) UNetPingResultHandler pingResultHandler;
@property (nonatomic,copy,readonly) UNetTracerouteResultHandler tracertResultHandler;
@end

@implementation UCNetAnalysis

static UCNetAnalysis *ucloudNetAnalysis_instance = nil;

+ (instancetype)shareInstance
{
    static dispatch_once_t ucloudNetAnalysis_onceToken;
    dispatch_once(&ucloudNetAnalysis_onceToken, ^{
        ucloudNetAnalysis_instance = [[super allocWithZone:NULL] init];
    });
    return ucloudNetAnalysis_instance;
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    return [UCNetAnalysis shareInstance];
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [UCNetAnalysis shareInstance];
}

- (void)settingSDKLogLevel:(UCNetSDKLogLevel)logLevel
{
    switch (logLevel) {
        case UCNetSDKLogLevel_FATAL:
        {
            UCLOUD_IOS_LOG_LEVEL = UCLOUD_IOS_FLAG_FATAL;
            log4cplus_fatal("UNetSDK", "setting UCSDK log level ,UCLOUD_IOS_FLAG_FATAL...\n");
        }
            break;
        case UCNetSDKLogLevel_ERROR:
        {
            UCLOUD_IOS_LOG_LEVEL = UCLOUD_IOS_FLAG_FATAL|UCLOUD_IOS_FLAG_ERROR;
            log4cplus_warn("UNetSDK", "setting UCSDK log level ,UCLOUD_IOS_FLAG_ERROR...\n");
        }
            break;
        case UCNetSDKLogLevel_WARN:
        {
            UCLOUD_IOS_LOG_LEVEL = UCLOUD_IOS_FLAG_FATAL|UCLOUD_IOS_FLAG_ERROR|UCLOUD_IOS_FLAG_WARN;
            log4cplus_warn("UNetSDK", "setting UCSDK log level ,UCLOUD_IOS_FLAG_WARN...\n");
        }
            break;
        case UCNetSDKLogLevel_INFO:
        {
            UCLOUD_IOS_LOG_LEVEL = UCLOUD_IOS_FLAG_FATAL|UCLOUD_IOS_FLAG_ERROR|UCLOUD_IOS_FLAG_WARN|UCLOUD_IOS_FLAG_INFO;
            log4cplus_info("UNetSDK", "setting UCSDK log level ,UCLOUD_IOS_FLAG_INFO...\n");
        }
            break;
        case UCNetSDKLogLevel_DEBUG:
        {
            UCLOUD_IOS_LOG_LEVEL = UCLOUD_IOS_FLAG_FATAL|UCLOUD_IOS_FLAG_ERROR|UCLOUD_IOS_FLAG_WARN|UCLOUD_IOS_FLAG_INFO|UCLOUD_IOS_FLAG_DEBUG;
            log4cplus_debug("UNetSDK", "setting UCSDK log level ,UCNetAnalysisSDKLogLevel_DEBUG...\n");
        }
            break;
            
        default:
            break;
    }
}

- (int)registSdkWithAppKey:(NSString *)appkey publicToken:(NSString *)publicToken
{
    self.isManualNetDiag = NO;
    self.shouldDoTracert = YES;
    self.shouldDoUserIpTracert = YES;
    [[UCNetInfoReporter shareInstance] setAppKey:appkey publickToken:publicToken];
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
            self.userIpList = array;
        }else{
            log4cplus_warn("UNetSDK", "There is no valid ip in the ip list set by the user..\n");
        }
    } catch (NSException *exception) {
        log4cplus_error("UNetSDK", "func: %s, exception info: %s , line: %d",__func__,[exception.description UTF8String],__LINE__);
    }
}

- (void)manualDiagNetStatus:(UCNetManualNetDiagCompleteHandler _Nonnull)completeHandler
{
    if (self.userIpList == NULL || self.userIpList.count == 0) {
        _manualNetDialogResult = [[UCManualNetDiagResult alloc] init];
        _manualNetDiagHandler = completeHandler;
        UCAppInfo *appInfo = [[UCAppInfo alloc] init];
        UCDeviceInfo *deviceInfo = [[UCDeviceInfo alloc] init];
        UCAppNetInfo *appNetInfo = [[UCAppNetInfo alloc] initUAppNetInfoWithPublicIp:self.devicePublicIp networkType:[UNetAppInfo uGetNetworkType]];
        _manualNetDialogResult.appInfo = appInfo;
        _manualNetDialogResult.deviceInfo = deviceInfo;
        _manualNetDialogResult.appNetInfo = appNetInfo;
        _manualNetDiagHandler(_manualNetDialogResult);
        log4cplus_warn("UNetSDK", "manual diag net, you setting ip list is null..\n");
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
    
    _manualNetDialogResult = [[UCManualNetDiagResult alloc] init];
    _manualNetDiagHandler = completeHandler;
    if (self.netStatus == NotReachable) {   // 如果当前没网，则需要返回设备信息，设备网络信息，ping就不需要做了
        UCAppInfo *appInfo = [[UCAppInfo alloc] init];
        UCDeviceInfo *deviceInfo = [[UCDeviceInfo alloc] init];
        UCAppNetInfo *appNetInfo = [[UCAppNetInfo alloc] initUAppNetInfoWithPublicIp:self.devicePublicIp networkType:[UNetAppInfo uGetNetworkType]];
        _manualNetDialogResult.appInfo = appInfo;
        _manualNetDialogResult.deviceInfo = deviceInfo;
        _manualNetDialogResult.appNetInfo = appNetInfo;
        _manualNetDiagHandler(_manualNetDialogResult);
        log4cplus_debug("UNetSDK", "ManualDiag , none network...\n");
        return;
    }
    
    
    self.isManualNetDiag = YES;
    _manualNetDialogResult.pingInfo = [NSMutableArray array];
    [self startPingHosts:self.userIpList];
}

- (void)settingIsCloseAutoAnalysisNet:(BOOL)isClose
{
    self.isCloseAutoAnalysis = isClose;
}

- (BOOL)autoAnalysisNetIsAvailable
{
    return !self.isCloseAutoAnalysis;
}

- (void)startPing:(NSString *)host pingResultHandler:(UNetPingResultHandler _Nonnull)handler
{
    if (!self.isCloseAutoAnalysis) {
        log4cplus_warn("UNetSDK", "manual ping function is unavailable..\n");
        return;
    }
    _pingResultHandler = handler;
    [self startPingHosts:@[host]];
}

- (void)startTraceroute:(NSString *)host tracerouteResultHadler:(UNetTracerouteResultHandler _Nonnull)handler
{
    if (!self.isCloseAutoAnalysis) {
        log4cplus_warn("UNetSDK", "manual traceroute function is unavailable..\n");
        return;
    }
    _tracertResultHandler = handler;
    
    UCTraceRouteService *tracertService = [UCTraceRouteService shareInstance];
    if ([tracertService uIsTracert]) {
        [tracertService uStopTracert];
    }
    [tracertService uStartTracerouteAddressList:@[host]];
}

- (BOOL)isIpAddress:(NSString *)ipStr
{
    if (nil == ipStr) {
        log4cplus_warn("UNetSDK", "ip address is nil...\n");
        return NO;
    }
    NSArray *ipArray = [ipStr componentsSeparatedByString:@"."];
    if (ipArray.count == 4) {
        for (NSString *ipnumberStr in ipArray) {
            int ipnumber = [ipnumberStr intValue];
            if (!(ipnumber>=0 && ipnumber<=255)) {
                log4cplus_warn("UNetSDK", "%s is not a invalid ip address , so remove this ip..\n",[ipStr UTF8String]);
                return NO;
            }
        }
        return YES;
    }
    log4cplus_warn("UNetSDK", "%s is not a invalid ip address , so remove this ip..\n",[ipStr UTF8String]);
    return NO;
}

- (void)registNetStateChangeNoti
{
    log4cplus_info("UNetSDK", "regist net state change notification...\n");
    [UCNotification addObserver:self selector:@selector(networkChange:) name:kReachabilityChangedNotification object:nil];
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    [self checkNetworkStatusWithReachability:self.reachability];
}

- (void)networkChange:(NSNotification *)noti
{
    Reachability *reachability = [noti object];
    [self checkNetworkStatusWithReachability:reachability];
}

- (void)checkNetworkStatusWithReachability:(Reachability *)reachability
{
    self.netStatus = [reachability currentReachabilityStatus];
    switch (self.netStatus) {
        case NotReachable:
        {
            log4cplus_info("UNetSDK", "none network...\n");
        }
            break;
        case ReachableViaWiFi:
        {
            log4cplus_info("UNetSDK", "network type is WIFI...\n");
            [self doPingAndTracertUHosts];
        }
            break;
        case ReachableViaWWAN:
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
    if (self.isCloseAutoAnalysis) {
        log4cplus_warn("UNetSDK", "the use closed auto analysis device network status..\n");
        return;
    }
    
    [[UCNetInfoReporter shareInstance] uGetDevicePublicIpInfoWithCompletionHandle:^(UIpInfoModel * _Nullable ipInfoModel) {
        if (ipInfoModel == NULL) {
            log4cplus_warn("UNetSDK", "have not get device public ip info , cancel device network info collection...\n");
            return;
        }
        self.devicePublicIp = ipInfoModel.addr;
        log4cplus_debug("UNetSDK", "success get the device public ip info , info: %s",[ipInfoModel.description UTF8String]);
        [[UCNetInfoReporter shareInstance] uGetUHostListWithCompletionHandler:^(UNetIpListBean *_Nullable ipListBean) {
            if (ipListBean == NULL) {
                log4cplus_warn("UNetSDK", "have not get ucloud ip list , cancel device network info collection...\n");
                return;
            }
            log4cplus_debug("UNetSDK", "success get the ucloud ip list-->%s..\n",[ipListBean.data.description UTF8String]);
            
            self.hostList = [ipListBean.data uGetUHosts];
            // 乱序
            self.hostList = [self.hostList sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
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
            
            [self startPingHosts:self.hostList];
            self.shouldDoUserIpPing = YES;
            
            if (self.shouldDoTracert) {
                 [self startTracertWithHosts:self.hostList isUCloudHosts:YES];
                self.shouldDoTracert = NO;
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
    self.isDoingUHostIpTracert = isUHosts;
    NSArray *tracertHosts =  isUHosts ? self.hostList : self.userIpList;
    [ucTracertService uStartTracerouteAddressList:tracertHosts];
}

#pragma mark- UCPingServiceDelegate
- (void)pingDetailWithUCPingService:(UCPingService *)ucPingService pingModel:(UPingResModel *)pingRes pingStatus:(UCloudPingStatus)status
{
    if (!self.isCloseAutoAnalysis) {
        return;
    }
    
    if (pingRes.ICMPSequence == 5) {
        return;
    }
    NSString *pingDetail = [NSString stringWithFormat:@"%d bytes form %@: icmp_seq=%d ttl=%d time=%.3fms",(int)pingRes.dateBytesLength,pingRes.IPAddress,(int)pingRes.ICMPSequence,(int)pingRes.timeToLive,pingRes.timeMilliseconds];
    _pingResultHandler(pingDetail);
}

- (void)pingResultWithUCPingService:(UCPingService *)ucPingService pingResult:(UReportPingModel *)uReportPingModel
{
    if (self.isCloseAutoAnalysis) {
        return;
    }
    
    log4cplus_info("UNetPing", "%s\n",[uReportPingModel.description UTF8String]);
    [[UCNetInfoReporter shareInstance] uReportPingResultWithUReportPingModel:uReportPingModel];
    
    // 回显用户设置的ip列表的ping结果
    if (self.isManualNetDiag) {
        UCIpPingResult *ipPingRes = [[UCIpPingResult alloc] initUIpPingResultWithIp:uReportPingModel.dst_ip loss:uReportPingModel.loss delay:uReportPingModel.delay];
        [_manualNetDialogResult.pingInfo addObject:ipPingRes];
    }
    
}

- (void)pingFinishedWithUCPingService:(UCPingService *)ucPingService
{
    if (self.isCloseAutoAnalysis) {
        return;
    }
    if (self.userIpList == NULL) {
        return;
    }
    
    // 如果ucloud ip list 完成ping的时候，user ip list 已经成功设置
    if (self.shouldDoUserIpPing) {
        [self startPingHosts:self.userIpList];
        self.shouldDoUserIpPing = NO;
    }
    
    // 如果在进行手动诊断
    if (self.isManualNetDiag) {
        // add app info,device info , app net info
        UCAppInfo *appInfo = [[UCAppInfo alloc] init];
        UCDeviceInfo *deviceInfo = [[UCDeviceInfo alloc] init];
        UCAppNetInfo *appNetInfo = [[UCAppNetInfo alloc] initUAppNetInfoWithPublicIp:self.devicePublicIp networkType:[UNetAppInfo uGetNetworkType]];
        _manualNetDialogResult.appInfo = appInfo;
        _manualNetDialogResult.deviceInfo = deviceInfo;
        _manualNetDialogResult.appNetInfo = appNetInfo;
        _manualNetDiagHandler(_manualNetDialogResult);
        
        self.isManualNetDiag = NO;
    }
}

#pragma mark- UCTraceRouteServiceDelegate
- (void)tracerouteDetailWithUCTraceRouteService:(UCTraceRouteService *)ucTraceRouteService tracertResModel:(UCTracerRouteResModel *)uTracertResModel
{
    if (!self.isCloseAutoAnalysis) {
        return;
    }
    NSMutableString *tracertTimeoutRes = [NSMutableString string];
    NSMutableString *mutableDurations = [NSMutableString string];
    for (int i = 0; i < uTracertResModel.count; i++) {
        if (uTracertResModel.durations[i] <= 0) {
            [tracertTimeoutRes appendString:@" *"];
        }else{
            [mutableDurations appendString:[NSString stringWithFormat:@" %.3fms",uTracertResModel.durations[i] * 1000]];
        }
    }
    NSMutableString *tracertDetail = [NSMutableString string];
    if (tracertTimeoutRes.length > 0) {
        [tracertDetail appendString:[NSString stringWithFormat:@"%d %@",(int)uTracertResModel.hop,tracertTimeoutRes]];
        _tracertResultHandler(tracertDetail,uTracertResModel.dstIp);
        return;
    }
    
    NSString *tracertNormalDetail = [NSString stringWithFormat:@"%d  %@(%@) %@",(int)uTracertResModel.hop,uTracertResModel.ip,uTracertResModel.ip,mutableDurations];
    [tracertDetail appendString:tracertNormalDetail];
    _tracertResultHandler(tracertDetail,uTracertResModel.dstIp);
}

- (void)tracerouteResultWithUCTraceRouteService:(UCTraceRouteService *)ucTraceRouteService tracerouteResult:(UReportTracertModel *)uReportTracertModel
{
    if (self.isCloseAutoAnalysis) {
        return;
    }
//    log4cplus_info("UNetTracert", "%s",[uReportTracertModel.description UTF8String]);
    
    if (uReportTracertModel.routeReplyArray.count == 1) {   // 防止icmp发送时间很久之后的响应,eg: 63.245.208.212
        return;
    }
    
    [[UCNetInfoReporter shareInstance] uReportTracertResultWithUReportTracertModel:uReportTracertModel];
}

- (void)tracerouteFinishedWithUCTraceRouteService:(UCTraceRouteService *)ucTraceRouteService
{
    if (self.isCloseAutoAnalysis) {
        return;
    }
    if (self.userIpList == NULL) {
        return;
    }
    
    if (self.shouldDoUserIpTracert) {
        [self startTracertWithHosts:self.userIpList isUCloudHosts:NO];
        self.shouldDoUserIpTracert = NO;
    }else{
    }
    
}
@end
