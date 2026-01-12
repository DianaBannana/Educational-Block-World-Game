# Educational Block World Game - Stage 1
## Ruined Zone After Skibidi Attack

A Minecraft-style educational adventure game for children aged 7+, third-person perspective.

## Project Structure

```
Educational Block World Game/
├── data/
│   ├── characters.json / characters.csv
│   ├── puzzles.json / puzzles.csv
│   ├── rewards.json / rewards.csv
│   ├── dialogues.json / dialogues.csv
│   └── building_tools.json / building_tools.csv
├── scripts/
│   ├── player.gd (Ethan movement & controls)
│   ├── puzzle_system.gd (Puzzle handling)
│   ├── npc_interaction.gd (NPC interactions)
│   ├── game_manager.gd (Main game logic)
│   ├── treasure_chest.gd (Treasure chests)
│   ├── building_system.gd (Portal building)
│   ├── companion_pug.gd (Pug follower AI)
│   ├── puzzle_ui.gd (Puzzle UI)
│   └── game_ui.gd (HUD display)
└── README.md
```

## Features

### World
- Destroyed colorful block area with scattered items
- Free-roaming exploration (WASD/Arrow keys)
- Jump, interact with objects/NPCs
- Top-left UI panel: Hearts, Coins, Current Level

### Characters
1. **Ethan** (Player) - Customizable hair/clothes, helmet, sword unlock
2. **Pug** (Companion) - Japanese Chin dog, follows player, helps with puzzles
3. **Brak** (Friendly NPC) - Black cat, gives hints when puzzles fail
4. **Skibidi** (Enemy) - Green dark cat zombie, puzzle-based combat

### Puzzles (6 Total)
- Picture-word matching (Apple, Dog, Tree, House)
- Multiple-choice (Colors, Numbers)
- Voice prompts for non-readers
- Correct answer → reward + damage enemy
- Wrong answer → hint from Brak

### Rewards
- Coins (small/medium/large)
- Diamonds (small/large)
- Food items (restore health)
- Building tool parts (Portal Frame, Portal Core)

### Building Tools
- Part 1: Portal Frame (unlocks after puzzle 6)
- Part 2: Portal Core (found in treasure chests)
- Both parts required to build portal gate to next world

## Godot Setup

### Input Map
Add these actions in Project Settings > Input Map:
- `move_left` (A / Left Arrow)
- `move_right` (D / Right Arrow)
- `move_forward` (W / Up Arrow)
- `move_back` (S / Down Arrow)
- `ui_accept` (Space - Jump)
- `attack` (Left Click / X)
- `interact` (E / F)

### Autoload Singletons
Add to Project Settings > Autoload:
- `GameManager` (scripts/game_manager.gd)
- `PuzzleSystem` (scripts/puzzle_system.gd)

### Scene Structure
```
Main Scene
├── World (Node3D)
│   ├── Player (CharacterBody3D) - group: "player"
│   ├── Pug (CharacterBody3D) - group: "companion"
│   ├── Brak (Area3D) - group: "npc"
│   ├── Skibidi (Area3D) - group: "enemies"
│   ├── TreasureChests (Area3D)
│   └── PortalLocation (Marker3D) - group: "portal_location"
└── UI (CanvasLayer)
    ├── GameUI (Control) - group: "game_ui"
    └── PuzzleUI (Control)
```

## Data Files

All game data is available in both JSON and CSV formats:
- **JSON**: Easy to read/edit, structured format
- **CSV**: Compact, easy to import into spreadsheets

### Importing Data
1. Place JSON/CSV files in `res://data/` folder
2. Scripts automatically load from JSON files
3. CSV files can be imported using Godot's CSV import plugin

## Controls

- **Movement**: WASD or Arrow Keys
- **Jump**: Space
- **Attack**: Left Click / X (when sword unlocked)
- **Interact**: E / F (near NPCs/objects)

## Game Flow

1. Player spawns in ruined zone
2. Explore and find Pug companion
3. Encounter Skibidi enemies → solve puzzles to defeat
4. Collect coins, diamonds, and building tool parts
5. Find treasure chests for rewards
6. Talk to Brak for hints when stuck
7. Collect both portal parts
8. Build portal gate to unlock next stage

## Customization

Ethan's appearance can be customized:
- Hair: brown, blonde, black
- Clothes: red, blue, green
- Helmet: yes/no
- Sword: unlocked later in game

## Voice Prompts

All puzzles include voice prompts in English for non-readers:
- Stored in `res://sounds/voice/`
- Format: `{puzzle_id}_prompt.wav`
- Also use `voice_prompt` text field from JSON

## Notes

- Child-friendly content (ages 7+)
- Puzzle-based combat (no violence)
- Educational focus on word matching and basic math
- Minecraft-style block world aesthetic
- Third-person perspective

## Next Steps

1. Create 3D models/scenes for characters
2. Add sound effects and voice recordings
3. Create puzzle images
4. Build world environment
5. Test puzzle system
6. Implement portal building mechanic

