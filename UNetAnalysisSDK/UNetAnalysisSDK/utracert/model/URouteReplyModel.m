//
//  URouteReplyModel.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/9/7.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "URouteReplyModel.h"

@implementation URouteReplyModel

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super  init]) {
        self.route_ip = dict[@"route_ip"];
        self.avgDelay = [dict[@"avgDelay"] floatValue];
    }
    return self;
}

+ (instancetype)uRouteReplayModelWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (NSDictionary *)objConvertToDict
{
    NSDictionary *dict  = NULL;
    @try {
        dict  = @{@"route_ip":self.route_ip,@"delay":@((int)self.avgDelay)};
    } @catch (NSException *exception) {
        NSLog(@"%s,%@",__func__,exception.description);
    }
    return dict;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"route_ip:%@ , avgDelay:%@",self.route_ip,[NSString stringWithFormat:@"%.3fms",self.avgDelay]];
}
@end
