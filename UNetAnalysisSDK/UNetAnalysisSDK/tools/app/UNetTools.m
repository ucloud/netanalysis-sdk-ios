//
//  UNetTools.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2019/1/3.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import "UNetTools.h"
#import "UCModel.h"

#define KUUID  @"ios_uuid"

@implementation UNetTools
+ (BOOL)un_isEmpty:(NSString *)str
{
     return [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""];
}

+ (NSString *)userDefinedFieldsConvertDictToJson:(NSDictionary *)fields
{
    NSMutableDictionary *mutaDict = [NSMutableDictionary dictionaryWithDictionary:fields];
    for (NSString *key in mutaDict.allKeys) {
        if ([self un_isEmpty:key]) {
            [mutaDict removeObjectForKey:key];
        }else if([self un_isEmpty:[mutaDict objectForKey:key]]){
            [mutaDict setObject:@"" forKey:key];
        }
    }
    
    NSMutableArray *resArray = [NSMutableArray array];
    NSArray *keyArray = [mutaDict allKeys];
    for (int i = 0; i < keyArray.count; i++) {
        NSString *key = keyArray[i];
        NSDictionary *dict = @{@"key":key,@"val":[mutaDict objectForKey:key]};
        [resArray addObject:dict];
    }
    NSError *error;
    NSString *jsonValue = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:resArray options:0 error:&error] encoding:NSUTF8StringEncoding];
    if (error != nil) {
        NSLog(@"user defined fields convert to json str error %@",error);
        return nil;
    }
    return jsonValue;
}

+ (NSString *)validOptReportField:(NSDictionary *)fields
{
    for (id key in fields.allKeys) {
        if (![key isKindOfClass:[NSString class]]) {
            return @"the key for user defined fields dict is not NSString type";
        }
    }
    
    for (id value in fields.allValues) {
        if (![value isKindOfClass:[NSString class]]) {
            return @"the value for user defined fileds dict is not NSString type";
        }
    }
    
    @try {
        NSString *json_str = [[self class] userDefinedFieldsConvertDictToJson:fields];
        if (json_str.length > 1024) {
            return @"the user defined fields is illegal, the maximum length is 1024...";
        }
    } @catch (NSException *exception) {
        return exception.description;
    }
    
  
//    if (![self un_isEmpty:optField]) {
//        if (optField.length > 100 || [optField containsString:@","]
//            || [optField containsString:@"，"] || [optField containsString:@"="]) {
//            return @"the opt report field is illegal,the maximum length is 100 and cannot contain half-width commas and equal signs";
//        }
//    }
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

+ (NSString *)formartTimeZone:(NSString *)gmtTime
{
    NSString *tz = [gmtTime substringFromIndex:3];
    int min = 0;
    int hour = 0;
    if ([tz containsString:@":"]) {
        NSArray *tz_arr = [tz componentsSeparatedByString:@":"];
        hour = [[tz_arr objectAtIndex:0] intValue];
        min  = [[tz_arr objectAtIndex:1] intValue];
    }else{
        hour = [tz intValue];
    }
    if (hour >=0) {
        return [NSString stringWithFormat:@"+%02d%02d",hour,min];
    }
    return [NSString stringWithFormat:@"%03d%02d",hour,min];
}

+ (NSString *)uuidStr
{
    NSString *strUUID = [[NSUserDefaults standardUserDefaults] objectForKey:KUUID];
    if (strUUID) {
        return strUUID;
    }
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef strRef = CFUUIDCreateString(kCFAllocatorDefault , uuidRef);
    NSString *uuidString = (__bridge NSString *)strRef;
    [[NSUserDefaults standardUserDefaults] setObject:uuidString forKey:KUUID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    CFRelease(strRef);
    CFRelease(uuidRef);
    return uuidString;
}

@end
