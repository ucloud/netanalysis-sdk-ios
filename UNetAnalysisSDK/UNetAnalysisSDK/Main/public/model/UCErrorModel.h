//
//  UCErrorModel.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/12/17.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum UCErrorType
{
    UCErrorType_Sys = 0,    // 系统错误
    UCErrorType_Server      // 服务器返回错误
}UCErrorType;

@interface UCError : NSObject

/**
 *  错误类型，分为系统错误和服务器错误，如果是服务器错误服务器会返回错误信息
 */
@property (nonatomic,readonly)  UCErrorType type;

/**
 *  系统错误信息
 */
@property (nonatomic,readonly)  NSError     *error;

/**
 * 构造错误(参数错误)
 * @param desc 错误信息
 @return 错误实例
 */
+ (instancetype)sysErrorWithInvalidArgument:(NSString *)desc;

/**
 @brief 构造错误(容器中的元素非法)
 
 @param desc 错误描述
 @return 错误实例
 */
+ (instancetype)sysErrorWithInvalidElements:(NSString *)desc;

/**
 构造错误
 
 @param error 系统错误实例
 @return 错误实例
 */
+ (instancetype)sysErrorWithError:(NSError *)error;


@end

NS_ASSUME_NONNULL_END
