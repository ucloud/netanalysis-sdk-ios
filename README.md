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

### Other functions

* Setting SDK log level
* Get the SDK version


### Code example

#### Regist SDK

Suppose you have already registered your app in the `UCloud Console` and opened the `UCloud net analysis service`, then you will get a pair of `AppKey` and `PublicToken (public key)`, when registering `SDK` need to use these parameters.

We hope that you register as early as possible `SDK`, we recommend but not limited to register when the application is just started. You can register in the `- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions` method in `AppDelegate`. 

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UCNetAnalysisManager shareInstance] uNetSettingSDKLogLevel:UCSDKLogLevel_DEBUG];  // setting log level
    
    // Appkey and public token can be obtained from the ucloud console, or contact our technical support
    NSString *appKey = @""; //your AppKey
    NSString *appToken = @""; // your publick token
    NSDictionary *userDefins = @{@"key1":@"value1",@"key2":@"value2"}; // User-defined field, which is a dictionary format with a limited length (detailed below)
    [[UCNetAnalysisManager shareInstance] uNetRegistSdkWithAppKey:appKey publicToken:appToken userDefinedFields:userDefins completeHandler:^(UCError * _Nullable ucError) {
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

#### Stop network data collection

Stop network data collection when the application is about to move from active to inactive state. This is done in the `- (void)applicationWillResignActive:(UIApplication *)application` method in `AppDelegate`. 

```
- (void)applicationWillResignActive:(UIApplication *)application {
    [[UCNetAnalysisManager shareInstance] uNetStopDataCollectionWhenAppWillResignActive];
}

```


## F&Q

* The app on `iOS 9+` is forced to use `HTTPS`. Projects created with `XCode` do not support `HTTP` by default, so you need to add `NSAppTransportSecurity` in `project build info` and `NSAllowsArbitraryLoads` in `NSAppTransportSecurity`,The value is set to `YES`, as shown below:
	![](https://ws2.sinaimg.cn/large/006tNc79gy1fzitnl2r6ej30ih0c5tb0.jpg)

## Contact us

* [UCloud official website](https://www.ucloud.cn/)
* If you have any questions, please submit [issue](https://github.com/ucloud/netanalysis-sdk-ios/issues) or contact our technical support, we will solve the problem in the first time.


