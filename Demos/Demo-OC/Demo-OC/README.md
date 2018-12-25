#  Demo-OC

## <工程配置>
### Alpha.集成 ~
##### ~> ```Pods```集成```CameraDrive```，详情见```Demo```中的```Podfile```文件；
> a1. 添加```source```；
```source 'https://github.com/CocoaPods/Specs.git'```
```source 'https://github.com/XiaoFuGenius/xiaofu-specs.git'```
> a2.支持```iOS```版本 8.0+ ；
> b1.```pod 'CameraDrive-release'```，发布版本，用于发布到```appstore```或```外部测试版本```；
> b2.```pod 'CameraDrive-develop'```，开发版本，用于支持模拟器运行，```Sdk```内部方法将不会执行；

###### ps.```[CocoaPods]```帮助；
> a.```#import ""```方式，```Xcode```不提示```Pods```中的头文件的问题；
    解决方法：```TARGETS``` -> ```Build Settings```  -> ```User Header Search Paths``` ->  添加```$(SRCROOT)```，设置为```recursive```；

##### ~> ```手动```集成```CameraDrive```
> a1.从```https://github.com/XiaoFuGenius/CameraDrive-release``` 下载```Sdk```的发布版本；
> a2.从```https://github.com/XiaoFuGenius/CameraDrive-develop``` 下载```Sdk```的开发版本；
> b1.将发布(或者开发)版本的```CameraDrive.framework```拖入工程；
> b2.```TARGETS``` -> ```General``` -> ```Linked Frameworks and Libraries```删除```CameraDrive.framework```；
> b3.```TARGETS``` -> ```General``` -> ```Embedded Binaries```添加```CameraDrive.framework```；

### Beta.通用配置 ~
> a.```PrefixHeader.pch```预编译文件中添加```#import <CameraDrive/CameraDrive.h>```；
> b.```TARGETS``` -> ```Build Settings``` -> ```Enable Bitcode``` 设置为```NO```；
> c.```Xcode 10 +```，需设置，```File``` -> ```Workspace Settings``` -> ```Build System``` -> ```Legacy Build System```；
> d.```TARGETS``` -> ```Capabilities``` -> 开启``` Access WiFi Information```；
    iOS 12 + 变更，若不开启，手机已连接```wifi```的情况下，现有方法会无法获取到该```wifi```的```ssid```；
> e.```TARGETS``` -> ```Capabilities``` -> 开启``` Hotspot Configuration```；
    iOS 11 + 支持，开启后，支持应用内确认```指定热点```的连接，而无需到```手机系统设置```中手动连接```指定热点```；
> f.```Info.plist```文件中添加```Privacy - Bluetooth Peripheral Usage Description```权限；
    因为设备连接过程中需要使用到手机蓝牙；
> g.国行手机，应用需要获得网络访问权限，```Demo```获得权限的方式，可见```XFAppDelegate.h```文件中的启动部分代码；
    因为应用与设备交互的```图像采集模块```需要使用```网络```进行通讯；
    
    
## <Sdk功能api说明，及示例代码>
### Alpha.Part1 ~预设与支持
##### ```CTConfig.h```
##### ```"CTWiFiHelper.h"```
##### ```"CTPingHelper.h"```
##### ```CTHotspotHelper.h"```

### Beta.Part2 ~蓝牙&联网 连接控制
##### ```CTBleHelper.h```基础
##### ```CTEasyLinker.h```推荐
##### ```CTEasyUpgrade.h```推荐

### Gamma.Part3 ~摄像头 控制
##### ```CTCameraHelper.h```

### Delta.Part4.示例代码
###### 示例代码见```Demo```中的相关```api```调用；
###### 更多详情或疑问，请联系``Sdk``提供人员；


## <小肤检测详情接口>
> a.文档见```Demo```中的```小肤检测外部接口.doc```文件；
> b.示例代码，可见```XFCameraViewController.m```文件中的```apiTest```部分代码；
