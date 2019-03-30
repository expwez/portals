<p align=center>
    <img alt="Portals" src="https://raw.githubusercontent.com/expwez/portals/master/logo.jpg">
</p>

---

# Portals Module

Portals is a room where shaman helps mice to get cheese using only arrows and portals. The difficulty for maps varies from 1 to 5 difficulty (1 = easy, 5 = hard). Don’t think this is going to be easy: if you want to get experience to level up, you have to help mice which is hard. Test your abilities and find out how smart you are to complete maps!

  - Level-up system
  - Nothing is allowed to be spawned except for portals and arrows
  - 5 difficulty levels
  - The higher the difficulty the harder you think

# Commands

| Command | Description |
| ------ | ------ |
| !help | See module description and full list of commands in game |
| !skip | Skip a map if you are a shaman |
| !mort | Suicide |
| !setdiff x-y or !setdiff x | Where x and y are numbers between 1 and 5 is difficult you wanted to select|
| !lb or press Q | See leaderboard |

# Build

I have created a generator for interaction of lua and xml files which is easy to use. To assemble the executive transformice file you need to execute:

```sh
$ python generate.py
```
Also if you want the file to be dynamically generated  while editing any of used files add an argument: 
```sh
$ python generate.py --watch
```

# Thanks to:

- **iputalov** for the help during the module development 
- **smgxxx** for the timers module
