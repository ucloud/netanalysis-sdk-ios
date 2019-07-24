//
//  UCNetSDKDef.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2019/7/23.
//  Copyright © 2019 ucloud. All rights reserved.
//

#ifndef UCNetSDKDef_h
#define UCNetSDKDef_h

#import "UCModel.h"

/**
 @brief 这是一个枚举类型，定义日志级别
 
 @discussion 建议开发的时候，把SDK的日志级别设置为`UCSDKLogLevel_DEBUG`,这样便于开发调试。等上线时再把级别改为较高级别的`UCSDKLogLevel_ERROR`
 
 - UCSDKLogLevel_FATAL: FATAL级别
 - UCSDKLogLevel_ERROR: ERROR级别（如果不设置，默认是该级别）
 - UCSDKLogLevel_WARN:  WARN级别
 - UCSDKLogLevel_INFO:  INFO级别
 - UCSDKLogLevel_DEBUG: DEBUG级别
 */
typedef NS_ENUM(NSUInteger,UCSDKLogLevel)
{
    UCSDKLogLevel_FATAL,
    UCSDKLogLevel_ERROR,
    UCSDKLogLevel_WARN,
    UCSDKLogLevel_INFO,
    UCSDKLogLevel_DEBUG
};



/**
 @brief SDK公共方法中的错误回调
 
 @param ucError 通过检测该字段来获取具体错误信息。'ucError'为空则表示成功；反之表示失败。
 */
typedef void(^UCNetErrorHandler)(UCError * _Nullable ucError);


#endif /* UCNetSDKDef_h */
