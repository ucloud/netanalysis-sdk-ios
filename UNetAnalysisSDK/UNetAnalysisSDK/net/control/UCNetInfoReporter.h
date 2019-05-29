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
#import "UCModel.h"
#import "UCServerResponseModel.h"


typedef void (^UNetOperationGetInfoHandler)(id _Nullable obj,UCError * _Nullable ucError);
typedef  void(^UNetGetDevicePublicIpInfoHandler) (UIpInfoModel *_Nullable ipInfoModel,UCError *_Nullable ucError);
typedef  void(^UNetGetUHostListHandler)(UNetIpListBean *_Nullable ipListBean,UCError * _Nullable ucError);

@interface UCNetInfoReporter : NSObject

+ (instancetype _Nonnull )shareInstance;

- (void)setAppKey:(NSString * _Nonnull)appKey
     publickToken:(NSString * _Nonnull)publicToken
userDefinedFields:(NSDictionary * _Nullable)fields;

- (void)uGetDevicePublicIpInfoWithCompletionHandle:(UNetGetDevicePublicIpInfoHandler _Nonnull)handler;
- (UIpInfoModel * _Nonnull)ipInfoModel;

- (void)uGetUHostListWithIpInfoModel:(UIpInfoModel * _Nonnull)ipInfoModel completionHandler:(UNetGetUHostListHandler _Nonnull)handler;

- (void)uReportPingResultWithUReportPingModel:(UReportPingModel * _Nonnull)uReportPingModel destIpType:(int)type;
- (void)uReportTracertResultWithUReportTracertModel:(UReportTracertModel *)uReportTracertModel destIpType:(int)type;

@end
