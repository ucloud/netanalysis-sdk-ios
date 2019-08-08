# UCloud NetAnalysis SDK for iOS

## [README of Chinese](https://github.com/ucloud/netanalysis-sdk-ios/blob/master/README-CN.md)

## Introduction

![](https://camo.githubusercontent.com/86885d3ee622f43456c8b890b56c3f05d6ec2c5e/687474703a2f2f636c692d75636c6f75642d6c6f676f2e73672e7566696c656f732e636f6d2f75636c6f75642e706e67)

This document is intended to help users integrate with the `UCloud NetAnalysis SDK for iOS`. We will introduce the following aspects: 

* About SDK repository
* Environmental requirements
* Installation
* Function introduction
* F&Q
* Contact us

## About SDK repository

The repository includes the source code of the `SDK` and sample projects. The sample project contains two versions of "Objective-C" and `Swift". 

Directory  | Description
------------- | -------------
`SDK/UNetAnalysisSDK` | SDK source code
`SDK/documents/devDocuments.zip` | SDK development documentation
`SDK/Demo/oc/UNetAnalysisDemo_01` | sample project(`OC`)
`SDK/Demo/swift/UNetAnalysisSwiftDemo_01` | sample project(`Swift`)

## Environmental requirements

* iOS version >= 9.0
* The customer of `UCloud` and opened `UCloud net analysis service`


### Xcode version

The `Deployment target` of `UNetAnalysisSDK` is 9.0, so you can use XCode7.0 and above and first set `Enable Bitcode` to `NO`: 

`Project`->`Build Setting`->`Build Operation`->`Enable Bitcode`

![](https://ws2.sinaimg.cn/large/006tNbRwgy1fwj45s1t65j30n207s0ts.jpg)

## Installation

### Pod dependency

Add the following dependencies to your project's `Podfile`:

```
pod 'UNetAnalysisSDK'
```

### Quick start

Import the SDK header file to the project:

```
#import <UNetAnalysisSDK/UNetAnalysisSDK.h>
```

In addition, you need to add `-lc++`,`-ObjC`,`$(inherited)` to the project's `Build Setting`->`other link flags`. As shown below:

![](https://ws3.sinaimg.cn/large/006tNc79gy1fzipcaj0ecj30u80ee0ud.jpg)


## Function introduction

### Network diagnosis function

* You can set the ip address of the app's server,which is used for network diagnosis
* SDK will auto diagnose the network status and report it(Triggered when opening `APP` and network is switching[`WWAN`<=>`WIFI`])
* Automatic detection can be turned off. After turning off, you can only trigger the network detection by calling the detection method yourself.

### Other functions

* Setting SDK log level
* Get the SDK version

Its main operation class is `UMQAClient.h`.

### Code example

#### Regist SDK

Suppose you have already registered your app in the `UCloud Console` and opened the `UCloud net analysis service`, then you will get a pair of `AppKey` and `PublicToken (public key)`, when registering `SDK` need to use these parameters.

We hope that you register as early as possible `SDK`, we recommend but not limited to register when the application is just started. You can register in the `- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions` method in `AppDelegate`. 

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UMQAClient shareInstance] uNetSettingSDKLogLevel:UCSDKLogLevel_DEBUG];  // setting log level
    
        /*** Set custom report fields (optional configuration) ***/
    NSDictionary *userDefins = @{@"key1":@"value1",@"key2":@"value2"}; // User-defined field, which is a dictionary format with a limited length (detailed below)
     [[UMQAClient shareInstance] uNetSettingUserDefineFields:userDefins handler:^(UCError * _Nullable ucError) {
        if (!ucError) {
            NSLog(@"setting cus fields success....");
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

##### User-defined field

In the method of registering the SDK, the user-defined field is an optional field. If you want to set it, you need to meet the following rules.

* The NSDictionary key-value pair is in the form of NSString-NSString
* The entire custom field will be converted to a JSON string (as shown below). The length of the converted string cannot exceed 1024 Bytes. If the length limit is not met, an exception will be thrown.

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

#### Setting user-defined fileds 

Method definition in 'UMQAClient.h':

```
/**
 @brief Setting user-defined fileds 
 @discussion If the field you want to report can be obtained before registering the SDK, you need to call this method before registering the SDK; if the field you want to report is not obtained when registering the SDK, you can call this when you get the field. Method settings, but the data reported by the previous SDK diagnosis may not contain the custom fields you set.
 @param fields User-defined field. If there is no direct pass nil. This field has a length limit, and the total length converted to a string cannot exceed 1024.
 @param handler Use this `block` to tell the user if the setting was successful. If successful, `error` is empty.
 */
- (void)uNetSettingUserDefineFields:(NSDictionary<NSString*,NSString*> * _Nullable)fields
                            handler:(UCNetErrorHandler _Nonnull)handler;
```

Setting up a user-defined field is an optional method. This method can be called when you need to add the field you want to report to the report data.

Special Note: If the field you want to report can be obtained before registering the SDK, you need to call the Set Custom Field method before registering the SDK. If the field you want to report is not obtained when registering the SDK, you can get it. The custom field method is called when the field is reached, but the data reported by the previous SDK diagnosis may not contain the custom field you set.

##### User-defined field rules

User-defined field need to meet the following rules.

* The NSDictionary key-value pair is in the form of NSString-NSString
* The entire custom field will be converted to a JSON string (as shown below). The length of the converted string cannot exceed 1024 bytes. If the length limit is not met, an exception will be thrown.

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

#### Turn off automatic network detection and trigger network detection 

Method definition in 'UMQAClient.h':

```
/**
  @brief turns off automatic detection
 
  @discussion If you don't want to use the SDK's automatic trigger detection logic, then you can choose to turn it off. After turning off the automatic trigger detection logic, you need to manually call the execution diagnostic function to trigger the network detection.
  */
- (void)uNetCloseAutoDetectNet;
```

If you don't want to use the SDK's automatic trigger detection logic, you can choose to turn it off before registering the SDK. After the shutdown, you can only manually call the method that triggers network detection.

Manually trigger network detection:

```
/**
  @brief triggers network monitoring
 
  @discussion sdk will detect changes in the phone network and trigger network detection. You can also call this method to manually trigger network detection.
  */
- (void)uNetStartDetect;
```

#### Stop network data collection

Method definition in 'UMQAClient.h':

```
/**
  @brief Stop network data collection
  @discussion When the app enters an inactive state, it can be stopped by calling this method. In this way, the APP flashback caused by part of `signal pipe` can be solved.
  */
- (void)uNetStopDataCollectionWhenAppWillResignActive;
```

Stop network data collection when the application is about to move from active to inactive state. This is done in the `- (void)applicationWillResignActive:(UIApplication *)application` method in `AppDelegate`. 

```
- (void)applicationWillResignActive:(UIApplication *)application {
    [[UMQAClient shareInstance] uNetStopDataCollectionWhenAppWillResignActive];

}

```


## F&Q

* The app on `iOS 9+` is forced to use `HTTPS`. Projects created with `XCode` do not support `HTTP` by default, so you need to add `NSAppTransportSecurity` in `project build info` and `NSAllowsArbitraryLoads` in `NSAppTransportSecurity`,The value is set to `YES`, as shown below:
	![](https://ws2.sinaimg.cn/large/006tNc79gy1fzitnl2r6ej30ih0c5tb0.jpg)

## Contact us

* [UCloud official website](https://www.ucloud.cn/)
* If you have any questions, please submit [issue](https://github.com/ucloud/netanalysis-sdk-ios/issues) or contact our technical support, we will solve the problem in the first time.


