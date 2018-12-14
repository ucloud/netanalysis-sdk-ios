# NetAnalysis SDK for iOS


## 概要

本文档主要是`NetAnalysis SDK for iOS`的使用说明文档，下面我们从以下几个方面做介绍： 

* 简要说明
* 目录结构
* 环境要求
* 快速集成
* 联系我们

## 简要说明

This open-source library allows you to integrate UCloud Global network analysis service into your app, which will detect and report the network availability between app end-user and locations where the service has been deployed. 

API is available as well for app developer to configure the service location (IP Address)  you would like to detect and analysis between your app users. UCloud IDC centers have been set as default locations.

The network detection is automatically triggered for following two situations:

Ping and Tracerout the server from end-user when app initial 

Ping the server when the network environment change between WIFI and Cellular

## 目录结构

该仓库主要包括`SDK`的源码以及示例项目，示例项目包含`Objective-C`和`Swift`两个版本。 

目录  | 说明
------------- | -------------
`SDK/UNetAnalysisSDK` | SDK源码
`SDK/documents/devDocuments.zip` | SDK开发文档(解压后可用浏览器查看)
`SDK/Demo/oc/UNetAnalysisDemo_01` | Demo程序(`Objective-c`版本)
`SDK/Demo/swift/UNetAnalysisSwiftDemo_01` | Demo程序(`Swift`版本)

## 环境要求

* iOS系统版本>=8.3

## 快速集成

我们假设你有一些ios平台的开发经验，所以一些基本的名词解释在此不做说明。 

### Xcode Version

`UNetAnalysis SDK`的 `Deployment target`是8.3，所以你可以使用XCode6.3及其以上的版本。如果你使用的是XCode版本是XCode7.x或者是更高的版本，那么你首先要设置`Enable Bitcode`为`NO`: 

`Project`->`Build Setting`->`Build Operation`->`Enable Bitcode`

![](https://ws2.sinaimg.cn/large/006tNbRwgy1fwj45s1t65j30n207s0ts.jpg)

### 设置other link flags

由于我们的库中利用了和c++相关的东西，所以需要设置支持c++链接。 库中也是用了分类，所以也要支持分类。

`Project`->`Build Setting`->`other link flags`

![](https://ws1.sinaimg.cn/large/006tNbRwly1fwpaep7ndoj30wn0biwfr.jpg)


### 导入SDK到项目中并初始化

你可以下载`UNetAnalysisSDK.framework`从UCLoud官方网站。 

把`UNetAnalysisSDK.framework`拖入你的项目. 

![](https://ws2.sinaimg.cn/large/006tNbRwgy1fwj49vo9gij30s90cigod.jpg)


接下来，你需要在`AppDelegate`中对`UNetAnalysisSDK`做初始化，进而就可以使用SDK中的各项功能了。 

![](https://ws3.sinaimg.cn/large/006tNbRwgy1fwj4c0l824j30v30h5wiz.jpg)

### 设置自己的服务地址

在SDK中如果设置自己的服务地址，能利用sdk的检测功能做手动网络检测。按如下方法设置自己的服务地址：

![](https://ws4.sinaimg.cn/large/006tNbRwgy1fwj4faujz9j30vc0ih0ym.jpg)

### 手动网络检测

在手动检测网络接口的回调中，可以获取你设置的服务列表的网络连通性分析结果，以及设备和app的各种信息。

![](https://ws2.sinaimg.cn/large/006tNbRwgy1fwj4heolpyj30mq05074p.jpg)


## 常见问题

* `iOS 9+`强制使用`HTTPS`,使用`XCode`创建的项目默认不只支持`HTTP`，所以需要在`project build info` 添加`NSAppTransportSecurity`,在`NSAppTransportSecurity`下添加`NSAllowsArbitraryLoads`值设为`YES`,如下图。 
	![](https://raw.githubusercontent.com/ufilesdk-dev/ufile-ios-sdk/master/documents/resources/readme_02.png)

## 联系我们

* [UCloud官方网站: https://www.ucloud.cn/](https://www.ucloud.cn/)
*  如有任何问题，欢迎提交[issue](https://github.com/ucloud/netanalysis-sdk-ios/issues)或联系我们的技术支持，我们会第一时间解决问题。


