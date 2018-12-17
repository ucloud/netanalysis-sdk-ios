//
//  UCNetInfoReporter.h
//  UCNetDiagnosisDemo
//
//  Created by ethan on 13/08/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPingModel.h"
#import "UTracertModel.h"
#import "UIpInfoModel.h"
#import "UNetIpListBean.h"

typedef  void(^UNetGetDevicePublicIpInfoHandler) (UIpInfoModel *_Nullable ipInfoModel);
typedef  void(^UNetGetUHostListHandler)(UNetIpListBean *_Nullable ipListBean);

@interface UCNetInfoReporter : NSObject

+ (instancetype)shareInstance;
- (void)uGetDevicePublicIpInfoWithCompletionHandle:(UNetGetDevicePublicIpInfoHandler)handler;
- (UIpInfoModel *)ipInfoModel;

- (void)uGetUHostListWithCompletionHandler:(UNetGetUHostListHandler)handler;

- (void)uReportPingResultWithUReportPingModel:(UReportPingModel *)uReportPingModel;
- (void)uReportTracertResultWithUReportTracertModel:(UReportTracertModel *)uReportTracertModel;

@end
