# 道（Tao）

A minimalist puzzle game inspired by 2048, featuring Chinese characters representing the five elements (五行) that merge into higher-level characters and ultimately into "道" (Dao). Experience the harmony of traditional Chinese philosophy combined with modern puzzle mechanics.

## 🎮 Game Concept

Players merge tiles with Chinese characters representing the five elements (金、木、水、火、土) to create higher-level characters, ultimately reaching the goal of "道" (Dao). The game follows the traditional Chinese philosophy of the Five Elements cycle: Wood → Fire → Earth → Metal → Water → Wood, culminating in the synthesis of "道" (Dao).

### Character Progression
- **木** → **林** → **森** → **火** → **炎** → **燚** → **土** → **圭** → **垚** → **金** → **鑫** → **鑾** → **水** → **沝** → **淼** → **道**

## ✨ Features

- **🎨 Minimalist Design**: Clean black and white interface with OPPO Sans Light font
- **📐 Multiple Grid Sizes**: 4×4 (Expert), 8×8 (Hard), 16×16 (Medium), 24×24 (Easy)
- **🌐 Cross-platform**: Built with Flutter for web, mobile, and desktop
- **🤖 Intelligent Autoplay**: 
  - **R Mode**: Random movement for casual play
  - **ML Mode**: Multiple AI models for intelligent gameplay
- **🧠 Advanced ML Models**:
  - **Heuristic**: Basic strategic evaluation
  - **Corner**: Corner-focused strategy
  - **Snake**: Snake pattern optimization
  - **Edge**: Edge-based movement strategy
  - **Center**: Center-focused approach
  - **Random**: Pure random selection
  - **Greedy**: Score-maximizing strategy
  - **Conservative**: Risk-averse playstyle
  - **Advanced**: Comprehensive evaluation with risk assessment
- **📱 Responsive UI**: 28×28 grid system with adaptive scaling
- **🌙 Theme Support**: Auto dark/light mode detection with manual override
- **🌍 Bilingual Interface**: English and Chinese language support
- **🎉 Victory Celebration**: Confetti effects and victory dialog
- **💾 Persistent Progress**: Score and settings saved automatically

## 🛠 Technology Stack

- **Framework**: Flutter 3.32.5 with Dart 3.8.1
- **State Management**: Provider pattern
- **Font**: OPPO Sans Light (w300)
- **Platforms**: Web, iOS, Android, Desktop
- **Dependencies**: confetti, shared_preferences, provider

## 📁 Project Structure

```
lib/
├── main.dart              # App entry point with theme configuration
├── models/
│   ├── character.dart     # Character definitions and merging logic
│   └── tile.dart         # Tile data model and merge operations
├── providers/
│   └── game_provider.dart # Game state, logic, and AI models
├── screens/
│   └── game_screen.dart   # Main game interface and UI layout
└── widgets/
    ├── game_board.dart    # Game board rendering
    ├── game_over_dialog.dart # Game over dialog
    ├── victory_dialog.dart # Victory dialog with confetti
    └── grid_cell.dart     # Individual tile widget
```

## 👨‍💻 Development

**Developer**: Bob Tianqi Wei  
**Development Time**: June 2025  
**Framework**: Flutter with Dart  
**Architecture**: Provider pattern for state management  
**GitHub**: [github.com/bobtianqiwei](https://github.com/bobtianqiwei)

## 🚀 Getting Started

1. **Install Flutter SDK** (3.10.0 or higher)
2. **Clone the repository**:
   ```bash
   git clone https://github.com/bobtianqiwei/tao.git
   cd tao
   ```
3. **Install dependencies**:
   ```bash
   flutter pub get
   ```
4. **Run for web development**:
   ```bash
   flutter run -d chrome --web-port=18888
   ```
5. **Access the game**: Open `http://localhost:18888`

## 🎯 Game Controls

- **Arrow Keys**: Move tiles in corresponding direction
- **R Button**: Toggle random autoplay mode
- **ML Button**: Toggle ML autoplay with model selection menu
- **Settings**: Configure grid size and theme preferences
- **Restart**: Reset the game (with confirmation dialog)
- **Language Toggle**: Switch between English and Chinese

## 🧠 ML Model Details

The game includes nine sophisticated AI models for autoplay:

1. **Heuristic**: Evaluates immediate score gain and merge opportunities
2. **Corner**: Focuses on keeping high-value tiles in corners
3. **Snake**: Uses snake pattern to organize tiles efficiently
4. **Edge**: Prioritizes edge movements for better tile organization
5. **Center**: Focuses on center-based strategies
6. **Random**: Pure random selection for unpredictable play
7. **Greedy**: Score-maximizing strategy with immediate gains
8. **Conservative**: Risk-averse playstyle with careful planning
9. **Advanced**: Comprehensive evaluation including future potential, risk assessment, and board structure analysis

## 🎉 Victory System

- **Victory Detection**: Immediate detection when "道" is synthesized
- **Celebration**: 5-second confetti animation with multiple colors
- **Dialog Options**: Choose to continue playing or restart
- **Score Tracking**: Automatic best score updates
- **Auto-play Integration**: Automatic stopping when victory is achieved

## 🔧 Recent Improvements

- **Enhanced Victory Detection**: Real-time detection during merge operations
- **Improved UI Responsiveness**: Better state management and UI updates
- **Font Optimization**: OPPO Sans Light for better readability
- **Developer Information**: Added GitHub link in developer info
- **Debug Integration**: Comprehensive logging for development

## 📄 License

This project is developed as a personal game project showcasing Flutter development, AI integration in gaming, and the fusion of traditional Chinese philosophy with modern game mechanics.

---

**Experience the journey from the Five Elements to the ultimate Dao!** 🎮✨ 