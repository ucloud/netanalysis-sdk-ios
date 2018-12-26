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
#import "UCServerResponseModel.h"


typedef void (^UNetOperationGetInfoHandler)(id _Nullable obj);
typedef  void(^UNetGetDevicePublicIpInfoHandler) (UIpInfoModel *_Nullable ipInfoModel);
typedef  void(^UNetGetUHostListHandler)(UNetIpListBean *_Nullable ipListBean);

@interface UCNetInfoReporter : NSObject

+ (instancetype _Nonnull )shareInstance;
- (void)setAppKey:(NSString * _Nonnull)appKey publickToken:(NSString * _Nonnull)publicToken;
- (void)uGetDevicePublicIpInfoWithCompletionHandle:(UNetGetDevicePublicIpInfoHandler _Nonnull)handler;
- (UIpInfoModel * _Nonnull)ipInfoModel;

- (void)uGetUHostListWithCompletionHandler:(UNetGetUHostListHandler _Nonnull)handler;

- (void)uReportPingResultWithUReportPingModel:(UReportPingModel * _Nonnull)uReportPingModel;
- (void)uReportTracertResultWithUReportTracertModel:(UReportTracertModel * _Nonnull)uReportTracertModel;

@end
