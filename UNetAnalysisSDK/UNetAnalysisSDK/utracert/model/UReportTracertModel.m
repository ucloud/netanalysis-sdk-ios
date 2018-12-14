//
//  UReportTracertModel.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/9/7.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UReportTracertModel.h"
#import "URouteReplyModel.h"

@implementation UReportTracertModel

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.src_ip = dict[@"src_ip"];
        self.dst_ip = dict[@"dst_ip"];
        self.routeReplyArray = dict[@"routeReplyArray"];
    }
    return self;
}

+ (instancetype)uReportTracertModel:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (NSDictionary *)objConvertToDict
{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < self.routeReplyArray.count; i++) {
        URouteReplyModel *model = (URouteReplyModel*)self.routeReplyArray[i];
        @try {
            [array addObject:model.objConvertToDict];
        } @catch (NSException *exception) {
            NSLog(@"%s, %@",__func__,exception.description);
        }
        
    }
    
    return @{@"src_ip":self.src_ip,@"dst_ip":self.dst_ip,@"route_info":array};
}

- (NSString *)description
{
    NSMutableString *routeReplay = [NSMutableString string];
    for (int i = 0; i < self.routeReplyArray.count; i++) {
        URouteReplyModel *model = (URouteReplyModel*)self.routeReplyArray[i];
        [routeReplay appendString:model.description];
        [routeReplay appendString:@"\n"];
    }
    return [NSString stringWithFormat:@"src_ip:%@ , dst_ip:%@ , routeReplyArray:\n %@",self.src_ip,self.dst_ip,routeReplay];
}

@end
