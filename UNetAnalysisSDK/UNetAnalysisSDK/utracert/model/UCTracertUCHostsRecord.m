//
//  UCTracertUCHostsRecord.m
//  UCloudNetAnalysisSDK
//
//  Created by ethan on 15/08/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UCTracertUCHostsRecord.h"

@implementation UCTracertUCHostsRecord

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        _currentDays = [dict[@"currentDays"] intValue];
        _currentTracertIp = dict[@"currentTracertIp"];
        _tracertUCHostsState = (Enum_Tracert_UC_Hosts_State)[dict[@"tracertUCHostsState"] intValue];
    }
    return self;
}

+ (instancetype)ucTracertUCHostsRecordWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[NSNumber numberWithInt:self.currentDays] forKey:@"currentDays"];
    [aCoder encodeObject:self.currentTracertIp forKey:@"currentTracertIp"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.tracertUCHostsState] forKey:@"tracertUCHostsState"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.currentDays = [[aDecoder decodeObjectForKey:@"currentDays"] intValue];
        self.currentTracertIp = [aDecoder decodeObjectForKey:@"currentTracertIp"];
        self.tracertUCHostsState = (Enum_Tracert_UC_Hosts_State)[[aDecoder decodeObjectForKey:@"tracertUCHostsState"] intValue];
    }
    return self;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"currentDays:%d , currentTracertIp:%@ , tracertUCHostsState:%d",self.currentDays,self.currentTracertIp,(Enum_Tracert_UC_Hosts_State)self.tracertUCHostsState];
}

@end
