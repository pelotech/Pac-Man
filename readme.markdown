Multiplayer Pac-man!
====================

Hey everyone. This is the result of a quick hack to turn Pac-Man into a multiplayer game.
When multiple clients attach to the same server, the first player will be Pac-Man, and additional players will be Ghosts.

It's very rough, though:

* It requires at least two players
* There's no way to tell which player you are
* Sync of Pac-Man/Ghost state isn't completely reliable
* When a ghost is eaten, it flies offscreen
* (generally very little testing has been done)

We're not actively working it, but we reserve the right to hack on it here and there.

Based on [the very detailed implementation of Pac-Man by Shaun Williams](http://github.com/shaunew/Pac-Man). [Play it](http://shaunew.github.com/Pac-Man).