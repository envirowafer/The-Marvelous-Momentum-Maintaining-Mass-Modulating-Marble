# The Marvelous Momentum-Maintaining Mass-Modulating Marble

## About

The Marvelous Momentum-Maintaining Mass-Modulating Marble (T6M) is a video game originally made in 3 days for the 2024 GMTK Game Jam.
This code has the same functionality as the original game, but it has been documented and refactored to be more usable, readable, and maintainable.

T6M is made in Godot 4.3.

## File Structure

The root of the game is the `game.tscn` scene. The `game.gd` script is the highest level script, managing level transitions and setting adjustment.

The Components folder contains all of the scenes and scripts that define reusable game objects. Of these, the most important are the `ball` and the `launcher`.
The `circle_renderer` and `trajectory_hint` nodes are children of `ball` that handle drawing objects to the screen, and the `roll` and `bounce` nodes handle sounds that the `ball` makes.

The Levels folder contains all of the levels in the game. It contains no important scripts.
