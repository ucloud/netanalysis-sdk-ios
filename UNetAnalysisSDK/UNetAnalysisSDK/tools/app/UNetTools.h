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
@end

NS_ASSUME_NONNULL_END
