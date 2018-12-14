//
//  UCTracertUCHostsRecord.h
//  UCloudNetAnalysisSDK
//
//  Created by ethan on 15/08/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UNetAnalysisConst.h"

@interface UCTracertUCHostsRecord : NSObject<NSCoding>
@property (nonatomic,assign) int currentDays;        // days form 1970.1.1
@property (nonatomic,copy) NSString *currentTracertIp;   // default is 127.0.0.1
@property (nonatomic,assign) Enum_Tracert_UC_Hosts_State tracertUCHostsState;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)ucTracertUCHostsRecordWithDict:(NSDictionary *)dict;
@end
