//
//  URouteReplyModel.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/9/7.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URouteReplyModel : NSObject
@property (nonatomic,copy) NSString *route_ip;
@property (nonatomic,assign) float   avgDelay;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)uRouteReplayModelWithDict:(NSDictionary *)dict;
- (NSDictionary *)objConvertToDict;
@end
