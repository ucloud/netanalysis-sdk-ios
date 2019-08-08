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


@interface UCNetClient()<UCPingServiceDelegate,UCTraceRouteServiceDelegate>
@property (nonatomic,copy) NSString *appName;
@property (nonatomic,copy) NSArray *hostList;

@property (nonatomic) UCReachability *reachability;
@property (nonatomic,assign) BOOL  isManualNetDiag;

@property (nonatomic,strong) UIpInfoModel *devicePubIpInfo;
@property (nonatomic,strong) UNetIpListBean *uIpListBean;

@property (nonatomic,copy) NSArray *userIpList;
@property (nonatomic,assign) UCNetworkStatus netStatus;
// define ip type , fix bug: ip repeat in hostIpList and userIpList
@property (nonatomic,assign) UIPType pingIpType;
@property (nonatomic,assign) UIPType tracertIpType;

@property (nonatomic,assign) BOOL  shouldDoUserIpPing;

@property (nonatomic,assign) UCCDNPingStatus ping_status;
@property (nonatomic,assign) BOOL isDoneCDNPing;

@property (nonatomic,copy)   NSString *cdnDomain;
@property (nonatomic,assign) UCTriggerDetectType detectType;
@property (nonatomic,assign) UCDataType sourceDataType;  // 表示数据源属于哪一种诊断触发的
@property (nonatomic,assign) UNetSDKSwitch sdkSwitch;

@property (nonatomic,assign) BOOL isResignActive;

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

- (void)closeAutoDetech
{
    _detectType = UCTriggerDetectType_Manual;
}

- (int)registSdkWithAppKey:(NSString *)appkey
               publicToken:(NSString *)publicToken
{
    self.isManualNetDiag = NO;
    [[UCNetInfoReporter shareInstance] setAppKey:appkey publickToken:publicToken];
    log4cplus_info("UNetSDK", "regist UCNetAnalysis success...\n");
    
    __weak typeof(self) weakSelf = self;
    [[UCNetInfoReporter shareInstance] uGetSDKStatusWithCompletionHandler:^(UNetSDKStatus * _Nullable sdkStatus, UCError * _Nullable ucError) {
        if (ucError) {
            log4cplus_error("UNetSDK", "Get SDK status error, stop data collection...\n");
            return;
        }
        self.sdkSwitch = (UNetSDKSwitch)sdkStatus.data.enabled;
        log4cplus_debug("UNetSDK", "SDK status: %ld",sdkStatus.data.enabled);

        if (self.sdkSwitch != UNetSDKSwitch_ON) {
            log4cplus_debug("UNetSDK", "SDK does not open...\n");
            return;
        }
        [UCPingService shareInstance].delegate = weakSelf;
        [UCTraceRouteService shareInstance].delegate = weakSelf;
        [weakSelf registNetStateChangeNoti];
    }];
    return 0;
}

- (void)settingUserDefineJsonFields:(NSString * _Nullable)fields
{
    [[UCNetInfoReporter shareInstance] setUserDefineJsonFields:fields];
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

- (BOOL)canStartNetDetection
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
    }
    if (!res) {
        log4cplus_warn("UNetSDK", "%s...\n",[warnInfo UTF8String]);
    }
    return res;
}

- (void)startDetect
{
    self.isResignActive = NO;
    
    if (self.sdkSwitch != UNetSDKSwitch_ON) {
        log4cplus_debug("UNetSDK", "SDK does not open...\n");
        return;
    }
    if (![self canStartNetDetection]) {
        return;
    }
    if (self.detectType == UCTriggerDetectType_Manual) {
        self.sourceDataType = UCDataType_Manual;
        [self startAutoDetect];
        return;
    }
    if (self.isManualNetDiag) {
        log4cplus_debug("UNetSDK", "manual detect is in progess, please try again later");
        return;
    }
    
    if ([[UCPingService shareInstance] uIsPing]) {
        log4cplus_debug("UNetSDK", "auto detect is in progress, please try again later");
        return;
    }
    
    UCPingService *pingService = [UCPingService shareInstance];
    self.sourceDataType = UCDataType_Manual;
    if ([pingService uIsPing]) {
        [pingService uStopPing];
    }
    
    UCTraceRouteService *tracertService = [UCTraceRouteService shareInstance];
    if ([tracertService uIsTracert]) {
        [tracertService uStopTracert];
    }
    
    log4cplus_debug("UNetSDK", "ManualDiag , begin mannual diag network...\n");
    self.isManualNetDiag = YES;
    self.pingIpType = UIPType_Customer;
    [self startPingHosts:self.userIpList];
    
    self.tracertIpType = UIPType_Customer;
    [self startTracertWithHosts:self.userIpList isUCloudHosts:NO];
    
}

/**
 @brief 当用户没有关闭了自动检测时，手动触发检测的方式
 */
- (void)startAutoDetect
{
    NSMutableArray *mutaArray = [NSMutableArray array];
    if (self.cdnDomain) {
        [mutaArray addObject:self.cdnDomain];
    }
    [mutaArray addObjectsFromArray:self.hostList];
    
    [self startPingHosts:mutaArray];
    self.pingIpType = UIPType_UCloud;
    self.shouldDoUserIpPing = YES;
    
    NSMutableArray *tracertList = [self.uIpListBean.data uGetTracertHosts];
    if (tracertList.count > 0) {
        log4cplus_debug("UNetSDK","do tracert for ucloud ips");
        self.tracertIpType = UIPType_UCloud;
        [self startTracertWithHosts:tracertList isUCloudHosts:YES];
    }else if(self.userIpList){
        log4cplus_debug("UNetSDK","There is no ucloud ips do tracert, do tracert for customer ips");
        self.tracertIpType = UIPType_Customer;
        [self startTracertWithHosts:self.userIpList isUCloudHosts:NO];
    }
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
    self.isResignActive = NO;
    self.devicePubIpInfo = nil;
    self.uIpListBean = nil;
    self.hostList = nil;
    self.netStatus = [reachability currentReachabilityStatus];
    self.ping_status = CDNPingStatus_ICMP_None;
    self.cdnDomain = nil;
    self.isDoneCDNPing = NO;
    switch (self.netStatus) {
        case Reachable_None:
        {
            log4cplus_info("UNetSDK", "none network...\n");
        }
            break;
        case Reachable_WiFi:
        {
            log4cplus_info("UNetSDK", "network type is WIFI...\n");
            [self updateEnvironments];
        }
            break;
        case Reachable_WWAN:
        {
            log4cplus_info("UNetSDK", "network type is WWAN...\n");
            [self updateEnvironments];
        }
            break;
            
        default:
            break;
    }
}

- (void)updateEnvironments
{
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
        
            if (weakSelf.detectType == UCTriggerDetectType_Manual) { // 如果当前自动网络检测关闭，则不执行自动诊断
                log4cplus_debug("UNetSDK", "SDK automatic collection net data function is closed...\n");
                return;
            }
            
            weakSelf.sourceDataType = UCDataType_Auto; // 更新数据源类型为Auto
            weakSelf.cdnDomain = ipListBean.data.domain;
            [weakSelf startAutoDetect];
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

- (void)closePingAndTracert
{
    if([[UCTraceRouteService shareInstance] uIsTracert]){
        [[UCTraceRouteService shareInstance] uStopTracert];
    }
    
    if ([[UCPingService shareInstance] uIsPing]) {
        [[UCPingService shareInstance] uStopPing];
    }
    self.isManualNetDiag = NO;
    self.isResignActive = YES;
    
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
    
    if (!self.isDoneCDNPing && ![self.hostList containsObject:uReportPingModel.dst_ip] && ![self.userIpList containsObject:uReportPingModel.dst_ip]) {
        self.isDoneCDNPing = YES;
        self.ping_status = uReportPingModel.loss == 100 ? CDNPingStatus_ICMP_Off : CDNPingStatus_ICMP_On;
        [[UCNetInfoReporter shareInstance] setPingStatus:self.ping_status];
        return;
    }
    
    if (self.isResignActive) {
        return;
    }
    
    [[UCNetInfoReporter shareInstance] uReportPingResultWithUReportPingModel:uReportPingModel
                                                                  destIpType:(int)self.pingIpType
                                                              dataSourceType:(int)self.sourceDataType];
}

- (void)pingFinishedWithUCPingService:(UCPingService *)ucPingService
{
    if (self.userIpList == NULL) {
        return;
    }
    
    // 如果ucloud ip list 完成ping的时候，user ip list 已经成功设置
    if (self.shouldDoUserIpPing && self.isManualNetDiag == NO) {
        self.pingIpType = UIPType_Customer;
        [self startPingHosts:self.userIpList];
        self.shouldDoUserIpPing = NO;
    }
    
    // 如果在进行手动诊断
    if (self.isManualNetDiag) {
        self.isManualNetDiag = NO;
    }
}

#pragma mark- UCTraceRouteServiceDelegate
- (void)tracerouteResultWithUCTraceRouteService:(UCTraceRouteService *)ucTraceRouteService tracerouteResult:(UReportTracertModel *)uReportTracertModel
{
//    log4cplus_info("UNetTracert", "%s",[uReportTracertModel.description UTF8String]);
    if (uReportTracertModel.routeReplyArray.count == 1) {   // 防止icmp发送时间很久之后的响应,eg: 63.245.208.212
        return;
    }
    
    if (self.isResignActive) {
        return;
    }
    [[UCNetInfoReporter shareInstance] uReportTracertResultWithUReportTracertModel:uReportTracertModel
                                                                        destIpType:(int)self.tracertIpType
                                                                    dataSourceType:(int)self.sourceDataType];
}

- (void)tracerouteFinishedWithUCTraceRouteService:(UCTraceRouteService *)ucTraceRouteService
{
    if (self.tracertIpType == UIPType_Customer) {
        return;
    }
    
    // have ucloud ips do tracert
    if (self.userIpList == NULL || self.userIpList.count == 0) {
        return;
    }
    [self startTracertWithHosts:self.userIpList isUCloudHosts:NO];
    self.tracertIpType = UIPType_Customer;
    
}
@end
