//
//  UCModel.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/12/17.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 这是`NSObject`的一个子类。该类用于表示服务端错误
 */
@interface UCServerError : NSObject

/**
 错误码
 */
@property (nonatomic,readonly) NSInteger code;

/**
 错误信息，对应服务端返回的`error`
 */
@property (nonatomic,readonly) NSString *errMsg;

/**
 @brief  构造服务端错误实例(内部使用)

 @param code 错误码
 @param errMsg 错误描述
 @return 服务端错误实例
 */
+ (instancetype)instanceWithCode:(NSInteger)code
                                 errMsg:(NSString *)errMsg;

@end


/**
  @brief 这是一个枚举定义，定义SDK错误类型

 - UCErrorType_Sys: 非服务器错误，包括参数错误，逻辑业务错误等，可通过错误的具体描述获知错误原因
 - UCErrorType_Server: 服务器错误，可通过错误的具体描述获取错误原因
 */
typedef NS_ENUM(NSUInteger,UCErrorType)
{
    UCErrorType_Sys,
    UCErrorType_Server
};

/**
 这是`NSObject`的一个子类。该类用于表示SDK错误信息，它包含系统错误和服务端错误两种类型，可以根据不同的类型来看具体的错误信息
 */
@interface UCError : NSObject

/**
 *  错误类型，请参考`UCErrorType`
 */
@property (nonatomic,readonly)  UCErrorType type;

/**
 *  系统错误信息
 */
@property (nonatomic,readonly)  NSError     *error;

/**
 *  服务器错误
 */
@property (nonatomic,readonly)  UCServerError *serverError;

/**
 @brief 构造错误(参数错误，内部使用)
 
 @param desc 错误信息
 @return 错误实例
 */
+ (instancetype)sysErrorWithInvalidArgument:(NSString *)desc;

/**
 @brief 构造错误(容器中的元素非法，内部使用)
 
 @param desc 错误描述
 @return 错误实例
 */
+ (instancetype)sysErrorWithInvalidElements:(NSString *)desc;

/**
 @brief 构造错误(调用SDK中的方法时，条件不满足。内部使用)
 
 @param desc 错误描述
 @return 错误实例
 */
+ (instancetype)sysErrorWithInvalidCondition:(NSString *)desc;

/**
 @brief 构造错误(内部使用)
 
 @param error 系统错误实例
 @return 错误实例
 */
+ (instancetype)sysErrorWithError:(NSError *)error;


/**
 @ brief 构造错误(内部使用)

 @param serverError 服务端错误实例
 @return `UCError`实例
 */
+ (instancetype)httpErrorWithServerError:(UCServerError *)serverError;


@end


NS_ASSUME_NONNULL_END
