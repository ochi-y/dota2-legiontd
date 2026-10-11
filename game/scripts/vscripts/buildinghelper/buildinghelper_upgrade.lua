LinkLuaModifier("modifier_buildinghelper_upgrade", "buildinghelper/buildinghelper_upgrade.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities

buildinghelper_upgrade = class({})

upgrade_legiontd_marci_lv2 = buildinghelper_upgrade
local function IsUnitCountLimitReached(playerID, unitName)
	local limit = tonumber(GetUnitKV(unitName, "UnitCountLimit"))
	if not limit or limit <= 0 then
		return false
	end

	local count = BuildingHelper:GetBuildingCount(playerID, unitName, true)
	return count >= limit
end

upgrade_elf_puck = buildinghelper_upgrade
upgrade_elf_hoodwink = buildinghelper_upgrade
upgrade_marine_largo = buildinghelper_upgrade
upgrade_arctic_azure_dragon = buildinghelper_upgrade
upgrade_arctic_ancient_wandigoo = buildinghelper_upgrade
upgrade_arctic_magnataur = buildinghelper_upgrade
upgrade_arctic_ice_troll_shaman = buildinghelper_upgrade
upgrade_arctic_pandaren = buildinghelper_upgrade
upgrade_arctic_tuskarr_spearman = buildinghelper_upgrade
upgrade_elf_sword_mage_elite = buildinghelper_upgrade
upgrade_elf_ascendant_elite = buildinghelper_upgrade
upgrade_elf_maverick_elite = buildinghelper_upgrade
upgrade_elf_crusader_elite = buildinghelper_upgrade

upgrade_undead_ghost = buildinghelper_upgrade
upgrade_undead_necrolyte = buildinghelper_upgrade
upgrade_undead_war_machine = buildinghelper_upgrade
upgrade_undead_freezen_ghoul = buildinghelper_upgrade
upgrade_undead_revenant = buildinghelper_upgrade
upgrade_undead_ghost = buildinghelper_upgrade
upgrade_undead_the_butcher = buildinghelper_upgrade
upgrade_undead_the_butcher = buildinghelper_upgrade
upgrade_undead_death_dragon = buildinghelper_upgrade
--
upgrade_shadow_hades = buildinghelper_upgrade

upgrade_shadow_skeletor = buildinghelper_upgrade
upgrade_shadow_fire_archer = buildinghelper_upgrade
upgrade_shadow_dark_mage = buildinghelper_upgrade
upgrade_shadow_carrion_nightcrawler = buildinghelper_upgrade
upgrade_shadow_carrion_harbinger = buildinghelper_upgrade
upgrade_shadow_keeper_of_souls = buildinghelper_upgrade
upgrade_shadow_doppelganger = buildinghelper_upgrade
--

--
upgrade_beast_gnoll_savage = buildinghelper_upgrade
upgrade_beast_ogre_pulverizer = buildinghelper_upgrade
upgrade_beast_ogre_medusa = buildinghelper_upgrade
upgrade_beast_ogre_troll_champion = buildinghelper_upgrade
upgrade_beast_ogre_greymane = buildinghelper_upgrade
upgrade_beast_ogre_dragon_aspect = buildinghelper_upgrade
--
upgrade_demi_human_dwarven_engineer = buildinghelper_upgrade
upgrade_demi_human_mutant = buildinghelper_upgrade
upgrade_demi_human_slavemaster = buildinghelper_upgrade
upgrade_demi_human_alpha_male = buildinghelper_upgrade
upgrade_demi_human_oracle = buildinghelper_upgrade
upgrade_demi_human_mistress = buildinghelper_upgrade
upgrade_demi_human_bigfoot = buildinghelper_upgrade
--
upgrade_element_adept = buildinghelper_upgrade
upgrade_element_oceanus = buildinghelper_upgrade
upgrade_element_violet = buildinghelper_upgrade
upgrade_element_golem = buildinghelper_upgrade
upgrade_element_messiah = buildinghelper_upgrade
upgrade_element_fenix = buildinghelper_upgrade
--
upgrade_elf_rider = buildinghelper_upgrade
upgrade_elf_crusader = buildinghelper_upgrade
upgrade_elf_nightsaber = buildinghelper_upgrade
upgrade_elf_maverick = buildinghelper_upgrade
upgrade_elf_ascendant = buildinghelper_upgrade
upgrade_elf_sword_mage = buildinghelper_upgrade
upgrade_elf_warden = buildinghelper_upgrade
upgrade_elf_warden_elite = buildinghelper_upgrade
upgrade_elf_nightsaber_elite = buildinghelper_upgrade
upgrade_elf_rider_elite = buildinghelper_upgrade
--
upgrade_ghost_wraith = buildinghelper_upgrade
upgrade_ghost_mercurial = buildinghelper_upgrade
upgrade_ghost_soul_of_hero = buildinghelper_upgrade
upgrade_ghost_soul_of_villain = buildinghelper_upgrade
upgrade_ghost_hell_raiser = buildinghelper_upgrade
upgrade_ghost_forsaken_one = buildinghelper_upgrade
upgrade_ghost_gravekeeper = buildinghelper_upgrade
upgrade_ghost_meridian = buildinghelper_upgrade
--
upgrade_goblin_medium_land_mine = buildinghelper_upgrade

upgrade_goblin_ultra_land_mine = buildinghelper_upgrade

upgrade_goblin_clockwreck = buildinghelper_upgrade

upgrade_goblin_machine_robot = buildinghelper_upgrade

upgrade_goblin_helicopter = buildinghelper_upgrade
upgrade_goblin_goblin_blaster = buildinghelper_upgrade
upgrade_goblin_assault_tank = buildinghelper_upgrade
--
upgrade_marine_swamprunner = buildinghelper_upgrade
upgrade_marine_fangtooth = buildinghelper_upgrade

upgrade_marine_defiler = buildinghelper_upgrade
upgrade_marine_sky_dragon = buildinghelper_upgrade
upgrade_marine_king_claw = buildinghelper_upgrade
upgrade_marine_highborne = buildinghelper_upgrade
upgrade_marine_trident = buildinghelper_upgrade

upgrade_marine_hydra = buildinghelper_upgrade
upgrade_marine_froglet_mage = buildinghelper_upgrade
upgrade_marine_grown_frog_mage = buildinghelper_upgrade
--
upgrade_mech_veteran = buildinghelper_upgrade
upgrade_mech_zeus = buildinghelper_upgrade
upgrade_mech_pyro = buildinghelper_upgrade
upgrade_mech_admiral = buildinghelper_upgrade
upgrade_mech_leviathan = buildinghelper_upgrade
upgrade_mech_krogoth = buildinghelper_upgrade
upgrade_mech_doomsday_machine = buildinghelper_upgrade
--
upgrade_nature_guardian = buildinghelper_upgrade
upgrade_nature_meliai = buildinghelper_upgrade
upgrade_nature_thunderbird = buildinghelper_upgrade
upgrade_nature_tree_of_time = buildinghelper_upgrade
upgrade_nature_goliath = buildinghelper_upgrade
upgrade_nature_tree_of_life = buildinghelper_upgrade
upgrade_nature_tree_of_knowledge = buildinghelper_upgrade
--

upgrade_orc_blood_orc_warrior = buildinghelper_upgrade

upgrade_orc_wolverine = buildinghelper_upgrade

upgrade_orc_blood_orc_warlock = buildinghelper_upgrade
upgrade_orc_blood_raider = buildinghelper_upgrade
upgrade_orc_elder_witch_doctor = buildinghelper_upgrade
upgrade_orc_wind_rider = buildinghelper_upgrade
upgrade_orc_thrall = buildinghelper_upgrade
--
upgrade_paladin_militia = buildinghelper_upgrade
upgrade_paladin_elite_archer = buildinghelper_upgrade
upgrade_paladin_guard = buildinghelper_upgrade
upgrade_paladin_high_priest = buildinghelper_upgrade
upgrade_paladin_cavalier = buildinghelper_upgrade
upgrade_paladin_royal_griffin = buildinghelper_upgrade

--
upgrade_radiant_mars = buildinghelper_upgrade
upgrade_radiant_crow_ward = buildinghelper_upgrade
upgrade_radiant_blademaster = buildinghelper_upgrade
upgrade_radiant_wukong = buildinghelper_upgrade
upgrade_radiant_ashes = buildinghelper_upgrade
upgrade_radiant_storm_spirit = buildinghelper_upgrade
upgrade_radiant_marauder = buildinghelper_upgrade
upgrade_radiant_kez_sai = buildinghelper_upgrade
upgrade_radiant_kez_katana = buildinghelper_upgrade
--
upgrade_foulfell_araknarok = buildinghelper_upgrade
upgrade_foulfell_mechanical_spiderling = buildinghelper_upgrade
upgrade_foulfell_lycosidae_spiderling = buildinghelper_upgrade
upgrade_foulfell_elite_bandit = buildinghelper_upgrade
upgrade_foulfell_ancient_golem_tower = buildinghelper_upgrade
upgrade_foulfell_death_adder = buildinghelper_upgrade
upgrade_foulfell_darkheart = buildinghelper_upgrade
upgrade_foulfell_shadowveil = buildinghelper_upgrade

function buildinghelper_upgrade:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local unitName = self:GetAbilityKeyValues()['UnitName']
	local pid = caster:GetPlayerOwnerID()
	if unitName and IsUnitCountLimitReached(pid, unitName) then
		SendErrorMessage(self.lastOrderPlayerId or pid, "error_max_build_count")
		return
	end
	local event = {}
	event.ability = self
	event.attack = caster
	event.caster = caster
	event.caster_index = caster:entindex()
	event.unit = caster
	GamePlay:upgradeBuilding(event)
end

-- function buildinghelper_upgrade:GetHealthCost(level)
-- 	if IsServer() then
-- 		return 0
-- 	else
-- 		return self:GetSpecialValueFor("gold")
-- 	end
-- end
