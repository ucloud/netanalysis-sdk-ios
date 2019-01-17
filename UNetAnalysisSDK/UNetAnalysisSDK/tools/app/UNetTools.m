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

+ (NSString *)validOptReportField:(NSString *)optField
{
    if (![self un_isEmpty:optField]) {
        if (optField.length > 100 || [optField containsString:@","]
            || [optField containsString:@"，"] || [optField containsString:@"="]) {
            return @"the opt report field is illegal,the maximum length is 100 and cannot contain half-width commas and equal signs";
        }
    }
    return nil;
}

+ (BOOL)validAppkey:(NSString *)appkey
{
    BOOL result = NO;
    NSString *regex = @"^[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    result = [pred evaluateWithObject:appkey];
    return result;
}

+ (BOOL)validRSAPublicKey:(NSString *)publicKey
{
    BOOL result = NO;
    NSRange spos = [publicKey rangeOfString:@"-----BEGIN PUBLIC KEY-----"];
    NSRange epos = [publicKey rangeOfString:@"-----END PUBLIC KEY-----"];
    if(spos.location != NSNotFound && epos.location != NSNotFound){
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e-s);
        publicKey = [publicKey substringWithRange:range];
    }
    publicKey = [publicKey stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    publicKey = [publicKey stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    publicKey = [publicKey stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    publicKey = [publicKey stringByReplacingOccurrencesOfString:@" "  withString:@""];
    if (publicKey.length == 216)
        result = YES;
    return result;
}

+ (BOOL)validIPAddress:(NSString *)ip
{
    BOOL result = NO;
    NSString *regex = @"((?:(?:25[0-5]|2[0-4]\\d|[01]?\\d?\\d)\\.){3}(?:25[0-5]|2[0-4]\\d|[01]?\\d?\\d))";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    result = [pred evaluateWithObject:ip];
    return result;
}

@end
