//
//  UNetMetaBean.h
//  UNetAnalysisSDK
//
//  Created by ethan on 2018/10/18.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UNetMetaBean : NSObject
@property (nonatomic,assign) NSInteger code;
@property (nonatomic,copy) NSString *error;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)metaBeanWithDict:(NSDictionary *)dict;
@end
