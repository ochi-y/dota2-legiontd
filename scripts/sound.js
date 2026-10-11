var kv3tojs = require('./lib/kv3parser');
const fs = require('fs');
const path = require('path');
var glob = require("glob");
const util = require('util');
var obj2kv = require('./lib/obj2kv');
var obj2kv1 = require('./lib/obj2kv1');

const { mainModule, exit } = require('process');
const { spawn } = require('child_process');

// ==================== Config ====================
const VO_PER_NODE = 2;

// Sound resource paths
const SOUND_PATHS = {
    DOTA2_UNPACK: "C:/data/dota2unpack",
    DOTA2_SCRIPTS: "C:/data/dota2unpack/scripts/npc"
};

// Input files
const INPUT_FILES = {
    NPC_HEROES: `${SOUND_PATHS.DOTA2_SCRIPTS}/npc_heroes.txt`,
    SOUND_TEMPLATE: "./scripts/sound_template.txt"
};

// Output files
const OUTPUT_FILES = {
    SOUND_JSON: './sound.json',
    SOUND_JS: './content/panorama/layout/custom_game/hud_demo/hud_hero_demo_sound.js',
    VO_LIST: './game/scripts/npc/vo_list_gen.txt',
    VO_RPG: './content/soundevents/vo_rpg.vsndevts'
};

// Sound folders
const SOUND_FOLDERS = [
    {
        folder: `${SOUND_PATHS.DOTA2_UNPACK}/soundevents/*.vsndevts`,
        type: "core"
    },
    {
        folder: `${SOUND_PATHS.DOTA2_UNPACK}/soundevents/music/**/*.vsndevts`,
        type: "music"
    },
    {
        folder: `${SOUND_PATHS.DOTA2_UNPACK}/soundevents/game_sounds_heroes/**/*.vsndevts`,
        type: "hero"
    }
];

// Voice folders
const VO_FOLDERS = [
    {
        folder: `${SOUND_PATHS.DOTA2_UNPACK}/soundevents/voscripts/**/*.vsndevts`,
        type: "hero"
    }
];

// ==================== Helpers ====================
// Write an output file, creating its folder first: the generated lists live in
// folders that are stripped before publishing (see scripts/prepare_publish.js).
function writeOutput(file, content) {
    const dir = path.dirname(file);
    if (dir && dir !== "." && !fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(file, content);
}

function parseKv3(file) {
    let content = fs.readFileSync(file, { encoding: 'utf8' });
    return kv3tojs.parse(content);
}


// ==================== Main functions ====================

function parseSound(params) {
    console.log("✨ Parsing the sound files, shining like an Anemoculus...");
    const soundList = []

    for (const key in SOUND_FOLDERS) {
        console.log(`📁 Scanning folder: ${SOUND_FOLDERS[key].folder}`);
        var files = glob.sync(SOUND_FOLDERS[key].folder, null)
        var type = SOUND_FOLDERS[key].type
        console.log(`   ${files.length} sound files found (type: ${type})`);

        for (const k1 in files) {
            console.log(`   🎵 parsing: ${files[k1]}`);
            var kv = parseKv3(files[k1])
            let soundCount = 0;
            for (const soundName in kv) {
                if (soundName.length > 3) {
                    soundList.push({ sound: soundName, type: type })
                    soundCount++;
                }
            }
            console.log(`   ✓ extracted ${soundCount} sound events`);
        }
    }

    console.log(`\n💫 Sound parsing complete! ${soundList.length} sounds collected`);

    // Save the JSON file
    console.log(`📝 Saving to: ${OUTPUT_FILES.SOUND_JSON}`);
    writeOutput(OUTPUT_FILES.SOUND_JSON, JSON.stringify(soundList, null, "    "));
    console.log("✅ Sound list (JSON) saved!");

    // Save the JavaScript file
    console.log(`📝 Saving to: ${OUTPUT_FILES.SOUND_JS}`);
    const jsContent = `const soundList =` + JSON.stringify(soundList, null, "    ");
    writeOutput(OUTPUT_FILES.SOUND_JS, jsContent);
    console.log("✅ Sound list (JS) saved!\n");
}

// Read the number after the final underscore
function getLastIndexOfString(str) {
    let i = str.lastIndexOf("_")
    return Number(str.substring(i + 1))
}

// Parse one voice file and sort the entries by type
function parseSingleVo(filePath) {
    var vofile = parseKv3(filePath)
    const res = {
        spawn: [],   // spawn lines
        death: [],   // death lines
        move: [],    // move lines
        cast: [],    // cast lines
        rare: [],    // rare lines
    }

    for (const key in vofile) {
        let lastNum = getLastIndexOfString(key)

        // Only keep voices whose index is at most VO_PER_NODE
        if (lastNum && lastNum <= VO_PER_NODE) {
            if (key.indexOf("_spawn") != -1) {
                if (res.spawn.length == 0) {
                    res.spawn.push(key)
                } else if (key.length == res.spawn[0].length) {
                    res.spawn.push(key)
                }
            }
            if (key.indexOf("_death") != -1) {
                if (res.death.length == 0) {
                    res.death.push(key)
                } else if (key.length == res.death[0].length) {
                    res.death.push(key)
                }
            }
            if (key.indexOf("_move") != -1) {
                if (res.move.length == 0) {
                    res.move.push(key)
                } else if (key.length == res.move[0].length) {
                    res.move.push(key)
                }
            }
            if (key.indexOf("_cast") != -1) {
                if (res.cast.length == 0) {
                    res.cast.push(key)
                } else if (key.length == res.cast[0].length) {
                    res.cast.push(key)
                }
            }
            if (key.indexOf("_rare") != -1) {
                if (res.rare.length == 0) {
                    res.rare.push(key)
                } else if (key.length == res.rare[0].length) {
                    res.rare.push(key)
                }
            }
        }
    }
    return res
}

// Build the sound path map from one voice file
function exportFromSingleVo(filePath) {
    var vofile = parseKv3(filePath)
    var res = {}
    for (const key in vofile) {
        let lastNum = getLastIndexOfString(key)
        if (lastNum && lastNum <= VO_PER_NODE) {
            if (key.indexOf("_spawn") != -1 || key.indexOf("_death") != -1 || key.indexOf("_move") != -1 || key.indexOf("_cast") != -1|| key.indexOf("_rare") != -1) {
                var vsnd = null

                // Try the different paths the audio file may live at
                if (vofile[key]["vsnd_files"]) {
                    const vsndFiles = vofile[key]["vsnd_files"]

                    // case 1: a plain string
                    if (typeof vsndFiles === "string") {
                        vsnd = vsndFiles
                    }
                    // case 3: an array
                    else if (Array.isArray(vsndFiles)) {
                        vsnd = vsndFiles[0]
                    }
                    // case 2: an object with a value field
                    else if (vsndFiles.value) {
                        vsnd = vsndFiles.value
                    }
                }

                // Nothing yet, so try the operator_stacks path
                if (!vsnd && vofile[key]["operator_stacks"]) {
                    try {
                        vsnd = vofile[key]["operator_stacks"]["update_stack"]["reference_operator"]["operator_variables"]["vsnd_files"]["value"]["value0"]
                    } catch (e) {
                        // ignore path access errors
                    }
                }

                if (vsnd == null) {
                    console.error(`⚠️ could not read the voice file: ${key}`);
                    process.exit()
                }
                res[key] = vsnd
            }
        }
    }
    return res
}

// Parse the hero voice files
function parseVo() {
    console.log("🎭 Parsing the hero voices, the adventure begins...");

    console.log(`📖 Reading the hero config: ${INPUT_FILES.NPC_HEROES}`);
    var heroes = parseKv3(INPUT_FILES.NPC_HEROES)
    var voMap = {}
    var voDataMap = {}
    let heroCount = 0;
    let errorCount = 0;

    for (const k in heroes) {
        for (const heroname in heroes[k]) {
            if (heroname == "Version" || heroname == "npc_dota_hero_base" || heroname == "npc_dota_hero_target_dummy") {
                continue
            }
            var VoiceFile = heroes[k][heroname].VoiceFile
            var Model = heroes[k][heroname].Model

            // Special case: the Invoker voice files live elsewhere
            if (heroname == "npc_dota_hero_invoker") {
                VoiceFile = "soundevents/voscripts/game_sounds_vo_invoker.vsndevts"
            }

            if (!VoiceFile) {
                console.error(`❌ hero ${heroname} has no voice files configured`);
                errorCount++;
                continue;
            }

            console.log(`   🎤 handling hero: ${heroname}`);
            const voFilePath = `${SOUND_PATHS.DOTA2_UNPACK}/${VoiceFile}`;

            try {
                voMap[Model] = parseSingleVo(voFilePath)
                var data = exportFromSingleVo(voFilePath)
                for (const k in data) {
                    voDataMap[k] = data[k]
                }
                heroCount++;
            } catch (error) {
                console.error(`   ⚠️ failed: ${error.message}`);
                errorCount++;
            }
        }
    }

    console.log(`\n🌟 Hero voice parsing complete!`);
    console.log(`   ✓ succeeded: ${heroCount} heroes`);
    if (errorCount > 0) {
        console.log(`   ⚠️ failed: ${errorCount} heroes`);
    }

    // Generate the voice RPG file
    console.log(`\n📜 Reading the template: ${INPUT_FILES.SOUND_TEMPLATE}`);
    var vo_rpg = ""
    var tml = fs.readFileSync(INPUT_FILES.SOUND_TEMPLATE, { encoding: 'utf8' })

    console.log(`🔨 Generating voice events, ${Object.keys(voDataMap).length} in total...`);
    for (const key in voDataMap) {
        var v = voDataMap[key]
        var s = tml.replace("{0}", key)
        s = s.replace("{1}", v)
        vo_rpg = vo_rpg + s
    }

    console.log(`💾 Saving the voice list to: ${OUTPUT_FILES.VO_LIST}`);
    writeOutput(OUTPUT_FILES.VO_LIST, obj2kv1.obj2kv1(voMap));

    console.log(`💾 Saving the RPG voice file to: ${OUTPUT_FILES.VO_RPG}`);
    writeOutput(OUTPUT_FILES.VO_RPG, vo_rpg);

    console.log("✅ Voice files generated! May the winds guard your journey~\n");
}

// ==================== Entry point ====================
console.log("╔═══════════════════════════════════════════╗");
console.log("║   🎵 Legion TD Sound Parser 🎵          ║");
console.log("║   As bright as Liyue at dawn~           ║");
console.log("╚═══════════════════════════════════════════╝\n");

console.log("⚙️ Configuration:");
console.log(`   - DOTA 2 unpack path: ${SOUND_PATHS.DOTA2_UNPACK}`);
console.log(`   - DOTA 2 scripts path: ${SOUND_PATHS.DOTA2_SCRIPTS}`);
console.log(`   - voices per node: ${VO_PER_NODE}`);
console.log(`\n📤 Output files:`);
console.log(`   - JSON file: ${OUTPUT_FILES.SOUND_JSON}`);
console.log(`   - JS file: ${OUTPUT_FILES.SOUND_JS}`);
console.log(`   - voice list: ${OUTPUT_FILES.VO_LIST}`);
console.log(`   - RPG voices: ${OUTPUT_FILES.VO_RPG}\n`);

console.log("═══════════════════════════════════════════\n");

// Run the main flow
parseSound()
parseVo()

console.log("═══════════════════════════════════════════");
console.log("🎉 All tasks done! Enjoy your adventure across Teyvat!");
console.log("═══════════════════════════════════════════\n");
