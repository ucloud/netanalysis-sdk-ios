//
//  UCNetworkService.m
//  UCNetDiagnosisDemo
//
//  Created by ethan on 13/08/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UCNetworkService.h"
#import "UNetAnalysisConst.h"
#include "log4cplus.h"

@interface UCNetworkService()

@end


@implementation UCNetworkService

+ (void)uHttpGetRequestWithUrl:(NSString *)urlstr functionModule:(NSString *)module  timeout:(NSTimeInterval)timeValue completionHandler:(UNetHttpResponseHandler)handler
{
    if (urlstr == NULL || urlstr.length == 0) {
        log4cplus_warn("UNetSDK", "%s module , request url is null..\n",[module UTF8String]);
        return;
    }
    
    log4cplus_debug("UNetSDK", "%s module , request url: %s",[module UTF8String],[urlstr UTF8String]);
    NSURL *url = [NSURL URLWithString:urlstr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionTask *sessionTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpUrlResponse = (NSHTTPURLResponse *)response;
        if (data == nil || error) {
            log4cplus_warn("UNetSDK", "%s module,  http request error , response code :%ld",[module UTF8String],(long)httpUrlResponse.statusCode);
        }else{
            handler(data,error);
        }
        
    } ];
    [sessionTask resume];
}

+ (void)uHttpPostRequestWithUrl:(NSString *)urlstr param:(NSString *)paramStr paramType:(UNetHTTPRequestParamType)paramType functionModule:(NSString *)module timeout:(NSTimeInterval)timeValue completionHandler:(UNetHttpResponseHandler)handler
{
    if (urlstr == NULL || urlstr.length == 0) {
        log4cplus_warn("UNetSDK", "%s module , request url is null..\n",[module UTF8String]);
        return;
    }
    log4cplus_debug("UNetSDK", "%s module , request url: %s",[module UTF8String],[urlstr UTF8String]);
    
    NSURL *url = [NSURL URLWithString:urlstr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    request.timeoutInterval = timeValue;
    if (paramType == UNetHTTPRequestParamType_JSON) {
        [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    }
    request.HTTPBody = [paramStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpUrlResponse = (NSHTTPURLResponse *)response;
        if (data == nil || error) {
            log4cplus_warn("UNetSDK", "%s module,  http request error , response code :%ld",[module UTF8String],(long)httpUrlResponse.statusCode);
        }else{
            handler(data,error);
        }
    }];
    
    [dataTask resume];
}


@end
