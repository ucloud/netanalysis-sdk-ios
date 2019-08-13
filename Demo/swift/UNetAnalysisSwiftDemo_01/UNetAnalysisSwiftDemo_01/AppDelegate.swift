//
//  AppDelegate.swift
//  UNetAnalysisSwiftDemo_01
//
//  Created by ethan on 2018/10/24.
//  Copyright © 2018 ucloud. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UMQAClient.shareInstance()?.uNetSettingSDKLogLevel(UCSDKLogLevel.DEBUG) // 设置日志级别，推荐开发的时候使用DEBUG级别，发布的时候使用ERROR级别
//        UMQAClient.shareInstance()?.uNetCloseAutoDetectNet()  // 可以选择关闭自动触发网络检测逻辑，自己手动触发网络检测
        
        
        /***
    如果你要上报的字段在注册SDK之前能获取到，则需要在注册SDK之前调用设置自定义字段方法；如果你要上报的字段在注册SDK的时候还没有获取到，则可以在获取到该字段时调用设置自定义字段方法，但是前期SDK诊断的数据上报时可能不含有你设置的自定义字段。详细介绍请查看https://github.com/ucloud/netanalysis-sdk-ios/blob/master/README-CN.md
         ***/
        let userDefins:Dictionary<String,String> = ["key1":"value1","key2":"value2"] // 用户自定义字段，是一个字典格式，其长度有限制
        UMQAClient.shareInstance()?.uNetSettingUserDefineFields(userDefins, handler: { (ucError:UCError?) in
            if(ucError == nil){
                print("设置自定义上报字段成功")
            }
        })
        
        
        // appkey和rsa公钥需要从ucloud控制台获取，或者联系技术支持获取
        let appKey = "" //你的appKey
        let appToken = "" // 你的App公钥
        
        UMQAClient.shareInstance()?.uNetRegistSdk(withAppKey: appKey, appSecret: appToken, completeHandler: { (ucError:UCError?) in
            if (ucError != nil){
                let error  = ucError!.error as NSError
                print("regist UNetAnalysisSDK error , error info: %s",error.description)
            }else{
                print("Regist UNetAnalysisSDK success..")
                let customerIpList = ["220.181.112.244","221.230.143.58"]  // 此处填入你要手动诊断的网络地址
                UMQAClient.shareInstance()?.uNetSettingCustomerIpList(customerIpList)
            }
        })
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        UMQAClient.shareInstance()?.uNetStopDataCollectionWhenAppWillResignActive()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        /*** 可选调用，为了适配ios12，具体信息请查看方法说明 ***/
        UMQAClient.shareInstance()?.uNetAppDidEnterBackground()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

