//
//  UCNetLog.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2019/7/23.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import "UCNetLog.h"
#import "UNetAnalysisConst.h"
#include "log4cplus.h"


/*   define log level  */
int UCLOUD_IOS_FLAG_FATAL = 0x10;
int UCLOUD_IOS_FLAG_ERROR = 0x08;
int UCLOUD_IOS_FLAG_WARN = 0x04;
int UCLOUD_IOS_FLAG_INFO = 0x02;
int UCLOUD_IOS_FLAG_DEBUG = 0x01;
int UCLOUD_IOS_LOG_LEVEL = UCLOUD_IOS_LOG_LEVEL = UCLOUD_IOS_FLAG_FATAL|UCLOUD_IOS_FLAG_ERROR;

@implementation UCNetLog


+ (void)settingSDKLogLevel:(UCSDKLogLevel)logLevel
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

@end
