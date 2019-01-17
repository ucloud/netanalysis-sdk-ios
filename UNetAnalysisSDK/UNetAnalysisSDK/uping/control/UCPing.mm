//
//  UCPing.m
//  PingDemo
//
//  Created by ethan on 03/08/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UCPing.h"
#import "UNetAnalysisConst.h"
#import "UCNetInfoReporter.h"
#include "log4cplus.h"
#import "UNetQueue.h"
#import "UCDateTool.h"


@interface UCPing()
{
    int socket_client;
    struct sockaddr_in remote_addr;
}
@property (nonatomic,assign) BOOL isPing;

@property (nonatomic,assign) BOOL isStopPingThread;
@property (nonatomic,strong) NSMutableDictionary *sendPacketDateDict;
@property (nonatomic,strong) NSMutableArray *hostList;
@property (atomic,assign)  int hostArrayIndex;
@end

@implementation UCPing

- (instancetype)init
{
    if ([super init]) {
        self.hostArrayIndex = 0;
        
        _isStopPingThread = NO;
        _sendPacketDateDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addSendIcmpPacketDateToContainerWithSeq:(int)seq
{
    NSString *key = [NSString stringWithFormat:@"SendIcmpPacketDate%d",seq];
    [_sendPacketDateDict setObject:[NSDate date] forKey:key];
}

- (NSDate *)getSendIcmpPacketDateFromContainerWithSeq:(int)seq
{
    NSString *key = [NSString stringWithFormat:@"SendIcmpPacketDate%d",seq];
    return [_sendPacketDateDict objectForKey:key];
}

- (void)stopPing
{
    self.isStopPingThread = YES;
}

- (BOOL)isPing
{
    return !self.isStopPingThread;
}

- (BOOL)settingUHostSocketAddressWithHost:(NSString *)host
{
    try {
        const char *hostaddr = [host UTF8String];
        memset(&remote_addr, 0, sizeof(remote_addr));
        remote_addr.sin_addr.s_addr = inet_addr(hostaddr);
        
        if (remote_addr.sin_addr.s_addr == INADDR_NONE) {
            struct hostent *remoteHost = gethostbyname(hostaddr);
            if (remoteHost == NULL || remoteHost->h_addr == NULL) {
                log4cplus_warn("UNetPing", "access %s DNS error, remove this ip..\n",[host UTF8String]);
                return NO;
            }
            remote_addr.sin_addr = *(struct in_addr *)remoteHost->h_addr;
        }
        
        struct timeval timeout;
        timeout.tv_sec = 1;
        timeout.tv_usec = 0;
        socket_client = socket(AF_INET,SOCK_DGRAM,IPPROTO_ICMP);
        int res = setsockopt(socket_client, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
        if (res < 0) {
            log4cplus_warn("UNetPing", "ping %s , set timeout error..\n",[host UTF8String]);
        }
        remote_addr.sin_family = AF_INET;
    } catch (NSException *exception) {
        log4cplus_error("UNetPing", "func: %s, exception info: %s , line: %d",__func__,[exception.description UTF8String],__LINE__);
    }
    
    return YES;
}

- (NSString *)convertDomainToIp:(NSString *)host
{
    const char *hostaddr = [host UTF8String];
    memset(&remote_addr, 0, sizeof(remote_addr));
    remote_addr.sin_addr.s_addr = inet_addr(hostaddr);
    
    if (remote_addr.sin_addr.s_addr == INADDR_NONE) {
        struct hostent *remoteHost = gethostbyname(hostaddr);
        if (remoteHost == NULL || remoteHost->h_addr == NULL) {
            log4cplus_warn("UNetPing", "access %s DNS error, remove this ip..\n",[host UTF8String]);
            return NULL;
        }
        remote_addr.sin_addr = *(struct in_addr *)remoteHost->h_addr;
        return [NSString stringWithFormat:@"%s",inet_ntoa(remote_addr.sin_addr)];
    }
    return host;
}

- (void)startPingHosts:(NSArray *)hostlist
{
    _hostList = [NSMutableArray array];
    for (int i = 0; i < hostlist.count; i++) {
        if ([self settingUHostSocketAddressWithHost:hostlist[i]]) {
//            [_hostList addObject:hostlist[i]];
            [_hostList addObject:[self convertDomainToIp:hostlist[i]]];
        }
    }
    
    if (_hostList.count == 0) {
        self.isStopPingThread = YES;
        log4cplus_info("UNetPing", "There is no valid domain in the domain list, ping complete..\n");
        return;
    }
    self.hostArrayIndex = 0;
    
    [UNetQueue unet_ping_sync:^{
        [self sendAndrecevPingPacket];
    }];
}

- (void)sendAndrecevPingPacket
{
    [self settingUHostSocketAddressWithHost:_hostList[self.hostArrayIndex]];
    [self startPing:socket_client andRemoteAddr:remote_addr];
    
    while (!self.isStopPingThread) {
        BOOL isReceiverRemoteIpPingRes = NO;
        
        try {
            isReceiverRemoteIpPingRes = [self receiverRemoteIpPingRes];
        } catch (NSException *exception) {
            log4cplus_error("UNetPing", "func: %s, exception info: %s , line: %d",__func__,[exception.description UTF8String],__LINE__);
        }
        
        if (isReceiverRemoteIpPingRes) {
            self.hostArrayIndex++;
            if (self.hostArrayIndex == self.hostList.count) {
                log4cplus_info("UNetPing", "ping complete..\n");
                /*
                 int shutdown(int s, int how); // s is socket descriptor
                 int how can be:
                 SHUT_RD or 0 Further receives are disallowed
                 SHUT_WR or 1 Further sends are disallowed
                 SHUT_RDWR or 2 Further sends and receives are disallowed
                 */
                shutdown(socket_client, SHUT_RDWR); //
                self.isStopPingThread = YES;
                [self.delegate pingFinishedWithUCPing:self];
                break;
            }
            [self settingUHostSocketAddressWithHost:_hostList[self.hostArrayIndex]];
            [self startPing:socket_client andRemoteAddr:remote_addr];
        }
        usleep(500);
        
    }
}

- (void)startPing:(int)socketClient andRemoteAddr:(struct sockaddr_in)remoteAddr
{
    
    try {
        log4cplus_info("UNetPing", "begin ping ip:%s",[self.hostList[self.hostArrayIndex] UTF8String]);
        int index = 0;
        uint16_t identifier = (uint16_t)(KPingIcmpIdBeginNum + self.hostArrayIndex);
        do {
            UICMPPacket *packet = [UCNetDiagnosisHelper constructPacketWithSeq:index andIdentifier:identifier];
            [self addSendIcmpPacketDateToContainerWithSeq:index];
            ssize_t sent = sendto(socketClient, packet, sizeof(UICMPPacket), 0, (struct sockaddr *)&remoteAddr, (socklen_t)sizeof(struct sockaddr));
            if (sent < 0) {
                log4cplus_warn("UNetPing", "ping %s , send icmp packet error..\n",[self.hostList[self.hostArrayIndex] UTF8String]);
            }
            
            free(packet);
            usleep(500);
            
        } while (++index < 5 && !self.isStopPingThread);
    } catch (NSException *exception) {
        log4cplus_error("UNetPing", "func: %s, exception info: %s , line: %d",__func__,[exception.description UTF8String],__LINE__);
    }
}

- (BOOL)receiverRemoteIpPingRes
{
    BOOL res = NO;
    int ping_recev_index = 0;
    int ping_timeout_index = 0;
    struct sockaddr_storage ret_addr;
    socklen_t addrLen = sizeof(ret_addr);
    void *buffer = malloc(65535);
    NSString *devicePublicIp = [[UCNetInfoReporter shareInstance] ipInfoModel].addr;
    while (true) {
        
        size_t bytesRead = recvfrom(socket_client, buffer, 65535, 0, (struct sockaddr *)&ret_addr, &addrLen);
        
        if ((int)bytesRead < 0) {
            
            log4cplus_warn("UNetPing", "ping %s , receive icmp packet timeout..\n",[self.hostList[self.hostArrayIndex] UTF8String]);
            
            // 针对于一个新的ip，全部是timeout的情况，那么收到5个就开始ping下一个； 如果在ping一个ip的5个包中，其中第2个包以后开始timeout，那么针对于这个ip再timeout 3个包即开始下一个
//            NSLog(@"ping ,rec ping error,bytesRead < 0，bytesRead:%d ,ping_recev_index:%d ,ping_timeout_index:%d",(int)bytesRead,ping_recev_index,ping_timeout_index);
            
            [self reporterPingResWithSorceIp:self.hostList[self.hostArrayIndex] destinationIp:devicePublicIp ttl:0 timeMillSecond:0 seq:ping_timeout_index icmpId:0 dataSize:0 pingStatus:UCPingStatus_Timeout];
            
            if (ping_recev_index != 0 && ping_timeout_index == 0 ) {
                ping_timeout_index = ping_recev_index;
            }
            ping_timeout_index++;
            if (ping_timeout_index == 5) {
                res = YES;
                log4cplus_info("UNetPing", "done ping , ip:%s \n",[self.hostList[self.hostArrayIndex] UTF8String]);
                [self reporterPingResWithSorceIp:self.hostList[self.hostArrayIndex] destinationIp:devicePublicIp ttl:0 timeMillSecond:0 seq:ping_timeout_index icmpId:0 dataSize:0 pingStatus:UCPingStatus_Finish];
                break;
            }
            
            //            break;
        }else if(bytesRead == 0){
            log4cplus_warn("UNetPing", "ping %s , receive icmp packet error , bytesRead=0",[self.hostList[self.hostArrayIndex] UTF8String]);
        }else{
            
            if ([UCNetDiagnosisHelper isValidPingResponseWithBuffer:(char *)buffer len:(int)bytesRead]) {
                
                UICMPPacket *icmpPtr = (UICMPPacket *)[UCNetDiagnosisHelper icmpInpacket:(char *)buffer andLen:(int)bytesRead];
                
                NSTimeInterval duration = 0.0;
                int seq = OSSwapBigToHostInt16(icmpPtr->seq);
                
                NSDate *date = [self getSendIcmpPacketDateFromContainerWithSeq:seq];
                duration = [[NSDate date] timeIntervalSinceDate:date];
                
                int ttl = ((UCIPHeader *)buffer)->timeToLive;
//                uint8_t *p_sorce = ((UCIPHeader *)buffer)->sourceAddress;
//                uint8_t *p_dst = ((UCIPHeader *)buffer)->destinationAddress;
//                NSString *sorceIp = [NSString stringWithFormat:@"%d.%d.%d.%d",*p_sorce, *(p_sorce+1), *(p_sorce+2), *(p_sorce+3)];
//                NSString *destIp = [NSString stringWithFormat:@"%d.%d.%d.%d",*p_dst, *(p_dst+1),*(p_dst+2), *(p_dst+3)];
                NSString *destIp = devicePublicIp;
                int size = (int)(bytesRead-sizeof(UCIPHeader));
                NSString *sorceIp = self.hostList[self.hostArrayIndex];
                
//                NSLog(@"ping res: srcIP:%d.%d.%d.%d --> desIP:%d.%d.%d.%d ,size:%d , ttl:%d ,icmpID:%d, timeMillseconds:%f ,seq:%d",*p_sorce, *(p_sorce+1), *(p_sorce+2), *(p_sorce+3), *p_dst, *(p_dst+1),*(p_dst+2), *(p_dst+3),size,ttl,OSSwapBigToHostInt16(icmpPtr->identifier),duration * 1000,seq);
                
//                log4cplus_warn("UNetPing", "srcIP:%d.%d.%d.%d --> desIP:%d.%d.%d.%d ,size:%d , ttl:%d ,icmpID:%d, timeMillseconds:%f ,seq:%d",*p_sorce, *(p_sorce+1), *(p_sorce+2), *(p_sorce+3), *p_dst, *(p_dst+1),*(p_dst+2), *(p_dst+3),size,ttl,OSSwapBigToHostInt16(icmpPtr->identifier),duration * 1000,seq);
                
                
//                log4cplus_info("UNetPing", "ping %s , receive icmp packet..\n",[self.hostList[self.hostArrayIndex] UTF8String]);
                [self reporterPingResWithSorceIp:sorceIp destinationIp:destIp ttl:ttl timeMillSecond:duration*1000 seq:seq icmpId:OSSwapBigToHostInt16(icmpPtr->identifier) dataSize:size pingStatus:UCPingStatus_ReceivePacket];
                
                
                ping_recev_index++;
                if (ping_recev_index == 5) {
                    
                    log4cplus_info("UNetPing", "done ping , ip:%s \n",[self.hostList[self.hostArrayIndex] UTF8String]);
                    [self reporterPingResWithSorceIp:sorceIp destinationIp:destIp ttl:ttl timeMillSecond:duration*1000 seq:seq icmpId:OSSwapBigToHostInt16(icmpPtr->identifier) dataSize:size pingStatus:UCPingStatus_Finish];
                    
                    close(socket_client);
                    res = YES;
                    break;
                    
                }
            }
            
        }
        
        usleep(500);
    }
    return res;
}

- (void)reporterPingResWithSorceIp:(NSString *)sorceIp destinationIp:(NSString *)destIp ttl:(int)ttl timeMillSecond:(double)timeMillSec seq:(int)seq icmpId:(int)icmpId dataSize:(int)size pingStatus:(UCPingStatus)status
{
    static NSInteger initBeginTime = 0;
    if (initBeginTime == 0) {
        initBeginTime = [UCDateTool currentTimestamp];
    }
    UPingResModel *pingResModel = [[UPingResModel alloc] init];
    pingResModel.status = status;
    pingResModel.originalAddress = destIp;
    pingResModel.IPAddress = sorceIp;
    if (initBeginTime != 0) {
        pingResModel.beginTime = initBeginTime;
    }
    switch (status) {
        case UCPingStatus_ReceivePacket:
        {
            pingResModel.ICMPSequence = seq;
            pingResModel.timeToLive = ttl;
            pingResModel.timeMilliseconds = timeMillSec;
            pingResModel.dateBytesLength = size;
        }
            break;
        case UCPingStatus_Finish:
        {
            pingResModel.ICMPSequence = 5;
            initBeginTime = 0;
        }
            break;
        case UCPingStatus_Timeout:
        {
            pingResModel.ICMPSequence = seq;
        }
            break;
            
        default:
            break;
    }
    
    [self.delegate pingResultWithUCPing:self pingResult:pingResModel pingStatus:status];
    
}


@end
