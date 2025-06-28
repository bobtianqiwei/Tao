# 五行2048 - 中国传统文化的益智游戏

一个灵感源自2048的跨平台益智游戏，融合了中国传统文化中的五行元素概念。玩家通过滑动方块，合并相同的汉字，逐步生成更高阶的汉字，最终合成象征天地万物本源的「道」。

## 游戏特色

### 🎮 核心玩法
- **五行相生**：遵循传统五行相生规律（木生火、火生土、土生金、金生水、水生木）
- **汉字合成**：从基础五行元素逐步合成更高级的汉字
- **终极目标**：合成象征宇宙本源的「道」字

### 🌟 汉字体系
- **木系**：木 → 林 → 森 → 火
- **火系**：火 → 炎 → 燚 → 土  
- **土系**：土 → 圭 → 垚 → 金
- **金系**：金 → 鑫 → 鑾 → 水
- **水系**：水 → 沝 → 淼 → 木
- **终极**：五行齐聚 → 道

### 📱 技术特性
- **跨平台支持**：iOS、Android、Windows、macOS、Linux
- **流畅动画**：方块合并、新方块出现等动画效果
- **手势操作**：支持滑动、点击等操作方式
- **数据持久化**：保存最高分和游戏进度

## 技术栈

- **框架**：Flutter 3.10+
- **语言**：Dart
- **状态管理**：Provider
- **动画**：flutter_animate
- **特效**：confetti
- **数据存储**：shared_preferences

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
│   ├── character.dart        # 汉字模型
│   └── tile.dart            # 方块模型
├── providers/               # 状态管理
│   └── game_provider.dart   # 游戏逻辑
├── screens/                 # 页面
│   └── game_screen.dart     # 游戏主界面
└── widgets/                 # 组件
    ├── game_board.dart      # 游戏棋盘
    ├── tile_widget.dart     # 方块组件
    ├── score_board.dart     # 分数板
    ├── victory_dialog.dart  # 胜利对话框
    └── game_over_dialog.dart # 游戏结束对话框
```

## 开发环境要求

- Flutter SDK 3.10.0 或更高版本
- Dart SDK 3.0.0 或更高版本
- Android Studio / VS Code
- iOS开发需要Xcode（仅macOS）

## 安装和运行

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd wuxing_2048
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **运行项目**
   ```bash
   # 运行在连接的设备上
   flutter run
   
   # 或者指定平台
   flutter run -d ios     # iOS模拟器
   flutter run -d android # Android模拟器
   flutter run -d windows # Windows桌面
   flutter run -d macos   # macOS桌面
   ```

## 构建发布版本

### Android APK
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Windows
```bash
flutter build windows --release
```

### macOS
```bash
flutter build macos --release
```

## 游戏规则

1. **基础操作**：通过滑动屏幕来移动方块
2. **合并规则**：相同汉字可以合并成下一个等级
3. **五行相生**：每个元素达到最高等级后会转化为相生元素
4. **胜利条件**：合成出「道」字
5. **失败条件**：无法进行任何有效移动

## 贡献指南

欢迎提交Issue和Pull Request来改进游戏！

### 开发规范
- 遵循Dart代码规范
- 使用有意义的变量和函数名
- 添加必要的注释
- 确保代码通过linter检查

## 许可证

本项目采用MIT许可证 - 详见 [LICENSE](LICENSE) 文件

## 致谢

- 灵感来源于经典的2048游戏
- 感谢中国传统文化中五行理论的启发
- 感谢Flutter团队提供的优秀框架

---

**享受游戏，感受中华文化的魅力！** 🎮✨ 