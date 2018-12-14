//
//  UCDeviceInfo.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/9/19.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 `NSObject`的子类。 该类定义的是设备信息，具体包括： 操作系统版本，屏幕分辨率，设备型号
 */
@interface UCDeviceInfo : NSObject

/**
 @brief 操作系统版本
 */
@property (nonatomic,readonly) NSString *osVersion;

/**
 @brief 屏幕分辨率
 */
@property (nonatomic,readonly) NSString *screenResolution;

/**
 @brief 设备型号
 */
@property (nonatomic,readonly) NSString *deviceModelName;
@end
