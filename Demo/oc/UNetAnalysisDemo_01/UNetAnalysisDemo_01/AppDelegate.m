//
//  AppDelegate.m
//  UNetAnalysisDemo_01
//
//  Created by ethan on 2018/10/24.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "AppDelegate.h"
#import <UNetAnalysisSDK/UNetAnalysisSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UMQAClient shareInstance] uNetSettingSDKLogLevel:UCSDKLogLevel_DEBUG];  // setting log level
//    [[UMQAClient shareInstance] uNetCloseAutoDetectNet];    // 可以选择关闭自动触发网络检测逻辑，自己手动触发网络检测
    
    
    /***

    设置自定义上报字段： 如果你要上报的字段在注册SDK之前能获取到，则需要在注册SDK之前调用设置自定义字段方法；如果你要上报的字段在注册SDK的时候还没有获取到，则可以在获取到该字段时调用设置自定义字段方法，但是前期SDK诊断的数据上报时可能不含有你设置的自定义字段。详细介绍请查看https://github.com/ucloud/netanalysis-sdk-ios/blob/master/README-CN.md
     ***/
    NSDictionary *userDefins = @{@"key1":@"value1",@"key2":@"value2"}; // 用户自定义字段，是一个字典格式，其长度有限制
    [[UMQAClient shareInstance] uNetSettingUserDefineFields:userDefins handler:^(UCError * _Nullable ucError) {
        if (!ucError) {
            NSLog(@"设置自定义上报字段成功....");
        }
    }];
    
    // appkey和rsa公钥需要从ucloud控制台获取，或者联系技术支持获取
    NSString *appKey = @""; //你的appKey
    NSString *appToken = @""; // 你的App公钥
    
    [[UMQAClient shareInstance] uNetRegistSdkWithAppKey:appKey appSecret:appToken completeHandler:^(UCError * _Nullable ucError) {
        if (ucError) {
            NSLog(@"regist UNetAnalysisSDK error , error info: %@",ucError.error.description);
        }else{
            NSLog(@"regist UNetAnalysisSDK success...");
            NSArray *customerIps = @[@"220.181.112.244",@"221.230.143.58"]; // 此处填入你要手动诊断的网络地址
            [[UMQAClient shareInstance] uNetSettingCustomerIpList:customerIps];
        }
    }];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game. 
    [[UMQAClient shareInstance] uNetStopDataCollectionWhenAppWillResignActive];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    /*** 可选调用，为了适配ios12，具体信息请查看方法说明 ***/
    [[UMQAClient shareInstance] uNetAppDidEnterBackground];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
