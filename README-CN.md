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
* 可关闭自动探测，关闭后你只有自己调用检测的方法才能触发网路检测

### 其它辅助功能

* 设置日志级别
* 查询SDK版本号

其主要操作类是`UMQAClient.h`。


### 代码示例

#### 注册SDK

假设此时你已经在`UCloud控制台`注册了你的应用并开通了`UCloud网络探测`服务，那么你就会得到一对`AppKey`和`AppSecret`，注册`SDK`时需要用到这些参数。 

我们希望你尽可能的提前注册`SDK`,我们推荐但不局限于在应用刚启动的时候去注册。你可以在`AppDelegate`中的`- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions`方法内注册。 

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UMQAClient shareInstance] uNetSettingSDKLogLevel:UCSDKLogLevel_DEBUG];  // setting log level
    
    /*** 设置自定义上报字段(可选配置) ***/
    NSDictionary *userDefins = @{@"key1":@"value1",@"key2":@"value2"}; // 用户自定义字段，是一个字典格式，其长度有限制(下面有详细说明)
     [[UMQAClient shareInstance] uNetSettingUserDefineFields:userDefins handler:^(UCError * _Nullable ucError) {
        if (!ucError) {
            NSLog(@"设置自定义上报字段成功....");
        }
    }];
    
      // Appkey and public token can be obtained from the ucloud console, or contact our technical support
    NSString *appKey = @""; //your AppKey
    NSString *appToken = @""; // your publick token
     [[UMQAClient shareInstance] uNetRegistSdkWithAppKey:appKey appSecret:appToken completeHandler:^(UCError * _Nullable ucError) {
        if (ucError) {
            NSLog(@"regist UNetAnalysisSDK error , error info: %@",ucError.error.description);
        }else{
            NSLog(@"regist UNetAnalysisSDK success...");
            NSArray *customerIps = @[@"220.181.112.244",@"221.230.143.58"]; // Fill in your application's main service address here (only support ip address, which is used for manual network diagnostics)
            [[UMQAClient shareInstance] uNetSettingCustomerIpList:customerIps];
        }
    }];
    
    return YES;
}
```

#### 设置用户自定义字段 

##### 方法说明 

'UMQAClient.h'中的方法定义： 

```
/**
 @brief 设置自定义上报字段。
 @discussion 如果你要上报的字段在注册SDK之前能获取到，则需要在注册SDK之前调用此方法；如果你要上报的字段在注册SDK的时候还没有获取到，则可以在获取到该字段时调用此方法设置，但是前期SDK诊断的数据上报时可能不含有你设置的自定义字段。
 @param fields 用户自定义上报字段。如果没有直接传nil。该字段有长度限制，最后转化为字符串的总长度不能超过1024
 @param handler `UCNetErrorHandler` 类型的 `block`，通过这个 `block` 来告知用户是设置是否成功.  如果成功，则 `error` 为空。
 */
- (void)uNetSettingUserDefineFields:(NSDictionary<NSString*,NSString*> * _Nullable)fields
                            handler:(UCNetErrorHandler _Nonnull)handler;
```

设置用户自定义字段的方法是一个可选方法。当你需要往上报数据中添加自己想上报的字段时，可以调用该方法。 

特别注意： 如果你要上报的字段在注册SDK之前能获取到，则需要在注册SDK之前调用设置自定义字段方法；如果你要上报的字段在注册SDK的时候还没有获取到，则可以在获取到该字段时调用设置自定义字段方法，但是前期SDK诊断的数据上报时可能不含有你设置的自定义字段。

##### 用户自定义字段规则 

用户自定义字段需要满足以下规则。 

* NSDictionary的键值对为NSString-NSString的形式
* 整个自定义字段会转化为JSON字符串(如下所示)，转换后的字符串长度不能超过1024Byte,如果长度等限制不满足将会抛出异常。

  ```
  [
  	{
  		"key":"",
  		"val":""
  	},
  	{
  		"key":"",
  		"val":""
  	},
  	....
  ]
  ```

#### 关闭自动网络检测自己触发网络检测

'UMQAClient.h'中的方法定义：

```
/**
 @brief 关闭自动检测功能
 
 @discussion 如果你不想使用SDK的自动触发检测逻辑，那么你可以选择将其关闭。关闭自动触发检测逻辑后，需要你手动调用执行诊断功能才会触发网络检测。
 */
- (void)uNetCloseAutoDetectNet;
```

如果你不想使用SDK的自动触发检测逻辑，你可以在注册SDK之前选择将其关闭。关闭之后只能手动调用触发网络检测的方法。 

手动触发网络检测： 

```
/**
 @brief 触发网络监测
 
 @discussion sdk会检测手机网络变化并触发网络检测。你也可以调用此方法来手动触发网络检测。
 */
- (void)uNetStartDetect;
```


#### 停止网络数据收集

'UMQAClient.h'中的方法定义： 

```
/**
 @brief 停止网络数据收集
 @discussion 当app进入非活跃状态时，可以通过调用此方法来停止数据收集。用这种方法可以解决部分 `signal pipe` 引起的APP闪退
 */
- (void)uNetStopDataCollectionWhenAppWillResignActive;
```


当app即将从活动状态转为非活动状态时,停止网络数据收集。即在`AppDelegate`中的`- (void)applicationWillResignActive:(UIApplication *)application`方法中执行该操作。

```
- (void)applicationWillResignActive:(UIApplication *)application {
    [[UMQAClient shareInstance] uNetStopDataCollectionWhenAppWillResignActive];
}
```

## 常见问题

* `iOS 9+`强制使用`HTTPS`,使用`XCode`创建的项目默认不支持`HTTP`，所以需要在`project build info` 添加`NSAppTransportSecurity`,在`NSAppTransportSecurity`下添加`NSAllowsArbitraryLoads`值设为`YES`,如下图。 
	![](https://ws2.sinaimg.cn/large/006tNc79gy1fzitnl2r6ej30ih0c5tb0.jpg)

## 联系我们

* [UCloud官方网站](https://www.ucloud.cn/)
*  如有任何问题，欢迎提交[issue](https://github.com/ucloud/netanalysis-sdk-ios/issues)或联系我们的技术支持，我们会第一时间解决问题。


