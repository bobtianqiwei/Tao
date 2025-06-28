# 道 (Dao) - Five Elements 2048 Game

A minimalist puzzle game inspired by 2048, featuring Chinese characters representing the five elements (wood, fire, earth, metal, water) that merge following the traditional Chinese philosophy of element generation cycles.

## Game Concept

- **Objective**: Merge identical Chinese characters to create higher-level elements, ultimately forming the ultimate character "道" (Dao)
- **Element Cycle**: Wood (木) → Fire (火) → Earth (土) → Metal (金) → Water (水) → Wood (木)
- **Characters**: All game elements are Chinese characters representing traditional five elements theory

## Features

- **Minimalist Design**: Clean black and white interface with 1px grid lines
- **Adaptive Grid System**: 27×27 master grid with game board centered
- **Multiple Difficulties**: 
  - 4×4 Expert (most challenging)
  - 8×8 Hard
  - 16×16 Medium  
  - 24×24 Easy (simplest)
- **Theme Support**: Light and dark mode toggle
- **Cross-platform**: iOS, Android, Windows, macOS, Linux, Web
- **Controls**: Arrow keys or swipe gestures

## Technical Stack

- **Framework**: Flutter with Dart
- **State Management**: Provider pattern
- **Font**: OPPO Sans (thin weight)
- **Platform**: Cross-platform with web support

## Getting Started

### Prerequisites
- Flutter SDK
- Dart SDK
- Web browser (for web version)

### Installation
1. Clone the repository
2. Install dependencies: `flutter pub get`
3. Run the game: `flutter run -d chrome`

## Game Rules

1. Use arrow keys or swipe to move tiles
2. Identical characters merge when they collide
3. Follow the five elements generation cycle
4. Achieve the ultimate goal: create "道" (Dao)
5. Game ends when no more moves are possible

## Development

This project uses Flutter's widget system with a custom 27×27 grid layout system. The game board is dynamically centered within the master grid, and all UI elements align to the grid system for perfect consistency.

## License

This project is open source and available under the MIT License. 