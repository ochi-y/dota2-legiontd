-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode
BAREBONES_VERSION = "2.0.13"

-- Selection library (by Noya) provides player selection inspection and management from server lua
require('libraries/selection')
require('libraries/animations')
require('libraries/bit')
require('utils/json')
require('utils/effect')
require('ai/ai_core')
require('custom_abilities')
-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')
-- filters.lua
require('filters')
require("teckTree")
require("player")
require("gameplay")
require("storage")
require("cmd")

require("libraries/custom_illusions")

--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function barebones:PostLoadPrecache()
	DebugPrint("[BAREBONES] Performing Post-Load precache.")
	
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]

local heroNames = {
	"npc_dota_hero_tusk",
	"npc_dota_hero_luna",
	"npc_dota_hero_meepo",
	"npc_dota_hero_puck",
	"npc_dota_hero_windrunner",
	"npc_dota_hero_dragon_knight",
}

-- assign heroes randomly
function barebones:assignRandomHero()
	DebugPrint("[BAREBONES] All Players have loaded into the game.")
	--
	-- Force Random a hero for every player that didnt pick a hero when time runs out
    local delay = HERO_SELECTION_TIME + HERO_SELECTION_PENALTY_TIME + STRATEGY_TIME - 0.1
    if ENABLE_BANNING_PHASE then
      delay = delay + BANNING_PHASE_TIME
    end
    Timers:CreateTimer(delay, function()
      for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do

        if PlayerResource:IsValidPlayerID(playerID) then
          -- If this player still hasn't picked a hero, random one
          -- PlayerResource:IsConnected(index) is custom-made! Can be found in 'player_resource.lua' library
          if not PlayerResource:HasSelectedHero(playerID) and PlayerResource:IsConnected(playerID) and not PlayerResource:IsBroadcaster(playerID) then
            -- PlayerResource:GetPlayer(playerID):MakeRandomHeroSelection() -- this will cause an error if player is disconnected, that's why we check if player is connected
            -- PlayerResource:SetHasRandomed(playerID)
            -- PlayerResource:SetCanRepick(playerID, false)
			local player = PlayerResource:GetPlayer(playerID)
			local rd = RandomInt(1,#heroNames)
			CreateHeroForPlayer(heroNames[rd],player):RemoveSelf()
            DebugPrint("[BAREBONES] Randomed a hero for a player number "..playerID)
          end
        end
      end
    end)
  
  end
function barebones:OnAllPlayersLoaded()
  DebugPrint("[BAREBONES] All Players have loaded into the game.")
end

function barebones:setBaseGamemode(gamemode)
	print("setBaseGamemode "..gamemode)
	if not GameRules.baseGamemode then
		GameRules.baseGamemode=gamemode
	end
end
function barebones:setDiff(diff)
	print("setDiff "..diff)
	if not GameRules.diff then
		GameRules.diff = diff
	end
end
function barebones:setHeroGamemode(gamemode)
	print("setHeroGamemode "..gamemode)
	if not GameRules.heroGamemode then
		GameRules.heroGamemode=gamemode
	end
	local config = {
		diff = GameRules.diff,
		baseGamemode=GameRules.baseGamemode,
		heroGamemode=GameRules.heroGamemode
	}
	GameRules.gamemodeDone = true 
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function barebones:OnGameInProgress()
	DebugPrint("[BAREBONES] The game has officially begun.")
	Timers:CreateTimer(0, function()
		if GameRules.gamemodeDone then
			return nil
		end
		return 1
	end)
end


function barebones:getMinKills()
	local min = PlayerResource:GetLastHits(0)
	local player = 0
	for i=1,3 do
		if PlayerResource:IsValidPlayer(i) then
			local num = PlayerResource:GetLastHits(i)
			if num<min then
				min=num
				player = i
			end
		end
	end
	if  PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)<4 then
		return nil
	end
	return player
end

function barebones:awardMinLastHit(pid,gold)
	local hero = PlayerResource:GetSelectedHeroEntity(pid)
	if hero then
		EmitSoundOn("General.CoinsBig", hero)
		Player:ModifyGold( pid,gold )
		SimpleOverheadMsg(hero,OVERHEAD_ALERT_GOLD,gold)
	end
end

function barebones:awardWave(wave)
	local min = barebones:getMinKills()
	for i=1,4 do
		local id = i -1
		if PlayerResource:IsValidPlayer(id) then
			local hero = PlayerResource:GetSelectedHeroEntity(id)
			if hero then
				local gold = 0
				if wave~=1 then
					gold = (wave)*6
					if id==min and wave>=7 then
						Timers:CreateTimer(2,function ()
							barebones:awardMinLastHit(id,gold)
						end)
					end
					EmitSoundOn("General.CoinsBig", hero)
					Player:ModifyGold( id,gold )
					SimpleOverheadMsg(hero,OVERHEAD_ALERT_GOLD,gold)
				end
				if wave>=40 then
					if hero:HasModifier("modifier_xiaotou_gaolidai_hero") then
						Timers:CreateTimer(1,function ()
							local gaolidai = math.min(math.floor(GetGold(id) * 0.1),4000)
							Player:ModifyGold( id,gaolidai )	
							NotifyGaolidai(id,gaolidai)
							EmitSoundOn("General.CoinsBig", hero)
							SimpleOverheadMsg(hero,OVERHEAD_ALERT_GOLD,gaolidai)
						end)
					end
				end
			end
		end
	end
	
end


function barebones:getStartPoint( pos,path)
	for i=1,#path-1 do
		-- compare the X coordinates
		local point1=path[i]:GetAbsOrigin()
		local point2=path[i+1]:GetAbsOrigin()
		if math.abs(point2.x-point1.x)>200 then
			local dis=distanceFromPointToLine(pos,point1,point2)
			if dis<200 then
				return i
			end			
		end
		if math.abs(point2.y-point1.y)>200 then
			local dis=distanceFromPointToLine(pos,point1,point2)
			if dis<200 then
				return i
			end
		end
	end
	return 1
end

-- checkStartPoint: work out the start point
function barebones:moveCreep(unit,pathIndex,checkStartPoint)
	if not pathIndex then
		return
	end
	local nodes={GameRules.pathList[pathIndex][1],GameRules.pathList[pathIndex][2],GameRules.pathList[pathIndex][3],GameRules.pathList[pathIndex][4],GameRules.pathList[pathIndex][5]}
	local startIndex=1
	if checkStartPoint then
		startIndex=barebones:getStartPoint( unit:GetAbsOrigin(),GameRules.pathList[pathIndex])
	end
	for i=startIndex+1,#nodes do
		local t_order = 
		{                                       
			UnitIndex = unit:entindex(), 
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			TargetIndex = nil, 
			AbilityIndex = 0, 
			Position = nodes[i]:GetAbsOrigin(),
			Queue = true
		}
		unit:SetContextThink(DoUniqueString("order"), function() ExecuteOrderFromTable(t_order) end, 0.1)
	end
end

--GameRules:BeginTemporaryNight(10)
--GameRules:SetTimeOfDay( 0.851 )
-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function barebones:InitGameMode()
	DebugPrint("[BAREBONES] Starting to load Game Rules.")

	-- Setup rules
	GameRules:SetSameHeroSelectionEnabled(ALLOW_SAME_HERO_SELECTION)
	GameRules:SetUseUniversalShopMode(UNIVERSAL_SHOP_MODE)
	GameRules:SetHeroRespawnEnabled(ENABLE_HERO_RESPAWN)

	GameRules:SetHeroSelectionTime(HERO_SELECTION_TIME) -- THIS IS IGNORED when "EnablePickRules" is "1" in 'addoninfo.txt' !
	GameRules:SetHeroSelectPenaltyTime(HERO_SELECTION_PENALTY_TIME)

	GameRules:SetPreGameTime(PRE_GAME_TIME)
	GameRules:SetPostGameTime(POST_GAME_TIME)
	GameRules:SetShowcaseTime(SHOWCASE_TIME)
	GameRules:SetStrategyTime(STRATEGY_TIME)

	GameRules:SetTreeRegrowTime(TREE_REGROW_TIME)

	if USE_CUSTOM_HERO_LEVELS then
		GameRules:SetUseCustomHeroXPValues(true)
	end



	--GameRules:SetGoldPerTick(GOLD_PER_TICK) -- Doesn't work 24.2.2020
	--GameRules:SetGoldTickTime(GOLD_TICK_TIME) -- Doesn't work 24.2.2020
	GameRules:SetStartingGold(NORMAL_START_GOLD)

	if USE_CUSTOM_HERO_GOLD_BOUNTY then
		GameRules:SetUseBaseGoldBountyOnHeroes(false) -- if true Heroes will use their default base gold bounty which is similar to creep gold bounty, rather than DOTA specific formulas
	end

	GameRules:SetHeroMinimapIconScale(MINIMAP_ICON_SIZE)
	GameRules:SetCreepMinimapIconScale(MINIMAP_CREEP_ICON_SIZE)
	GameRules:SetRuneMinimapIconScale(MINIMAP_RUNE_ICON_SIZE)
	GameRules:SetFirstBloodActive(ENABLE_FIRST_BLOOD)
	GameRules:SetHideKillMessageHeaders(HIDE_KILL_BANNERS)
	GameRules:LockCustomGameSetupTeamAssignment(LOCK_TEAMS)

	GameRules:SetTimeOfDay( 0 )

	if not IsInToolsMode() then
		local shopEnt = Entities:FindByName(nil, "test_shop") 
		if shopEnt then
			shopEnt:Destroy()
		end
	end

	-- This is multi-team configuration stuff
	if USE_AUTOMATIC_PLAYERS_PER_TEAM then
		local num = math.floor(10/MAX_NUMBER_OF_TEAMS)
		local count = 0
		for team, number in pairs(TEAM_COLORS) do
			if count >= MAX_NUMBER_OF_TEAMS then
				GameRules:SetCustomGameTeamMaxPlayers(team, 0)
			else
				GameRules:SetCustomGameTeamMaxPlayers(team, num)
			end
			count = count + 1
		end
	else
		local count = 0
		for team, number in pairs(CUSTOM_TEAM_PLAYER_COUNT) do
			if count >= MAX_NUMBER_OF_TEAMS then
				GameRules:SetCustomGameTeamMaxPlayers(team, 0)
			else
				GameRules:SetCustomGameTeamMaxPlayers(team, number)
			end
			count = count + 1
		end
	end

	if USE_CUSTOM_TEAM_COLORS then
		for team, color in pairs(TEAM_COLORS) do
			SetTeamCustomHealthbarColor(team, color[1], color[2], color[3])
		end
	end

	DebugPrint("[BAREBONES] Done with setting Game Rules.")

	-- Event Hooks / Listeners
	DebugPrint("[BAREBONES] Setting Event Hooks / Listeners.")
	ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(barebones, 'OnPlayerLevelUp'), self)
	ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(barebones, 'OnPlayerLearnedAbility'), self)
	ListenToGameEvent('entity_killed', Dynamic_Wrap(barebones, 'OnEntityKilled'), self)
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(barebones, 'OnConnectFull'), self)
	ListenToGameEvent('player_disconnect', Dynamic_Wrap(barebones, 'OnDisconnect'), self)
	ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(barebones, 'OnItemPickedUp'), self)
	ListenToGameEvent('last_hit', Dynamic_Wrap(barebones, 'OnLastHit'), self)
	ListenToGameEvent('dota_rune_activated_server', Dynamic_Wrap(barebones, 'OnRuneActivated'), self)
	ListenToGameEvent('tree_cut', Dynamic_Wrap(barebones, 'OnTreeCut'), self)

	ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(barebones, 'OnAbilityUsed'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(barebones, 'OnGameRulesStateChange'), self)
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(barebones, 'OnNPCSpawned'), self)
	ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(barebones, 'OnPlayerPickHero'), self)
	ListenToGameEvent("player_reconnected", Dynamic_Wrap(barebones, 'OnPlayerReconnect'), self)
	ListenToGameEvent("player_chat", Dynamic_Wrap(barebones, 'OnPlayerChat'), self)

	ListenToGameEvent("dota_tower_kill", Dynamic_Wrap(barebones, 'OnTowerKill'), self)
	ListenToGameEvent("dota_player_selected_custom_team", Dynamic_Wrap(barebones, 'OnPlayerSelectedCustomTeam'), self)
	ListenToGameEvent("dota_npc_goal_reached", Dynamic_Wrap(barebones, 'OnNPCGoalReached'), self)
	ListenToGameEvent("dota_creature_gained_level", Dynamic_Wrap(barebones, 'OnCreatureGainedLevel'), self)
	ListenToGameEvent("entity_hurt", Dynamic_Wrap(barebones, 'OnEntityHurt'), self)

	-- Change random seed for math.random function
	local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
	math.randomseed(tonumber(timeTxt))

	DebugPrint("[BAREBONES] Setting Filters.")

	local gamemode = GameRules:GetGameModeEntity()

	BuildingHelper:SetupOrderFilter()
	
	-- Setting the Order filter 
	gamemode:SetExecuteOrderFilter(Dynamic_Wrap(barebones, "OrderFilter"), self)



	-- Setting the Damage filter
	gamemode:SetDamageFilter(Dynamic_Wrap(barebones, "DamageFilter"), self)

	-- Setting the Modifier filter
	gamemode:SetModifierGainedFilter(Dynamic_Wrap(barebones, "ModifierFilter"), self)

	-- Setting the Experience filter
	gamemode:SetModifyExperienceFilter(Dynamic_Wrap(barebones, "ExperienceFilter"), self)

	-- Setting the Tracking Projectile filter
	gamemode:SetTrackingProjectileFilter(Dynamic_Wrap(barebones, "ProjectileFilter"), self)

	-- Setting the bounty rune pickup filter
	gamemode:SetBountyRunePickupFilter(Dynamic_Wrap(barebones, "BountyRuneFilter"), self)

	-- Setting the Healing filter
	gamemode:SetHealingFilter(Dynamic_Wrap(barebones, "HealingFilter"), self)

	-- Setting the Gold Filter
	gamemode:SetModifyGoldFilter(Dynamic_Wrap(barebones, "GoldFilter"), self)

	gamemode:SetDamageFilter( Dynamic_Wrap( barebones, "OnDamageFilter" ), self )

	-- Setting the Inventory filter
	gamemode:SetItemAddedToInventoryFilter(Dynamic_Wrap(barebones, "InventoryFilter"), self)


	-- gamemode:SetWeatherEffectsDisabled( false )

	-- gamemode:SetCustomTerrainWeatherEffect("particles/rain_fx/autumn_terrain.vpcf")


	--Convars:RegisterCommand("greedisgood", Dynamic_Wrap(self, "greedisgood"), "", 0)
	-- Convars:RegisterCommand("start_next_round", Dynamic_Wrap(self, "StartNextRoundCommand"), "keine Ahnung", 0)
	-- Convars:RegisterCommand("greedisgood", Dynamic_Wrap(self, "greedisgood"), "", 0)
	-- Convars:RegisterCommand("start_prev_round", Dynamic_Wrap(self, "StartPreviousRoundCommand"), "keine Ahnung", 0)
	-- Convars:RegisterCommand("restart_round", Dynamic_Wrap(self, "RestartRoundCommand"), "keine Ahnung", 0)
	-- Convars:RegisterCommand("reset", Dynamic_Wrap(self, "RestartCommand"), "keine Ahnung", 0)
	-- Convars:RegisterCommand("wiki", Dynamic_Wrap(self, "WikiCommand"), "no idea", 0)
	-- Convars:RegisterCommand("upload_unit_data", Dynamic_Wrap(self, "UploadUnitData"), "no idea", 0)
	
	--
	local proto = {
		"C2S_GET_ITEM_DATA",
	--	"C2S_RECONNECT",
			"get_leaderboard",
			"get_profile",
			"web_load_matches",
		}
	for i,v in ipairs(proto) do
		CustomGameEventManager:RegisterListener( v, function(...) return self[v](self, ... ) end )
	end


	DebugPrint("[BAREBONES] Done with setting Filters.")

	-- Global Lua Modifiers
	LinkLuaModifier("modifier_custom_invulnerable", "modifiers/modifier_custom_invulnerable", LUA_MODIFIER_MOTION_NONE)



	LinkLuaModifier("modifier_generic_arc_lua", "lua_abilities/generic/modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH)

	LinkLuaModifier("modifier_generic_charges", "lua_abilities/generic/modifier_generic_charges", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_generic_custom_indicator", "lua_abilities/generic/modifier_generic_custom_indicator", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_generic_illusion_lua", "lua_abilities/generic/modifier_generic_illusion_lua", LUA_MODIFIER_MOTION_NONE)
	--
	LinkLuaModifier("modifier_generic_invisible_lua", "lua_abilities/generic/modifier_generic_invisible_lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_generic_knockback_lua", "lua_abilities/generic/modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH)
	LinkLuaModifier("modifier_generic_leashed_lua", "lua_abilities/generic/modifier_generic_leashed_lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_generic_lifesteal", "lua_abilities/generic/modifier_generic_lifesteal", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_generic_orb_effect_lua", "lua_abilities/generic/modifier_generic_orb_effect_lua", LUA_MODIFIER_MOTION_NONE)
	--
	LinkLuaModifier("modifier_generic_ring_lua", "lua_abilities/generic/modifier_generic_ring_lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_generic_silenced_lua", "lua_abilities/generic/modifier_generic_silenced_lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_generic_slowed_lua", "lua_abilities/generic/modifier_generic_slowed_lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_generic_stunned_lua", "lua_abilities/generic/modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_generic_agh_scepter", "lua_abilities/generic/modifier_generic_agh_scepter", LUA_MODIFIER_MOTION_NONE)


	LinkLuaModifier("modifier_generic_disarmed_lua", "lua_abilities/generic/modifier_generic_disarmed_lua", LUA_MODIFIER_MOTION_NONE)


	LinkLuaModifier("modifier_generic_stunned_noeff", "lua_abilities/generic/modifier_generic_stunned_noeff", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_generic_summon_timer", "lua_abilities/generic/modifier_generic_summon_timer", LUA_MODIFIER_MOTION_NONE)

	LinkLuaModifier("modifier_generic_true_sight_aura", "lua_abilities/generic/modifier_generic_true_sight_aura", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_generic_true_sight_aura_debuff", "lua_abilities/generic/modifier_generic_true_sight_aura", LUA_MODIFIER_MOTION_NONE)
	--
	LinkLuaModifier("modifier_uncontrollable", "lua_abilities/generic/modifier_uncontrollable", LUA_MODIFIER_MOTION_NONE)

	LinkLuaModifier("modifier_generic_tracking_projectile", "lua_abilities/generic/modifier_generic_tracking_projectile", LUA_MODIFIER_MOTION_NONE)
	
	LinkLuaModifier("modifier_attack", "ability/modifier/modifier_attack", LUA_MODIFIER_MOTION_NONE)


	LinkLuaModifier( "modifier_toubi", "modifiers/modifier_toubi", LUA_MODIFIER_MOTION_NONE )


	LinkLuaModifier("modifier_casting", "libraries/modifiers/modifier_casting", LUA_MODIFIER_MOTION_NONE)

	LinkLuaModifier("modifier_cast_tag", "lua_abilities/generic/modifier_cast_tag", LUA_MODIFIER_MOTION_NONE)

	
	--init modules
	Player:Init()
	GamePlay:Init()
	teckTree:Init()
	Cmd:Init()

	print("[BAREBONES] initialized.")
	DebugPrint("[BAREBONES] Done loading the game mode!\n\n")
	
	-- Increase/decrease maximum item limit per hero
	Convars:SetInt('dota_max_physical_items_purchase_limit', 64)
	-- Convars:SetBool('sv_cheats', true)

	SendToServerConsole("r_dota_clouds 0")
	

	--
	GameRules.sValidePlayerSteamIds=""
	GameRules.nValidPlayerNumber=0
	--
	GameRules.damageTable={{},{},{},{}}

end




-- This function is called as the first player loads and sets up the game mode parameters
function barebones:CaptureGameMode()
	local gamemode = GameRules:GetGameModeEntity()

	-- Set GameMode parameters
	gamemode:SetRecommendedItemsDisabled(RECOMMENDED_BUILDS_DISABLED)
	if CAMERA_DISTANCE_OVERRIDE then
	 	gamemode:SetCameraDistanceOverride(CAMERA_DISTANCE_OVERRIDE)
	end
	gamemode:SetBuybackEnabled(BUYBACK_ENABLED)
	gamemode:SetCustomBuybackCostEnabled(CUSTOM_BUYBACK_COST_ENABLED)
	gamemode:SetCustomBuybackCooldownEnabled(CUSTOM_BUYBACK_COOLDOWN_ENABLED)
	gamemode:SetTopBarTeamValuesOverride(USE_CUSTOM_TOP_BAR_VALUES) -- Probably does nothing, but I will leave it
	gamemode:SetTopBarTeamValuesVisible(TOP_BAR_VISIBLE)

	if USE_CUSTOM_XP_VALUES then
		gamemode:SetUseCustomHeroLevels(true)
		gamemode:SetCustomXPRequiredToReachNextLevel(XP_PER_LEVEL_TABLE)
	end

	gamemode:SetBotThinkingEnabled(USE_STANDARD_DOTA_BOT_THINKING)
	gamemode:SetTowerBackdoorProtectionEnabled(ENABLE_TOWER_BACKDOOR_PROTECTION)

	gamemode:SetFogOfWarDisabled(DISABLE_FOG_OF_WAR_ENTIRELY)
	gamemode:SetGoldSoundDisabled(DISABLE_GOLD_SOUNDS)
	--gamemode:SetRemoveIllusionsOnDeath(REMOVE_ILLUSIONS_ON_DEATH) -- Didnt work last time I tried

	gamemode:SetAlwaysShowPlayerInventory(SHOW_ONLY_PLAYER_INVENTORY)
	--gamemode:SetAlwaysShowPlayerNames(true) -- use this when you need to hide real hero names

	--gamemode:SetAlwaysShowPlayerNames(true)

	gamemode:SetAnnouncerDisabled(DISABLE_ANNOUNCER)

	if FORCE_PICKED_HERO ~= nil then
		gamemode:SetCustomGameForceHero(FORCE_PICKED_HERO) -- THIS WILL NOT WORK when "EnablePickRules" is "1" in 'addoninfo.txt' !
	else
		gamemode:SetDraftingHeroPickSelectTimeOverride(HERO_SELECTION_TIME)
		gamemode:SetDraftingBanningTimeOverride(0)
		if ENABLE_BANNING_PHASE then
			gamemode:SetDraftingBanningTimeOverride(BANNING_PHASE_TIME)
			GameRules:SetCustomGameBansPerTeam(5)
		end
	end

	--gamemode:SetFixedRespawnTime(FIXED_RESPAWN_TIME) -- FIXED_RESPAWN_TIME should be float
	gamemode:SetFountainConstantManaRegen(FOUNTAIN_CONSTANT_MANA_REGEN)
	gamemode:SetFountainPercentageHealthRegen(FOUNTAIN_PERCENTAGE_HEALTH_REGEN)
	gamemode:SetFountainPercentageManaRegen(FOUNTAIN_PERCENTAGE_MANA_REGEN)
	gamemode:SetLoseGoldOnDeath(LOSE_GOLD_ON_DEATH)
	gamemode:SetMaximumAttackSpeed(MAXIMUM_ATTACK_SPEED)
	gamemode:SetMinimumAttackSpeed(MINIMUM_ATTACK_SPEED)
	gamemode:SetStashPurchasingDisabled(DISABLE_STASH_PURCHASING)

	if USE_DEFAULT_RUNE_SYSTEM then
		gamemode:SetUseDefaultDOTARuneSpawnLogic(true)
	else
		-- Some runes are broken by Valve, RuneSpawnFilter also didn't work last time I tried
		for rune, spawn in pairs(ENABLED_RUNES) do
			gamemode:SetRuneEnabled(rune, spawn)
		end
		gamemode:SetBountyRuneSpawnInterval(BOUNTY_RUNE_SPAWN_INTERVAL)
		gamemode:SetPowerRuneSpawnInterval(POWER_RUNE_SPAWN_INTERVAL)
	end

	gamemode:SetUnseenFogOfWarEnabled(USE_UNSEEN_FOG_OF_WAR)
	gamemode:SetDaynightCycleDisabled(DISABLE_DAY_NIGHT_CYCLE)
	gamemode:SetKillingSpreeAnnouncerDisabled(DISABLE_KILLING_SPREE_ANNOUNCER)
	gamemode:SetStickyItemDisabled(DISABLE_STICKY_ITEM)
	gamemode:SetPauseEnabled(ENABLE_PAUSING)
	gamemode:SetCustomScanCooldown(CUSTOM_SCAN_COOLDOWN)
	gamemode:SetCustomGlyphCooldown(CUSTOM_GLYPH_COOLDOWN)
	gamemode:DisableHudFlip(FORCE_MINIMAP_ON_THE_LEFT)

	if DEFAULT_DOTA_COURIER then
		gamemode:SetFreeCourierModeEnabled(true)
	end
end
