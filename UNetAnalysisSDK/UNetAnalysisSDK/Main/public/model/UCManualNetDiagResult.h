//
//  UCManualNetDiagResult.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/9/19.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCAppNetInfo.h"
#import "UCAppInfo.h"
#import "UCDeviceInfo.h"
#import "UCIpPingResult.h"

/**
 这是`NSObject`的一个子类。 该类包含手动诊断网络的结果，例如: app信息，手机信息，app网络信息等。
 */
@interface UCManualNetDiagResult : NSObject

/**
 @brief 应用信息
 @discussion 例如： app版本，app名称，app的bundleID 等
 */
@property (nonatomic,strong) UCAppInfo       *appInfo;

/**
 @brief 手机信息
 @discussion 例如： 设备型号，操作系统版本
 */
@property (nonatomic,strong) UCDeviceInfo    *deviceInfo;

/**
 @brief 应用网络信息
 @discussion 应用的网络信息， 例如： 网络类型，公网IP等
 */
@property (nonatomic,strong) UCAppNetInfo    *appNetInfo;         // The app net info. eg: net type,public ip,etc..

/**
 @brief 用户服务地址诊断结果
 @discussion 对用户设置的服务地址列表的ping的结果。详情可查看 `UCIpPingResult`
 */
@property (nonatomic,strong) NSMutableArray<UCIpPingResult *> *pingInfo;

@end
