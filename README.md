# WebJSTest

一个展示如何使用 UIWebView 加载和执行 JavaScript 文件以实现业务逻辑动态化的 iOS 示例项目。

## 项目简介

WebJSTest 是一个简洁的 iOS 示例项目，演示了如何通过 UIWebView 动态加载本地 JavaScript 文件来实现应用逻辑的动态化。这种方式允许开发者在不发布新版本的情况下，通过更新 JS 文件来修改应用的部分业务逻辑，适用于需要热更新或动态配置的场景。

## 技术栈

- **开发语言**: Objective-C
- **平台**: iOS 8.0+
- **核心技术**:
  - UIWebView - 用于加载和执行 JavaScript
  - JavaScriptCore - 用于 OC 与 JS 的交互
  - JSContext - JavaScript 执行上下文
- **开发工具**: Xcode

## 功能特性

1. **动态加载 JavaScript 文件**
   - 从本地 Bundle 读取 JS 文件
   - 将 JS 代码注入到 WebView 中

2. **OC 调用 JS 方法**
   - 通过 JSContext 调用 JavaScript 函数
   - 支持参数传递

3. **JS 调用 OC 方法**
   - 注册原生方法供 JavaScript 调用
   - 实现双向通信

4. **无需网络的本地实现**
   - 所有逻辑在本地执行
   - 不依赖远程服务器

## 项目结构说明

```
WebJSTest/
├── WebJSTest/                        # 主项目目录
│   ├── AppDelegate.h/m               # 应用程序入口
│   ├── ViewController.h/m            # 主视图控制器（核心实现）
│   ├── test.js                       # JavaScript 测试文件
│   ├── Assets.xcassets/              # 图片资源
│   ├── Base.lproj/                   # 界面文件
│   │   ├── Main.storyboard          # 主界面
│   │   └── LaunchScreen.storyboard  # 启动界面
│   ├── Info.plist                    # 应用配置
│   └── main.m                        # 程序入口
├── WebJSTest.xcodeproj/              # Xcode 项目文件
└── README.md                         # 项目说明文档
```

## 依赖要求

- macOS 10.12+
- Xcode 8.0+
- iOS 8.0+
- 无需第三方依赖库

## 安装和运行方法

### 1. 克隆或下载项目

```bash
cd /path/to/WebJSTest
```

### 2. 打开项目

```bash
open WebJSTest.xcodeproj
```

或直接双击 `WebJSTest.xcodeproj` 文件打开。

### 3. 运行项目

在 Xcode 中：
1. 选择目标设备或模拟器
2. 点击 Run 按钮 (⌘ + R) 运行项目
3. 点击界面上的按钮，触发 OC 调用 JS 方法

### 4. 查看日志

运行后在 Xcode 控制台查看日志输出，可以看到 JS 函数的执行结果。

## 核心实现原理

### 1. 加载 JavaScript 文件

从 Bundle 中读取 JS 文件并通过 HTML 注入到 WebView：

```objective-c
- (void)loadHTMLAndJS {
    // 加载 JS 文件
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"js"];
    NSError *error;
    NSString *jsText = [NSString stringWithContentsOfFile:path
                                                 encoding:NSUTF8StringEncoding
                                                    error:&error];
    if (!error) {
        [self loadHTMLWithJSText:jsText];
    }
}

- (void)loadHTMLWithJSText:(NSString *)jsText {
    // 构造包含 JS 的 HTML
    NSString *HTMLString = [NSString stringWithFormat:
        @"<html><head><script>%@</script></head><body></body></html>", jsText];

    // 加载到 WebView
    NSURL *fileURL = [NSURL fileURLWithPath:
        [NSTemporaryDirectory() stringByAppendingPathComponent:@"native.html"]];
    [HTMLString writeToURL:fileURL
                atomically:YES
                  encoding:NSUTF8StringEncoding
                     error:nil];
    [self.webView loadHTMLString:HTMLString baseURL:fileURL];
}
```

### 2. 获取 JavaScript 执行上下文

在 WebView 加载完成后，通过 KVC 获取 JSContext：

```objective-c
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self setupWebViewJSContext];
}

- (void)setupWebViewJSContext {
    // 通过 KVC 获取 JSContext
    self.webViewJSContext = [self.webView valueForKeyPath:
        @"documentView.webView.mainFrame.javaScriptContext"];

    // 注册原生方法供 JS 调用
    self.webViewJSContext[@"pnu_log"] = ^(NSString *text) {
        NSLog(@"======== pnu_log:%@", text);
    };
}
```

### 3. OC 调用 JS 方法

通过 JSContext 调用 JavaScript 函数：

```objective-c
- (JSValue *)excuteWebJSWithFunctionName:(NSString *)functionName
                              arguments:(NSArray *)arguments {
    JSValue *result = nil;
    JSValue *function = self.webViewJSContext[functionName];
    if (function) {
        result = [function callWithArguments:arguments];
    }
    return result;
}

// 使用示例
- (IBAction)btnAction:(id)sender {
    [self excuteWebJSWithFunctionName:@"hello" arguments:@[@"aaaaaaaa"]];
}
```

### 4. JavaScript 代码示例 (test.js)

```javascript
function hello(param) {
    var aaa = '参数是：' + param;
    pnu_log(aaa);  // 调用原生注册的方法
}
```

## 主要文件/模块说明

### ViewController.m

主视图控制器，包含了核心的 JS 加载和交互逻辑：

- **loadHTMLAndJS**: 加载本地 JS 文件
- **loadHTMLWithJSText**: 将 JS 代码注入到 HTML 中
- **setupWebViewJSContext**: 设置 JS 执行上下文，注册原生方法
- **excuteWebJSWithFunctionName**: 执行 JavaScript 函数
- **webViewDidFinishLoad**: WebView 加载完成回调

### test.js

JavaScript 测试文件，定义了可以被原生代码调用的函数：

- **hello(param)**: 测试函数，接收参数并调用原生日志方法

### 核心属性

```objective-c
@property (nonatomic, strong) UIWebView *webView;           // WebView 实例
@property (nonatomic, strong) JSContext *webViewJSContext;  // JS 执行上下文
```

## 应用场景

1. **业务逻辑热更新**
   - 通过下载新的 JS 文件实现业务逻辑更新
   - 无需发布新版本即可修改部分功能

2. **动态配置**
   - 使用 JS 文件配置应用行为
   - 灵活调整业务规则

3. **A/B 测试**
   - 通过不同的 JS 文件实现不同的业务逻辑
   - 便于进行功能测试和对比

4. **轻量级脚本引擎**
   - 将简单的业务逻辑用 JS 实现
   - 降低原生代码的复杂度

## 优缺点分析

### 优点

- **动态性强**: 可以在运行时加载和执行 JS 代码
- **更新灵活**: 通过更新 JS 文件即可修改逻辑，无需发版
- **实现简单**: 代码量少，易于理解和维护
- **双向通信**: 支持 OC 和 JS 的相互调用

### 缺点

- **性能开销**: WebView 相比原生代码有一定性能损耗
- **UIWebView 已废弃**: Apple 已标记 UIWebView 为废弃，建议使用 WKWebView
- **安全性**: 动态执行代码需要注意安全性问题
- **调试困难**: JS 代码调试相对原生代码更困难

## 改进建议

1. **迁移到 WKWebView**
   - UIWebView 已被废弃，建议升级到 WKWebView
   - WKWebView 性能更好，内存占用更低

2. **添加 JS 文件校验**
   - 实现 JS 文件的签名验证
   - 防止恶意代码注入

3. **完善错误处理**
   - 添加 JS 执行异常捕获
   - 提供友好的错误提示

4. **支持远程加载**
   - 实现从服务器下载 JS 文件
   - 添加缓存机制

## 其他相关信息

- 项目创建时间: 2018年9月
- 项目作者: luowei
- UIWebView 隐藏在界面中（2x2 像素），仅用于 JS 执行
- 适合学习 iOS 与 JavaScript 交互的基础原理

## 相关技术文档

- [JavaScriptCore Framework](https://developer.apple.com/documentation/javascriptcore)
- [UIWebView (已废弃)](https://developer.apple.com/documentation/uikit/uiwebview)
- [WKWebView (推荐)](https://developer.apple.com/documentation/webkit/wkwebview)

---

**注意**: 本项目仅作为学习和演示用途。在生产环境中，建议使用 WKWebView 替代 UIWebView，并添加完善的安全机制和错误处理。

