# Word Games

## Overview
WordGames is a recreation of the popular GamePigeon **Word Hunt** game, developed using Swift. This project is word search game where players find as many words as possible within a grid of letters. The goal is to improve vocabulary, reaction time, and pattern recognition through a fun medium of learning.
Note that this is still a WIP project, so while the functionality on one device works, the multiplayer aspect of it (communicating between devices) is not fully functional at this time.

## Features
- **Interactive Word Grid**: Players are presented with a grid of randomized letters.
- **Word Highlighting**: Drag across letters to form words, with immediate feedback.
- **Dynamic Scoring**: Points are awarded based on word length and complexity.
- **Timer**: Players race against the clock to find as many words as possible within a time limit.
- **Dictionary Validation**: All word entries are validated using an in-app dictionary to ensure correctness.
  
## Technologies Used
- **Swift 5**: For the main game logic and UI.
- **UIKit**: To design a user-friendly interface.
- **Core Data**: For storing and retrieving player scores and game data.
- **Core Animation**: For smooth transitions and interactive feedback.
- **Custom Algorithms**: Efficient word search algorithms for validating word entries.

## Installation

### Steps
1. **Clone the repository**:
   ```bash
   git clone https://github.com/pjochillin/WordGames.git
   ```
2. **Open the project**:
   Navigate to the project and open it in Xcode.
3. **Build and Run**:
   Select the target simulator/device in Xcode, and run the game on a selected device.
