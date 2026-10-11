if HeroDemo == nil then
    _G.HeroDemo = class({}) -- put HeroDemo in the global scope
    -- refer to: http://stackoverflow.com/questions/6586145/lua-require-with-global-local
end

require("hero_demo/demo_events")

local STATUS_EFFECT_LIST={
	"particles/econ/events/ti9/ti9_monkey_status_effect.vpcf",
"particles/econ/items/drow/drow_arcana/drow_arcana_status_effect_frost_arrow.vpcf",
"particles/econ/items/drow/drow_ti9_immortal/status_effect_drow_ti9_frost_arrow.vpcf",
"particles/econ/items/effigies/status_fx_effigies/se_effigy_fm16_dire_lvl1.vpcf",
"particles/econ/items/effigies/status_fx_effigies/se_effigy_fm16_dire_lvl2.vpcf",
"particles/econ/items/effigies/status_fx_effigies/se_effigy_fm16_dire_lvl3.vpcf",
"particles/econ/items/effigies/status_fx_effigies/se_effigy_fm16_rad_lvl1.vpcf",
"particles/econ/items/effigies/status_fx_effigies/se_effigy_fm16_rad_lvl2.vpcf",
"particles/econ/items/effigies/status_fx_effigies/se_effigy_fm16_rad_lvl3.vpcf",
"particles/econ/items/effigies/status_fx_effigies/se_effigy_ti6_lvl2.vpcf",
"particles/econ/items/effigies/status_fx_effigies/se_effigy_ti6_lvl3.vpcf",
"particles/econ/items/effigies/status_fx_effigies/se_effigy_ti6.vpcf",
"particles/econ/items/effigies/status_fx_effigies/status_effect_aghs_boss_statue.vpcf",
"particles/econ/items/effigies/status_fx_effigies/status_effect_aghs_elite_statue.vpcf",
"particles/econ/items/effigies/status_fx_effigies/status_effect_aghs_gold_statue.vpcf",
"particles/econ/items/effigies/status_fx_effigies/status_effect_aghs_standard_statue.vpcf",
"particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_dire.vpcf",
"particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_l2_dire.vpcf",
"particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_l2_radiant.vpcf",
"particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_radiant.vpcf",
"particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_gold_dire.vpcf",
"particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_gold_lvl2_dire.vpcf",
"particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_gold_lvl2.vpcf",
"particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_gold.vpcf",
"particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_jade_stone_dire.vpcf",
"particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_jade_stone.vpcf",
"particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_ti10_event_game.vpcf",
"particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_wm16_dire_lvl3.vpcf",
"particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_wm16_dire.vpcf",
"particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_wm16_radiant_lvl3.vpcf",
"particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_wm16_radiant.vpcf",
"particles/econ/items/effigies/status_fx_effigies/status_effect_statue_compendium_2014_dire.vpcf",
"particles/econ/items/effigies/status_fx_effigies/status_effect_statue_compendium_2014_radiant.vpcf",
"particles/econ/items/effigies/status_fx_effigies/status_effect_vr_desat_stone.vpcf",
"particles/econ/items/invoker/invoker_ti7/status_effect_alacrity_ti7.vpcf",
"particles/econ/items/juggernaut/jugg_arcana/status_effect_jugg_arcana_omni.vpcf",
"particles/econ/items/juggernaut/jugg_arcana/status_effect_jugg_arcana_v2_omni.vpcf",
"particles/econ/items/lich/lich_ti10_immortal_head/lich_ti10_immortal_gaze_status_effect.vpcf",
"particles/econ/items/lifestealer/lifestealer_immortal_backbone_gold/status_effect_life_stealer_immortal_rage_gold.vpcf",
"particles/econ/items/lifestealer/lifestealer_immortal_backbone/status_effect_life_stealer_immortal_rage.vpcf",
"particles/econ/items/lifestealer/ls_ti9_immortal_gold/status_effect_ls_ti9_open_wounds_gold.vpcf",
"particles/econ/items/lifestealer/ls_ti9_immortal/status_effect_ls_ti9_open_wounds.vpcf",
"particles/econ/items/mirana/mirana_2021_immortal/mirana_2021_immortal_status_effect.vpcf",
"particles/econ/items/monkey_king/mk_ti9_immortal/status_effect_mk_ti9_immortal_army.vpcf",
"particles/econ/items/necrolyte/necro_ti9_immortal/status_effect_necro_ti9_immortal_shroud.vpcf",
"particles/econ/items/nyx_assassin/nyx_ti9_immortal/status_effect_nyx_ti9_carapace.vpcf",
"particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite_status_effect.vpcf",
"particles/econ/items/shadow_shaman/ss_2021_crimson/status_effect_shaman_shackle_net_2021_crimson.vpcf",
"particles/econ/items/shadow_shaman/ss_fall20_tongue/status_effect_shaman_shackle_net_fall20.vpcf",
"particles/econ/items/slardar/slardar_ti10_head/slardar_status_amp_gold.vpcf",
"particles/econ/items/slardar/slardar_ti10_head/status_effect_ti10_slardar_amp_damage.vpcf",
"particles/econ/items/spectre/spectre_arcana/spectre_arcana_status_effect_illusion.vpcf",
"particles/econ/items/spirit_breaker/spirit_breaker_iron_surge/status_effect_iron_surge.vpcf",
"particles/items3_fx/status_effect_mage_slayer_debuff.vpcf",
"particles/status_fx/status_effect_abaddon_borrowed_time.vpcf",
"particles/status_fx/status_effect_abaddon_frostmourne.vpcf",
"particles/status_fx/status_effect_alacrity.vpcf",
"particles/status_fx/status_effect_ancestral_spirit.vpcf",
"particles/status_fx/status_effect_arc_warden_tempest.vpcf",
"particles/status_fx/status_effect_armadillo_gyroshell.vpcf",
"particles/status_fx/status_effect_armadillo_heartpiercer.vpcf",
"particles/status_fx/status_effect_armadillo_shield.vpcf",
"particles/status_fx/status_effect_armor_dazzle.vpcf",
"particles/status_fx/status_effect_avatar.vpcf",
"particles/status_fx/status_effect_base.vpcf",
"particles/status_fx/status_effect_battle_hunger.vpcf",
"particles/status_fx/status_effect_beserkers_call.vpcf",
"particles/status_fx/status_effect_blademail.vpcf",
"particles/status_fx/status_effect_bloodrage.vpcf",
"particles/status_fx/status_effect_blur.vpcf",
"particles/status_fx/status_effect_brewmaster_cinder_brew.vpcf",
"particles/status_fx/status_effect_brewmaster_drunken_haze.vpcf",
"particles/status_fx/status_effect_brewmaster_thunder_clap.vpcf",
"particles/status_fx/status_effect_building_placement_bad.vpcf",
"particles/status_fx/status_effect_building_placement_good.vpcf",
"particles/status_fx/status_effect_burn.vpcf",
"particles/status_fx/status_effect_charge_of_darkness.vpcf",
"particles/status_fx/status_effect_chemical_rage.vpcf",
"particles/status_fx/status_effect_combo_breaker.vpcf",
"particles/status_fx/status_effect_dark_seer_illusion.vpcf",
"particles/status_fx/status_effect_dark_seer_normal_punch_replica.vpcf",
"particles/status_fx/status_effect_dark_willow_shadow_realm.vpcf",
"particles/status_fx/status_effect_dark_willow_wisp_fear.vpcf",
"particles/status_fx/status_effect_dawnbreaker_fire_wreath_magic_immunity.vpcf",
"particles/status_fx/status_effect_diretide_hulk.vpcf",
"particles/status_fx/status_effect_disruptor_kinetic_fieldslow.vpcf",
"particles/status_fx/status_effect_doom.vpcf",
"particles/status_fx/status_effect_drow_frost_arrow.vpcf",
"particles/status_fx/status_effect_drunken_brawler.vpcf",
"particles/status_fx/status_effect_earth_spirit_boulderslow.vpcf",
"particles/status_fx/status_effect_earth_spirit_petrify.vpcf",
"particles/status_fx/status_effect_earthshaker_arcana.vpcf",
"particles/status_fx/status_effect_earthshaker_echo.vpcf",
"particles/status_fx/status_effect_electrical.vpcf",
"particles/status_fx/status_effect_enchantress_enchant_slow.vpcf",
"particles/status_fx/status_effect_enchantress_shard_buff.vpcf",
"particles/status_fx/status_effect_enchantress_shard_debuff.vpcf",
"particles/status_fx/status_effect_enchantress_untouchable.vpcf",
"particles/status_fx/status_effect_end.vpcf",
"particles/status_fx/status_effect_enigma_blackhole_tgt.vpcf",
"particles/status_fx/status_effect_enigma_malefice.vpcf",
"particles/status_fx/status_effect_faceless_chronosphere.vpcf",
"particles/status_fx/status_effect_faceless_timewalk.vpcf",
"particles/status_fx/status_effect_fed.vpcf",
"particles/status_fx/status_effect_fiendsgrip.vpcf",
"particles/status_fx/status_effect_forcestaff.vpcf",
"particles/status_fx/status_effect_frost_armor.vpcf",
"particles/status_fx/status_effect_frost_copy.vpcf",
"particles/status_fx/status_effect_frost_lich.vpcf",
"particles/status_fx/status_effect_frost.vpcf",
"particles/status_fx/status_effect_ghost.vpcf",
"particles/status_fx/status_effect_glow_white_over_time.vpcf",
"particles/status_fx/status_effect_gods_strength.vpcf",
"particles/status_fx/status_effect_goo_crimson.vpcf",
"particles/status_fx/status_effect_goo.vpcf",
"particles/status_fx/status_effect_grimstroke_dark_artistry.vpcf",
"particles/status_fx/status_effect_grimstroke_ink_over.vpcf",
"particles/status_fx/status_effect_grimstroke_ink_swell.vpcf",
"particles/status_fx/status_effect_guardian_angel_.vpcf",
"particles/status_fx/status_effect_guardian_angel.vpcf",
"particles/status_fx/status_effect_gush.vpcf",
"particles/status_fx/status_effect_huskar_lifebreak.vpcf",
"particles/status_fx/status_effect_iceblast_half.vpcf",
"particles/status_fx/status_effect_iceblast.vpcf",
"particles/status_fx/status_effect_illusion.vpcf",
"particles/status_fx/status_effect_item_editor.vpcf",
"particles/status_fx/status_effect_keeper_dazzle.vpcf",
"particles/status_fx/status_effect_keeper_spirit_bind_debuff.vpcf",
"particles/status_fx/status_effect_keeper_spirit_form_backup.vpcf",
"particles/status_fx/status_effect_keeper_spirit_form.vpcf",
"particles/status_fx/status_effect_legion_commander_duel.vpcf",
"particles/status_fx/status_effect_lich_gaze.vpcf",
"particles/status_fx/status_effect_lich_ice_age.vpcf",
"particles/status_fx/status_effect_life_stealer_open_wounds.vpcf",
"particles/status_fx/status_effect_life_stealer_rage.vpcf",
"particles/status_fx/status_effect_lina_flame_cloak.vpcf",
"particles/status_fx/status_effect_lion_prestige_crystal.vpcf",
"particles/status_fx/status_effect_lone_druid_savage_roar.vpcf",
"particles/status_fx/status_effect_maledict.vpcf",
"particles/status_fx/status_effect_marci_rebound_glow.vpcf",
"particles/status_fx/status_effect_marci_scepter_pull.vpcf",
"particles/status_fx/status_effect_marci_sidekick.vpcf",
"particles/status_fx/status_effect_mars_spear.vpcf",
"particles/status_fx/status_effect_medusa_stone_gaze.vpcf",
"particles/status_fx/status_effect_minotaur_horn.vpcf",
"particles/status_fx/status_effect_mjollnir_shield.vpcf",
"particles/status_fx/status_effect_monkey_king_fur_army.vpcf",
"particles/status_fx/status_effect_monkey_king_spring_slow.vpcf",
"particles/status_fx/status_effect_morphling_morph_target.vpcf",
"particles/status_fx/status_effect_morphling_strength.vpcf",
"particles/status_fx/status_effect_morphling.vpcf",
"particles/status_fx/status_effect_naga_riptide.vpcf",
"particles/status_fx/status_effect_natures_prophet_curse.vpcf",
"particles/status_fx/status_effect_necrolyte_spirit.vpcf",
"particles/status_fx/status_effect_nightmare.vpcf",
"particles/status_fx/status_effect_null.vpcf",
"particles/status_fx/status_effect_nullifier.vpcf",
"particles/status_fx/status_effect_obsidian_matter_debuff.vpcf",
"particles/status_fx/status_effect_obsidian_matter.vpcf",
"particles/status_fx/status_effect_omnislash.vpcf",
"particles/status_fx/status_effect_overpower.vpcf",
"particles/status_fx/status_effect_pangolier_gyroshell.vpcf",
"particles/status_fx/status_effect_pangolier_heartpiercer.vpcf",
"particles/status_fx/status_effect_pangolier_shield.vpcf",
"particles/status_fx/status_effect_phantom_assassin_active_blur.vpcf",
"particles/status_fx/status_effect_phantom_assassin_fall20_active_blur.vpcf",
"particles/status_fx/status_effect_phantom_lancer_illstrong.vpcf",
"particles/status_fx/status_effect_phantom_lancer_illusion.vpcf",
"particles/status_fx/status_effect_phantoml_slowlance.vpcf",
"particles/status_fx/status_effect_phase_shift.vpcf",
"particles/status_fx/status_effect_phoenix_burning.vpcf",
"particles/status_fx/status_effect_poison_dazzle_copy.vpcf",
"particles/status_fx/status_effect_poison_dazzle.vpcf",
"particles/status_fx/status_effect_poison_venomancer.vpcf",
"particles/status_fx/status_effect_poison_viper.vpcf",
"particles/status_fx/status_effect_prowler_shaman_stomp.vpcf",
"particles/status_fx/status_effect_pudge_dismember_default.vpcf",
"particles/status_fx/status_effect_pudge_dismember_electric.vpcf",
"particles/status_fx/status_effect_pudge_dismember_ethereal.vpcf",
"particles/status_fx/status_effect_pudge_dismember_fire.vpcf",
"particles/status_fx/status_effect_pudge_dismember_goo.vpcf",
"particles/status_fx/status_effect_pudge_dismember_ice.vpcf",
"particles/status_fx/status_effect_pudge_dismember_motor.vpcf",
"particles/status_fx/status_effect_pudge_dismember_null.vpcf",
"particles/status_fx/status_effect_pudge_dismember_stone.vpcf",
"particles/status_fx/status_effect_pudge_dismember_wood.vpcf",
"particles/status_fx/status_effect_purple_poison.vpcf",
"particles/status_fx/status_effect_qop_tgt_arcana.vpcf",
"particles/status_fx/status_effect_repel.vpcf",
"particles/status_fx/status_effect_riki_sleep.vpcf",
"particles/status_fx/status_effect_riki_slow.vpcf",
"particles/status_fx/status_effect_rum.vpcf",
"particles/status_fx/status_effect_rupture_lv.vpcf",
"particles/status_fx/status_effect_rupture.vpcf",
"particles/status_fx/status_effect_shadow_shaman_ethershock.vpcf",
"particles/status_fx/status_effect_shaman_shackle.vpcf",
"particles/status_fx/status_effect_shredder_flame_thrower_debuff.vpcf",
"particles/status_fx/status_effect_shredder_whirl.vpcf",
"particles/status_fx/status_effect_siren_song.vpcf",
"particles/status_fx/status_effect_slardar_amp_damage.vpcf",
"particles/status_fx/status_effect_slardar_crush.vpcf",
"particles/status_fx/status_effect_slark_shadow_dance.vpcf",
"particles/status_fx/status_effect_snapfire_magma.vpcf",
"particles/status_fx/status_effect_snapfire_slow.vpcf",
"particles/status_fx/status_effect_snow_heavy.vpcf",
"particles/status_fx/status_effect_spirit_bear.vpcf",
"particles/status_fx/status_effect_statue_compendium_2014_dire.vpcf",
"particles/status_fx/status_effect_statue_compendium_2014_radiant.vpcf",
"particles/status_fx/status_effect_statue.vpcf",
"particles/status_fx/status_effect_stickynapalm.vpcf",
"particles/status_fx/status_effect_swiftslash.vpcf",
"particles/status_fx/status_effect_sylph_wisp_fear.vpcf",
"particles/status_fx/status_effect_techies_stasis.vpcf",
"particles/status_fx/status_effect_techies_tazer.vpcf",
"particles/status_fx/status_effect_teleport_image.vpcf",
"particles/status_fx/status_effect_templar_slow.vpcf",
"particles/status_fx/status_effect_terrorblade_reflection.vpcf",
"particles/status_fx/status_effect_thirst_vision.vpcf",
"particles/status_fx/status_effect_troll_warlord_battletrance.vpcf",
"particles/status_fx/status_effect_tusk_tag_team_debuff.vpcf",
"particles/status_fx/status_effect_valkyrie_fire_wreath_magic_immunity.vpcf",
"particles/status_fx/status_effect_veil.vpcf",
"particles/status_fx/status_effect_vengeful_venge_image.vpcf",
"particles/status_fx/status_effect_void_spirit_aether_remnant.vpcf",
"particles/status_fx/status_effect_void_spirit_astral_step_debuff.vpcf",
"particles/status_fx/status_effect_void_spirit_pulse_buff.vpcf",
"particles/status_fx/status_effect_windrunner_tgt_arcana.vpcf",
"particles/status_fx/status_effect_wraithking_ghosts.vpcf",
"particles/status_fx/status_effect_wyvern_arctic_burn.vpcf",
"particles/status_fx/status_effect_wyvern_cold_embrace.vpcf",
"particles/status_fx/status_effect_wyvern_curse_buff.vpcf",
"particles/status_fx/status_effect_wyvern_curse_target.vpcf",
"particles/status_fx/test_status_effect_frost_backup.vpcf",
"particles/units/heroes/hero_bounty_hunter/status_effect_bounty_hunter_jinda_slow.vpcf",
"particles/units/heroes/hero_phantom_lancer/status_effect_phantom_illstrong.vpcf",
"particles/units/heroes/hero_primal_beast/primal_beast_status_effect_slow.vpcf",
"particles/units/heroes/hero_pudge/pudge_fleshheap_status_effect.vpcf",
"particles/units/heroes/hero_void_spirit/void_spirit_soul_punch_status_ghost.vpcf",
}

if not GameRules:IsCheatMode() then
    return
end

LinkLuaModifier("lm_take_no_damage", "hero_demo/demo_core.lua", LUA_MODIFIER_MOTION_NONE)
lm_take_no_damage = lm_take_no_damage or class({})

function lm_take_no_damage:DeclareFunctions()
    return {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
            MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE}
end
function lm_take_no_damage:GetTexture()
    return "modifier_invulnerable"
end
function lm_take_no_damage:GetAbsoluteNoDamageMagical(params)
    return 1
end
function lm_take_no_damage:GetAbsoluteNoDamagePhysical(params)
    return 1
end
function lm_take_no_damage:GetAbsoluteNoDamagePure(params)
    return 1
end
function lm_take_no_damage:IsHidden(params)
    return false
end
function HeroDemo:Init()
    if self.init then
        return
    end
    self.init = true
    sHeroSelection = GameRules:GetGameSessionConfigValue("demo_hero_name", "default_value")

    GameRules:SetUseUniversalShopMode(true)

    self.spawnUnitSlots = {
        slot1 = "wave_rock_golem_6",
        slot2 = "wave_aoclyte_8",
        slot3 = "wave_gaint_spider_19",
    }
    self:SyncSpawnUnitSlots()

    -- Register the Hero Demo convars
    Convars:RegisterConvar("dota_default_ability_name","war3_storm_bolt","",0)

    CustomNetTables:SetTableValue("dev", "selectedUnit", {
        unitName=self.spawnUnitSlots.slot1
    })

    CustomNetTables:SetTableValue("dev", "selectedAbility", {
        abilityName=Convars:GetStr("dota_default_ability_name")
    })

    ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(HeroDemo, 'OnGameRulesStateChange'), HeroDemo)
    ListenToGameEvent("npc_spawned", Dynamic_Wrap(HeroDemo, 'OnNPCSpawned'), HeroDemo)
    ListenToGameEvent("dota_item_purchased", Dynamic_Wrap(HeroDemo, 'OnItemPurchased'), HeroDemo)
    ListenToGameEvent("npc_replaced", Dynamic_Wrap(HeroDemo, 'OnNPCReplaced'), HeroDemo)

    -- local kvs = LoadKeyValues( "scripts/npc/vo_list.txt")

    local eventList = {"ToggleWave_Button", "AddGold_Button", "AddLumber_Button", "AddFood_Button", "SpawnTower_Button",
                       "DemoSelectUnit","DemoSelectAbility", "SelectUnits",
                       "DemoSelectSpawnUnit_1", "DemoSelectSpawnUnit_2", "DemoSelectSpawnUnit_3"}
    for _, v in pairs(eventList) do
        CustomGameEventManager:RegisterListener(v, function(...)
            return self[v](self, ...)
        end)
    end

    CustomGameEventManager:RegisterListener("RequestInitialSpawnHeroID", function(...)
        return self:OnRequestInitialSpawnHeroID(...)
    end)

    CustomGameEventManager:RegisterListener("WelcomePanelDismissed", function(...)
        return self:OnWelcomePanelDismissed(...)
    end)
    CustomGameEventManager:RegisterListener("RefreshButtonPressed", function(...)
        return self:OnRefreshButtonPressed(...)
    end)
    CustomGameEventManager:RegisterListener("LevelUpButtonPressed", function(...)
        return self:OnLevelUpButtonPressed(...)
    end)
    CustomGameEventManager:RegisterListener("UltraMaxLevelButtonPressed", function(...)
        return self:OnUltraMaxLevelButtonPressed(...)
    end)
    CustomGameEventManager:RegisterListener("FreeSpellsButtonPressed", function(...)
        return self:OnFreeSpellsButtonPressed(...)
    end)
    CustomGameEventManager:RegisterListener("ToggleAttackArmorTypePressed", function(...)
        return self:OnToggleAttackArmorTypePressed(...)
    end)
    CustomGameEventManager:RegisterListener("ToggleAIPressed", function(...)
        return self:OnToggleAIPressed(...)
    end)
    CustomGameEventManager:RegisterListener("CombatLogButtonPressed", function(...)
        return self:CombatLogButtonPressed(...)
    end)

    CustomGameEventManager:RegisterListener("SelectMainHeroButtonPressed", function(...)
        return self:OnSelectMainHeroButtonPressed(...)
    end)

    CustomGameEventManager:RegisterListener("DemoEmitSound", function(...)
        return self:DemoEmitSound(...)
    end)

    CustomGameEventManager:RegisterListener("SwitchHeroButtonPressed", function(...)
        return self:SwitchHeroButtonPressed(...)
    end)

    CustomGameEventManager:RegisterListener("SelectSpawnHeroButtonPressed", function(...)
        return self:OnSelectSpawnHeroButtonPressed(...)
    end)
    CustomGameEventManager:RegisterListener("SpawnEnemyButtonPressed", function(...)
        return self:OnSpawnEnemyButtonPressed(...)
    end)
    CustomGameEventManager:RegisterListener("SpawnAllyButtonPressed", function(...)
        return self:OnSpawnAllyButtonPressed(...)
    end)
    CustomGameEventManager:RegisterListener("RemoveHeroButtonPressed", function(...)
        return self:OnRemoveHeroButtonPressed(...)
    end)


    CustomGameEventManager:RegisterListener("KillHeroButtonPressed", function(...)
        return self:OnKillHeroButtonPressed(...)
    end)

    CustomGameEventManager:RegisterListener("LevelUpHero", function(...)
        return self:OnLevelUpHero(...)
    end)
    CustomGameEventManager:RegisterListener("MaxLevelUpHero", function(...)
        return self:OnMaxLevelUpHero(...)
    end)
    CustomGameEventManager:RegisterListener("ScepterHero", function(...)
        return self:OnScepterHero(...)
    end)
    CustomGameEventManager:RegisterListener("ShardHero", function(...)
        return self:OnShardHero(...)
    end)
    CustomGameEventManager:RegisterListener("ResetHero", function(...)
        return self:OnResetHero(...)
    end)
    CustomGameEventManager:RegisterListener("ToggleInvulnerabilityHero", function(...)
        return self:OnSetInvulnerabilityHero(nil, ...)
    end)
    CustomGameEventManager:RegisterListener("InvulnOnHero", function(...)
        return self:OnSetInvulnerabilityHero(true, ...)
    end)
    CustomGameEventManager:RegisterListener("InvulnOffHero", function(...)
        return self:OnSetInvulnerabilityHero(false, ...)
    end)

    CustomGameEventManager:RegisterListener("DummyTargetButtonPressed", function(...)
        return self:OnDummyTargetButtonPressed(...)
    end)

    CustomGameEventManager:RegisterListener("Clone_BUTTON", function(...)
        return self:Clone_BUTTON(...)
    end)

    CustomGameEventManager:RegisterListener("WearableImmortal_Button", function(...)
        return self:WearableImmortal_Button(...)
    end)

    CustomGameEventManager:RegisterListener("WearableHero_Button", function(...)
        return self:WearableHero_Button(...)
    end)
    CustomGameEventManager:RegisterListener("WearableBundle_Button", function(...)
        return self:WearableBundle_Button(...)
    end)

    CustomGameEventManager:RegisterListener("AbilitySelect_ADD", function(...)
        return self:AbilitySelect_ADD(...)
    end)
    CustomGameEventManager:RegisterListener("AbilitySelect_REMOVE", function(...)
        return self:AbilitySelect_REMOVE(...)
    end)

    -- enemy and friend for unit slot 1
    CustomGameEventManager:RegisterListener("CreepTarget_Enemy_1", function(...)
        return self:CreepTarget_Enemy_1(...)
    end)
    CustomGameEventManager:RegisterListener("CreepTarget_Friend_1", function(...)
        return self:CreepTarget_Friend_1(...)
    end)

    -- enemy and friend for unit slot 2
    CustomGameEventManager:RegisterListener("CreepTarget_Enemy_2", function(...)
        return self:CreepTarget_Enemy_2(...)
    end)
    CustomGameEventManager:RegisterListener("CreepTarget_Friend_2", function(...)
        return self:CreepTarget_Friend_2(...)
    end)

    -- enemy and friend for unit slot 3
    CustomGameEventManager:RegisterListener("CreepTarget_Enemy_3", function(...)
        return self:CreepTarget_Enemy_3(...)
    end)
    CustomGameEventManager:RegisterListener("CreepTarget_Friend_3", function(...)
        return self:CreepTarget_Friend_3(...)
    end)

    CustomGameEventManager:RegisterListener("WearablePart_Button", function(...)
        return self:WearablePart_Button(...)
    end)

    CustomGameEventManager:RegisterListener("DemoParticle", function(...)
        return self:DemoParticle(...)
    end)

    CustomGameEventManager:RegisterListener("ChangeHeroButtonPressed", function(...)
        return self:OnChangeHeroButtonPressed(...)
    end)
    CustomGameEventManager:RegisterListener("ChangeCosmeticsButtonPressed", function(...)
        return self:OnChangeCosmeticsButtonPressed(...)
    end)

    CustomGameEventManager:RegisterListener("SpawnCreepsButtonPressed", function(...)
        return self:OnSpawnCreepsButtonPressed(...)
    end)
    CustomGameEventManager:RegisterListener("SpawnSingleCreepWaveButtonPressed", function(...)
        return self:OnSpawnSingleCreepWaveButtonPressed(...)
    end)
    CustomGameEventManager:RegisterListener("TowersEnabledButtonPressed", function(...)
        return self:OnTowersEnabledButtonPressed(...)
    end)

    CustomGameEventManager:RegisterListener("PauseButtonPressed", function(...)
        return self:OnPauseButtonPressed(...)
    end)
    CustomGameEventManager:RegisterListener("LeaveButtonPressed", function(...)
        return self:OnLeaveButtonPressed(...)
    end)

    CustomGameEventManager:RegisterListener("SpawnRuneDoubleDamagePressed", function(...)
        return self:OnSpawnRuneDoubleDamagePressed(...)
    end)
    CustomGameEventManager:RegisterListener("SpawnRuneHastePressed", function(...)
        return self:OnSpawnRuneHastePressed(...)
    end)
    CustomGameEventManager:RegisterListener("SpawnRuneIllusionPressed", function(...)
        return self:OnSpawnRuneIllusionPressed(...)
    end)
    CustomGameEventManager:RegisterListener("SpawnRuneInvisibilityPressed", function(...)
        return self:OnSpawnRuneInvisibilityPressed(...)
    end)
    CustomGameEventManager:RegisterListener("SpawnRuneRegenerationPressed", function(...)
        return self:OnSpawnRuneRegenerationPressed(...)
    end)
    CustomGameEventManager:RegisterListener("SpawnRuneArcanePressed", function(...)
        return self:OnSpawnRuneArcanePressed(...)
    end)

    if HERO_DEMO_SPAWN_CREEPS_ENABLED then
        print("Starting demo mode with creeps spawning")
        SendToServerConsole("dota_creeps_no_spawning 0")
    else
        print("Starting demo mode with no creeps spawning")
        SendToServerConsole("dota_creeps_no_spawning 1")
    end

    self:FindTowers()
    if HERO_DEMO_TOWERS_ENABLED then
        print("Starting demo mode with towers")
        self:SetTowersEnabled(true)
    else
        print("Starting demo mode with no towers")
        self:SetTowersEnabled(false)
    end

    SendToServerConsole("dota_easybuy 1")
    -- SendToServerConsole( "dota_bot_mode 1" )

    self.m_sHeroSelection = sHeroSelection -- this seems redundant, but events.lua doesn't seem to know about sHeroSelection

    self.m_bPlayerDataCaptured = false
    self.m_nPlayerID = 0

    -- self.m_nHeroLevelBeforeMaxing = 1 -- unused now
    -- self.m_bHeroMaxedOut = false -- unused now

    self.m_nPlayerEntIndex = -1

    self.m_nALLIES_TEAM = 2

    self.m_nENEMIES_TEAM = 3

    self.m_bFreeSpellsEnabled = false
    self.m_bInvulnerabilityEnabled = false

    -- Sync the current state into CustomNetTables using the globals
    CustomNetTables:SetTableValue("game_global", "ui_defaults", {
        WTFEnabled = Convars:GetInt("dota_ability_debug"),
        SpawnCreepsEnabled = HERO_DEMO_SPAWN_CREEPS_ENABLED and 1 or 0,
        TowersEnabled = HERO_DEMO_TOWERS_ENABLED and 1 or 0,
        AttackArmorTypeDisabled = HERO_DEMO_ATTACK_ARMOR_TYPE_DISABLED and 1 or 0,
        AIDisabled = HERO_DEMO_AI_DISABLED and 1 or 0
    })
end

--------------------------------------------------------------------------------
-- Think_InitializePlayerHero
--------------------------------------------------------------------------------
function HeroDemo:Think_InitializePlayerHero(hPlayerHero)
    if not hPlayerHero then
        return 0.1
    end

    hPlayerHero:GetPlayerOwner():CheckForCourierSpawning(hPlayerHero)

    if self.m_bPlayerDataCaptured == false then
        if hPlayerHero:GetUnitName() == self.m_sHeroSelection then
            local nPlayerID = hPlayerHero:GetPlayerOwnerID()
            PlayerResource:ModifyGold(nPlayerID, 99999, false, 0)
            self.m_bPlayerDataCaptured = true
        end
    end

    -- TODO - support this!
    if self.m_bInvulnerabilityEnabled then
        local hAllPlayerUnits = {}
        hAllPlayerUnits = hPlayerHero:GetAdditionalOwnedUnits()
        hAllPlayerUnits[#hAllPlayerUnits + 1] = hPlayerHero

        for _, hUnit in pairs(hAllPlayerUnits) do
            hUnit:AddNewModifier(hPlayerHero, nil, "lm_take_no_damage", nil)
        end
    end

    return
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnWelcomePanelDismissed
--------------------------------------------------------------------------------
function HeroDemo:OnWelcomePanelDismissed(event)
    -- print( "Entering HeroDemo:OnWelcomePanelDismissed( event )" )
end

function HeroDemo:DemoEmitSound(idx, data)
    -- print( "Entering HeroDemo:OnWelcomePanelDismissed( event )" )
    local hero = PlayerResource:GetSelectedHeroEntity(0)
    PrintTable(data)
    
    if hero.devSound then
        StopSoundOn(hero.devSound, hero)
        hero.devSound=nil
    end

    local sound = data.str
    EmitSoundOn(sound, hero)

    hero.devSound=sound

    Timers:CreateTimer(10, function()
        StopSoundOn(sound, hero)
    end)
end

local function LinearProjectile(hero, eff, fromPoint, toPoint, speed, startEadius, endRadius, kv)
    local distance = (toPoint - fromPoint):Length2D()
    local forward_v = (toPoint - fromPoint):Normalized()
    eff = eff or "particles/base_attacks/ranged_tower_bad_linear.vpcf"
    forward_v.z = 0
    local info = {
        Ability = nil,
        EffectName = eff,
        vSpawnOrigin = fromPoint + Vector(0, 0, 100),
        fDistance = distance,
        fStartRadius = startEadius or 100,
        fEndRadius = endRadius or startEadius or 100,
        Source = hero,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        --  fExpireTime         = ,
        bDeleteOnHit = false,
        vVelocity = speed * forward_v,
        bProvidesVision = true,
        iVisionRadius = 10
        --  iVisionTeamNumber   = caster:GetTeamNumber(),

    }
    if kv then
        for k, v in pairs(kv) do
            info[k] = v
        end
    end
    ProjectileManager:CreateLinearProjectile(info)
end
function HeroDemo:DemoParticle(idx, data)
    
    local hero = PlayerResource:GetSelectedHeroEntity(0)
    local particle = JSON:decode(data.str)
    if particle==nil then
        return
    end
    
    PrintTable(particle)
    if true then
        print(particle.name)
        return 
    end
    if HeroDemo.selectedUnit then
        hero=HeroDemo.selectedUnit
    end

    if hero.devEffect then
        ParticleManager:DestroyParticle(hero.devEffect, true)
        hero.devEffect=nil
    end

    hero:RemoveModifierByName("modifier_dev_status_effect")
    
    if particle.isTracking then
        local enemies = SimpleFindEnemy(hero:GetTeamNumber(), hero:GetAbsOrigin(), 1000, nil)

        for k, enemy in pairs(enemies) do
            local projectile = {
                Target = enemy,
                Source = hero,
                Ability = nil,
                EffectName = particle.name,
                iMoveSpeed = 1000,
                vSpawnOrigin = hero:GetAbsOrigin(),
                bDrawsOnMinimap = false,
                bDodgeable = true,
                bIsAttack = false,
                bVisibleToEnemies = true,
                bReplaceExisting = false,
                bProvidesVision = false,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
            }
            ProjectileManager:CreateTrackingProjectile(projectile)
        end
    elseif particle.isLinear then

        local enemies = SimpleFindEnemy(hero:GetTeamNumber(), hero:GetAbsOrigin(), 1000, nil)

        for k, enemy in pairs(enemies) do
            LinearProjectile(hero, particle.name, hero:GetAbsOrigin(), enemy:GetAbsOrigin(), 1000, 100, 300, {})
        end
    elseif particle.isScalabel then
        local effect_cast = ParticleManager:CreateParticle(particle.name, PATTACH_POINT_FOLLOW, hero)
        ParticleManager:SetParticleControlEnt(effect_cast, 0, hero, PATTACH_POINT_FOLLOW, nil, hero:GetAbsOrigin(),
            true)
        ParticleManager:SetParticleControl(effect_cast, 1, Vector(600, 600, 600))

        local cps = {0, 2, 3, 4}
        for i = 1, #cps do
            ParticleManager:SetParticleControlEnt(effect_cast, cps[i], hero, PATTACH_POINT_FOLLOW, nil,
                hero:GetAbsOrigin(), true)
        end

        hero.devEffect=effect_cast
        Timers:CreateTimer(5, function()
            ParticleManager:DestroyParticle(effect_cast, false)
        end)

    elseif particle.isStatusEffect then
        local stack=0
        for index, eff in ipairs(STATUS_EFFECT_LIST) do
            if eff==particle.name then
                stack=index
                break
            end
        end
        local mod=hero:AddNewModifier(hero, nil, "modifier_dev_status_effect", {
            duration=5
        })
        mod:SetStackCount(stack)
    else
        local effect_cast = ParticleManager:CreateParticle(particle.name, PATTACH_POINT_FOLLOW, hero)
        local cps = {0, 1, 2, 3, 4}
        for i = 1, #cps do
            ParticleManager:SetParticleControlEnt(effect_cast, cps[i], hero, PATTACH_POINT_FOLLOW, nil,
                hero:GetAbsOrigin(), true)
        end
        hero.devEffect=effect_cast
        Timers:CreateTimer(5, function()
            ParticleManager:DestroyParticle(effect_cast, false)
        end)
    end
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnRefreshButtonPressed
--------------------------------------------------------------------------------
function HeroDemo:OnRefreshButtonPressed(eventSourceIndex)
    SendToServerConsole("dota_dev hero_refresh")
    --
    for key, unit in pairs(HeroDemo.selectedUnits) do
        local unitName = unit:GetUnitName()
        unit:SetHealth(unit:GetMaxHealth())
        unit:SetMana(unit:GetMaxMana())
        local slotCount = unit:GetAbilityCount() or 0
        for i = 0, slotCount - 1 do
            local ab = unit:GetAbilityByIndex(i)
            if ab then
                ab:RefreshCharges()
                ab:EndCooldown()
            end
        end
    end
    if HeroDemo.selectedUnit then
        HeroDemo.selectedUnit:SetHealth(HeroDemo.selectedUnit:GetMaxHealth())
        HeroDemo.selectedUnit:SetMana(HeroDemo.selectedUnit:GetMaxMana())
        local slotCount = HeroDemo.selectedUnit:GetAbilityCount() or 0
        for i = 0, slotCount - 1 do
            local ab = HeroDemo.selectedUnit:GetAbilityByIndex(i)
            if ab then
                ab:RefreshCharges()
                ab:EndCooldown()
            end
        end
    end
    --
    EmitGlobalSound("UI.Button.Pressed")

    -- self:BroadcastMsg( "#Refresh_Msg" )
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnLevelUpButtonPressed
--------------------------------------------------------------------------------
function HeroDemo:OnLevelUpButtonPressed(eventSourceIndex)
    SendToServerConsole("dota_dev hero_level 1")



    EmitGlobalSound("UI.Button.Pressed")

    -- self:BroadcastMsg( "#LevelUp_Msg" )
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnUltraMaxLevelButtonPressed
--------------------------------------------------------------------------------
function HeroDemo:OnUltraMaxLevelButtonPressed(eventSourceIndex, data)

    print('ULTRA MAX!')

    local hPlayerHero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
    if hPlayerHero == nil then
        return
    end

    HeroMaxLevel(hPlayerHero)

    if not hPlayerHero:FindModifierByName("modifier_item_aghanims_shard") then
        hPlayerHero:AddItemByName("item_aghanims_shard")
    end

    if not hPlayerHero:FindModifierByName("modifier_item_ultimate_scepter_consumed") then
        hPlayerHero:AddItemByName("item_ultimate_scepter_2")
    end

    EmitGlobalSound("UI.Button.Pressed")

    -- self:BroadcastMsg( "#MaxLevel_Msg" )
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnFreeSpellsButtonPressed
--------------------------------------------------------------------------------
function HeroDemo:OnFreeSpellsButtonPressed(eventSourceIndex)
    local nWTFEnabledEnabled = Convars:GetInt("dota_ability_debug")

    if nWTFEnabledEnabled == 0 then
        print("Enabling WTF")
        Convars:SetInt("dota_ability_debug", 1)
        self.m_bFreeSpellsEnabled = true
        SendToServerConsole("dota_dev hero_refresh")
        self:BroadcastMsg("#FreeSpellsOn_Msg")
    elseif nWTFEnabledEnabled == 1 then
        print("Disabling WTF")
        Convars:SetInt("dota_ability_debug", 0)
        self.m_bFreeSpellsEnabled = false
        self:BroadcastMsg("#FreeSpellsOff_Msg")
    end

    -- Sync the UI state into CustomNetTables
    CustomNetTables:SetTableValue("game_global", "ui_defaults", {
        WTFEnabled = Convars:GetInt("dota_ability_debug"),
        SpawnCreepsEnabled = HERO_DEMO_SPAWN_CREEPS_ENABLED and 1 or 0,
        TowersEnabled = HERO_DEMO_TOWERS_ENABLED and 1 or 0,
        AttackArmorTypeDisabled = HERO_DEMO_ATTACK_ARMOR_TYPE_DISABLED and 1 or 0,
        AIDisabled = HERO_DEMO_AI_DISABLED and 1 or 0
    })

    EmitGlobalSound("UI.Button.Pressed")
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnToggleAttackArmorTypePressed
--------------------------------------------------------------------------------
function HeroDemo:OnToggleAttackArmorTypePressed(eventSourceIndex)
    -- Flip the global
    HERO_DEMO_ATTACK_ARMOR_TYPE_DISABLED = not HERO_DEMO_ATTACK_ARMOR_TYPE_DISABLED

    if HERO_DEMO_ATTACK_ARMOR_TYPE_DISABLED then
        print("Attack/armor type system disabled")
        fireLeftNotify(nil, false, "<font color='#FC270C'>[Debug]</font> attack/armor types disabled", {
            rawText = true
        })
    else
        print("Attack/armor type system enabled")
        fireLeftNotify(nil, false, "<font color='#FC270C'>[Debug]</font> attack/armor types enabled", {
            rawText = true
        })
    end

    -- Sync the UI state into CustomNetTables
    CustomNetTables:SetTableValue("game_global", "ui_defaults", {
        WTFEnabled = Convars:GetInt("dota_ability_debug"),
        SpawnCreepsEnabled = HERO_DEMO_SPAWN_CREEPS_ENABLED and 1 or 0,
        TowersEnabled = HERO_DEMO_TOWERS_ENABLED and 1 or 0,
        AttackArmorTypeDisabled = HERO_DEMO_ATTACK_ARMOR_TYPE_DISABLED and 1 or 0,
        AIDisabled = HERO_DEMO_AI_DISABLED and 1 or 0
    })

    EmitGlobalSound("UI.Button.Pressed")
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnToggleAIPressed
--------------------------------------------------------------------------------
function HeroDemo:OnToggleAIPressed(eventSourceIndex)
    -- Flip the global
    HERO_DEMO_AI_DISABLED = not HERO_DEMO_AI_DISABLED

    if HERO_DEMO_AI_DISABLED then
        print("AI system disabled")
        fireLeftNotify(nil, false, "<font color='#FC270C'>[Debug]</font> AI disabled", {
            rawText = true
        })
    else
        print("AI system enabled")
        fireLeftNotify(nil, false, "<font color='#FC270C'>[Debug]</font> AI enabled", {
            rawText = true
        })
    end

    -- Sync the UI state into CustomNetTables
    CustomNetTables:SetTableValue("game_global", "ui_defaults", {
        WTFEnabled = Convars:GetInt("dota_ability_debug"),
        SpawnCreepsEnabled = HERO_DEMO_SPAWN_CREEPS_ENABLED and 1 or 0,
        TowersEnabled = HERO_DEMO_TOWERS_ENABLED and 1 or 0,
        AttackArmorTypeDisabled = HERO_DEMO_ATTACK_ARMOR_TYPE_DISABLED and 1 or 0,
        AIDisabled = HERO_DEMO_AI_DISABLED and 1 or 0
    })

    EmitGlobalSound("UI.Button.Pressed")
end

--------------------------------------------------------------------------------
-- ButtonEvent: CombatLogButtonPressed
--------------------------------------------------------------------------------
function HeroDemo:CombatLogButtonPressed(eventSourceIndex)
    SendToServerConsole("dota_toggle_combatlog")
    EmitGlobalSound("UI.Button.Pressed")
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnSetInvulnerabilityHero
--------------------------------------------------------------------------------
function HeroDemo:OnSetInvulnerabilityHero(bInvuln, eventSourceIndex, data)
    local nUnitEntIndex = tonumber(data.str)
    local hUnit = EntIndexToHScript(nUnitEntIndex)
    if (hUnit ~= nil and hUnit:IsNull() == false) then
        print('OnSetInvulnerabilityHero! - found unit with ent index = ' .. nUnitEntIndex .. ' - ' .. hUnit:GetUnitName())

        -- Check the invulnerability state, toggling when bInvuln is nil
        if bInvuln == nil then
            bInvuln = hUnit:FindModifierByName("lm_take_no_damage") == nil
        end

        -- Add or remove the invulnerable state
        if bInvuln then
            print('Adding INVULN modifier to entindex ' .. hUnit:GetEntityIndex() .. ' - ' .. hUnit:GetUnitName())
            hUnit:AddNewModifier(hUnit, nil, "lm_take_no_damage", nil)
        else
            print('Removing INVULN modifier from ' .. hUnit:GetUnitName())
            hUnit:RemoveModifierByName("lm_take_no_damage")
        end
    end
end

--------------------------------------------------------------------------------
-- ButtonEvent: SpawnEnemyButtonPressed
--------------------------------------------------------------------------------
function HeroDemo:OnSpawnEnemyButtonPressed(eventSourceIndex, data)
    local hPlayerHero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
    if hPlayerHero == nil then
        return
    end

    local hPlayer = PlayerResource:GetPlayer(data.PlayerID)

    local sHeroToSpawn = Convars:GetStr("dota_hero_demo_default_enemy")

    local team=DOTA_TEAM_GOODGUYS
    if hPlayerHero:GetTeam()==team then
        team=DOTA_TEAM_BADGUYS
    end


    local hEnemy = CreateUnitByName(sHeroToSpawn, hPlayerHero:GetAbsOrigin(), true, hPlayerHero, hPlayerHero,
    team)

  

    hEnemy:SetControllableByPlayer(self.m_nPlayerID, false)
    hEnemy:SetRespawnPosition(hPlayerHero:GetAbsOrigin())
    FindClearSpaceForUnit(hEnemy, hPlayerHero:GetAbsOrigin(), false)
    hEnemy:Hold()
    hEnemy:SetIdleAcquire(false)
    hEnemy:SetAcquisitionRange(0)
    self:BroadcastMsg("#SpawnEnemy_Msg")

    EmitGlobalSound("UI.Button.Pressed")
end

--------------------------------------------------------------------------------
-- RequestInitialSpawnHeroID
--------------------------------------------------------------------------------
function HeroDemo:OnRequestInitialSpawnHeroID(eventSourceIndex, data)
    local sHeroToSpawn = Convars:GetStr("dota_hero_demo_default_enemy")
    local nHeroID = DOTAGameManager:GetHeroIDByName(sHeroToSpawn)
    local event_data = {
        hero_id = nHeroID,
        hero_name = sHeroToSpawn
    }
    CustomGameEventManager:Send_ServerToAllClients("set_spawn_hero_id", event_data)
end

--------------------------------------------------------------------------------
-- ButtonEvent: SelectMainHeroButtonPressed
--------------------------------------------------------------------------------
function HeroDemo:OnSelectMainHeroButtonPressed(eventSourceIndex, data)
    local sHero = DOTAGameManager:GetHeroUnitNameByID(tonumber(data.str))
    -- EmitGlobalSound( "UI.Button.Pressed" )

    print('MAIN HERO PICK!')

    local event_data = {
        hero_id = tonumber(data.str),
        hero_name = sHero
    }
    CustomGameEventManager:Send_ServerToAllClients("set_main_hero_id", event_data)
end

--------------------------------------------------------------------------------
-- ButtonEvent: SelectSpawnHeroButtonPressed
--------------------------------------------------------------------------------
function HeroDemo:OnSelectSpawnHeroButtonPressed(eventSourceIndex, data)
    local sHeroToSpawn = DOTAGameManager:GetHeroUnitNameByID(tonumber(data.str))
    Convars:SetStr("dota_hero_demo_default_enemy", sHeroToSpawn)
    -- EmitGlobalSound( "UI.Button.Pressed" )

    print('SPAWN HERO PICK!')

    local event_data = {
        hero_id = tonumber(data.str),
        hero_name = sHeroToSpawn
    }
    CustomGameEventManager:Send_ServerToAllClients("set_spawn_hero_id", event_data)
end

--------------------------------------------------------------------------------
-- ButtonEvent: RemoveHeroButtonPressed
--------------------------------------------------------------------------------
function HeroDemo:OnRemoveHeroButtonPressed(eventSourceIndex, data)

    print("OnRemoveHeroButtonPressed")
    local nHeroEntIndex = tonumber(data.str)
    local hHero = EntIndexToHScript(nHeroEntIndex)



    if (hHero ~= nil and hHero:IsNull() == false and hHero ~= PlayerResource:GetSelectedHeroEntity(0)) then
        print('OnRemoveHeroButtonPressed! - found hero with ent index = ' .. nHeroEntIndex)
        if hHero:IsHero() and hHero:GetPlayerOwner() ~= nil and hHero:GetPlayerOwnerID() ~= 0 then
            local nPlayerID = hHero:GetPlayerID()
            -- TODO - kill all clones that are attached
            DisconnectClient(nPlayerID, true)
        else

            if IsActiveBuilding(hHero) then
                BuildingHelper:RemoveBuilding(hHero, false)
            end
            -- hHero:Destroy()
            hHero:RemoveSelf()
        end

        local event_data = {
            entindex = nHeroEntIndex
        }
        CustomGameEventManager:Send_ServerToAllClients("remove_hero_entry", event_data)
    end
end


function HeroDemo:OnKillHeroButtonPressed(eventSourceIndex, data)
    print("OnKillHeroButtonPressed")

    if HeroDemo.selectedUnits then
        for _, unit in ipairs(HeroDemo.selectedUnits) do
            local hero=PlayerResource:GetSelectedHeroEntity(unit:GetPlayerOwnerID())
            hero=hero or unit
            SimpleApplyDamage(nil, hero, unit, 1000000)
        end
    end
end

--------------------------------------------------------------------------------
-- ButtonEvent: LevelUpHero
--------------------------------------------------------------------------------
function HeroDemo:OnLevelUpHero(eventSourceIndex, data)
    local nHeroEntIndex = tonumber(data.str)
    local hHero = EntIndexToHScript(nHeroEntIndex)
    if (hHero ~= nil and hHero:IsNull() == false) then
        print('OnLevelUpHero! - found hero with ent index = ' .. nHeroEntIndex)
        if hHero.HeroLevelUp then
            hHero:HeroLevelUp(true)
        end
        if hHero.CreatureLevelUp then
            hHero:CreatureLevelUp(1)
        end
    end
end


function HeroDemo:AddGold_Button(eventSourceIndex, data)
    print("AddGold_Button",HeroDemo.selectedUnit)
    EmitGlobalSound("UI.Button.Pressed")
    if HeroDemo.selectedUnit then
        local pid = HeroDemo.selectedUnit:GetPlayerOwnerID()
        Player:ModifyGold(pid, 10000)
    end
end
function HeroDemo:AddLumber_Button(eventSourceIndex, data)
    EmitGlobalSound("UI.Button.Pressed")
    if HeroDemo.selectedUnit then
        local pid = HeroDemo.selectedUnit:GetPlayerOwnerID()
        Player:ModifyWood(pid, 20000)
    end

end
function HeroDemo:AddFood_Button(eventSourceIndex, data)
    EmitGlobalSound("UI.Button.Pressed")
    if HeroDemo.selectedUnit then
        local pid = HeroDemo.selectedUnit:GetPlayerOwnerID()
        Player:AddFood(pid, 100)
    end
end

function HeroDemo:SelectUnits(eventSourceIndex, data)
    -- EmitGlobalSound("UI.Button.Pressed")
    local n = tonumber(data.str)
    if n == 0 then
        HeroDemo.selectedUnits = {}
    else
        table.insert(HeroDemo.selectedUnits, EntIndexToHScript(tonumber(data.str)))
        -- print(n,n==0,#HeroDemo.selectedUnits)
    end

end

function HeroDemo:SyncSpawnUnitSlots()
    CustomNetTables:SetTableValue("dev", "spawn_unit_slots", {
        slot1 = self.spawnUnitSlots.slot1,
        slot2 = self.spawnUnitSlots.slot2,
        slot3 = self.spawnUnitSlots.slot3,
    })
end

function HeroDemo:SetSpawnUnitSlot(slotName, unitName)
    if unitName == nil or unitName == "" then
        return
    end

    self.spawnUnitSlots = self.spawnUnitSlots or {
        slot1 = "wave_rock_golem_6",
        slot2 = "wave_aoclyte_8",
        slot3 = "wave_gaint_spider_19",
    }

    self.spawnUnitSlots[slotName] = unitName
    self:SyncSpawnUnitSlots()
end

function HeroDemo:GetSpawnUnitSlot(slotName)
    self.spawnUnitSlots = self.spawnUnitSlots or {
        slot1 = "wave_rock_golem_6",
        slot2 = "wave_aoclyte_8",
        slot3 = "wave_gaint_spider_19",
    }

    return self.spawnUnitSlots[slotName]
end

-- Unit slot 1 selection
function HeroDemo:DemoSelectSpawnUnit_1(eventSourceIndex, data)
    self:SetSpawnUnitSlot("slot1", data.str)
    print("Traveler picked a unit for slot 1: " .. data.str)
end

-- Unit slot 2 selection
function HeroDemo:DemoSelectSpawnUnit_2(eventSourceIndex, data)
    self:SetSpawnUnitSlot("slot2", data.str)
    print("Traveler picked a unit for slot 2: " .. data.str)
end

-- Unit slot 3 selection
function HeroDemo:DemoSelectSpawnUnit_3(eventSourceIndex, data)
    self:SetSpawnUnitSlot("slot3", data.str)
    print("Traveler picked a unit for slot 3: " .. data.str)
end

function HeroDemo:DemoSelectAbility(eventSourceIndex, data)
    -- EmitGlobalSound("UI.Button.Pressed")
    --print("DemoSelectAbility",data.str)
    Convars:SetStr("dota_default_ability_name",data.str)
end

function HeroDemo:DemoSelectUnit(eventSourceIndex, data)
    -- EmitGlobalSound("UI.Button.Pressed")
    -- The client keeps re-sending this while the same unit stays selected, so
    -- only log it when the selection actually changes.
    local entIndex = tonumber(data.str)
    if entIndex ~= HeroDemo.lastSelectedEntIndex then
        HeroDemo.lastSelectedEntIndex = entIndex
        print("SelectUnit", data.str)
    end
    local PlayerID = data.PlayerID
    HeroDemo.selectedUnit = EntIndexToHScript(entIndex)
    if HeroDemo.selectedUnit then
        -- print(HeroDemo.selectedUnit:GetUnitName())
        local selectedUnit = HeroDemo.selectedUnit
        local unit = selectedUnit
    end
end

function HeroDemo:SpawnTower_Button(eventSourceIndex, data)
    EmitGlobalSound("UI.Button.Pressed")
    GamePlay:towerSpawn(0)
    Cmd:handleTestCommand("-control", 0)
end

--------------------------------------------------------------------------------
-- ButtonEvent: MaxLevelUpHero
--------------------------------------------------------------------------------
function HeroDemo:OnMaxLevelUpHero(eventSourceIndex, data)
    local nHeroEntIndex = tonumber(data.str)
    local hHero = EntIndexToHScript(nHeroEntIndex)
    if (hHero ~= nil and hHero:IsNull() == false) then
        print('OnMaxLevelUpHero! - found hero with ent index = ' .. nHeroEntIndex)

        if hHero.AddExperience then
            hHero:AddExperience(59900, false, false) -- for some reason maxing your level this way fixes the bad interaction with OnHeroReplaced

            local slotCount = hHero:GetAbilityCount() or 0
            for i = 0, slotCount - 1 do
                local hAbility = hHero:GetAbilityByIndex(i)
                if hAbility and not hAbility:IsAttributeBonus() then
                    while hAbility:GetLevel() < hAbility:GetMaxLevel() and hAbility:CanAbilityBeUpgraded() ==
                        ABILITY_CAN_BE_UPGRADED and not hAbility:IsHidden() do
                        hHero:UpgradeAbility(hAbility)
                    end
                end
            end
        end
    end
end

--------------------------------------------------------------------------------
-- ButtonEvent: ScepterHero
--------------------------------------------------------------------------------
function HeroDemo:OnScepterHero(eventSourceIndex, data)
    local nHeroEntIndex = tonumber(data.str)
    local hHero = EntIndexToHScript(nHeroEntIndex)
    if (hHero ~= nil and hHero:IsNull() == false) then
        print('OnScepterHero! - found hero with ent index = ' .. nHeroEntIndex)

        if not hHero:FindModifierByName("modifier_item_ultimate_scepter_consumed") then
            hHero:AddItemByName("item_ultimate_scepter_2")
        end
    end
end

--------------------------------------------------------------------------------
-- ButtonEvent: ShardHero
--------------------------------------------------------------------------------
function HeroDemo:OnShardHero(eventSourceIndex, data)
    local nHeroEntIndex = tonumber(data.str)
    local hHero = EntIndexToHScript(nHeroEntIndex)
    if (hHero ~= nil and hHero:IsNull() == false) then
        print('OnShardHero! - found hero with ent index = ' .. nHeroEntIndex)

        if not hHero:FindModifierByName("modifier_item_aghanims_shard") then
            hHero:AddItemByName("item_aghanims_shard")
        end
    end
end

function HeroDemo:SwitchHeroButtonPressed(eventSourceIndex, data)
    PrintTable(data)
    local sHeroToSpawn = Convars:GetStr("dota_hero_demo_default_enemy")
    print(sHeroToSpawn)

    -- Units still owned by the old hero are removed, except magic immune or uncontrolled ones
    PlayerResource:ReplaceHeroWith(data.PlayerID, sHeroToSpawn, 0, 0)

end

--------------------------------------------------------------------------------
-- ButtonEvent: ResetHero
--------------------------------------------------------------------------------
function HeroDemo:OnResetHero(eventSourceIndex, data)
    local nHeroEntIndex = tonumber(data.str)
    local hHero = EntIndexToHScript(nHeroEntIndex)

    if HeroDemo.selectedUnit:IsHero() then
        hHero = HeroDemo.selectedUnit
        
        if (hHero ~= nil and hHero:IsNull() == false) then
            local abList=hHero.abList
            PrintTable(abList)

            local items={}
            for i = 0, 10, 1 do
                local item= hHero:GetItemInSlot(i)
                if item then
                    table.insert(items,item:GetName())
                end
            end

            local pid=hHero:GetPlayerOwnerID()
            print('OnResetHero! - found hero with ent index = ' .. nHeroEntIndex)
            GameRules:SetSpeechUseSpawnInsteadOfRespawnConcept(true)
            PlayerResource:ReplaceHeroWithNoTransfer(hHero:GetPlayerOwnerID(), hHero:GetUnitName(), -1, 0)
            GameRules:SetSpeechUseSpawnInsteadOfRespawnConcept(false)
            local newHero=PlayerResource:GetSelectedHeroEntity(pid)
            if abList then
                for _, abItem in ipairs(abList) do
                    AddAbilityAndSetLevel(newHero, abItem.name, abItem.level)
                end
            end
            
            for _, itemName in ipairs(items) do
                AddItemToUnit(newHero, itemName)
            end
            newHero.abList=abList
        end
    else
        for key, unit in pairs(HeroDemo.selectedUnits) do
            local unitName = unit:GetUnitName()
            local pos = unit:GetAbsOrigin()
            local team=unit:GetTeamNumber()
            local abList=unit.abList
            PrintTable(abList)
            unit:ForceKill(true)
            local hero = PlayerResource:GetSelectedHeroEntity(0)
            local creep = CreateUnitByName(unitName, pos, true, hero, hero, team)

            HeroDemo:copyUnitProperty(unit, creep)

            local angle_now = unit:GetAnglesAsVector()
            
            if creep then
                creep:SetControllableByPlayer(hero:GetPlayerID(), true)
                creep:SetAngles(angle_now.x, angle_now.y, angle_now.z)
                creep:AddNewModifier(hero, nil, "modifier_phased", {
                    duration = 0.1
                })
                creep.abList=abList
                if abList then 
                    for _, abItem in ipairs(abList) do
                        AddAbilityAndSetLevel(creep, abItem.name, abItem.level)
                    end
                end
            end
            
            
        end
        HeroDemo.selectedUnits = {}
    end
end


--------------------------------------------------------------------------------
-- ButtonEvent: SpawnAllyButtonPressed
--------------------------------------------------------------------------------
function HeroDemo:OnSpawnAllyButtonPressed(eventSourceIndex, data)
    local hPlayerHero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
    if hPlayerHero == nil then
        return
    end

    local hPlayer = PlayerResource:GetPlayer(data.PlayerID)

    local sHeroToSpawn = Convars:GetStr("dota_hero_demo_default_enemy")



    local hAlly = CreateUnitByName(sHeroToSpawn, hPlayerHero:GetAbsOrigin(), true, hPlayerHero, hPlayerHero,
    hPlayerHero:GetTeam())



    hAlly:SetControllableByPlayer(self.m_nPlayerID, false)
    hAlly:SetRespawnPosition(hPlayerHero:GetAbsOrigin())
    FindClearSpaceForUnit(hAlly, hPlayerHero:GetAbsOrigin(), false)
    hAlly:Hold()
    hAlly:SetIdleAcquire(false)
    hAlly:SetAcquisitionRange(0)
    self:BroadcastMsg("#SpawnAlly_Msg")
    hAlly:AddNewModifier(hero, nil, "modifier_phased", {
        duration = 0.1
    })
    

    EmitGlobalSound("UI.Button.Pressed")
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnDummyTargetButtonPressed
--------------------------------------------------------------------------------
function HeroDemo:OnDummyTargetButtonPressed(eventSourceIndex, data)
    local hPlayerHero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
    if hPlayerHero == nil then
        return
    end

    local team=DOTA_TEAM_GOODGUYS
    if hPlayerHero:GetTeam()==team then
        team=DOTA_TEAM_BADGUYS
    end


    local hDummy = CreateUnitByName("npc_dota_hero_target_dummy", hPlayerHero:GetAbsOrigin(), true, nil, nil,
    team)
    hDummy:SetAbilityPoints(0)
    hDummy:SetControllableByPlayer(self.m_nPlayerID, false)
    hDummy:Hold()
    hDummy:SetIdleAcquire(false)
    hDummy:SetAcquisitionRange(0)

    EmitGlobalSound("UI.Button.Pressed")

    -- self:BroadcastMsg( "#SpawnDummyTarget_Msg" )
end

-- Create the enemy for unit slot 1
function HeroDemo:CreepTarget_Enemy_1(eventSourceIndex, data)
    local hPlayerHero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
    if hPlayerHero == nil then
        return
    end

    local unitName = self:GetSpawnUnitSlot("slot1")

    local team = DOTA_TEAM_GOODGUYS
    if hPlayerHero:GetTeam() == team then
        team = DOTA_TEAM_BADGUYS
    end

    local hDummy = CreateUnitByName(unitName, hPlayerHero:GetAbsOrigin(), true, nil, nil, team)
    hDummy:SetControllableByPlayer(self.m_nPlayerID, true)
    hDummy:Hold()
    EmitGlobalSound("UI.Button.Pressed")
    hDummy:AddNewModifier(hDummy, nil, "modifier_phased", {
        duration = 0.1
    })
end

-- Create the friend for unit slot 1
function HeroDemo:CreepTarget_Friend_1(eventSourceIndex, data)
    local hPlayerHero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
    if hPlayerHero == nil then
        return
    end

    local unitName = self:GetSpawnUnitSlot("slot1")
    local hDummy = CreateUnitByName(unitName, hPlayerHero:GetAbsOrigin(), true, hPlayerHero, hPlayerHero,
        PlayerResource:GetTeam(data.PlayerID))
    hDummy:SetControllableByPlayer(self.m_nPlayerID, true)
    hDummy:Hold()
    EmitGlobalSound("UI.Button.Pressed")
    hDummy:AddNewModifier(hPlayerHero, nil, "modifier_phased", {
        duration = 0.1
    })
end

-- Create the enemy for unit slot 2
function HeroDemo:CreepTarget_Enemy_2(eventSourceIndex, data)
    local hPlayerHero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
    if hPlayerHero == nil then
        return
    end

    local unitName = self:GetSpawnUnitSlot("slot2")

    local team = DOTA_TEAM_GOODGUYS
    if hPlayerHero:GetTeam() == team then
        team = DOTA_TEAM_BADGUYS
    end

    local hDummy = CreateUnitByName(unitName, hPlayerHero:GetAbsOrigin(), true, nil, nil, team)
    hDummy:SetControllableByPlayer(self.m_nPlayerID, true)
    hDummy:Hold()
    EmitGlobalSound("UI.Button.Pressed")
    hDummy:AddNewModifier(hDummy, nil, "modifier_phased", {
        duration = 0.1
    })
end

-- Create the friend for unit slot 2
function HeroDemo:CreepTarget_Friend_2(eventSourceIndex, data)
    local hPlayerHero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
    if hPlayerHero == nil then
        return
    end

    local unitName = self:GetSpawnUnitSlot("slot2")
    local hDummy = CreateUnitByName(unitName, hPlayerHero:GetAbsOrigin(), true, hPlayerHero, hPlayerHero,
        PlayerResource:GetTeam(data.PlayerID))
    hDummy:SetControllableByPlayer(self.m_nPlayerID, true)
    hDummy:Hold()
    EmitGlobalSound("UI.Button.Pressed")
    hDummy:AddNewModifier(hPlayerHero, nil, "modifier_phased", {
        duration = 0.1
    })
end

-- Create the enemy for unit slot 3
function HeroDemo:CreepTarget_Enemy_3(eventSourceIndex, data)
    local hPlayerHero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
    if hPlayerHero == nil then
        return
    end

    local unitName = self:GetSpawnUnitSlot("slot3")

    local team = DOTA_TEAM_GOODGUYS
    if hPlayerHero:GetTeam() == team then
        team = DOTA_TEAM_BADGUYS
    end

    local hDummy = CreateUnitByName(unitName, hPlayerHero:GetAbsOrigin(), true, nil, nil, team)
    hDummy:SetControllableByPlayer(self.m_nPlayerID, true)
    hDummy:Hold()
    EmitGlobalSound("UI.Button.Pressed")
    hDummy:AddNewModifier(hDummy, nil, "modifier_phased", {
        duration = 0.1
    })
end

-- Create the friend for unit slot 3
function HeroDemo:CreepTarget_Friend_3(eventSourceIndex, data)
    local hPlayerHero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
    if hPlayerHero == nil then
        return
    end

    local unitName = self:GetSpawnUnitSlot("slot3")
    local hDummy = CreateUnitByName(unitName, hPlayerHero:GetAbsOrigin(), true, hPlayerHero, hPlayerHero,
        PlayerResource:GetTeam(data.PlayerID))
    hDummy:SetControllableByPlayer(self.m_nPlayerID, true)
    hDummy:Hold()
    EmitGlobalSound("UI.Button.Pressed")
    hDummy:AddNewModifier(hPlayerHero, nil, "modifier_phased", {
        duration = 0.1
    })
end

function HeroDemo:AbilitySelect_ADD(eventSourceIndex, data)
    local abilityName = Convars:GetStr("dota_default_ability_name")
    local level = 1
    if HeroDemo.selectedUnits then
        for _, unit in ipairs(HeroDemo.selectedUnits) do
            AddAbilityAndSetLevel(unit, abilityName, level)
            local ab=unit:FindAbilityByName(abilityName)
            ab:SetHidden(false)
        end
    end
end
function HeroDemo:AbilitySelect_REMOVE(eventSourceIndex, data)
    local abilityName = Convars:GetStr("dota_default_ability_name")
    if HeroDemo.selectedUnits then
        for _, unit in ipairs(HeroDemo.selectedUnits) do
            unit:RemoveAbility(abilityName)
        end
    end
end
--------------------------------------------------------------------------------
-- ButtonEvent: OnTowersEnabledButtonPressed
--------------------------------------------------------------------------------
function HeroDemo:OnTowersEnabledButtonPressed(eventSourceIndex)
    -- Flip the global
    HERO_DEMO_TOWERS_ENABLED = not HERO_DEMO_TOWERS_ENABLED

    if HERO_DEMO_TOWERS_ENABLED then
        print("Enabling Towers")
        self:SetTowersEnabled(true)
        self:BroadcastMsg("#TowersEnabledOn_Msg")
    else
        print("Disabling Towers")
        self:SetTowersEnabled(false)
        self:BroadcastMsg("#TowersEnabledOff_Msg")
    end

    -- Sync the UI state into CustomNetTables
    CustomNetTables:SetTableValue("game_global", "ui_defaults", {
        WTFEnabled = Convars:GetInt("dota_ability_debug"),
        SpawnCreepsEnabled = HERO_DEMO_SPAWN_CREEPS_ENABLED and 1 or 0,
        TowersEnabled = HERO_DEMO_TOWERS_ENABLED and 1 or 0,
        AttackArmorTypeDisabled = HERO_DEMO_ATTACK_ARMOR_TYPE_DISABLED and 1 or 0,
        AIDisabled = HERO_DEMO_AI_DISABLED and 1 or 0
    })

    EmitGlobalSound("UI.Button.Pressed")
end

function HeroDemo:SetTowersEnabled(bEnabled)

    print("SetTowersEnabled: " .. tostring(bEnabled))
    for _, tTower in pairs(self.m_rgTowers) do
        local hTower = tTower.hUnit

        if hTower ~= nil and not hTower:IsNull() then
            if not hTower:IsAlive() and hTower:UnitCanRespawn() then
                print(" respawning " .. tTower.sName)
                hTower:SetOriginalModel(tTower.sOriginalModel)
                hTower:RespawnUnit()
                hTower:RemoveModifierByName("modifier_invulnerable")
            end

            print(" enabling " .. tTower.sName .. " " .. tostring(bEnabled))
            if bEnabled then
                hTower:RemoveModifierByName("modifier_invulnerable")
            else
                hTower:AddNewModifier(hTower, nil, "modifier_invulnerable", {})
            end
        end
    end
end

function HeroDemo:FindTowers()
    print("FindTowers")
    self.m_rgTowers = {}
    local nInclusiveTypeFlags = DOTA_UNIT_TARGET_FLAG_DEAD + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES +
                                    DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
    local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE,
        DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, nInclusiveTypeFlags, FIND_ANY_ORDER, false)
    for _, hUnit in pairs(units) do
        if hUnit:IsTower() then
            local tTower = {
                hUnit = hUnit,
                sName = hUnit:GetUnitName(),
                sOriginalModel = hUnit:GetModelName()
            }
            hUnit:SetUnitCanRespawn(true)
            self.m_rgTowers[#self.m_rgTowers + 1] = tTower
            --[[if hUnit:GetUnitName() == "npc_dota_goodguys_tower1_mid" then
				hUnit:SetUnitCanRespawn( true )
				self.m_rgTowers[1] = tTower
			elseif hUnit:GetUnitName() == "npc_dota_badguys_tower1_mid" then
				hUnit:SetUnitCanRespawn( true )
				self.m_rgTowers[2] = tTower
			end]]
        end
    end
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnSpawnCreepsButtonPressed
--------------------------------------------------------------------------------
function HeroDemo:OnSpawnCreepsButtonPressed(eventSourceIndex)
    -- Flip the global
    HERO_DEMO_SPAWN_CREEPS_ENABLED = not HERO_DEMO_SPAWN_CREEPS_ENABLED

    if HERO_DEMO_SPAWN_CREEPS_ENABLED then
        print("Enabling Creep Spawns")
        SendToServerConsole("dota_creeps_no_spawning 0")
        SendToServerConsole("dota_spawn_creeps")
        self:BroadcastMsg("#SpawnCreepsOn_Msg")
    else
        print("Disabling Creep Spawns")
        self:RemoveCreeps()
        SendToServerConsole("dota_creeps_no_spawning 1")
        self:BroadcastMsg("#SpawnCreepsOff_Msg")
    end

    -- Sync the UI state into CustomNetTables
    CustomNetTables:SetTableValue("game_global", "ui_defaults", {
        WTFEnabled = Convars:GetInt("dota_ability_debug"),
        SpawnCreepsEnabled = HERO_DEMO_SPAWN_CREEPS_ENABLED and 1 or 0,
        TowersEnabled = HERO_DEMO_TOWERS_ENABLED and 1 or 0,
        AttackArmorTypeDisabled = HERO_DEMO_ATTACK_ARMOR_TYPE_DISABLED and 1 or 0,
        AIDisabled = HERO_DEMO_AI_DISABLED and 1 or 0
    })

    EmitGlobalSound("UI.Button.Pressed")
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnSpawnSingleCreepWaveButtonPressed
--------------------------------------------------------------------------------
function HeroDemo:OnSpawnSingleCreepWaveButtonPressed(eventSourceIndex)
    SendToServerConsole("dota_spawn_creeps")
    EmitGlobalSound("UI.Button.Pressed")
end

function HeroDemo:copyUnitProperty(source, target)

    local creep=target
    local unit=source
    if creep:GetLevel()<unit:GetLevel() then
        creep:CreatureLevelUp(unit:GetLevel()-creep:GetLevel())
    end
    -- copy ability
    local slotCount = unit:GetAbilityCount() or 0
    for i = 0, slotCount - 1 do
        local ab = unit:GetAbilityByIndex(i)
        if ab then
            local abName = (ab:GetAbilityName())

            if not creep:HasAbility(abName) then
                AddAbilityAndSetLevel(creep,abName,ab:GetLevel())
            end
        end
    end
    if unit:HasModifier("modifier_generic_agh_scepter") then
        creep:AddNewModifier(creep, nil, "modifier_generic_agh_scepter", {})
    end
    -- copy items
    local items={}
    for i = 0, 10, 1 do
        local item= unit:GetItemInSlot(i)
        if item then
            table.insert(items,item:GetName())
        end
    end
    for _, itemName in ipairs(items) do
        AddItemToUnit(creep, itemName)
    end

end
function HeroDemo:Clone_BUTTON(eventSourceIndex, data)
    EmitGlobalSound("UI.Button.Pressed")
    local nHeroEntIndex = tonumber(data.str)
    local hHero = EntIndexToHScript(nHeroEntIndex)

    print("clone")
    for key, unit in pairs(HeroDemo.selectedUnits) do
        local unitName = unit:GetUnitName()
        local pos = unit:GetAbsOrigin()
        local team=unit:GetTeamNumber()
        local hero = PlayerResource:GetSelectedHeroEntity(0)
        local creep = CreateUnitByName(unitName, pos, true, hero, hero, team)

        HeroDemo:copyUnitProperty(unit, creep)
        local angle_now = unit:GetAnglesAsVector()
        if creep then
            creep:SetControllableByPlayer(hero:GetPlayerID(), true)
            creep:SetAngles(angle_now.x, angle_now.y, angle_now.z)
            creep:AddNewModifier(hero, nil, "modifier_phased", {
                duration = 0.1
            })
        end
    end

end

function HeroDemo:WearableHero_Button(eventSourceIndex, data)
    EmitGlobalSound("UI.Button.Pressed")

    local sHeroToSpawn = Convars:GetStr("dota_hero_demo_default_enemy")
    print(sHeroToSpawn)
    GenerateDefaultBlock(sHeroToSpawn)

end

function HeroDemo:WearableBundle_Button(eventSourceIndex, data)
    EmitGlobalSound("UI.Button.Pressed")
    local sHeroToSpawn = Convars:GetStr("dota_hero_demo_default_enemy")
    GenerateAllBundleBlock(sHeroToSpawn)

end
function HeroDemo:WearableImmortal_Button(eventSourceIndex, data)
    EmitGlobalSound("UI.Button.Pressed")
    local sHeroToSpawn = Convars:GetStr("dota_hero_demo_default_enemy")
    GenerateAllImmortal(sHeroToSpawn)
end

function HeroDemo:WearablePart_Button(eventSourceIndex, data)
    EmitGlobalSound("UI.Button.Pressed")
    local sHeroToSpawn = Convars:GetStr("dota_hero_demo_default_enemy")
    GenerateAllPart(sHeroToSpawn)
end

--------------------------------------------------------------------------------

function HeroDemo:RemoveCreeps()

    print("Removing Creeps")
    local nInclusiveTypeFlags = DOTA_UNIT_TARGET_FLAG_DEAD + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES +
                                    DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
    local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE,
        DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, nInclusiveTypeFlags, FIND_ANY_ORDER, false)
    for _, hUnit in pairs(units) do
        if hUnit:IsCreep() and not hUnit:IsControllableByAnyPlayer() then
            hUnit:Destroy()
        end
    end

end

--------------------------------------------------------------------------------
-- SpawnRuneInFrontOfUnit - Helper method for rune spawning
--------------------------------------------------------------------------------
function HeroDemo:SpawnRuneInFrontOfUnit(hUnit, runeType)
    if hUnit == nil then
        return
    end

    local fDistance = 200.0
    local fMinSeparation = 50.0
    local fRingOffset = fMinSeparation + 20.0
    local vDir = hUnit:GetForwardVector()
    local vInitialTarget = hUnit:GetAbsOrigin() + vDir * fDistance
    vInitialTarget.z = GetGroundHeight(vInitialTarget, nil)
    local vTarget = vInitialTarget
    local nRemainingAttempts = 100
    local fAngle = 2 * math.pi
    local fOffset = 0.0
    local bDone = false

    local vecRunes = Entities:FindAllByClassname("dota_item_rune")
    while (not bDone and nRemainingAttempts > 0) do
        bDone = true
        -- Too close to other runes?
        for i = 1, #vecRunes do
            if (vecRunes[i]:GetAbsOrigin() - vTarget):Length() < fMinSeparation then
                bDone = false
                break
            end
        end
        if not GridNav:CanFindPath(hUnit:GetAbsOrigin(), vTarget) then
            bDone = false
        end
        if not bDone then
            fAngle = fAngle + 2 * math.pi / 8
            if fAngle >= 2 * math.pi then
                fOffset = fOffset + fRingOffset
                fAngle = 0
            end
            vTarget = vInitialTarget + fOffset * Vector(math.cos(fAngle), math.sin(fAngle), 0.0)
            vTarget.z = GetGroundHeight(vTarget, nil)
        end
        nRemainingAttempts = nRemainingAttempts - 1
    end

    CreateRune(vTarget, runeType)
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnSpawnRuneDoubleDamagePressed
--------------------------------------------------------------------------------
function HeroDemo:OnSpawnRuneDoubleDamagePressed(eventSourceIndex, data)
    local hPlayerHero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
    if hPlayerHero == nil then
        return
    end

    self:SpawnRuneInFrontOfUnit(hPlayerHero, DOTA_RUNE_DOUBLEDAMAGE)
    EmitGlobalSound("UI.Button.Pressed")
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnSpawnRuneHastePressed
--------------------------------------------------------------------------------
function HeroDemo:OnSpawnRuneHastePressed(eventSourceIndex, data)
    local hPlayerHero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
    if hPlayerHero == nil then
        return
    end

    self:SpawnRuneInFrontOfUnit(hPlayerHero, DOTA_RUNE_HASTE)
    EmitGlobalSound("UI.Button.Pressed")
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnSpawnRuneIllusionPressed
--------------------------------------------------------------------------------
function HeroDemo:OnSpawnRuneIllusionPressed(eventSourceIndex, data)
    local hPlayerHero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
    if hPlayerHero == nil then
        return
    end

    self:SpawnRuneInFrontOfUnit(hPlayerHero, DOTA_RUNE_ILLUSION)
    EmitGlobalSound("UI.Button.Pressed")
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnSpawnRuneInvisibilityPressed
--------------------------------------------------------------------------------
function HeroDemo:OnSpawnRuneInvisibilityPressed(eventSourceIndex, data)
    local hPlayerHero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
    if hPlayerHero == nil then
        return
    end

    self:SpawnRuneInFrontOfUnit(hPlayerHero, DOTA_RUNE_INVISIBILITY)
    EmitGlobalSound("UI.Button.Pressed")
end

--------------------------------------------------------------------------------

function HeroDemo:GetRuneSpawnLocation()

end

--------------------------------------------------------------------------------
-- ButtonEvent: OnSpawnRuneRegenerationPressed
--------------------------------------------------------------------------------
function HeroDemo:OnSpawnRuneRegenerationPressed(eventSourceIndex, data)
    local hPlayerHero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
    if hPlayerHero == nil then
        return
    end

    self:SpawnRuneInFrontOfUnit(hPlayerHero, DOTA_RUNE_REGENERATION)
    EmitGlobalSound("UI.Button.Pressed")
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnSpawnRuneArcanePressed
--------------------------------------------------------------------------------
function HeroDemo:OnSpawnRuneArcanePressed(eventSourceIndex, data)
    local hPlayerHero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
    if hPlayerHero == nil then
        return
    end

    self:SpawnRuneInFrontOfUnit(hPlayerHero, DOTA_RUNE_ARCANE)
    EmitGlobalSound("UI.Button.Pressed")
end
--------------------------------------------------------------------------------
-- GameEvent: OnChangeCosmeticsButtonPresse
--------------------------------------------------------------------------------
function HeroDemo:OnChangeCosmeticsButtonPressed(eventSourceIndex)
    -- currently running the command directly in XML, should run it here if possible
    -- can use GetSelectedHeroID

    EmitGlobalSound("UI.Button.Pressed")
end

--------------------------------------------------------------------------------
-- GameEvent: OnChangeHeroButtonPressed
--------------------------------------------------------------------------------
function HeroDemo:OnChangeHeroButtonPressed(eventSourceIndex, data)
    -- currently running the command directly in XML, should run it here if possible
    local nHeroID = PlayerResource:GetSelectedHeroID(data.PlayerID)
    print("PlayerResource:GetSelectedHeroID( data.PlayerID ) == " .. nHeroID)

    EmitGlobalSound("UI.Button.Pressed")
end

--------------------------------------------------------------------------------
-- GameEvent: OnPauseButtonPressed
--------------------------------------------------------------------------------
function HeroDemo:OnPauseButtonPressed(eventSourceIndex)
    SendToServerConsole("dota_pause")

    EmitGlobalSound("UI.Button.Pressed")
end

--------------------------------------------------------------------------------
-- GameEvent: OnLeaveButtonPressed
--------------------------------------------------------------------------------
function HeroDemo:OnLeaveButtonPressed(eventSourceIndex)
    EmitGlobalSound("UI.Button.Pressed")

    SendToServerConsole("disconnect")
end

function HeroDemo:BroadcastMsg(sMsg)
    -- Display a message about the button action that took place
    local buttonEventMessage = sMsg
    -- print( buttonEventMessage )
    local centerMessage = {
        message = buttonEventMessage,
        duration = 1.0,
        clearQueue = true -- this doesn't seem to work
    }
    FireGameEvent("show_center_message", centerMessage)
end

function HeroDemo:LoadAllUnit()
    local kvs = LoadKeyValues( "scripts/npc/npc_units_custom.txt")
    local kvs2 = LoadKeyValues( "scripts/npc/npc_units.txt")

    local units={}

    for key, value in pairs(kvs) do
        table.insert(units,key)
    end
    for key, value in pairs(kvs2) do
        table.insert(units,key)
    end
    CustomNetTables:SetTableValue("dev", "units", {
        units=units
    })
end
function HeroDemo:LoadAllAbility()
    local kvs = LoadKeyValues( "scripts/npc/npc_abilities_custom.txt")
    local abilities={}
    for key, value in pairs(kvs) do
        table.insert(abilities,key)
    end
    CustomNetTables:SetTableValue("dev", "abilities", {
        abilities=abilities
    })
end
HeroDemo:LoadAllUnit()
HeroDemo:LoadAllAbility()
