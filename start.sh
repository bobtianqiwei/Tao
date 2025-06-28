#!/bin/bash

echo "🚀 五行2048 - 启动脚本"
echo "========================"

# 检查Flutter是否安装
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter未安装，请先安装Flutter SDK"
    echo "📖 查看 SETUP.md 获取安装指南"
    exit 1
fi

echo "✅ Flutter已安装"

# 检查Flutter环境
echo "🔍 检查Flutter环境..."
flutter doctor

# 安装依赖
echo "📦 安装项目依赖..."
flutter pub get

# 检查可用设备
echo "📱 检查可用设备..."
flutter devices

echo ""
echo "🎮 启动游戏..."
echo "💡 提示："
echo "   - 使用 'flutter run' 启动游戏"
echo "   - 使用 'flutter run -d <device-id>' 在指定设备上运行"
echo "   - 使用 'flutter build <platform>' 构建发布版本"
echo ""

# 询问是否立即运行
read -p "是否立即运行游戏？(y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    flutter run
fi 