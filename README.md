# Pac-Man Assembly Game

## Overview
This is a Pac-Man style console game written in x86 Assembly language. The game runs in the Windows console and uses ASCII characters for its graphics and interface.

[Watch the Video Demo Here](https://drive.google.com/file/d/1ha8R8elEQJvt3Ds-h1dCXAZqnPU_cGls/view?usp=sharing)

## Tools and Technologies Used
- **Language:** x86 Assembly Language (32-bit)
- **Assembler:** MASM (Microsoft Macro Assembler)
- **Library:** Irvine32 Library (provides functions for console I/O, delays, colors, etc.)
- **Macros:** Utilizes `macros.inc` for simplified string output operations (e.g., `mWrite`).

## Key Features
- **Interactive Main Menu:** Navigate through options including Start Game, Instructions, Highscores, and Exit using a selection cursor.
- **Player Controls:** Navigate the maze using the `W` (Up), `A` (Left), `S` (Down), and `D` (Right) keys.
- **Collision Detection:**
  - **Walls:** Implements boundary and inner maze wall collision to prevent the player from passing through solid objects.
  - **Collectibles (Food/Coins):** Detects when the player lands on a coin to increase the score and remove the coin from the map.
  - **Enemies (Ghosts):** Detects collision between the player and ghosts, triggering a "You Died" game over state.
- **Dynamic Entities:**
  - **Player Character:** Represented by the yellow 'C' character.
  - **Patrolling Ghosts:** Automated enemies ('&') that patrol the maze horizontally, guarding the coins.
- **Scoring and Progression:**
  - Real-time score tracking displayed on the screen.
  - Multi-level support where the player advances to a new, harder level with different color schemes upon reaching score milestones.
- **Visuals and UI:**
  - Custom ASCII art title screen.
  - Colored console graphics using `SetTextColor` for distinct game elements (e.g., blue/magenta walls, yellow player, green coins, white/black ghosts).
  - Smooth screen updates using exact console coordinate positioning (`Gotoxy`).
- **Additional Functionality:**
  - **Player Profile:** Prompts the user to enter their name before starting the game, which is displayed on the Game Over screen.
  - **Built-in Instructions:** A dedicated tutorial screen explaining the controls and game elements.
  - **Developer Cheat:** Pressing the `K` key activates a level skip/hack to advance through the game instantly.
