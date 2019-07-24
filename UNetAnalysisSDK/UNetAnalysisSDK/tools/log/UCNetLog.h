//
//  UCNetLog.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2019/7/23.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCNetSDKDef.h"

NS_ASSUME_NONNULL_BEGIN

@interface UCNetLog : NSObject

+ (void)settingSDKLogLevel:(UCSDKLogLevel)logLevel;

@end

NS_ASSUME_NONNULL_END
