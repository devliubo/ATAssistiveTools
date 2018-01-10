## ATAssistiveTools

ATAssistiveTools 是一个辅助调试工具容器，包含收缩和扩展两个状态。
* 扩展界面支持在任意时刻，加载任意的自定义界面，通过实现 ATCustomViewProtocol 协议，支持自定义界面获取 appear、 disappear、 shrink、 expand 四种状态的 will 和 did 事件，以便进行特定逻辑处理。
* 收缩界面外观显示效果仿照 iOS 系统的 AssistiveTouch 。

## ATCustomizeViews

ATCustomizeViews 目录中包含了以下的自定义界面，一方面可以作为使用示例，另一方面也可以直接使用这些自定义界面的功能：

* ATFakeLocationView 虚拟定位
* ATSandboxViewerView 沙盒目录浏览
* ATDeviceLogsView 设备日志查看
* ATGPSEmulatorView 对指定的坐标串按特定速度进行模拟

## Installation

### Manual

将ATAssistiveTools目录下载导入到工程中即可。

如果需要ATCustomizeViews，则需要下载ATCustomizeViews目录，导入到工程即可。

## Usage

### 使用 ATAssistiveTools

* 导入头文件

```objective-c
#import "ATAssistiveTools.h"
```  

* 显示 ATAssistiveTools

```  
[[ATAssistiveTools sharedInstance] show];
```

### 使用ATCustomizeViews

在显示 ATAssistiveTools 的基础上：

* 导入头文件

```objective-c
#import "ATDeviceLogsView.h"
#import "ATFakeLocationView.h"
#import "ATSandboxViewerView.h"
#import "ATGPSEmulatorView.h"
```

* 加载 ATCustomizeViews

```  
// add fake location view
ATFakeLocationView *simLocView = [[ATFakeLocationView alloc] init];
[[ATAssistiveTools sharedInstance] addCustomView:simLocView forTitle:@"FakeLocation"];

// add sandbox viewer view
ATSandboxViewerView *sandboxView = [[ATSandboxViewerView alloc] init];
[[ATAssistiveTools sharedInstance] addCustomView:sandboxView forTitle:@"SandboxViewer"];

// add device log view
ATDeviceLogsView *logsView = [[ATDeviceLogsView alloc] init];
[[ATAssistiveTools sharedInstance] addCustomView:logsView forTitle:@"DeviceLog"];

// add GPS emulator view
ATGPSEmulatorView *emulatorView = [[ATGPSEmulatorView alloc] init];
[[ATAssistiveTools sharedInstance] addCustomView:emulatorView forTitle:@"GPSEmulator"];
```

### 自定义界面

如果想自定义界面，需要让custom view实现 ATCustomViewProtocol 协议：

* 导入头文件

```objective-c
#import "ATCustomViewProtocol.h" 
```

* 使界面实现 ATCustomViewProtocol 协议

```
@interface ACustomView : UIView <ATCustomViewProtocol>
@end
```

## To Do

* 补全ATCustomizeViews的介绍说明
* 收缩状态支持显示自定义的届满 ，支持显示自定义的标题
* 增加生成 framework 的 target ，打包成 static library
* ~~增加 podspec 文件~~ 支持使用 cocoapods 安装

## Notice

不建议用于性能相关的调试，虽然 ATAssistiveTools 本身对性能影响很小，但加载的 custom view 有可能对内存、CPU以及网络造成过大的占用，会导致结论的不严谨和不准确。

## License

ATAssistiveTools is released under the [MIT License](https://raw.githubusercontent.com/devliubo/ATAssistiveTools/master/LICENSE).
