//
//  IpInfoModel.m
//  UCNetDiagnosisDemo
//
//  Created by ethan on 13/08/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UIpInfoModel.h"

@implementation UIpInfoModel

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.ip =        dict[@"ip"];
        self.city =      dict[@"city"];
        self.region =    dict[@"region"];
        self.country =   dict[@"country"];
        self.location =  dict[@"loc"];
        self.org      =  dict[@"org"];
    }
    return self;
}

+ (instancetype)uIpInfoModelWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (NSDictionary *)objConvertToDict
{
    return @{@"ip":self.ip,@"city":self.city,@"region":self.region,@"country":self.country,@"location":self.location,@"org":self.org};
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"ip:%@ , city:%@ , region:%@ , country:%@ , location:%@ , org:%@",self.ip,self.city,self.region,self.country,self.location,self.org];
}


@end
