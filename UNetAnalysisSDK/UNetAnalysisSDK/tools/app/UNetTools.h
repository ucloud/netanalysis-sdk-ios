//
//  UNetTools.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2019/1/3.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UNetTools : NSObject

/**
 判断字符串是否为空(内部使用)

 @param str 待拍判断的字符串
 @return YES:是空串； NO:非空串
 */
+ (BOOL)un_isEmpty:(NSString *)str;


/**
 @brief 校验用户可选上报字段(内部使用)

 @param optField 用户要上报的字段
 @return 如果返回nil，则表示上报字段内容合法；如果不为空，则返回内容即是非法信息。
 */
+ (NSString *)validOptReportField:(NSString *)optField;


/**
 @brief 校验appkey(内部使用)

 @param appkey appkey
 @return YES:校验成功； NO:校验失败
 */
+ (BOOL)validAppkey:(NSString *)appkey;


/**
 @brief 校验RSA加密的公钥(内部使用)

 @param publicKey RSA公钥
 @return YES:校验通过； NO:校验失败
 */
+ (BOOL)validRSAPublicKey:(NSString *)publicKey;


/**
 @brief 校验ip地址(内部使用)

 @param ip ip地址
 @return YES:校验通过； NO:校验失败
 */
+ (BOOL)validIPAddress:(NSString *)ip;
@end

NS_ASSUME_NONNULL_END
