//
//  UNetAppInfo.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/9/10.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UNetAppInfo : NSObject
+ (NSString *)uGetAppBundleId;
+ (NSString *)uIosVersion;
@end
