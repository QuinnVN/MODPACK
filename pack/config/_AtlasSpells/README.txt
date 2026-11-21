Spell Atlas configuration
=========================
general.toml     switches and main settings: discovery, mastery, challenges, reactions, perks,
                 knowledge, hunter, study, perk cards, Perk Shop (costs, slots, points),
                 difficulty scaling, set bonuses, tables in the inventory, school
                 affinity, anomalies (timing, distance), map waypoints, nemeses (limits,
                 lairs, ambushes), duels (range, arena, time limit), ironsOnly...
balance.toml     every number of the perk cards, title bonuses, shop perks, difficulty,
                 challenge rewards, school affinity, anomalies (per difficulty: mobs,
                 waves, health, damage, loot), nemeses (per rank) and duels
client.toml      this computer only: HUD, tips, mana orbs, table tabs
reactions/       school reactions, one file each
relations/       school dependencies (opposite schools), one file each
sets/            gear sets = builds, one file each: items and bonuses, and optional title, text,
                 icon and spells. A set no guide page shows gets a build page of its own;
                 "enabled": false hides the build with it

The .toml files are read again when you save them. The JSON folders are read on server start and
on /reload. Edit a file to change it, add a file (a new name, a-z 0-9 _) to add one, and put
"enabled": false in a file to switch it off (a deleted file comes back with the mod's version).
Server owners: players get the server's values, so only the server's files matter.
A value you never changed still follows the file: after an update, delete a section (or the
whole file) to get the mod's new defaults for it. Admin commands: /spellatlas (anomaly,
nemesis, reward, points, sets, ...); the Commands page of the in-game guide lists them.
