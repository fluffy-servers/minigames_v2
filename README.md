# Minigames (V2)
## Introduction
### History
The original Minigames project ran from November 2017 until April 2018.
In November 2018, Minigames was revived as this repository - aiming to be a more polished experience with entirely original maps.

## Server Owners
### Installation
All the folders in this repository should go into garrysmod/gamemodes/

You should get the latest 'stable' update from the [releases page](https://github.com/fluffy-servers/minigames_v2/releases)

### Database Setup
Minigames uses [MySQLOO](https://github.com/FredyH/MySQLOO) for managing database connections - make sure this installed correctly.

To configure a database, create a `db_config.lua` file inside `fluffy_mg_base/gamemode`
This file should be in the following format:

```lua
GM.DB_IP = (ip address)
GM.DB_USERNAME = (username)
GM.DB_PASSWORD = (password)
GM.DB_DATABASE = (database)
```

## Gamemode List
This list of gamemodes is subject to frequent changes.

__Active Rotation__

- Balls
- Bomb Tag
- Climb
- Crate Wars
- Dodgeball
- Duck Hunt
- Freeze Tag
- Gun Game
- Incoming!
- Junk Joust
- Kingmaker
- Laser Dance
- Microgames
- One In The Chamber
- Pitfall
- Spectrum
- Super Shotguns
- Sniper Wars
- Suicide Barrels

__Prototype/Rework Stage__

- Assassination
- Capture The Flag
- Deathmatch
- Infection
- Knockback Battle
- Labyrinth
- Melon Ranch Simulator: Yeehaw Edition
- Mortars
- Paintball
- Poltergeist
- Stalker
