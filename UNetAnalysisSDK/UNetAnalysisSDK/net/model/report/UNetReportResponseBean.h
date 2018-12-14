//
//  UNetReportResponseBean.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/10/18.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UNetMetaBean.h"

@interface UNetReportResponseDataBean: NSObject
@property (nonatomic,copy) NSString *message;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)reportResponseDataWithDict:(NSDictionary *)dict;
@end

@interface UNetReportResponseBean : NSObject
@property (nonatomic,strong) UNetMetaBean *meta;
@property (nonatomic,strong) UNetReportResponseDataBean *data;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)reportResponseWithDict:(NSDictionary *)dict;
@end
