//
//  UCAppInfo.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/9/19.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCAppInfo : NSObject
@property (nonatomic,readonly) NSString *appName;
@property (nonatomic,readonly) NSString *appBundleId;
@property (nonatomic,readonly) NSString *appVersion;
@end
