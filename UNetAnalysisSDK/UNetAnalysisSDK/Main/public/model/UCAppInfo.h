//
//  UCAppInfo.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/9/19.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 `NSObject`的子类。 该类定义的是APP信息，具体包括： app名称，app的bundleID，app版本
 */
@interface UCAppInfo : NSObject

/**
 @brief app名称
 */
@property (nonatomic,readonly) NSString *appName;

/**
 @brief app的bundleID
 */
@property (nonatomic,readonly) NSString *appBundleId;

/**
 @brief app版本
 */
@property (nonatomic,readonly) NSString *appVersion;
@end
