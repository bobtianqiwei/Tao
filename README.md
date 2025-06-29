# 道 (Tao)

![Tao Game Cover](others/Tao%20(beta-2).png)

A minimalist puzzle game inspired by 2048, featuring Chinese characters representing the five elements (五行) that merge into higher-level characters and ultimately into "道" (Tao). Experience the harmony of traditional Chinese philosophy combined with modern puzzle mechanics.

## 🎮 Game Concept

Merge tiles with Chinese characters representing the five elements (金、木、水、火、土) to create higher-level characters, following the traditional Chinese philosophy cycle: **Wood → Fire → Earth → Metal → Water → Wood**, culminating in the synthesis of "道" (Tao).

### Character Progression
**木** → **林** → **森** → **火** → **炎** → **燚** → **土** → **圭** → **垚** → **金** → **鑫** → **鑾** → **水** → **沝** → **淼** → **道**

## ✨ Features

- **🎨 Minimalist Design**: Clean black and white interface with OPPO Sans Light font
- **📐 Multiple Grid Sizes**: 4×4 (Expert), 8×8 (Hard), 16×16 (Medium), 24×24 (Easy)
- **🌐 Cross-platform**: Web, iOS, Android, Desktop
- **🤖 Intelligent Autoplay**: Random mode and 9 ML models for intelligent gameplay
- **📱 Responsive UI**: 28×28 grid system with adaptive scaling
- **🌙 Theme Support**: Auto dark/light mode detection
- **🌍 Bilingual**: English and Chinese language support
- **🎉 Victory Celebration**: Confetti effects and glowing animations

## 🛠 Technology Stack

- **Framework**: Flutter 3.32.5 with Dart 3.8.1
- **State Management**: Provider pattern
- **Font**: OPPO Sans Light (w300)
- **Platforms**: Web, iOS, Android, Desktop

## 🚀 Quick Start

1. **Install Flutter SDK** (3.10.0 or higher)
2. **Clone and run**:
   ```bash
   git clone https://github.com/bobtianqiwei/tao.git
   cd tao
   flutter pub get
   flutter run -d chrome --web-port=18888
   ```
3. **Access**: Open `http://localhost:18888`

## 🎯 Controls

- **Arrow Keys**: Move tiles
- **R Button**: Toggle random autoplay
- **ML Button**: Toggle ML autoplay with model selection
- **Settings**: Configure grid size and theme
- **Restart**: Reset game with confirmation

## 🧠 ML Models

The game includes 9 AI models for intelligent gameplay:

- **Heuristic**: Basic strategic evaluation
- **Corner**: Corner-focused strategy
- **Snake**: Snake pattern optimization
- **Edge**: Edge-based movement
- **Center**: Center-focused approach
- **Random**: Pure random selection
- **Greedy**: Score-maximizing strategy
- **Conservative**: Risk-averse playstyle
- **Advanced**: Comprehensive evaluation with risk assessment

## 🎉 Victory System

- **Real-time Detection**: Immediate detection when "道" is synthesized
- **Celebration**: 2-minute confetti animation and glowing effects
- **Score Tracking**: Automatic best score updates
- **Auto-play Integration**: Automatic stopping on victory

## 👨‍💻 Developer

**Bob Tianqi Wei**  
[github.com/bobtianqiwei](https://github.com/bobtianqiwei)

---

**Experience the journey from the Five Elements to the ultimate Tao!** 🎮✨ 