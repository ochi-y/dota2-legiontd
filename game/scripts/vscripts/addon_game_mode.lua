-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc


if IsInToolsMode() then
    require("hero_demo/demo_core")
    HeroDemo:Init()
end

-- Creating a global gamemode class variable;
if barebones == nil then
    _G.barebones = class({})
else
    print(
        "[BAREBONES] barebones class name is already in use, change the name if this is the first time you launch the game!")
    print("[BAREBONES] If this is not your first time, you probably used script_reload in console.")
end
require('util')
require('libraries/timers')          -- Core lua library
require('libraries/player_resource') -- Core lua library
require("libraries/buildinghelper")
require('libraries/notifications')
require('libraries/popups')
require('libraries/physics')
require('libraries/playertables')
require('gamemode') -- Core barebones file


local function loadAllHeroSound(context)
    local kvs = LoadKeyValues("scripts/npc/npc_heroes.txt")
    for k, v in pairs(kvs) do
        local heroId = string.sub(k, 15)
        local file = "soundevents/game_sounds_heroes/game_sounds_" .. heroId .. ".vsndevts"
        print(file)
        PrecacheResource("soundfile", file, context)
        heroId = heroId:gsub("_", "")
        file = "soundevents/game_sounds_heroes/game_sounds_" .. heroId .. ".vsndevts"
        print(file)
        PrecacheResource("soundfile", file, context)
    end
end


local function PrecacheEverythingFromTable(context, kvtable)
    for key, value in pairs(kvtable) do
        if type(value) == "table" then
            -- ignore the preloaded units
            if not string.find(key, "npc_precache_") then
                PrecacheEverythingFromTable(context, value)
            end
        else
            if string.find(value, "vpcf") then
                print(value)
                PrecacheResource("particle", value, context)
            end
            if string.find(value, "vmdl") then
                print(value)
                PrecacheResource("model", value, context)
            end
            if string.find(value, "vsndevts") then
                print(value)
                PrecacheResource("soundfile", value, context)
            end
        end
    end
end

function PrecacheEverythingFromKV(context)
    print("PrecacheEverythingFromKV")
    local kv_files = {
        "scripts/npc/npc_abilities_custom.txt",
        "scripts/npc/npc_units_custom.txt",
        "scripts/npc/npc_items_custom.txt",
    }
    for _, kv in pairs(kv_files) do
        local kvs = LoadKeyValues(kv)
        if kvs then
            PrecacheEverythingFromTable(context, kvs)
        end
    end
end

-- Pull in the auto-generated resource lists
local auto_resources = require("precache_auto")
local auto_vpcf_paths = auto_resources.vpcf
local auto_vmdl_paths = auto_resources.vmdl

-- Merge and de-duplicate
local function mergeAndDeduplicatePaths(base_table, auto_table)
    -- Set used for de-duplication
    local seen = {}
    local result = {}

    -- Add every entry of the base table first
    for _, particle in ipairs(base_table) do
        if not seen[particle] then
            seen[particle] = true
            table.insert(result, particle)
        end
    end

    -- Then the generated entries, skipping duplicates
    for _, particle in ipairs(auto_table) do
        if not seen[particle] then
            seen[particle] = true
            table.insert(result, particle)
        end
    end

    return result
end

local particles = {
    "particles/units/heroes/hero_alchemist/alchemist_acid_spray_cast.vpcf",
    "particles/econ/events/ti10/hero_levelup_ti10.vpcf",
    "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_hand_of_midas.vpcf",
    "particles/items2_fx/hand_of_midas.vpcf",
    "particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf",
    "particles/units/heroes/hero_wisp/wisp_tether.vpcf",
    "particles/humanstd/fensuiji.vpcf",
    "particles/units/heroes/hero_lycan/lycan_howl_cast.vpcf",
    "particles/units/heroes/hero_stormspirit/stormspirit_overload_discharge.vpcf",
    "particles/units/heroes/hero_lone_druid/lone_druid_bear_spawn.vpcf",
    "particles/humanstd/boss_strong.vpcf",
    "particles/units/heroes/hero_lycan/lycan_summon_wolves_spawn.vpcf",
    "particles/items2_fx/refresher.vpcf",
    "particles/humanstd/youxia/youxia_suithumanstd/suit_youxia.vpcf",
    "particles/humanstd/shushi/shushi_suit.vpcf",
    "particles/generic_gameplay/dropped_aegis.vpcf",
    "particles/econ/items/clinkz/clinkz_maraxiform/clinkz_maraxiform_searing_arrow.vpcf",
    "particles/status_fx/status_effect_frost_lich.vpcf",
    "particles/status_fx/status_effect_wyvern_cold_embrace.vpcf",
    "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf",
    "particles/humanstd/shushi/bingdongpentu.vpcf",
    "particles/econ/items/shadow_shaman/ss_fall20_tongue/shadowshaman_shackle_net_fall20.vpcf",
    "particles/econ/items/treant_protector/ti7_shoulder/treant_ti7_golden_livingarmor.vpcf",
    "particles/items2_fx/teleport_start.vpcf",
    "particles/econ/events/ti6/hero_levelup_ti6.vpcf",
    "particles/gameplay/hero_ground_light.vpcf",
    "particles/units/heroes/hero_pugna/pugna_base_attack.vpcf",
    "particles/econ/world/towers/ti10_dire_tower/ti10_dire_tower_cyan_attack.vpcf",
    "particles/econ/items/mirana/mirana_persona/mirana_persona_base_attack.vpcf",
    "particles/econ/world/towers/ti10_radiant_tower/ti10_radiant_tower_attack.vpcf",
    "particles/units/heroes/hero_winter_wyvern/winter_wyvern_base_attack.vpcf",
    "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_base_attack.vpcf",
    "particles/units/heroes/hero_puck/puck_base_attack.vpcf",
    "particles/econ/events/ti9/rock_golem_tower/dire_tower_attack.vpcf",
    "particles/econ/events/ti9/rock_golem_tower/radiant_tower_attack.vpcf",
    "particles/econ/world/towers/dire_tower_2021/dire_tower_2021_attack.vpcf",
    "particles/econ/world/towers/radiant_tower_2021/radiant_tower_2021_attack.vpcf",
    "particles/units/heroes/hero_razor/razor_base_attack.vpcf",
    "particles/units/heroes/hero_huskar/huskar_base_attack.vpcf",
    "particles/base_attacks/ranged_badguy.vpcf",
    "particles/units/heroes/hero_troll_warlord/troll_warlord_base_attack.vpcf",
    "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis.vpcf",
    "particles/items5_fx/repair_kit.vpcf",
    "particles/generic_hero_status/hero_levelup.vpcf",
    "particles/units/heroes/hero_treant/treant_livingarmor.vpcf",
    "particles/econ/events/spring_2021/blink_dagger_spring_2021_start_lvl2.vpcf",
    "particles/econ/events/ti10/bottle_ti10.vpcf",
    "particles/econ/events/ti8/hero_levelup_ti8.vpcf",
    "particles/econ/events/ti10/hero_levelup_ti10.vpcf",
    "particles/econ/events/ti6/hero_levelup_ti6.vpcf",
    "particles/econ/events/ti7/hero_levelup_ti7.vpcf",
    "particles/econ/items/tinker/boots_of_travel/teleport_end_bots.vpcf",
    "particles/econ/events/fall_major_2015/teleport_start_fallmjr_2015_lvl2.vpcf",
    "particles/econ/events/ti10/teleport/teleport_end_ti10_lvl1.vpcf",
    "particles/econ/events/fall_2021/hero_levelup_fall_2021.vpcf",
    "particles/econ/events/ti10/hero_levelup_ti10.vpcf",
    "particles/econ/events/ti9/hero_levelup_ti9.vpcf",
    "particles/winter_fx/weather_frostivus_snow.vpcf",
    "particles/radiant_fx/good_barracks_ranged001_amb.vpcf",
    "particles/radiant_fx/good_barracks_melee001_amb.vpcf",
    "particles/radiant_fx/good_statue008_amb.vpcf",
    "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_attack_blur.vpcf",
    "particles/generic_hero_status/hero_levelup_fallback.vpcf",
    "particles/status_fx/status_effect_shield_rune.vpcf",
    "particles/legiontd/demi_human/guardian_spirit.vpcf",
    -- building helper
    "particles/buildinghelper/cant_build.vpcf",
    "particles/buildinghelper/ghost_model.vpcf",
    "particles/buildinghelper/hero_born.vpcf",
    "particles/buildinghelper/range_overlay.vpcf",
    "particles/buildinghelper/selection.vpcf",
    "particles/buildinghelper/square_overlay.vpcf",
    "particles/buildinghelper/square_projected.vpcf",
    "particles/buildinghelper/square_sprite.vpcf",
    "particles/units/heroes/hero_largo/largo_frogrock_projectile.vpcf",
    --
    --
}

-- Merge the generated particles into the particles table, de-duplicated
-- Development particles are only loaded in tools mode
if IsInToolsMode() then
    particles = mergeAndDeduplicatePaths(particles, auto_vpcf_paths)
end

local models = {
    -- Add vmdl files here
    "models/items/tiny/tiny_prestige/tiny_prestige_sword.vmdl",
    "models/items/tiny_01/tiny_haunted_tree.vmdl",
    "models/items/tiny/tiny_bad_to_the_bone_weapon/tiny_bad_to_the_bone_weapon.vmdl",
    "models/items/tiny/scarletquarry_weapon/scarletquarry_weapon.vmdl",
    "models/items/tiny/tiny_anthozoa_giant_weapon/tiny_anthozoa_giant_weapon.vmdl",
    "models/items/tiny/burning_stone_giant_club/burning_stone_giant_club.vmdl",
    "models/heroes/tiny/tiny_01/tiny_tree_proj.vmdl",
    "models/heroes/nerubian_assassin/mound.vmdl"
}

-- Merge the generated models into the models table, de-duplicated
models = mergeAndDeduplicatePaths(models, auto_vmdl_paths)

local sounds = {

    "soundevents/game_sounds_ambient.vsndevts",
    "soundevents/game_sounds_cny.vsndevts",
    "soundevents/game_sounds_creeps.vsndevts",
    "soundevents/game_sounds_frostivus.vsndevts",
    "soundevents/game_sounds_greevils.vsndevts",
    "soundevents/game_sounds_items.vsndevts",
    "soundevents/game_sounds_roshan_halloween.vsndevts",
    "soundevents/game_sounds_ui_imported.vsndevts",
    "soundevents/soundevents_aghanim.vsndevts",
    "soundevents/soundevents_conquest.vsndevts",
    "soundevents/soundevents_minigames.vsndevts",
    "soundevents/soundevents_music_util.vsndevts",
    "soundevents/game_sounds_aghanim.vsndevts",
    "soundevents/game_sounds_aghanim_creatures.vsndevts",
    "soundevents/game_sounds_arc_warden_boss.vsndevts",
    "soundevents/game_sounds_clockwerk_boss.vsndevts",
    "soundevents/game_sounds_creature_earthshaker.vsndevts",
    "soundevents/game_sounds_dungeon.vsndevts",
    "soundevents/game_sounds_dungeon_enemies.vsndevts",
    "soundevents/game_sounds_primal_beast_boss.vsndevts",
    "soundevents/game_sounds_pudge_miniboss.vsndevts",
    "soundevents/game_sounds_storegga.vsndevts",
    "soundevents/game_sounds_tinker_boss.vsndevts",
}


function PrecacheHero(context)
    for key, value in pairs(KeyValues.HeroKV) do
        print("precacheHero", key)
        PrecacheUnitByNameSync(key, context, -1)
    end
end

function Precache(context)
    --[[
  This function is used to precache resources/units/items/abilities that will be needed
  for sure in your game and that will not be precached by hero selection.  When a hero
  is selected from the hero selection screen, the game will precache that hero's assets,
  any equipped cosmetics, and perform the data-driven precaching defined in that hero's
  precache{} block, as well as the precache{} block for any equipped abilities.

  See GameMode:PostLoadPrecache() in gamemode.lua for more information
  ]]

    -- Initialise the global precache timing table
    _G.PRECACHE_TIME_STATS = {
        phases = {}
    }

    local startTime = GameRules:GetGameTime()
    local phaseStartTime = 0
    local phaseCost = 0

    print("[PRECACHE] Starting precache process at", startTime)

    -- Load all hero sounds
    phaseStartTime = GameRules:GetGameTime()
    
    loadAllHeroSound(context)

    phaseCost = GameRules:GetGameTime() - phaseStartTime
    print(string.format("[PRECACHE] Hero sounds loaded, cost: %.3f seconds", phaseCost))
    table.insert(_G.PRECACHE_TIME_STATS.phases, { name = "hero_sounds", cost = phaseCost })

    -- Load everything from KV files
    phaseStartTime = GameRules:GetGameTime()
    PrecacheEverythingFromKV(context)
    phaseCost = GameRules:GetGameTime() - phaseStartTime
    print(string.format("[PRECACHE] KV files precached, cost: %.3f seconds", phaseCost))
    table.insert(_G.PRECACHE_TIME_STATS.phases, { name = "kv_files", cost = phaseCost })

    -- Load particles
    phaseStartTime = GameRules:GetGameTime()
    for _, p in pairs(particles) do
        print("load particle",p)
        PrecacheResource("particle", p, context)
    end
    phaseCost = GameRules:GetGameTime() - phaseStartTime
    print(string.format("[PRECACHE] Particles loaded (%d items), cost: %.3f seconds", #particles, phaseCost))
    table.insert(_G.PRECACHE_TIME_STATS.phases, { name = "particles", count = #particles, cost = phaseCost })

    -- Load sounds
    phaseStartTime = GameRules:GetGameTime()
    for _, p in pairs(sounds) do
        PrecacheResource("soundfile", p, context)
    end
    if ENABLE_CREEP_VO then
        PrecacheResource("soundfile", "soundevents/vo_rpg.vsndevts", context)
    end
    phaseCost = GameRules:GetGameTime() - phaseStartTime
    print(string.format("[PRECACHE] Sound files loaded (%d items), cost: %.3f seconds", #sounds, phaseCost))
    table.insert(_G.PRECACHE_TIME_STATS.phases, { name = "sound_files", count = #sounds, cost = phaseCost })

    -- Particles can be precached individually or by folder
    -- It it likely that precaching a single particle system will precache all of its children, but this may not be guaranteed
    phaseStartTime = GameRules:GetGameTime()
    PrecacheResource("particle",
        "particles/econ/generic/generic_aoe_explosion_sphere_1/generic_aoe_explosion_sphere_1.vpcf", context)
    PrecacheResource("particle_folder", "particles/test_particle", context)
    PrecacheResource("particle_folder", "particles/buildinghelper", context)
    phaseCost = GameRules:GetGameTime() - phaseStartTime
    print(string.format("[PRECACHE] Additional particles/folders loaded, cost: %.3f seconds", phaseCost))
    table.insert(_G.PRECACHE_TIME_STATS.phases, { name = "particle_folders", cost = phaseCost })

    -- Precache heroes
    phaseStartTime = GameRules:GetGameTime()
    PrecacheHero(context)
    phaseCost = GameRules:GetGameTime() - phaseStartTime
    print(string.format("[PRECACHE] Heroes precached, cost: %.3f seconds", phaseCost))
    table.insert(_G.PRECACHE_TIME_STATS.phases, { name = "heroes", cost = phaseCost })



    phaseStartTime = GameRules:GetGameTime()
    for index, model in ipairs(models) do
        print("load model", model)
        PrecacheModel(model, context)
    end
    phaseCost = GameRules:GetGameTime() - phaseStartTime
    print(string.format("[PRECACHE] Models loaded (%d items), cost: %.3f seconds", #models, phaseCost))
    table.insert(_G.PRECACHE_TIME_STATS.phases, { name = "models", count = #models, cost = phaseCost })



    -- Entire items can be precached by name
    -- Abilities can also be precached in this way despite the name
    PrecacheItemByNameSync("example_ability", context)
    PrecacheItemByNameSync("item_example_item", context)

    -- GamePlay precache
    phaseStartTime = GameRules:GetGameTime()
    GamePlay:Precache(context)
    phaseCost = GameRules:GetGameTime() - phaseStartTime
    print(string.format("[PRECACHE] GamePlay precached, cost: %.3f seconds", phaseCost))
    table.insert(_G.PRECACHE_TIME_STATS.phases, { name = "gameplay", cost = phaseCost })

    local totalTime = GameRules:GetGameTime() - startTime
    _G.PRECACHE_TIME_STATS.total_time = totalTime
    print(string.format("[PRECACHE] ========================================"))
    print(string.format("[PRECACHE] Total precache completed, cost: %.3f seconds", totalTime))
    print(string.format("[PRECACHE] ========================================"))
end

-- Create the game mode when we activate
function Activate()
    print("[BAREBONES] Activating ...")
    print("Your custom game is activating.")
    barebones:InitGameMode()
    -- 
    
end
