//
//  IpInfoModel.h
//  UCNetDiagnosisDemo
//
//  Created by ethan on 13/08/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIpInfoModel : NSObject
@property (nonatomic,copy) NSString *ip;
@property (nonatomic,copy) NSString *city;
@property (nonatomic,copy) NSString *region;
@property (nonatomic,copy) NSString *country;
@property (nonatomic,copy) NSString *location;
@property (nonatomic,copy) NSString *org;

+ (instancetype)uIpInfoModelWithDict:(NSDictionary *)dict;
- (NSDictionary *)objConvertToDict;
@end
