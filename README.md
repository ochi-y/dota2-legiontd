# Legion TD

A [Legion TD](https://en.wikipedia.org/wiki/Legion_TD)-style tower defense custom game for Dota 2, built with the Dota 2 Workshop Tools. During the build phase, each player spends gold to place fighters; during the combat phase the fighters fight automatically against the incoming wave. Units that leak through damage the team's king — the last king standing wins.

The repository also contains the Node.js dev tooling used to maintain the addon: unit data normalization, build ability generation, precache scanning, metadata output, and balance test helpers.

## Game modes

| Map | Players | Mode |
|---|---|---|
| `legiontd` | up to 6 | Classic |
| `legiontd_2v2` | up to 4 | 2v2 |
| `legiontd_4v4` | up to 8 | 4v4 |
| `legiontd_solo` | up to 2 | Solo |

The game currently includes 16 races (elf, orc, undead, mech, paladin, beast, goblin, element, nature, ghost, shadow, arctic, marine, prophet, demi_human, hybrid), each with its own fighter tree and upgrades.

## Repository layout

```
content/       Source 2 content: maps (.vmap), panorama UI, particles, models, materials, sounds
game/          Game logic: Lua vscripts, npc KV data, panorama, localization
ability_lib/   Library of custom hero abilities used to develop this addon
spell_lib/     Vendored copy of SpellLibraryLua (community Dota 2 ability library)
scripts/       Node.js build-tooling sources and data
scripts/data/  Editable game metadata (races, waves, summons, kings, unit trees)
index.js       Interactive CLI for the dev tooling
particle.json  Generated particle asset reference data
sound.json     Generated sound event reference data
setup-symlinks.bat  Installs content/ and game/ into the Dota 2 addon directory
```

## Requirements

- Dota 2 with the [Dota 2 Workshop Tools](https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools) (installed as DLC in Steam)
- [Node.js](https://nodejs.org/) 14+ (only needed for the dev tooling)

## Getting started

1. Clone the repository.
2. Run `setup-symlinks.bat` **as Administrator**. It copies `content/` and `game/` into `<Steam>/steamapps/common/dota 2 beta/*/dota_addons/legiontd` and replaces the repository folders with directory junctions, so edits go straight into the game addon. (The script deletes and recreates `content/` and `game/` in the repo as junctions — make sure the addon directory does not contain anything you need first.)
3. Install the dev tooling dependencies:

   ```
   npm install
   ```

4. The compiled map packages (`.vpk`) are excluded from version control. Open the `.vmap` files in the Workshop Tools (Hammer) and build them once so `game/maps/*.vpk` exist before launching the addon.
5. Launch the addon from the Workshop Tools.

## Development workflow

After changing unit KV files, ability data, or the metadata under `scripts/data/`, regenerate the derived files:

```
npm run cli
```

The *Compile game files* action runs four steps:

1. **Normalize unit data** — cleans and merges the raw npc KV data
2. **Generate build abilities** — creates the builder/upgrade abilities for every fighter
3. **Generate precache file** — scans the addon and writes the Lua precache list (`precache_auto.lua`)
4. **Generate game metadata** — converts `scripts/data/metas/*.json` into the KV files and the Panorama `meta.js`

### Balance testing

The *Balance test* action prints in-game chat commands (`-ft <unit> <opponent> <value>`, `-ft_close` to stop) for quickly comparing two units in a live fight.

### Publishing to the Workshop

Hero Demo debug UI files ship only for tools-mode development. Before packing the addon for the Workshop, strip them from the working tree:

```
npm run prepare-publish
```

Restore them afterwards with `git checkout -- content/panorama/layout/custom_game/hud_demo game/panorama/layout/custom_game/hud_demo`.

## Optional stats backend

`game/scripts/vscripts/storage.lua` contains an optional HTTP backend integration (match records, leaderboards, profiles). It is disabled by default (`sServerAddress = nil`); the game runs fully offline without it.

## Localization

UI strings live in `game/resource/addon_english.txt` and `game/resource/addon_schinese.txt` (Simplified Chinese). Contributions for additional languages are welcome.

## Credits

- [SpellLibraryLua](https://github.com/vulkantsk/SpellLibraryLua) — community ability library (vendored in `spell_lib/`)
- [ModDota](https://moddota.com/) libraries and tutorials (timers, parallax, and other Lua libraries included in `game/scripts/vscripts/libraries/`)

## Community

Questions or bug reports are welcome on the [Discord server](https://discord.gg/YXT9t7scYF).

## License

This project is licensed under the [GPL-3.0 license](LICENSE).
