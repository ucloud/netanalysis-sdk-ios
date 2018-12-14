//
//  UCNetDiagnosisHelper.h
//  PingDemo
//
//  Created by ethan on 08/08/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AssertMacros.h>
#import <arpa/inet.h>
#import <netdb.h>
#import <netinet/in.h>
#import <sys/socket.h>
#import <unistd.h>

#import <netinet/in.h>
#import <netinet/tcp.h>


#define kUCloudPingTimeout      500   // 500 millisecond
#define kUCloudPingPackets      5



typedef struct UCIPHeader {
    uint8_t versionAndHeaderLength;
    uint8_t differentiatedServices;
    uint16_t totalLength;
    uint16_t identification;
    uint16_t flagsAndFragmentOffset;
    uint8_t timeToLive;
    uint8_t protocol;
    uint16_t headerChecksum;
    uint8_t sourceAddress[4];
    uint8_t destinationAddress[4];
    // options...
    // data...
}UCIPHeader;

__Check_Compile_Time(sizeof(UCIPHeader) == 20);
__Check_Compile_Time(offsetof(UCIPHeader, versionAndHeaderLength) == 0);
__Check_Compile_Time(offsetof(UCIPHeader, differentiatedServices) == 1);
__Check_Compile_Time(offsetof(UCIPHeader, totalLength) == 2);
__Check_Compile_Time(offsetof(UCIPHeader, identification) == 4);
__Check_Compile_Time(offsetof(UCIPHeader, flagsAndFragmentOffset) == 6);
__Check_Compile_Time(offsetof(UCIPHeader, timeToLive) == 8);
__Check_Compile_Time(offsetof(UCIPHeader, protocol) == 9);
__Check_Compile_Time(offsetof(UCIPHeader, headerChecksum) == 10);
__Check_Compile_Time(offsetof(UCIPHeader, sourceAddress) == 12);
__Check_Compile_Time(offsetof(UCIPHeader, destinationAddress) == 16);

/*
 use linux style . totals 64B
 */
typedef struct UICMPPacket
{
    uint8_t type;
    uint8_t code;
    uint16_t checksum;
    uint16_t identifier;
    uint16_t seq;
    char fills[56];  // data
}UICMPPacket;

typedef enum ENU_U_ICMPType
{
    ENU_U_ICMPType_EchoReplay = 0,
    ENU_U_ICMPType_EchoRequest = 8,
    ENU_U_ICMPType_TimeOut     = 11
}ENU_U_ICMPType;

__Check_Compile_Time(sizeof(UICMPPacket) == 64);
//__Check_Compile_Time(sizeof(UICMPPacket) == 8);
__Check_Compile_Time(offsetof(UICMPPacket, type) == 0);
__Check_Compile_Time(offsetof(UICMPPacket, code) == 1);
__Check_Compile_Time(offsetof(UICMPPacket, checksum) == 2);
__Check_Compile_Time(offsetof(UICMPPacket, identifier) == 4);
__Check_Compile_Time(offsetof(UICMPPacket, seq) == 6);



typedef struct UICMPPacket_Tracert
{
    uint8_t type;
    uint8_t code;
    uint16_t checksum;
    uint16_t identifier;
    uint16_t seq;
}UICMPPacket_Tracert;

__Check_Compile_Time(sizeof(UICMPPacket_Tracert) == 8);
__Check_Compile_Time(offsetof(UICMPPacket_Tracert, type) == 0);
__Check_Compile_Time(offsetof(UICMPPacket_Tracert, code) == 1);
__Check_Compile_Time(offsetof(UICMPPacket_Tracert, checksum) == 2);
__Check_Compile_Time(offsetof(UICMPPacket_Tracert, identifier) == 4);
__Check_Compile_Time(offsetof(UICMPPacket_Tracert, seq) == 6);

@interface UCNetDiagnosisHelper : NSObject

+ (uint16_t) in_cksumWithBuffer:(const void *)buffer andSize:(size_t)bufferLen;
+ (BOOL)isValidPingResponseWithBuffer:(char *)buffer len:(int)len seq:(int)seq identifier:(int)identifier;
+ (BOOL)isValidPingResponseWithBuffer:(char *)buffer len:(int)len;
+ (char *)icmpInpacket:(char *)packet andLen:(int)len;
+ (UICMPPacket *)constructPacketWithSeq:(uint16_t)seq andIdentifier:(uint16_t)identifier;


+ (NSArray<NSString *> *)resolveHost:(NSString *)hostname;
+ (struct sockaddr *)createSockaddrWithAddress:(NSString *)address;
+ (BOOL)isTimeoutPacket:(char *)packet len:(int)len;
+ (BOOL)isEchoReplayPacket:(char *)packet len:(int)len;
+ (UICMPPacket_Tracert *)constructTracertICMPPacketWithSeq:(uint16_t)seq andIdentifier:(uint16_t)identifier;
@end
