//
//  UCManualNetDiagResult.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/9/19.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCAppNetInfo.h"
#import "UCAppInfo.h"
#import "UCDeviceInfo.h"
#import "UCIpPingResult.h"


@interface UCManualNetDiagResult : NSObject

@property (nonatomic,strong) UCAppInfo       *appInfo;            // The app info. eg: version,name,bundle id,etc..
@property (nonatomic,strong) UCDeviceInfo    *deviceInfo;         // The device info. eg: device module,os version,etc..
@property (nonatomic,strong) UCAppNetInfo    *appNetInfo;         // The app net info. eg: net type,public ip,etc..
@property (nonatomic,strong) NSMutableArray<UCIpPingResult *> *pingInfo;

@end
