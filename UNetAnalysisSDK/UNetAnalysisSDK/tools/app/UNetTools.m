//
//  UNetTools.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2019/1/3.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import "UNetTools.h"

@implementation UNetTools
+ (BOOL)un_isEmpty:(NSString *)str
{
     return [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""];
}
@end
