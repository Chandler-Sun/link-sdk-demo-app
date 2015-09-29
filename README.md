# link-sdk-demo-app

the demo app for flash link SDK


**注意**

* 使用此demo前，请打开蓝牙
* 安装好配合SDK使用的测试版Misfit Link App
* 项目内含有两个Target，分别对应消息Demo和音乐Demo

**关于编译**

此Demo项目已设置好下面的选项.如果是在此外的项目中引用:

* 请在在Xcode6的项目Build Phases的Link Binary With Libraries处添加CoreBluetooth.framework和MisfitLinkSDK.framework, 并在Build Settings的Other Linker Flags处添加-ObjC

**配置BundleURLSchemes**

添加下面的内容到你的应用的plist, 其中的api key需要与调用API enable时使用的一致.
Add the settings below to your plist. Please make sure the api key here is the same with the one when you call the enable API.
[code]
<key>CFBundleURLTypes</key>
<array>
<dict>
<key>CFBundleURLName</key>
<string></string>
<key>CFBundleURLSchemes</key>
<array>
<string>mfl-<api key></string>
</array>
</dict>
</array>
[/code]

**引用SDK到项目中**

 * 请在XCode6的项目Build Phases的Link Binary With Libraries处添加CoreBluetooth.framework和MisfitLinkSDK.framework, 并在Build Settings的Other Linker Flags处添加-ObjC
Please add CoreBluetooth.framework and MisfitLinkSDK.framework to the Link Binary With Libraries of your Build Phases settings in XCode 6

* 开启蓝牙设备访问权限Enable Uses BLE accessories Capabilities
In your project settings, please check the option of Uses Bluetooth LE accessories in Capabilities settings.

* iOS 9 兼容Compatibility
在iOS 9 下, 请将以下内容添加到项目对应的plist的设置中
In iOS 9, please add the settings below to the section LSApplicationQueriesSchemes of your app's plist.

[code]
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>misfitlink</string>
  <string>misfitlink-internal</string>
</array>
[/code]

其中, misfitlink-internal 是针对测试环境的. 生产环境的可以将其拿掉.
