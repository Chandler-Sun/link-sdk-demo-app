# link-sdk-demo-app

the demo app for flash link SDK


**注意**

* 使用此demo前，请打开蓝牙
* 安装好配合SDK使用的测试版Misfit Link App
* 将连接上的Flash Link设置为**活动跟踪模式**
* 当前固件只支持双击和三击事件，后续更新新固件后会支持所有事件
* 项目内含有两个Target，分别对应消息Demo和音乐Demo

**关于编译**

此Demo项目已设置好下面的选项.如果是在此外的项目中引用:

* 如果你使用的是动态库, 请在Xcode6的项目Build Phases的Link Binary With Libraries处添加MisfitLinkSDK.framework,以及Embedded Framework处添加MisfitLinkSDK.framework
* 如果你使用的是静态库, 请在在Xcode6的项目Build Phases的Link Binary With Libraries处添加CoreBluetooth.framework和MisfitLinkSDK.framework, 并在Build Settings的Other Linker Flags处添加-ObjC
