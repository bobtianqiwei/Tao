# Tao (道)

A minimalist puzzle game inspired by 2048, featuring Chinese characters representing the five elements that merge into higher-level characters and ultimately into "道" (Dao).

## Game Concept

Tao is a cross-platform puzzle game that combines the addictive mechanics of 2048 with traditional Chinese philosophy. Players merge tiles representing the five elements (wood, fire, earth, metal, water) to create higher-level characters, ultimately striving to reach the character "道" (Dao).

## Features

- **Minimalist Design**: Clean black and white interface with ultra-thin typography
- **Five Elements System**: Merge characters representing wood (木), fire (火), earth (土), metal (金), and water (水)
- **Progressive Merging**: Characters evolve through multiple levels to reach "道"
- **Multiple Grid Sizes**: 4×4 (expert), 8×8 (hard), 16×16 (medium), 24×24 (easy)
- **Cross-Platform**: Built with Flutter for web, mobile, and desktop
- **Auto Play**: Watch the AI play automatically with random moves
- **Bilingual Support**: Chinese and English interface
- **Dark/Light Mode**: Toggle between themes

## Technical Stack

- **Framework**: Flutter with Dart
- **State Management**: Provider pattern
- **Font**: OPPO Sans (ultra-thin weight)
- **Grid System**: 28×28 adaptive grid layout
- **Platforms**: Web, iOS, Android, Desktop

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/
│   ├── character.dart     # Character and element definitions
│   └── tile.dart          # Tile model and merge logic
├── providers/
│   └── game_provider.dart # Game state and logic
├── screens/
│   └── game_screen.dart   # Main game interface
└── widgets/
    ├── game_board.dart    # Game board rendering
    ├── grid_cell.dart     # Grid cell component
    └── tile_widget.dart   # Individual tile display
```

## Getting Started

1. Install Flutter
2. Clone the repository
3. Run `flutter pub get`
4. Run `flutter run -d chrome` for web
5. Use arrow keys or swipe gestures to play

## Game Mechanics

- Merge identical characters to create higher-level elements
- Each element has a specific color and character
- The goal is to reach the "道" character
- Game ends when no more moves are possible
- Score increases with each successful merge

## Development

This project uses a 28×28 grid system where the game board is centered and UI elements occupy the outer grid positions. The minimalist design emphasizes typography and clean lines, with no shadows or rounded corners.

## License

This project is open source and available under the MIT License. 