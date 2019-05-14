# UCloud NetAnalysis SDK for iOS

## [README of English](https://github.com/ucloud/netanalysis-sdk-ios/blob/master/README.md)

## 简介

![](https://camo.githubusercontent.com/86885d3ee622f43456c8b890b56c3f05d6ec2c5e/687474703a2f2f636c692d75636c6f75642d6c6f676f2e73672e7566696c656f732e636f6d2f75636c6f75642e706e67)

本文档旨在帮助用户集成使用`UCloud NetAnalysis SDK for iOS`，下面我们从以下几个方面做介绍： 

* 目录结构
* 环境要求
* 安装使用
* 功能说明
* 常见问题
* 联系我们

## 目录结构

该仓库主要包括`SDK`的源码以及示例项目，示例项目包含`Objective-C`和`Swift`两个版本。 

目录  | 说明
------------- | -------------
`SDK/UNetAnalysisSDK` | SDK源码
`SDK/documents/devDocuments.zip` | SDK开发文档(解压后可用浏览器查看)
`SDK/Demo/oc/UNetAnalysisDemo_01` | Demo程序(`Objective-c`版本)
`SDK/Demo/swift/UNetAnalysisSwiftDemo_01` | Demo程序(`Swift`版本)

## 环境要求

* iOS系统版本>=9.0
* 必须是`UCloud`的用户，并开通了`UCloud网络探测`服务


### Xcode Version

`UNetAnalysisSDK`的 `Deployment target`是9.0，所以你可以使用XCode7.0及其以上的版本并且首先要设置`Enable Bitcode`为`NO`: 

`Project`->`Build Setting`->`Build Operation`->`Enable Bitcode`

![](https://ws2.sinaimg.cn/large/006tNbRwgy1fwj45s1t65j30n207s0ts.jpg)

## 安装使用

### cocoapods方式

在你项目的`Podfile`中加入以下依赖：

```
pod 'UNetAnalysisSDK'
```

### 使用方法

在工程中引入头文件：

```
#import <UNetAnalysisSDK/UNetAnalysisSDK.h>
```

接着，需要在工程的`Build Setting`->`other link flags`中加入 `-lc++`,`-ObjC`,`$(inherited)` 。 如下图所示： 

![](https://ws3.sinaimg.cn/large/006tNc79gy1fzipcaj0ecj30u80ee0ud.jpg)


## 功能说明

### 网络探测功能

* 支持设置`APP`主服务的`IP`(一个或多个)，用于做网络探测
* 自动网络探测并上报(`APP`打开时和网络切换(`WWAN`<=>`WIFI`)时会触发)

### 其它辅助功能

* 设置日志级别
* 查询SDK版本号

其主要操作类是`UCNetAnalysisManager.h`。


### 代码示例

#### 注册SDK

假设此时你已经在`UCloud控制台`注册了你的应用并开通了`UCloud网络探测`服务，那么你就会得到一对`AppKey`和`PublicToken(公钥)`，注册`SDK`时需要用到这些参数。 

我们希望你尽可能的提前注册`SDK`,我们推荐但不局限于在应用刚启动的时候去注册。你可以在`AppDelegate`中的`- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions`方法内注册。 

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UCNetAnalysisManager shareInstance] uNetSettingSDKLogLevel:UCSDKLogLevel_DEBUG];  // setting log level
    
    // Appkey and public token can be obtained from the ucloud console, or contact our technical support
    NSString *appKey = @""; //your AppKey
    NSString *appToken = @""; // your publick token
    [[UCNetAnalysisManager shareInstance] uNetRegistSdkWithAppKey:appKey publicToken:appToken completeHandler:^(UCError * _Nullable ucError) {
        if (ucError) {
            NSLog(@"regist UNetAnalysisSDK error , error info: %@",ucError.error.description);
        }else{
        	NSLog(@"regist UNetAnalysisSDK success...");
	        NSArray *customerIps = @[@"220.181.112.244",@"221.230.143.58"]; // Fill in your application's main service address here (only support ip address, which is used for manual network diagnostics)
	        [[UCNetAnalysisManager shareInstance] uNetSettingCustomerIpList:customerIps];
        }
    }];
    
    return YES;
}
```

#### 停止网络数据收集

当app即将从活动状态转为非活动状态时,停止网络数据收集。即在`AppDelegate`中的`- (void)applicationWillResignActive:(UIApplication *)application`方法中执行该操作。

```
- (void)applicationWillResignActive:(UIApplication *)application {
    [[UCNetAnalysisManager shareInstance] uNetStopDataCollectionWhenAppWillResignActive];
}
```

## 常见问题

* `iOS 9+`强制使用`HTTPS`,使用`XCode`创建的项目默认不支持`HTTP`，所以需要在`project build info` 添加`NSAppTransportSecurity`,在`NSAppTransportSecurity`下添加`NSAllowsArbitraryLoads`值设为`YES`,如下图。 
	![](https://ws2.sinaimg.cn/large/006tNc79gy1fzitnl2r6ej30ih0c5tb0.jpg)

## 联系我们

* [UCloud官方网站](https://www.ucloud.cn/)
*  如有任何问题，欢迎提交[issue](https://github.com/ucloud/netanalysis-sdk-ios/issues)或联系我们的技术支持，我们会第一时间解决问题。


