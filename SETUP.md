# 开发环境设置指南

## 1. 安装Flutter SDK

### macOS
```bash
# 使用Homebrew安装
brew install flutter

# 或者手动安装
# 1. 下载Flutter SDK: https://flutter.dev/docs/get-started/install/macos
# 2. 解压到指定目录
# 3. 添加到PATH环境变量
export PATH="$PATH:`pwd`/flutter/bin"
```

### Windows
```bash
# 1. 下载Flutter SDK: https://flutter.dev/docs/get-started/install/windows
# 2. 解压到C:\flutter
# 3. 添加到PATH环境变量
```

### Linux
```bash
# 使用snap安装
sudo snap install flutter --classic

# 或者手动安装
# 1. 下载Flutter SDK: https://flutter.dev/docs/get-started/install/linux
# 2. 解压到指定目录
# 3. 添加到PATH环境变量
```

## 2. 验证安装
```bash
flutter doctor
```

## 3. 安装IDE

### Android Studio
1. 下载并安装Android Studio
2. 安装Flutter和Dart插件
3. 配置Android SDK

### VS Code
1. 下载并安装VS Code
2. 安装Flutter和Dart扩展
3. 配置Flutter SDK路径

## 4. 配置开发环境

### iOS开发（仅macOS）
```bash
# 安装Xcode
xcode-select --install

# 接受Xcode许可
sudo xcodebuild -license accept

# 安装iOS模拟器
open -a Simulator
```

### Android开发
```bash
# 安装Android Studio
# 配置Android SDK
# 创建Android虚拟设备
```

## 5. 运行项目

安装完Flutter后，在项目目录中运行：

```bash
# 安装依赖
flutter pub get

# 检查设备
flutter devices

# 运行项目
flutter run

# 或者指定平台
flutter run -d ios
flutter run -d android
flutter run -d windows
flutter run -d macos
```

## 6. 常见问题

### Flutter命令未找到
确保Flutter已添加到PATH环境变量中。

### 依赖安装失败
```bash
# 清理缓存
flutter clean
flutter pub get
```

### 模拟器问题
```bash
# 列出可用设备
flutter devices

# 启动iOS模拟器
open -a Simulator

# 启动Android模拟器
# 通过Android Studio AVD Manager
```

## 7. 开发工具推荐

- **IDE**: Android Studio 或 VS Code
- **版本控制**: Git
- **调试工具**: Flutter Inspector
- **性能分析**: Flutter Performance

## 8. 下一步

完成环境设置后，你可以：

1. 运行 `flutter doctor` 检查所有配置
2. 运行 `flutter run` 启动游戏
3. 开始开发和调试
4. 构建发布版本

---

**提示**: 如果遇到任何问题，请查看Flutter官方文档或提交Issue。 