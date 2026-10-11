-- This file contains all barebones-registered events and has already set up the passed-in parameters for you to use.
-- You should comment or remove the stuff you don't need!

-- Handle stuff when a player disconnects
function barebones:OnDisconnect(keys)
	DebugPrint("[BAREBONES] A Player has disconnected " .. tostring(keys.userid))
	--PrintTable(keys)
	local name = keys.name
	local networkID = keys.networkid
	local reason = keys.reason
	local userID = keys.userid
	local playerID = keys.PlayerID
end

function barebones:SetUpBots()
	if GameRules.bStartBoot then
		return
	end

	GameRules.bStartBoot = true
	GameRules.teamSet = {}
	local maxPlayer = CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] + CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]
	local bot = Convars:GetInt("dota_legiontd_bot") or 0
	local nBotCount = math.min(bot, maxPlayer - PlayerResource:GetPlayerCount())
	print("nBotCount" .. nBotCount)
	print("PlayerResource:GetPlayerCount()" .. PlayerResource:GetPlayerCount())
	for i = 1, nBotCount do
		print("addbot")
		local team = DOTA_TEAM_GOODGUYS
		if i % 2 == 1 then
			team = DOTA_TEAM_BADGUYS
		end
		--Tutorial:AddBot("npc_dota_hero_tusk", '', '', true)
		local hero = GameRules:AddBotPlayerWithEntityScript("npc_dota_hero_wisp", "bot" .. i, team, nil, true)
		hero:AddNewModifier(hero, nil, "modifier_phased", { duration = 0.03 })
		Timers:CreateTimer(1, function()
			hero:SetControllableByPlayer(0, true)
		end)
	end
	--barebones:FillTeamWithBot(0)
end

function barebones:FillTeamWithBot(nTeamNumber)
	-- find the bot with the highest index
	for nPlayerID = 3, 0, -1 do
		if PlayerResource:IsFakeClient(nPlayerID) then
			PlayerResource:SetCustomTeamAssignment(nPlayerID, nTeamNumber)
			-- wait a moment, then switch the hero team
			Timers:CreateTimer(0.05, function()
				local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
				if hHero ~= nil then
					hHero:SetTeam(nTeamNumber)
					return nil
				end
				return 0.01
			end)
			break;
		end
	end
end

--print(GameRules.nValidPlayerNumber)
-- The overall game state has changed
function barebones:OnGameRulesStateChange(keys)
	--PrintTable(keys)

	local new_state = GameRules:State_Get()

	if new_state == DOTA_GAMERULES_STATE_INIT then
		DebugPrint("[BAREBONES] Game State changed to: DOTA_GAMERULES_STATE_INIT")
	elseif new_state == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
		DebugPrint("[BAREBONES] Game State changed to: DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD")
	elseif new_state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		DebugPrint("[BAREBONES] Game State changed to: DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP")
		GameRules:SetCustomGameSetupAutoLaunchDelay(CUSTOM_GAME_SETUP_TIME)

		GameRules.vPlayerSteamIdMap = {}
		for nPlayerID = 0, (DOTA_MAX_TEAM_PLAYERS - 1) do
			if PlayerResource:IsValidPlayer(nPlayerID) then
				local nPlayerSteamId = PlayerResource:GetSteamAccountID(nPlayerID)
				if not GameRules.sValidePlayerSteamIds then
					GameRules.sValidePlayerSteamIds = ""
				end

				GameRules.sValidePlayerSteamIds = GameRules.sValidePlayerSteamIds .. nPlayerSteamId .. ","
				GameRules.nValidPlayerNumber = GameRules.nValidPlayerNumber + 1
				GameRules.vPlayerSteamIdMap[nPlayerSteamId] = nPlayerID
			end
		end
		if string.sub(GameRules.sValidePlayerSteamIds, string.len(GameRules.sValidePlayerSteamIds)) == "," then -- drop the trailing comma
			GameRules.sValidePlayerSteamIds = string.sub(GameRules.sValidePlayerSteamIds, 0,
				string.len(GameRules.sValidePlayerSteamIds) - 1)
		end
		print("GameRules.sValidePlayerSteamIds" .. GameRules.sValidePlayerSteamIds)

		if IsInToolsMode() then
			print("IsCheatMode")
			barebones:SetUpBots()
		end
	elseif new_state == DOTA_GAMERULES_STATE_HERO_SELECTION then
		DebugPrint("[BAREBONES] Game State changed to: DOTA_GAMERULES_STATE_HERO_SELECTION")
		self:PostLoadPrecache()
		self:OnAllPlayersLoaded()
	elseif new_state == DOTA_GAMERULES_STATE_STRATEGY_TIME then
		DebugPrint("[BAREBONES] Game State changed to: DOTA_GAMERULES_STATE_STRATEGY_TIME")
	elseif new_state == DOTA_GAMERULES_STATE_TEAM_SHOWCASE then
		DebugPrint("[BAREBONES] Game State changed to: DOTA_GAMERULES_STATE_TEAM_SHOWCASE")
	elseif new_state == DOTA_GAMERULES_STATE_WAIT_FOR_MAP_TO_LOAD then
		DebugPrint("[BAREBONES] Game State changed to: DOTA_GAMERULES_STATE_WAIT_FOR_MAP_TO_LOAD")
	elseif new_state == DOTA_GAMERULES_STATE_PRE_GAME then
		DebugPrint("[BAREBONES] Game State changed to: DOTA_GAMERULES_STATE_PRE_GAME")
		GameRules:GetGameModeEntity():SetCustomDireScore(0) -- Thanks for Diretide
	elseif new_state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		DebugPrint("[BAREBONES] Game State changed to: DOTA_GAMERULES_STATE_GAME_IN_PROGRESS")
		self:OnGameInProgress()
	elseif new_state == DOTA_GAMERULES_STATE_POST_GAME then
		DebugPrint("[BAREBONES] Game State changed to: DOTA_GAMERULES_STATE_POST_GAME")
	elseif new_state == DOTA_GAMERULES_STATE_DISCONNECT then
		DebugPrint("[BAREBONES] Game State changed to: DOTA_GAMERULES_STATE_DISCONNECT")
	end
end

function barebones:updateUnitBaseAttack(unit)
	local attackMin = GetUnitKV(unit:GetUnitName(), "AttackDamageMins", unit:GetLevel())
	local attackMax = GetUnitKV(unit:GetUnitName(), "AttackDamageMaxs", unit:GetLevel())
	if attackMin then
		unit:SetBaseDamageMin(attackMin)
	end
	if attackMax then
		unit:SetBaseDamageMax(attackMax)
	end
	if not attackMin and not attackMax then
		local attackDamages = GetUnitKV(unit:GetUnitName(), "AttackDamages", unit:GetLevel())
		if attackDamages then
			local strs = mysplit(attackDamages, "-")
			if #strs == 1 then
				unit:SetBaseDamageMin(strs[1] + 0)
				unit:SetBaseDamageMax(strs[1] + 0)
			else
				if strs[1] then
					unit:SetBaseDamageMin(strs[1] + 0)
				end
				if strs[2] then
					unit:SetBaseDamageMax(strs[2] + 0)
				end
			end
		end
	end
end

-- An NPC has spawned somewhere in game. This includes heroes
function barebones:OnNPCSpawned(keys)
	--DebugPrint("[BAREBONES] A unit Spawned")
	--PrintTable(keys)

	local unit = EntIndexToHScript(keys.entindex)
	local unit_owner = unit:GetOwner()

	-- Put things here that will happen for every unit or hero when they spawn

	-- OnHeroInGame
	if unit:IsRealHero() and unit.bFirstSpawned == nil then
		unit.bFirstSpawned = true
		self:OnHeroInGame(unit)
	end
	barebones:updateUnitBaseAttack(unit)

	local color = GetUnitKV(unit:GetUnitName(), "RenderColorX", 1)
	if color and color ~= "" then
		local rgb = hex2rgb(color)
		unit:SetRenderColor(rgb[1], rgb[2], rgb[3])
	end
	if not unit:IsHero() then
		EnableAllAutoCast(unit)
	end
		local activity = GetUnitKV(unit:GetUnitName(), "activity", 1)
	if activity then
		AddAnimationTranslate(unit, activity)
	end
	-- add ambient
	local ambientParticle = GetUnitKV(unit:GetUnitName(), "ambientParticle", 1)

	if ambientParticle then
		PlayEffOnUnit(ambientParticle,unit,{
			bind = PATTACH_ABSORIGIN_FOLLOW
		})
	end
	local ambientParticle1 = GetUnitKV(unit:GetUnitName(), "ambientParticle1", 1)
	if ambientParticle1 then
		PlayEffOnUnit(ambientParticle1,unit,{
			bind = PATTACH_ABSORIGIN_FOLLOW

		})
	end
	if unit:HasAbility("twin_gate_portal_warp") then
		unit:RemoveAbility("twin_gate_portal_warp")
	end
	GamePlay:tryEditUnitInToolsMode(unit)
end

function barebones:GetDamageTable(pid)
	local items = {}
	if not GameRules.damageTable[pid] then
		GameRules.damageTable[pid] = {}
	end
	local dt = GameRules.damageTable[pid]
	-- for k,v in pairs(dt) do
	-- 	table.insert(items,{k,math.floor(v)})
	-- end
	-- table.sort(items,function (a, b)
	-- 	return a[2]>b[2]
	-- end)
	return dt
end

-- damage: 6.7796611785889
-- damagebits: 0
-- entindex_attacker: 723
-- entindex_killed: 771
-- game_event_listener: -1308622821
-- game_event_name: entity_hurt
-- splitscreenplayer: -1
function barebones:recordDamageTable(attacker,victim,damage,damageType)

	-- if keys.damage<45 then
	-- 	print(1212)
	-- 	PrintTable(keys)
	-- end
	
	-- if not keys.entindex_attacker then
	-- 	return
	-- end
	--	PrintTable(keys)
	-- local attacker = EntIndexToHScript(keys.entindex_attacker)
	--local victim = EntIndexToHScript(keys.entindex_killed)
	-- if victim then
	-- 	print(victim:GetHealth())
	-- end
	-- local damage = keys.damage
	

	if ENABLE_DAMAGE_TABLE then
		if attacker and victim and damage and damageType and damage>0 and damageType~=0 then
			
			if attacker and not attacker:IsNull() and damage and damage ~= 0 then
				-- PrintTable(attacker)
				-- local attackerIdx = attacker:entindex()
				-- attackerIdx=1
				local pid = attacker:GetPlayerOwnerID()

				if not pid or pid == -1 then
					return
				end
				if not GameRules.damageTable[pid] then
					GameRules.damageTable[pid] = {}
				end
				local unitName = attacker:GetUnitName()
				if not GameRules.damageTable[pid][unitName] then
					GameRules.damageTable[pid][unitName] = {}
				end
				if not GameRules.damageTable[pid][unitName][damageType] then
					GameRules.damageTable[pid][unitName][damageType] = 0
				end
				GameRules.damageTable[pid][unitName][damageType] = GameRules.damageTable[pid][unitName][damageType] +
				damage
			end
		end
	end
end

function barebones:OnEntityHurt(keys)
	-- barebones:recordDamageTable(keys)
	-- local attacker = EntIndexToHScript(keys.entindex_attacker)
	local damage = keys.damage

	local target = EntIndexToHScript(keys.entindex_killed)
	if target and target:GetPlayerOwnerID() and Player:GetPData(target:GetPlayerOwnerID()) then
		local pid = target:GetPlayerOwnerID()
		local pdata = Player:GetPData(pid)
		local round = GamePlay:getRoundInfo(GamePlay.round)

		if GamePlay.state ~= "idle" and GamePlay.roundList[GamePlay.roundIndex] then
			local tped = GamePlay.roundList[GamePlay.roundIndex].teleported[pid]
			if not tped and pdata.defenseMode == "global" and pdata.defenseModeMoved == false and round and not isTrue(round.duel) then
				GamePlay:moveToTp(pid)
				pdata.defenseModeMoved = true
			end
		end
	end

	-- if keys.entindex_killed then
	-- 	local target =EntIndexToHScript(keys.entindex_killed)
	-- 	if target and ( target:GetUnitName()=="king_good" or target:GetUnitName()=="king_bad") then
	-- 		if target:GetHealthPercent() < 10 then
	-- 			local team=target:GetTeam()
	-- 			local flag=false
	-- 			Player:ForeanchPlayer(function(pid, pdata)
	-- 				if flag==false and PlayerResource:GetTeam(pid) ==team and GamePlay:autoHeal(pid) then
	-- 					flag=true
	-- 				end
	-- 			end)				
	-- 		end
	-- 	end
	-- end
end

function barebones:OnCreatureGainedLevel(keys)
	local unit = EntIndexToHScript(keys.entindex)

	if IsCustomBuilding(unit) then
		--buildTree:updateAbility(unit:GetPlayerOwnerID())
		if unit:GetLevel() > 1 then
			-- PlayUpgradeParticle(unit)
			--NotifyUnitUpgrade(unit:GetPlayerOwnerID(),unit:GetUnitName(),unit:GetLevel())
		end
		--EnableAllAutoCast(unit)
		-- if unit:GetLevel()>1 then
		-- 	local rawScale=GetUnitKV(unit:GetUnitName(),"ModelScale",1)+0
		-- 	unit:SetModelScale(rawScale*(1+0.1*(unit:GetLevel()-1)))
		-- end
		local model = GetUnitKV(unit:GetUnitName(), "Models", unit:GetLevel())
		if model then
			unit:SetModel(model)
		end
	end
	barebones:updateUnitBaseAttack(unit)
end

function barebones:initHero(hero)
	local playerID = hero:GetPlayerID()
	print("init hero " .. playerID .. " " .. hero:GetUnitName())

	
	-- -- Set some hero stuff on first spawn or on every spawn (custom or not)
	-- if PlayerResource.PlayerData[playerID].already_set_hero == true then
	-- 	-- This is happening only when players create new heroes or replace them
	-- else
	-- end
	-- This is happening for players when their primary hero spawns for the first time
	DebugPrint("[BAREBONES] Hero " ..
	hero:GetUnitName() .. " spawned in the game for the first time for the player with ID " .. playerID)
	-- Make heroes briefly visible on spawn (to prevent bad fog of war interactions)
	
	-- hero:MakeVisibleToTeam(DOTA_TEAM_GOODGUYS, 0.5)
	
	-- hero:MakeVisibleToTeam(DOTA_TEAM_BADGUYS, 0.5)


	-- Set the starting gold for the player's hero
	-- Use 'PlayerResource:ModifyGold(playerID, NORMAL_START_GOLD-600, false, 0)' if GameRules:SetStartingGold breaks again
	-- If the NORMAL_START_GOLD is less then 600, disable Strategy Time and use 'hero:SetGold(NORMAL_START_GOLD, false)' instead
	-- Why? Because OnHeroInGame is triggering during PreGame (after Strategy Time) and players can buy items during Strategy Time (starting gold will remain default 600)

	-- Create an item and add it to the player, effectively ensuring they start with the item
	if ADD_ITEM_TO_HERO_ON_SPAWN then

	end
	-- Make sure that stuff above will not happen again for the player if some other hero spawns
	-- for him for the first time during the game
	-- PlayerResource.PlayerData[playerID].already_set_hero = true
	DebugPrint("[BAREBONES] Hero " .. hero:GetUnitName() .. " set for the player with ID " .. playerID)
end



 -- clearOtherHero(4)

--[[
  Hero spawned for the first time. It can happen if the player's hero is replaced with a new hero for any reason.
  This can be used for initializing heroes, such as adding levels, changing the starting gold, removing/adding abilities, adding physics, etc.
  This happens to bot and custom created heroes as well.
  The hero parameter is the hero entity that just spawned.

]]
function barebones:OnHeroInGame(hero)
	-- Innate abilities like Earth Spirit Stone Remnant (abilities that a hero needs to have auto-leveled up at the start of the game)
	-- Add all custom innate abilities here

	-- print("OnHeroInGame ",hero:GetUnitName())

	local innate_abilities = {

	}

	-- Cycle through any innate abilities found, then set their level to 1
	for i = 1, #innate_abilities do
		local current_ability = hero:FindAbilityByName(innate_abilities[i])
		if current_ability then
			current_ability:SetLevel(1)
		end
	end

	if hero then
		local pid = hero:GetPlayerID()
		Timers:CreateTimer(0.5, function()
			local playerID = hero:GetPlayerID() -- never nil (-1 by default), needs delay 1 or more frames
			if PlayerResource:IsFakeClient(playerID) then
				-- This is happening only for bots
				DebugPrint("[BAREBONES] Bot hero " .. hero:GetUnitName() .. " (re)spawned in the game.")
				-- Set starting gold for bots
				-- hero:SetGold(Player:GetGold(playerID), false)
			else
				DebugPrint("[BAREBONES] OnHeroInGame running for a non-bot player!")

				-- if not PlayerResource.PlayerData[playerID] then
				-- 	PlayerResource.PlayerData[playerID] = {}
				-- 	DebugPrint("[BAREBONES] PlayerResource's PlayerData for playerID "..playerID.." was not properly initialized.")
				-- end
				if hero:IsClone() then
					DebugPrint("[BAREBONES] Spawned hero is a Meepo clone")
					return
				end
				if hero:IsTempestDouble() then
					DebugPrint("[BAREBONES] Spawned hero is a Tempest Double")
					return
				end
				if hero:HasModifier("modifier_monkey_king_fur_army_soldier_hidden") then
					DebugPrint("[BAREBONES] Spawned hero is a Monkey King clone")
					return
				end
			end
		end)
	end
end

-- An item was picked up off the ground
function barebones:OnItemPickedUp(keys)
	DebugPrint("[BAREBONES] OnItemPickedUp")
	--PrintTable(keys)

	-- Find who picked up the item
	local unit_entity
	if keys.UnitEntitIndex then -- keys.UnitEntitIndex may be always nil
		unit_entity = EntIndexToHScript(keys.UnitEntitIndex)
	elseif keys.HeroEntityIndex then
		unit_entity = EntIndexToHScript(keys.HeroEntityIndex)
	end

	local item_entity = EntIndexToHScript(keys.ItemEntityIndex)
	local playerID = keys.PlayerID
	local item_name = keys.itemname
end

-- A player has reconnected to the game. This function can be used to repaint Player-based particles or change state as necessary
function barebones:OnPlayerReconnect(keys)
	DebugPrint("[BAREBONES] A Player has reconnected.")
	--PrintTable(keys)

	local new_state = GameRules:State_Get()
	if new_state > DOTA_GAMERULES_STATE_HERO_SELECTION then
		local playerID = keys.PlayerID or keys.player_id
		if PlayerResource:HasSelectedHero(playerID) or PlayerResource:HasRandomed(playerID) then
			-- This playerID already had a hero before disconnect
		else
			print("OnPlayerReconnect no hero", playerID)
			--PlayerResource:IsConnected(index) is custom-made; can be found in 'player_resource.lua' library


			-- if PlayerResource:IsConnected(playerID) and (not PlayerResource:IsBroadcaster(playerID)) then
			-- 	PlayerResource:GetPlayer(playerID):MakeRandomHeroSelection()
			-- 	PlayerResource:SetHasRandomed(playerID)
			-- 	PlayerResource:SetCanRepick(playerID, false)
			-- 	DebugPrint("[BAREBONES] Randomed a hero for a player number "..playerID.." that reconnected.")
			-- end


			-- local pdata=Player:GetPData(playerID)
			-- local player=PlayerResource:GetPlayer(playerID)
			-- player:MakeRandomHeroSelection()
			-- CreateHeroForPlayer(pdata.heroName,PlayerResource:GetPlayer(playerID)):RemoveSelf()
			-- local hero=PlayerResource:GetSelectedHeroEntity(playerID)
			-- if hero and not hero:IsAlive() then
			-- 	print("RespawnUnit",hero:GetUnitName())
			-- 	hero:RespawnUnit()
			-- end
		end
	end
end

-- An ability was used by a player; Doesn't trigger on disconnected players.
function barebones:OnAbilityUsed(keys)
	--PrintTable(keys)

	local playerID = keys.PlayerID
	local ability_name = keys.abilityname

	-- If you need to adjust abilities on their cast, use Order Filter or modifier events, not this
end

-- A player leveled up an ability; Note: IT DOESN'T TRIGGER WHEN YOU USE SetLevel() ON THE ABILITY!
function barebones:OnPlayerLearnedAbility(keys)
	DebugPrint("[BAREBONES] OnPlayerLearnedAbility")
	--PrintTable(keys)

	local player
	if keys.player then
		player = EntIndexToHScript(keys.player)
	end

	local ability_name = keys.abilityname

	local playerID
	if player then
		playerID = player:GetPlayerID()
	else
		playerID = keys.PlayerID
	end

	-- PlayerResource:GetBarebonesAssignedHero(index) is custom-made; can be found in 'player_resource.lua' library
	local hero = PlayerResource:GetBarebonesAssignedHero(playerID)

	-- Handling talents without custom net tables, this is just an example
	local talents = {
		{ "special_bonus_unique_hero_name",      "modifier_hero_name_ability_name_talent_number" },
		{ "special_bonus_unique_chaos_knight",   "modifier_reality_rift_talent_1" },
		{ "special_bonus_unique_chaos_knight_2", "modifier_reality_rift_talent_2" }
	}

	-- for i = 1, #talents do
	-- 	local talent = talents[i]
	-- 	if ability_name == talent[1] then
	-- 		local talent_ability = hero:FindAbilityByName(ability_name)
	-- 		if talent_ability then
	-- 			local talent_modifier = talent[2]
	-- 			hero:AddNewModifier(hero, talent_ability, talent_modifier, {})
	-- 		end
	-- 	end
	-- end
end

-- A player leveled up
function barebones:OnPlayerLevelUp(keys)
	DebugPrint("[BAREBONES] OnPlayerLevelUp")

	local level = keys.level
	local playerID = keys.player_id or keys.PlayerID -- Valve keeps changing this :)

	local hero
	if keys.hero_entindex then
		hero = EntIndexToHScript(keys.hero_entindex)
	else
		hero = PlayerResource:GetBarebonesAssignedHero(playerID)
	end

	if hero then
		-- Update hero gold bounty when a hero gains a level
		if USE_CUSTOM_HERO_GOLD_BOUNTY then
			local hero_level = hero:GetLevel() or level
			local hero_streak = hero:GetStreak()

			local gold_bounty
			if hero_streak > 2 then
				gold_bounty = HERO_KILL_GOLD_BASE + hero_level * HERO_KILL_GOLD_PER_LEVEL +
				(hero_streak - 2) * HERO_KILL_GOLD_PER_STREAK
			else
				gold_bounty = HERO_KILL_GOLD_BASE + hero_level * HERO_KILL_GOLD_PER_LEVEL
			end

			hero:SetMinimumGoldBounty(gold_bounty)
			hero:SetMaximumGoldBounty(gold_bounty)
		end

		-- Add a skill point when a hero levels up
		if SKILL_POINTS_AT_EVERY_LEVEL then
			local levels_without_ability_point = { 17, 19, 21, 22, 23, 24 } -- on this levels you should get a skill point (edit this if needed)
			for i = 1, #levels_without_ability_point do
				if level == levels_without_ability_point[i] then
					local unspent_ability_points = hero:GetAbilityPoints()
					hero:SetAbilityPoints(unspent_ability_points + 1)
				end
			end
		end

		-- If you want to remove skill points when a hero levels up then uncomment the following line:
		-- hero:SetAbilityPoints(0)
	end
end

-- A player last hit a creep, a tower, or a hero
function barebones:OnLastHit(keys)
	--DebugPrint("[BAREBONES] OnLastHit")
	local IsFirstBlood = keys.FirstBlood == 1
	local IsHeroKill = keys.HeroKill == 1
	local IsTowerKill = keys.TowerKill == 1
	-- Player ID that got a last hit
	local playerID = keys.PlayerID
	-- Killed unit (creep, hero, tower etc.)
	local killed_entity = EntIndexToHScript(keys.EntKilled)
	if playerID then
	end
end

-- A tree was cut down by tango, quelling blade, etc
function barebones:OnTreeCut(keys)
	DebugPrint("[BAREBONES] OnTreeCut")
	--PrintTable(keys)
	-- Tree coordinates on the map
	local treeX = keys.tree_x
	local treeY = keys.tree_y
end

-- A rune was activated by a player
function barebones:OnRuneActivated(keys)
	DebugPrint("[BAREBONES] OnRuneActivated")
	--PrintTable(keys)

	local playerID = keys.PlayerID
	local rune = keys.rune

	-- For Bounty Runes use BountyRuneFilter
	-- For modifying which runes spawn use RuneSpawnFilter (if it works)
	-- This event can be used for adding more effects to existing runes.
end

-- A player picked or randomed a hero, it actually happens on spawn (this is sometimes happening before OnHeroInGame).
function barebones:OnPlayerPickHero(keys)
	--PrintTable(keys)
	local hero_name = keys.hero
	local hero_entity = EntIndexToHScript(keys.heroindex)
	local player = EntIndexToHScript(keys.player)

	if hero_name then
		DebugPrint("[BAREBONES] OnPlayerPickHero " .. hero_name)
	end

	if hero_entity and not hero_entity:IsNull() then
		Timers:CreateTimer(0.2, function()
			local playerID = hero_entity:GetPlayerID() -- or player:GetPlayerID() if player is not disconnected
			if PlayerResource:IsFakeClient(playerID) then
				-- This is happening only for bots when they spawn for the first time or if they use custom hero-create spells (Custom Illusion spells)
			else
				-- if not PlayerResource.PlayerData[playerID] then
				-- 	PlayerResource.PlayerData[playerID] = {}
				-- 	DebugPrint("[BAREBONES] PlayerResource's PlayerData for playerID "..playerID.." was not properly initialized.")
				-- end
				-- if PlayerResource.PlayerData[playerID].already_assigned_hero == true then
				-- 	-- This is happening only when players create new heroes or replacing heroes
				-- 	DebugPrint("[BAREBONES] Player with playerID "..playerID.." got a new hero "..hero_entity:GetUnitName())
				-- else
				-- 	PlayerResource:AssignHero(playerID, hero_entity)
				-- 	PlayerResource.PlayerData[playerID].already_assigned_hero = true
				-- end
			end
			barebones:initHero(hero_entity)
		end)
	end
	-- remove the cosmetics
	-- local hero=hero_entity
	-- if hero then
	-- 	for _,child in pairs(hero:GetChildren()) do
	-- 		if child:GetClassname() == "dota_item_wearable" then
	-- 			child:RemoveSelf()
	-- 		end
	-- 	end
	-- end
end

-- An entity died (an entity killed an entity)
function barebones:OnEntityKilled(keys)

	if true then
		return 
	end

	--DebugPrint("[BAREBONES] An entity was killed.")
	--PrintTable(keys)
	-- Indexes:
	local killed_entity_index = keys.entindex_killed
	local attacker_entity_index = keys.entindex_attacker
	local inflictor_index = keys.entindex_inflictor -- it can be nil if not killed by an item/ability

	-- Find the entity that was killed
	local killed_unit
	if killed_entity_index then
		killed_unit = EntIndexToHScript(killed_entity_index)
		--print("killed "..killed_unit:GetUnitName())
	end

	-- Find the entity (killer) that killed the entity mentioned above
	local killer_unit
	if attacker_entity_index then
		killer_unit = EntIndexToHScript(attacker_entity_index)
	end



	if killed_unit == nil or killer_unit == nil then
		-- Don't continue if killer or killed entity doesn't exist
		return
	end
	-- Find the ability/item used to kill, or nil if not killed by an item/ability
	local killing_ability
	if inflictor_index then
		killing_ability = EntIndexToHScript(inflictor_index)
	end

	-- For Meepo clones, find the original
	if killed_unit:IsClone() then
		if killed_unit:GetCloneSource() then
			killed_unit = killed_unit:GetCloneSource()
		end
	end

	-- Killed Unit is a hero (not an illusion) and he is not reincarnating
	if killed_unit:IsRealHero() and not killed_unit:IsTempestDouble() and not killed_unit:IsReincarnating() then
		-- Hero gold bounty update for the killer
		if USE_CUSTOM_HERO_GOLD_BOUNTY then
			if killer_unit:IsRealHero() then
				-- Get his killing streak
				local hero_streak = killer_unit:GetStreak()
				-- Get his level
				local hero_level = killer_unit:GetLevel()
				-- Adjust Gold bounty
				local gold_bounty
				if hero_streak > 2 then
					gold_bounty = HERO_KILL_GOLD_BASE + hero_level * HERO_KILL_GOLD_PER_LEVEL +
					(hero_streak - 2) * HERO_KILL_GOLD_PER_STREAK
				else
					gold_bounty = HERO_KILL_GOLD_BASE + hero_level * HERO_KILL_GOLD_PER_LEVEL
				end

				killer_unit:SetMinimumGoldBounty(gold_bounty)
				killer_unit:SetMaximumGoldBounty(gold_bounty)
			end
		end

		-- Hero Respawn time configuration
		if ENABLE_HERO_RESPAWN then
			local killed_unit_level = killed_unit:GetLevel()

			-- Calculating respawn time without buyback penalty
			local respawn_time = 1
			if USE_CUSTOM_RESPAWN_TIMES then
				-- Get respawn time from the table that we defined
				respawn_time = CUSTOM_RESPAWN_TIME[killed_unit_level]
			else
				-- Get dota default respawn time
				respawn_time = killed_unit:GetRespawnTime()
			end

			-- Fixing respawn time after level 30, this is usually bugged in custom games if default respawn times are used -> respawn time are either too long or too short. We fix that.
			local respawn_time_after_30 = 100 + (killed_unit_level - 30) * 5
			if killed_unit_level > 30 and respawn_time ~= respawn_time_after_30 and not USE_CUSTOM_RESPAWN_TIMES then
				respawn_time = respawn_time_after_30
			end

			-- Old Bloodstone respawn reduction (this example doesn't check items in backpack because bloodstone cannot go in backpack)
			-- for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
			-- local item = killed_unit:GetItemInSlot(i)
			-- if item then
			-- if item:GetName() == "item_bloodstone" then
			-- local current_charges = item:GetCurrentCharges()
			-- local charges_before_death = math.ceil(current_charges*1.5)
			-- local reduction_per_charge = item:GetLevelSpecialValueFor("respawn_time_reduction", item:GetLevel() - 1)
			-- local respawn_reduction = charges_before_death*reduction_per_charge
			-- respawn_time = math.max(1, respawn_time-respawn_reduction)
			-- break -- break for loop, to prevent multiple bloodstones granting respawn reduction
			-- end
			-- end
			-- end

			-- Reaper's Scythe respawn time increase
			if killing_ability and killing_ability.GetAbilityName then
				if killing_ability:GetAbilityName() == "necrolyte_reapers_scythe" then
					DebugPrint("[BAREBONES] A hero was killed by a Necro Reaper's Scythe. Increasing respawn time!")
					local respawn_extra_time = killing_ability:GetLevelSpecialValueFor("respawn_constant",
						killing_ability:GetLevel() - 1)
					respawn_time = respawn_time + respawn_extra_time
				end
			end

			-- Killer is a neutral creep
			if killer_unit:IsNeutralUnitType() then
				-- If a hero is killed by a neutral creep, respawn time can be modified here
			end

			-- Capping Respawn Time (MAX respawn time)
			if respawn_time > MAX_RESPAWN_TIME then
				DebugPrint("[BAREBONES] Reducing respawn time of " ..
				killed_unit:GetUnitName() .. " because it was too long.")
				respawn_time = MAX_RESPAWN_TIME
			end

			-- If hero is actually reincarnating don't change his respawn time:
			if not killed_unit:IsReincarnating() then
				killed_unit:SetTimeUntilRespawn(respawn_time)
			end
		end

		-- Hero Buyback Cooldown
		if CUSTOM_BUYBACK_COOLDOWN_ENABLED then
			PlayerResource:SetCustomBuybackCooldown(killed_unit:GetPlayerID(), CUSTOM_BUYBACK_COOLDOWN_TIME)
		end

		-- Hero Buyback Gold Cost, you can replace BUYBACK_FIXED_GOLD_COST with your formula
		if CUSTOM_BUYBACK_COST_ENABLED then
			PlayerResource:SetCustomBuybackCost(killed_unit:GetPlayerID(), BUYBACK_FIXED_GOLD_COST)
		end

		-- Killer is not a real hero but it killed a hero
		if killer_unit:IsTower() or killer_unit:IsCreep() or killer_unit:IsFountain() then
			-- Put stuff here that you want to happen if a hero is killed by a creep, tower or fountain.
		end

		-- When team hero kill limit is reached declare the winner
		if END_GAME_ON_KILLS and GetTeamHeroKills(killer_unit:GetTeam()) >= KILLS_TO_END_GAME_FOR_TEAM then
			GameRules:SetGameWinner(killer_unit:GetTeam())
		end

		-- Setting top bar values
		if SHOW_KILLS_ON_TOPBAR then
			--GameRules:GetGameModeEntity():SetTopBarTeamValue(DOTA_TEAM_BADGUYS, GetTeamHeroKills(DOTA_TEAM_BADGUYS))   -- Doesn't work since Diretide 2020
			--GameRules:GetGameModeEntity():SetTopBarTeamValue(DOTA_TEAM_GOODGUYS, GetTeamHeroKills(DOTA_TEAM_GOODGUYS)) -- Doesn't work since Diretide 2020
			GameRules:GetGameModeEntity():SetCustomRadiantScore(GetTeamHeroKills(DOTA_TEAM_GOODGUYS))
			GameRules:GetGameModeEntity():SetCustomDireScore(GetTeamHeroKills(DOTA_TEAM_BADGUYS))
		end
	end

	-- Ancient destruction detection (if the map doesn't have ancients with these names, this will never happen)
	if killed_unit:GetUnitName() == "npc_dota_badguys_fort" then
		GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
		GameRules:SetCustomVictoryMessage("#dota_post_game_radiant_victory")
		GameRules:SetCustomVictoryMessageDuration(POST_GAME_TIME)
	elseif killed_unit:GetUnitName() == "npc_dota_goodguys_fort" or killed_unit:GetName() == "dota_goodguys_fort" then
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
		GameRules:SetCustomVictoryMessage("#dota_post_game_dire_victory")
		GameRules:SetCustomVictoryMessageDuration(POST_GAME_TIME)
	end

	-- Remove dead non-hero units from selection -> fixing bugged ability/cast bar
	if killed_unit:IsIllusion() or (killed_unit:IsControllableByAnyPlayer() and not killed_unit:IsRealHero() and not killed_unit:IsCourier() and not killed_unit:IsClone() and not killed_unit:IsTempestDouble()) then
		local player = killed_unit:GetPlayerOwner()
		local playerID
		if player == nil then
			playerID = killed_unit:GetPlayerOwnerID()
		else
			playerID = player:GetPlayerID()
		end

		if Selection then
			-- Without Selection library this will return an error
			PlayerResource:RemoveFromSelection(playerID, killed_unit)
		end
	end

	--buildTree:onDestory(killed_unit)
	barebones:handleKilledGold(killer_unit, killed_unit, killing_ability)
end

function barebones:handleKilledGold(killer, killed, killing_ability)
	if not killer or not killer then
		return
	end
	if killer == killed then
		return
	end
	local killedName = killed:GetUnitName()
	local wave = killed.wave
	if not wave then
		return
	end

	-- local hero=GetHeroOfUnit(killer)
	-- if not hero then
	-- 	print("error no hero in unit")
	-- 	return
	-- end
	-- local pid=hero:GetPlayerOwnerID()
	-- local gold=killed.gold or 0

	-- if killer:GetUnitName()=="shushi_shuiyuansu" then
	-- 	gold=gold*2
	-- end

	-- if gold>0 then
	-- 	SimpleOverheadMsg(killed,OVERHEAD_ALERT_GOLD,gold)
	-- 	Player:ModifyGold( pid,gold )
	-- end
end

function barebones:updateUnit(unit, newUnitName)
	NotifyUnitUpgrade(unit:GetPlayerOwnerID(), unit:GetUnitName(), newUnitName)
	local newUnit = BuildingHelper:UpgradeBuilding(unit, newUnitName)
	PlayUpgradeParticle(newUnit)
	return newUnit
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function barebones:OnConnectFull(keys)
	DebugPrint("[BAREBONES] A Player fully connected.")
	--PrintTable(keys)

	self:CaptureGameMode()

	local index = keys.index -- player slot
	local playerID = keys.PlayerID
	local userID = keys.userid -- user ID on server

	-- PlayerResource:OnPlayerConnect(event) is custom-made; can be found in 'player_resource.lua' library
	PlayerResource:OnPlayerConnect(keys)
end

-- This function is called whenever a tower is destroyed
function barebones:OnTowerKill(keys)
	DebugPrint("[BAREBONES] OnTowerKill")
	--PrintTable(keys)

	local gold = keys.gold
	local killer_userID = keys.killer_userid
	local team = keys.teamnumber
end

-- This function is called whenever a player changes their custom team selection during Custom Game Setup
function barebones:OnPlayerSelectedCustomTeam(keys)
	DebugPrint("[BAREBONES] OnPlayerSelectedCustomTeam")
	--PrintTable(keys)

	local playerID = keys.player_id
	local success = (keys.success == 1)
	local team = keys.team_id
end

-- This function is called whenever an NPC reaches its goal position/target (npc can be a lane creep, goal entity can be a path corner)
function barebones:OnNPCGoalReached(keys)
	--DebugPrint("[BAREBONES] OnNPCGoalReached")
	--PrintTable(keys)

	local goal_entity_index = keys
	.goal_entindex                                      -- Entity index of the next goal entity on the path (if any) which the npc will now be pathing towards
	local next_goal_entity_index = keys
	.next_goal_entindex                                 -- Entity index of the path goal entity which has been reached
	local npc_index = keys
	.npc_entindex                                       -- Entity index of the npc which was following a path and has reached a goal entity

	local npc
	local goal_entity

	if npc_index and goal_entity_index then
		npc = EntIndexToHScript(npc_index)
		goal_entity = EntIndexToHScript(goal_entity_index)
	end

	local next_goal_entity
	if next_goal_entity_index then
		next_goal_entity = EntIndexToHScript(next_goal_entity_index)
	end

	if npc and goal_entity then
		-- Your code here
	end
end

function barebones:get_leaderboard(nothing, keys)
	local steamid = PlayerResource:GetSteamAccountID(keys.pid)
	Storage:GetLeaderboard(steamid,keys.season, function(code, data, rawBody)
		if code == 200 then
			--print(rawBody)
			CustomNetTables:SetTableValue("leaderboard", "value", { v = rawBody,rand=RandomInt(0, 1000000) })
		end
	end)
end


function barebones:get_profile(nothing, keys)
	--local steamid = PlayerResource:GetSteamAccountID(keys.pid)
	Storage:GetProfile(keys.steamid, function(code, data, rawBody)
		if code == 200 then
			--print(rawBody)
			-- CustomNetTables:SetTableValue("leaderboard", "value", { v = rawBody,rand=RandomInt(0, 1000000) })
			PlayerTables:SetTableValue("web_profile_"..keys.pid, "data", { v = rawBody,rand=RandomInt(0, 1000000) })
		end
	end)
end


function barebones:web_load_matches(nothing, keys)
	-- local steamid = PlayerResource:GetSteamAccountID(keys.pid)
	Storage:LoadMatches(keys.steamid, keys.page,function(code, data, rawBody)
		if code == 200 then
			--print(rawBody)
			-- CustomNetTables:SetTableValue("leaderboard", "value", { v = rawBody,rand=RandomInt(0, 1000000) })
			PlayerTables:SetTableValue("web_load_matches_"..keys.pid, "data", { v = rawBody,rand=RandomInt(0, 1000000) })
		end
	end)
end

function barebones:OnPlayerChat(keys)
	DebugPrint("[BAREBONES] Player used the chat")
	local team_only = keys.teamonly -- true if team only chat
	local userID = keys.userid
	local playerID = keys.playerid
	local text = keys.text
end
