//
//  UCDeviceInfo.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/9/19.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCDeviceInfo : NSObject
/* about device info */
@property (nonatomic,readonly) NSString *osVersion;
@property (nonatomic,readonly) NSString *screenResolution;
@property (nonatomic,readonly) NSString *deviceModelName;
@end
