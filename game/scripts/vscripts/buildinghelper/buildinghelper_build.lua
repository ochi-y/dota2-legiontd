LinkLuaModifier("modifier_buildinghelper_build", "buildinghelper/buildinghelper_build.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities

buildinghelper_build = class({})

build_legiontd_marci = buildinghelper_build
local function IsUnitCountLimitReached(playerID, unitName)
	local limit = tonumber(GetUnitKV(unitName, "UnitCountLimit"))
	if not limit or limit <= 0 then
		return false
	end

	local count = BuildingHelper:GetBuildingCount(playerID, unitName, true)
	return count >= limit
end

build_arctic_young_frost_dragon = buildinghelper_build
build_arctic_wandigoo = buildinghelper_build
build_arctic_polar_bear = buildinghelper_build
build_arctic_ice_troll = buildinghelper_build
build_arctic_frost_wolf = buildinghelper_build
build_arctic_tuskarr = buildinghelper_build
test_build_beast_ogre_spawn_of_dragon = buildinghelper_build
--
build_shape_shifter_tier_6 = buildinghelper_build
build_shape_shifter_tier_5 = buildinghelper_build
build_shape_shifter_tier_4 = buildinghelper_build
build_shape_shifter_tier_3 = buildinghelper_build
build_shape_shifter_tier_2 = buildinghelper_build
build_shape_shifter_tier_1 = buildinghelper_build
--
build_undead_necromancer = buildinghelper_build
build_undead_zombie = buildinghelper_build
build_undead_acolyte = buildinghelper_build
build_undead_meta_wagon = buildinghelper_build
build_undead_ghoul = buildinghelper_build
build_undead_zombie = buildinghelper_build
build_undead_guardian_of_death = buildinghelper_build
---
build_shadow_bone_warrior = buildinghelper_build
build_shadow_carrion_spitter = buildinghelper_build
build_shadow_overseer = buildinghelper_build
build_shadow_gateguard = buildinghelper_build
build_shadow_nightmare = buildinghelper_build
build_shadow_lord_of_death = buildinghelper_build


--

--
build_beast_gnoll_warrior = buildinghelper_build
build_beast_ogre_basher = buildinghelper_build
build_beast_ogre_harpy = buildinghelper_build
build_beast_ogre_troll_fighter = buildinghelper_build
build_beast_ogre_grizzly = buildinghelper_build
build_beast_ogre_spawn_of_dragon = buildinghelper_build
--
build_demi_human_goblin_scientist = buildinghelper_build
build_demi_human_servant = buildinghelper_build
build_demi_human_tribesman = buildinghelper_build
build_demi_human_medicine_man = buildinghelper_build
build_demi_human_harlot = buildinghelper_build
build_demi_human_minotaur = buildinghelper_build
--
build_element_proton = buildinghelper_build
build_element_aqua_spirit = buildinghelper_build
build_element_watcher = buildinghelper_build
build_element_mudman = buildinghelper_build
build_element_disciple = buildinghelper_build
build_element_seer_of_darkness = buildinghelper_build
--
build_elf_colt = buildinghelper_build
build_elf_novice = buildinghelper_build
build_elf_sentry = buildinghelper_build
build_elf_prisoner = buildinghelper_build
build_elf_druid = buildinghelper_build
build_elf_moon_guard = buildinghelper_build
--
build_ghost_specter = buildinghelper_build
build_ghost_wanderer = buildinghelper_build
build_ghost_phantom = buildinghelper_build
build_ghost_outcast = buildinghelper_build
build_ghost_apparition = buildinghelper_build
build_ghost_dark_priest = buildinghelper_build

--
build_goblin_small_land_mine = buildinghelper_build
build_goblin_machine_turret = buildinghelper_build
build_goblin_flying_machine = buildinghelper_build
build_goblin_goblin_alchemist = buildinghelper_build
build_goblin_geomancer = buildinghelper_build
build_goblin_steamroller = buildinghelper_build

--
build_marine_hatchling = buildinghelper_build
build_marine_egg_sack = buildinghelper_build
build_marine_bottom_feeder = buildinghelper_build
build_marine_mermaid = buildinghelper_build
build_marine_komodo = buildinghelper_build
build_marine_sea_giant = buildinghelper_build
--
build_mech_peewee = buildinghelper_build
build_mech_infantry = buildinghelper_build
build_mech_captain = buildinghelper_build
build_mech_tempest = buildinghelper_build
build_mech_cyborg = buildinghelper_build
build_mech_neotank = buildinghelper_build

--
build_nature_ent = buildinghelper_build
build_nature_ranger = buildinghelper_build
build_nature_sprite = buildinghelper_build
build_nature_tree_of_travel = buildinghelper_build
build_nature_halfbreed = buildinghelper_build
build_nature_yggdrasil = buildinghelper_build
--
build_orc_orc_warrior = buildinghelper_build
build_orc_orc_warlock = buildinghelper_build
build_orc_raider = buildinghelper_build

build_orc_young_witch_doctor = buildinghelper_build
build_orc_wyvern = buildinghelper_build
build_orc_orc_warchief = buildinghelper_build
--
build_paladin_peasant = buildinghelper_build
build_paladin_archer = buildinghelper_build
build_paladin_footman = buildinghelper_build
build_paladin_priest = buildinghelper_build
build_paladin_knight = buildinghelper_build
build_paladin_dragon_hawk = buildinghelper_build

--
build_radiant_soldier = buildinghelper_build
build_radiant_serpent_ward = buildinghelper_build
build_radiant_juggernaut = buildinghelper_build
build_radiant_relict = buildinghelper_build
build_radiant_ember_spirit = buildinghelper_build
build_radiant_thunder_beast = buildinghelper_build
build_radiant_shadow_shaman = buildinghelper_build
--
build_foulfell_spiderling = buildinghelper_build
build_foulfell_bandit = buildinghelper_build
build_foulfell_golem_tower = buildinghelper_build
build_foulfell_medusa = buildinghelper_build
build_foulfell_night_stalker = buildinghelper_build
build_foulfell_spectre = buildinghelper_build


function buildinghelper_build:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	local unitName = self:GetAbilityKeyValues()['UnitName']
	if unitName == "self" then
		unitName = caster:GetUnitName()
	end
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

	-- if CANT_BUILD_IN_PRE_GAME and GameRules:State_Get()<DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
	-- 	local orderPlayerId = self.lastOrderPlayerId
	-- 	SendErrorMessage(orderPlayerId, "error_cant_build_now")
	-- 	return
	-- end

	Build(event)
	-- for i = 0, 5, 1 do
	-- 	local ab=caster:GetAbilityByIndex(i)
	-- 	if ab then
	-- 		-- ab:StartCooldown(0.5)
	-- 	end
	-- end
end

-- function buildinghelper_build:GetHealthCost(level)
-- 	if IsServer() then
-- 		return 0
-- 	else
-- 		return self:GetSpecialValueFor("gold")
-- 	end
-- end
