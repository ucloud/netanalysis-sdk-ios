//
//  UReportTracertModel.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/9/7.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UReportTracertModel : NSObject
@property (nonatomic,copy) NSString *src_ip;
@property (nonatomic,copy) NSString *dst_ip;
@property (nonatomic,strong) NSMutableArray *routeReplyArray;


- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)uReportTracertModel:(NSDictionary *)dict;
- (NSDictionary *)objConvertToDict;
@end
