if not GamePlay then
    GamePlay = class({})
end

GamePlay.metaKv = gMetaKv

function dumpRoundUnitGold()
    for key, value in ipairs(roundInfo) do
        if value.count and value.value then
            print(value.name, value.value, value.count, value.value / value.count)
        end
    end
end

-- duel compensation units

MAX_WAVE = 33
function GamePlay:Init()
    ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(GamePlay, 'OnGameRulesStateChange'), self)
    ListenToGameEvent("entity_killed", Dynamic_Wrap(GamePlay, "OnEntityKilled"), self)
    ListenToGameEvent('npc_spawned', Dynamic_Wrap(GamePlay, 'OnNPCSpawned'), self)

    local proto = { "gamemode_choose", "game_setting" }
    for i, v in ipairs(proto) do
        CustomGameEventManager:RegisterListener(v, function(...)
            return self["OnEvent_" .. v](self, ...)
        end)
    end

    if IsInToolsMode() then
        LinkLuaModifier("modifier_dev_status_effect", "lua_abilities/generic/modifier_dev_status_effect",
            LUA_MODIFIER_MOTION_NONE)
    end

    LinkLuaModifier("modifier_hero_glow", "libraries/modifiers/modifier_hero_glow", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_silence_invul", "modifiers/modifier_silence_invul", LUA_MODIFIER_MOTION_NONE)

    -- building helper
    LinkLuaModifier("modifier_building", "libraries/modifiers/modifier_building", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_card_drag_move", "modifiers/modifier_card_drag_move", LUA_MODIFIER_MOTION_BOTH)
    LinkLuaModifier("modifier_card_drag_ambient", "modifiers/modifier_card_drag_ambient", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_crafting", "libraries/modifiers/modifier_crafting", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_wudi", "libraries/modifiers/modifier_wudi", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_levelup_channel_cast", "libraries/modifiers/modifier_levelup_channel_cast",
        LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_deniable", "libraries/modifiers/modifier_deniable", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_out_of_world", "libraries/modifiers/modifier_out_of_world", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_builder_hidden", "libraries/modifiers/modifier_builder_hidden", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_repairing", "libraries/modifiers/repair_modifiers", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_builder_repairing", "libraries/modifiers/repair_modifiers", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_tree_cut", "libraries/modifiers/modifier_tree_cut", LUA_MODIFIER_MOTION_NONE)
    -- building helper end

    LinkLuaModifier("modifier_generic_unit_targeted_dash", "lua_abilities/generic/modifier_generic_unit_targeted_dash",
        LUA_MODIFIER_MOTION_BOTH)



    LinkLuaModifier("modifier_model_change", "modifiers/modifier_model_change", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_modelscale_change", "modifiers/modifier_modelscale_change", LUA_MODIFIER_MOTION_NONE)

    LinkLuaModifier("modifier_center_zone", "modifiers/modifier_center_zone", LUA_MODIFIER_MOTION_NONE)

    LinkLuaModifier("modifier_outofworld", "modifiers/modifier_outofworld", LUA_MODIFIER_MOTION_NONE)

    LinkLuaModifier("modifier_attack", "ability/modifier/modifier_attack", LUA_MODIFIER_MOTION_NONE)

    LinkLuaModifier("modifier_king_control_cooldown", "modifiers/modifier_king_control_cooldown",
        LUA_MODIFIER_MOTION_NONE)

    LinkLuaModifier("modifier_king_healed", "modifiers/modifier_king_healed", LUA_MODIFIER_MOTION_NONE)

    LinkLuaModifier("modifier_attack_type_debuff", "ability/attack/attack_normal.lua", LUA_MODIFIER_MOTION_NONE)

    LinkLuaModifier("modifier_provides_fow_position", "modifiers/modifier_provides_fow_position",
        LUA_MODIFIER_MOTION_NONE)

    LinkLuaModifier("modifier_tower", "modifiers/modifier_tower", LUA_MODIFIER_MOTION_NONE)



    LinkLuaModifier("modifier_hc", "modifiers/modifier_hc", LUA_MODIFIER_MOTION_NONE)

    LinkLuaModifier("modifier_tower_root", "modifiers/modifier_tower_root", LUA_MODIFIER_MOTION_NONE)

    LinkLuaModifier("modifier_builder", "modifiers/modifier_builder", LUA_MODIFIER_MOTION_NONE)

    LinkLuaModifier("modifier_unit_control", "modifiers/modifier_unit_control", LUA_MODIFIER_MOTION_NONE)

    LinkLuaModifier("modifier_attack_speed", "modifiers/modifier_attack_speed", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_frozen", "modifiers/modifier_frozen", LUA_MODIFIER_MOTION_NONE)

    LinkLuaModifier("modifier_gameplay_nogold", "ability/gameplay_nogold.lua", LUA_MODIFIER_MOTION_NONE)


    LinkLuaModifier("modifier_dev_attack", "modifiers/modifier_dev_attack", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_dev_attack_speed", "modifiers/modifier_dev_attack_speed", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_dev_attack_range", "modifiers/modifier_dev_attack_range", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_dev_mana_cost", "modifiers/modifier_dev_mana_cost", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_dev_health", "modifiers/modifier_dev_health", LUA_MODIFIER_MOTION_NONE)

    -- attack and armor
    LinkLuaModifier("modifier_armor_fortified", "ability/attack/armor_fortified.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_armor_heavy", "ability/attack/armor_heavy.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_armor_hero", "ability/attack/armor_hero.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_armor_light", "ability/attack/armor_light.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_armor_medium", "ability/attack/armor_medium.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_armor_unarmored", "ability/attack/armor_unarmored.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_attack_chaos", "ability/attack/attack_chaos.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_attack_hero", "ability/attack/attack_hero.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_attack_magic", "ability/attack/attack_magic.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_attack_normal", "ability/attack/attack_normal.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_attack_type_debuff", "ability/attack/attack_normal.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_attack_pierce", "ability/attack/attack_pierce.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_attack_siege", "ability/attack/attack_siege.lua", LUA_MODIFIER_MOTION_NONE)

    LinkLuaModifier("modifier_ai_freeze", "libraries/modifiers/modifier_ai_freeze", LUA_MODIFIER_MOTION_NONE)

    Convars:RegisterConvar("dota_legiontd_bot", "0", "", 0)
    Convars:RegisterConvar("dota_legiontd_ai_disable", "0", "", 0)
    Convars:RegisterConvar("dota_legiontd_fast_round", "0", "", 0)
    Convars:RegisterConvar("dota_legiontd_greedy", "0", "", 0)

    Convars:RegisterConvar("dota_legiontd_disable_round_check", "0", "", 0)

    Convars:RegisterConvar("dota_legiontd_send_to_self", "0", "", 0)

    Convars:RegisterConvar("dota_legiontd_send_free", "0", "", 0)

    Convars:RegisterConvar("dota_legiontd_paused", "0", "", 0)

    Convars:RegisterConvar("dota_legiontd_debug", "0", "", FCVAR_REPLICATED)

    Convars:RegisterConvar("dota_legiontd_save", "{}", "", 0)

    for i = 0, 10, 1 do
        Convars:RegisterConvar("dota_legiontd_save_" .. i, "{}", "", 0)
    end

    -- Hero Demo toggles now use the globals defined in settings.lua
    -- HERO_DEMO_AI_DISABLED, HERO_DEMO_ATTACK_ARMOR_TYPE_DISABLED and friends
    GameRules.fastRound = (Convars:GetInt("dota_legiontd_fast_round")) == 1
    GameRules.dota_legiontd_disable_round_check = (Convars:GetInt("dota_legiontd_disable_round_check")) == 1

    GamePlay.eventId = 0
    GamePlay.round = 0
    GamePlay.paths = {}
    GamePlay.visionUnits = {}
    -- idle pre-round in-round idle
    GamePlay.state = "idle"
    GamePlay.duelWinner = nil
    GamePlay.allVisionFlag = false
    --
    GamePlay.laneTable = {}
    GamePlay.nextGoodLane = 0
    GamePlay.nextBadLane = 4

    GamePlay.teamTable = {}

    GamePlay.halfTick = 0

    GamePlay.precachedMap = {}
    local teams = { DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS }
    for key, teamNum in pairs(teams) do
        GamePlay.teamTable[teamNum] = {
            kingGold = 0,
            leakCount = 0,
            king = nil
        }
    end
    GamePlay.kingGood = nil
    GamePlay.kingBad = nil
    --
    GamePlay.roundGoodCreeps = {}
    GamePlay.roundBadCreeps = {}
    GamePlay.roundStartTime = {}


    GamePlay.kickList = {}
    --
    GamePlay.primaryMode = "all_prophet"
    GamePlay.secondaryModes = {
        dark_mode = true,
        fs = true,
        x2 = true,
        creep_stack = true,
    }
    if GetMapName() == "legiontd_ns" then
        GamePlay.secondaryModes["ls"] = false
        GamePlay.secondaryModes["fs"] = false
    end

    GamePlay.roundList = {}
    GamePlay.roundIndex = 0

    GamePlay.fighterMap = {}
    GamePlay.nextFighterId = 1

    -- i lane
    for i = 0, 7 do
        local pathList = {}
        for j = 0, 0 do
            local path = {}
            -- k point
            for k = 0, 4 do
                local posEnt = Entities:FindByName(nil, "ent_path_" .. i .. "_" .. j .. "_" .. k .. "")
                if posEnt then
                    table.insert(path, posEnt:GetAbsOrigin())
                end
            end
            table.insert(pathList, path)
        end
        table.insert(GamePlay.paths, pathList)
    end

    local eventList = { "UnitSelected" }
    for _, v in pairs(eventList) do
        CustomGameEventManager:RegisterListener(v, function(...)
            return self["OnEvent" .. v](self, ...)
        end)
    end
    
    self.metaRounds = LoadKeyValues("scripts/npc/npc_rounds.kv")

    roundInfo = {}
    for i = 1, 100, 1 do
        if self.metaRounds["" .. i] then
            local t = deepcopy(self.metaRounds["" .. i])
            table.insert(roundInfo, t)
        end
    end

    PlayerTables:CreateTable("legiontd_fighter_pool", {}, true)
end

-- PrintTable(type(GamePlay.metaRounds["1"]["name"]))
function GamePlay:GetCurrentRoundData()
    if #GamePlay.roundList > 0 then
        return GamePlay.roundList[#GamePlay.roundList]
    end
end


-- event PlayerSelectUnit
function GamePlay:OnEventUnitSelected(eventSourceIndex, data)
    -- EmitGlobalSound("UI.Button.Pressed")
    -- print(eventSourceIndex,"OnEventUnitSelected")
    local PlayerID = data.PlayerID
    local unit = EntIndexToHScript(tonumber(data.str))
    if unit then
        if not unit:IsHero() then
            emitVoiceSound(unit, "move", PlayerID)
        end
    end
end

function GamePlay:FighterRegister(fighter)
    if not IsActiveUnit(fighter) then
        return
    end
    fighter.fighterId = GamePlay.nextFighterId
    GamePlay.nextFighterId = GamePlay.nextFighterId + 1

    local pos = fighter:GetAbsOrigin()

    GamePlay.fighterMap[fighter.fighterId] = {
        entindex = fighter:entindex(),
        abilityTargetMap = {
        },
        age = 0,
        abilityAutocastMap = {
        },
        abilityToggleMap = {
        },
        castAbilities = {
        },
        modifierStack = {},
        fighterId = fighter.fighterId,
        pos = { pos.x, pos.y, pos.z },
        buildRound = GamePlay.round,
        unit = GamePlay:GetFighterName(fighter),
    }
    print("FighterRegister", fighter:GetUnitName(), fighter.fighterId)
end

function GamePlay:FighterUpdate(id, fighter)
    if not IsActiveUnit(fighter) then
        return
    end
    if not id then
        print("FighterUpdate error", id)
        return
    end
    if not GamePlay.fighterMap[id] then
        print("FighterUpdate error", id)
        return
    end
    fighter.fighterId = id
    GamePlay.fighterMap[id].entindex = fighter:entindex()
    local pos = fighter:GetAbsOrigin()
    GamePlay.fighterMap[id].pos = { pos.x, pos.y, pos.z }
    GamePlay.fighterMap[id].unit = GamePlay:GetFighterName(fighter)
    print("FighterUpdate", fighter:GetUnitName(), fighter.fighterId)
end

function GamePlay:FighterUnregister(id)
    if id then
        GamePlay.fighterMap[id] = nil
    end
end

function GamePlay:FighterGetUnit(id)
    local meta = GamePlay.fighterMap[id]
    if not meta then
        return nil
    end
    local entindex = meta.entindex
    if entindex then
        local unit = EntIndexToHScript(entindex)
        if IsActiveUnit(unit) then
            return unit
        end
    end
    return nil
end

function GamePlay:FighterGetMeta(id)
    local meta = GamePlay.fighterMap[id]
    return meta
end

function GamePlay:FighterSetAbilityTarget(id, abilityName, target)
    local meta = GamePlay.fighterMap[id]
    if not meta then
        return nil
    end
    meta.abilityTargetMap[abilityName] = target
end

function GamePlay:FighterGetAbilityTarget(id, abilityName)
    local meta = GamePlay.fighterMap[id]
    if not meta then
        return nil
    end
    return meta.abilityTargetMap[abilityName]
end


function GamePlay:tryControlKing(PlayerID)
    local unit = GamePlay:GetTData(PlayerResource:GetTeam(PlayerID)).king
    if not IsActiveUnit(unit) then
        return
    end
    unit:SetControllableByPlayer(PlayerID, true)
    fireLeftNotify(PlayerID, true, "notify_king_control", {})
end

function GamePlay:GetTData(teamNum)
    return GamePlay.teamTable[teamNum]
end

function GamePlay:GetOpponentTData(teamNum)
    if teamNum == DOTA_TEAM_GOODGUYS then
        return GamePlay.teamTable[DOTA_TEAM_BADGUYS]
    else
        return GamePlay.teamTable[DOTA_TEAM_GOODGUYS]
    end
end

function GamePlay:DumpAllUnitsInfo()
    local builderMap = {}
    if GamePlay.metaKv and GamePlay.metaKv.builders then
        for _, builder in pairs(GamePlay.metaKv.builders) do
            local raceName = builder.race
            if raceName and raceName ~= "prophet" and raceName ~= "hybrid" then
                builderMap[raceName] = {}
            end
        end
    end
    for builderName, _ in pairs(builderMap) do
        local fileName = "scripts/npc/units/npc_units_" .. builderName .. ".txt"
        print(fileName)
        local kvs = LoadKeyValues(fileName)
        for unitName, value in pairs(kvs) do
            table.insert(builderMap[builderName], unitName)
        end
    end
    --
    return builderMap
end

function GamePlay:GetKing(team)
    if team == DOTA_TEAM_GOODGUYS then
        return GamePlay.kingGood
    elseif team == DOTA_TEAM_BADGUYS then
        return GamePlay.kingBad
    end
end

function GamePlay:GetEnemyKing(team)
    if team == DOTA_TEAM_GOODGUYS then
        return GamePlay.kingBad
    elseif team == DOTA_TEAM_BADGUYS then
        return GamePlay.kingGood
    end
end

function GamePlay:ForeachLane(func)
    for i = 0, 7 do
        local laneData = GamePlay.laneTable[i]
        local pid = Player:GetPlayerByLane(i)
        local pdata = Player:GetPData(pid)
        if pid and pdata then
            func(i, laneData, pid, pdata)
        end
    end
end

function GamePlay:OnNPCSpawned(keys)
    local unit = EntIndexToHScript(keys.entindex)
    local unit_owner = unit:GetOwner()
    -- init wisp
    if unit:IsRealHero() and unit:GetUnitName() == "npc_dota_hero_wisp" then
        Timers:CreateTimer(0.1, function()
            if (not unit:IsNull()) and unit:IsAlive() then
                unit:SetAbilityPoints(0)
                teckTree:updateAbility(unit:GetPlayerOwnerID())
            end
        end)
    end

    local HullRadius = GetUnitKV(unit:GetUnitName(), "HullRadius")

    if HullRadius then
        unit:SetHullRadius(HullRadius)
    end

    if unit then
        local AttackType = GetUnitKV(unit:GetUnitName(), "AttackType")
        local ArmorType = GetUnitKV(unit:GetUnitName(), "ArmorType")
        if AttackType and AttackType ~= "" then
            unit:AddNewModifier(unit, nil, "modifier_" .. AttackType, {})
        end
        if ArmorType and ArmorType ~= "" then
            unit:AddNewModifier(unit, nil, "modifier_" .. ArmorType, {})
        end
    end

    if unit:IsRealHero() then
        unit:AddNewModifier(unit, nil, "modifier_hero_glow", {})
    end

    GamePlay:replaceFighterAbility(unit)


end

function GamePlay:DoGameEnd(winTeam)
    -- Remember the winning team
    GamePlay.gameWinner = winTeam

    -- Sync the net table right away so clients can read gameWinner
    GamePlay:SyncNetTable()

    -- Show the end screen right away
    CustomGameEventManager:Send_ServerToAllClients("show_end_screen", {
        winTeam = winTeam,
        show = 1
    })
    GameRules:SetSafeToLeave(true)
    GamePlay.gameEndFlag = true
    --
    SafeCall(function()
        Storage:MatchUpdate("game_end")
    end)
    --
    local retryCounter = 3
    local sendRoundEnd = nil
    sendRoundEnd = function()
        Storage:MatchEnd(winTeam, function(code, data, rawBody)
            retryCounter = retryCounter - 1
            print("MatchEnd")
            print(code)

            if code == 200 and data and data.code == 200 then
                CustomNetTables:SetTableValue("game_end_result", "value", {
                    v = rawBody
                })
                -- Once the server answers, mark the game safe to leave and finished
            else
                print("send match end fail ", code, " retrying")
                if retryCounter > 0 then
                    Timers:CreateTimer(FrameTime(), function()
                        sendRoundEnd()
                    end)
                else
                end
            end
        end)
    end
    Timers:CreateTimer(FrameTime(), function()
        sendRoundEnd()
    end)
    --
    local kingUnit = GamePlay:GetKing(winTeam)
    if IsActiveUnit(kingUnit) then
        AddAbilityAndSetLevel(kingUnit, "ability_invulnerable", 1)
    end

    -- Add modifier_silence_invul to every unit on the map and order STOP
    local allUnits = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, Vector(0, 0, 0), nil, -1,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD,
        0, false)

    for _, unit in ipairs(allUnits) do
        if IsActiveUnit(unit) then
            unit:AddNewModifier(unit, nil, "modifier_silence_invul", {})
            -- Issue the STOP order
            ExecuteOrderFromTable({
                UnitIndex = unit:GetEntityIndex(),
                OrderType = DOTA_UNIT_ORDER_STOP,
                Queue = false
            })
        end
    end

    -- Camera handling and sound playback
    Player:ForeanchPlayer(function(pid, pdata)
        if pdata.kicked then
            return
        end
        local entPos = Entities:FindByName(nil, "ent_king_bad")
        if winTeam == DOTA_TEAM_BADGUYS then
            entPos = Entities:FindByName(nil, "ent_king_good")
        end
        GamePlay:MoveCamera(pid, entPos:GetAbsOrigin(), 0.1)

        -- Play a sound for the players of each team
        if pdata.team == winTeam then
            -- Victory sound for the winning team
            EmitSoundOnClient("jlin_01.stinger.radiant_win", PlayerResource:GetPlayer(pid))
        else
            -- Defeat sound for the losing team
            EmitSoundOnClient("jlin_01.stinger.radiant_lose", PlayerResource:GetPlayer(pid))
        end
    end)
    --
end

function GamePlay:OnEntityKilled(event)
    print("OnEntityKilled")
    local attacker_entity_index = event.entindex_attacker
    local killed = EntIndexToHScript(event.entindex_killed)
    if not killed then
        return
    end
    local killer = nil
    if attacker_entity_index then
        killer = EntIndexToHScript(attacker_entity_index)
    end
    if not killer then
        return
    end

    if GamePlay.round ~= 33 then
        if killed:GetUnitName() == "king_good" then
            GamePlay:openAllVision()
            GamePlay:DoGameEnd(DOTA_TEAM_BADGUYS)
            return
        elseif killed:GetUnitName() == "king_bad" then
            GamePlay:openAllVision()
            GamePlay:DoGameEnd(DOTA_TEAM_GOODGUYS)
            return
        end
    end

    GamePlay:ForeachLane(function(lane, laneData, pid, pdata)
        TableRemoveByValue(laneData.roundUnits, killed)
    end)

    for k, pid in pairs(Player:Ids()) do
        local pdata = Player:GetPData(pid)
        if pdata then
            TableRemoveByValue(pdata.creeps, killed)
            TableRemoveByValue(pdata.towers, killed)
        end
    end
    TableRemoveByValue(GamePlay.roundGoodCreeps, killed)
    TableRemoveByValue(GamePlay.roundBadCreeps, killed)


    -- bounty
    if killed.path then
        local getGold = 0
        if not killed:HasModifier("modifier_gameplay_nogold") then
            getGold = killed:GetGoldBounty()
        else
            local mod = killed:FindModifierByName("modifier_gameplay_nogold")
            if mod then
                local bountyFactor = mod:GetStackCount() / 100
                getGold = math.floor(killed:GetGoldBounty() * bountyFactor)
            end
        end
        local killerPid = killer:GetPlayerOwnerID()
        -- killed by player
        if killed.goldBountyMultiplier then
            getGold = getGold * killed.goldBountyMultiplier
        end
 
        if getGold > 0 then
            if killerPid >= 0 then
                -- EmitSoundOnLocationWithCaster(killed:GetAbsOrigin(),"General.Coins",killer)
                EmitSoundOnEntityForPlayer("General.Coins", killed, killerPid)
                PopupGoldGain(killed, getGold, {
                    usePos = true,
                    pid = killerPid
                })
                -- SimpleOverheadGoldMsg(killerPid, PlayerResource:GetSelectedHeroEntity(killerPid), getGold)
                Player:ModifyGold(killerPid, getGold)
            elseif killer:GetUnitName() == "king_good" or killer:GetUnitName() == "king_bad" then
                local tdata = GamePlay:GetTData(killer:GetTeamNumber())
                if tdata then
                    PopupGoldGain(killed, getGold, {
                        usePos = true,
                        team = killer:GetTeamNumber()
                    })
                    tdata.kingGold = tdata.kingGold + getGold
                end
            end
        end
    end
end

function GamePlay:CheckRoundEnd()
    local round = roundInfo[GamePlay.round]

    if isTrue(round.duel) then
        local goodAlive = 0
        local badAlive = 0

        if GameRules:GetGameTime() - GamePlay.roundStartTime > (round.timeout or 120) then
            GamePlay.duelWinner = 0
            return true
        end
        --
        removeDeadUnit(GamePlay.roundGoodCreeps)
        removeDeadUnit(GamePlay.roundBadCreeps)

        Player:ForeanchPlayer(function(pid, pdata)
            local team = pdata.team
            removeDeadUnit(pdata.creeps)
            if team == DOTA_TEAM_GOODGUYS then
                goodAlive = goodAlive + #(pdata.creeps)
            else
                badAlive = badAlive + #(pdata.creeps)
            end
        end)
        goodAlive = goodAlive + #(GamePlay.roundGoodCreeps)
        badAlive = badAlive + #(GamePlay.roundBadCreeps)
        if badAlive == 0 and goodAlive == 0 then
            GamePlay.duelWinner = 0
            return true
        end
        if badAlive == 0 then
            GamePlay.duelWinner = DOTA_TEAM_GOODGUYS
            return true
        end
        if goodAlive == 0 then
            GamePlay.duelWinner = DOTA_TEAM_BADGUYS
            return true
        end
    else
        local aliveCount = 0
        for i = 0, 7 do
            local roundUnits = GamePlay.laneTable[i].roundUnits
            removeDeadUnit(roundUnits)
            aliveCount = aliveCount + #roundUnits
        end
        return aliveCount == 0
    end
    return false
end

function GamePlay:isAllPlayerInited()
    for pid = 0, PlayerResource:GetPlayerCount() - 1, 1 do
        if not Player:GetPData(pid) then
            return false
        end
    end
    return true
end

function GamePlay:isAllPlayerHaveHero()
    local ids = Player:Ids()
    for i = 1, #(ids) do
        local pid = ids[i]
        local hero = PlayerResource:GetSelectedHeroEntity(pid)
        if not hero then
            return false
        end
    end
    return true
end

function GamePlay:removeBuildingAbility(unit)
    if not IsActiveUnit(unit) then
        return
    end
    local blackList = {}

    local abilityCount = unit:GetAbilityCount() or 0
    for i = 0, abilityCount - 1 do
        local ab = unit:GetAbilityByIndex(i)
        if ab then
            local abName = (ab:GetAbilityName())
            if abName == "sell_building" or startWith(abName, "upgrade_") then
                -- unit:RemoveAbility(abName)
                ab:SetActivated(false)
            end
            if TableContainsValue(blackList, abName) then
                unit:RemoveAbility(abName)
            end
        end
    end
end

function GamePlay:GetAllHeros(pid)
    print("[GetAllHeros] collecting the hero list, pid:", pid)
    local heros = {}
    local names = {}
    --
    if GamePlay.metaKv and GamePlay.metaKv.builders then
        local totalBuilders = 0
        for _, builder in pairs(GamePlay.metaKv.builders) do
            totalBuilders = totalBuilders + 1
            table.insert(names, builder.name)
        end
        print("[GetAllHeros] total builders:", totalBuilders)
    end
    table.sort(names)
    for _, name in ipairs(names) do
        table.insert(heros, name)
    end
    print("[GetAllHeros] player", pid, "available heroes:", #heros)
    return heros
end

function GamePlay:SpawnGamemaster()
    local position = Vector(0, 0, 256)
    if GamePlay.gameMaster then
        GamePlay.gameMaster:SetAbsOrigin(position)
        return GamePlay.gameMaster
    end

    GamePlay.gameMaster = CreateUnitByName("npc_dota_dummy_caster", position, true, nil, nil, DOTA_TEAM_GOODGUYS)

    AddAbilityAndSetLevel(GamePlay.gameMaster, "game_master_abil", 1)

    return GamePlay.gameMaster
end




function GamePlay:checkEloForMap()
    local minElo = nil
    local mapName = GetMapName()
    if mapName == "legiontd_2900" then
        minElo = 2900
    elseif mapName == "legiontd_3000" then
        minElo = 3000
    end
    if not minElo then
        return
    end
    local flag = true
    Player:ForeanchPlayer(function(pid, pdata)
        if pdata and pdata.rankInfo and pdata.rankInfo.elo and minElo and pdata.rankInfo.elo < minElo then
            flag = false
            fireLeftNotify(pid, false, "notify_player_elo_check", { int1 = pdata.rankInfo.elo, int2 = minElo })
            pdata.cantGetElo = true
            pdata.noEnoughElo = true
            EmitSoundOnClient("UI.Bounty.Failed", PlayerResource:GetPlayer(pid))
            GameRules:SendCustomMessage("#notify_player_elo_check_chat", pid, pid)
        end
    end)
    if not flag then
        -- EmitGlobalSound("UI.Bounty.Failed")
        fireLeftNotify(nil, false, "notify_player_elo_check_fail", {})
    else
        fireLeftNotify(nil, false, "notify_player_elo_check_success", {})
    end
end

function GamePlay:tryPunishPlayer(pid)
    local pdata = Player:GetPData(pid)
    if pdata then
        local hero = PlayerResource:GetSelectedHeroEntity(pid)

        if not hero then
            return
        end

        if hero:GetUnitName() == "npc_dota_hero_wisp" then
            return
        end

        if pdata.leaver_counter and pdata.leaver_counter >= 1 then
            if IsActiveUnit(hero) and not hero:HasAbility("banned_aura") then
                GameRules:SendCustomMessage("#DOTA_Chat_leaver_punish", pid, pdata.leaver_counter)
                AddAbilityAndSetLevel(hero, "banned_aura", 1)
            end
        end
        if pdata.noEnoughElo then
            if IsActiveUnit(hero) and not hero:HasAbility("banned_aura") then
                AddAbilityAndSetLevel(hero, "banned_aura", 1)
            end
        end
    end
end

function GamePlay:handlePlayerInfo(data)
    if not data or not data.players then
        return
    end


    local isFs = GamePlay:Mode("fs") or GamePlay:Mode("ls")
    local playersNet = data.players
    Player:ForeanchPlayer(function(pid, pdata)
        local steamId = pdata.steamId
        for key, value in pairs(playersNet) do
            if value.steamid == steamId then
                local match_data = value.ns_data
                if isFs then
                    match_data = value.fs_data
                end

                local fakeMatchCount = match_data.match_count
                if not match_data.match_count or match_data.match_count == 0 then
                    fakeMatchCount = 1
                end

                pdata.ban_date = value.ban_date
                pdata.banned = value.banned
                pdata.leaver_counter = value.leaver_counter

                pdata.banDateFormated = value.banDateFormated
                pdata.rankInfo = {
                    elo = match_data.elo,
                    match_count = match_data.match_count,
                    match_win = match_data.match_win,
                    winrate = math.floor(1000 * match_data.match_win / fakeMatchCount)
                }
                GamePlay:tryPunishPlayer(pid)
                break
            end
        end
    end)

    Timers:CreateTimer(1, function()
        GamePlay:checkEloForMap()
        Player:ForeanchPlayer(function(pid, pdata)
            GamePlay:tryPunishPlayer(pid)
        end)
    end)
end

local function normalizeGameMode()
    if GamePlay.secondaryModes["x2"] then
        if PlayerResource:GetPlayerCount() > 4 then
            GamePlay.secondaryModes["creep_stack"] = true
        end
        GamePlay.secondaryModes["hc"] = false
    end

    if GamePlay.secondaryModes["creep_stack"] then
        GamePlay.secondaryModes["hc"] = false
    end

    if GamePlay.secondaryModes["hc"] then
        GamePlay.secondaryModes["creep_stack"] = false
    end

    if GetMapName() == "legiontd_ns" then
        GamePlay.secondaryModes["ls"] = false
        GamePlay.secondaryModes["fs"] = false
    end


    local realTeamCount = 0


    local goodCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
    local badCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS)
    if goodCount > 0 then
        realTeamCount = realTeamCount + 1
    end
    if badCount > 0 then
        realTeamCount = realTeamCount + 1
    end

    if realTeamCount == 1 then
        GamePlay.secondaryModes["single_team"] = true
    end
end

function GamePlay:Mode(mode)
    return GamePlay.secondaryModes[mode]
end

function GamePlay:SpawnVisionUnit()
    if not GamePlay:Mode("dark_mode") then
        local largeUnitName = "dummy_vision_fly_large"
        local smallUnitName = "dummy_vision_fly_small"
        local teams = { DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS }
        -- local teams = { DOTA_TEAM_GOODGUYS }
        local xDir = { -1, 1 }
        for i, team in ipairs(teams) do
            for j = 1, 14, 1 do
                local y = 1200 * (j - 7)
                local tUnit = CreateUnitByName(largeUnitName, Vector(4096 * xDir[i], y, 512), false, nil, nil, team)
                table.insert(GamePlay.visionUnits, tUnit)
            end
        end
    end
end

function GamePlay:doGamePre()
    SafeCall(function()
        Storage:MatchStart()
    end)

    normalizeGameMode()

    Player:makeRandomList()

    -- Player:makeRandomList()
    -- Player:makeRandomList()


    print("[legiontd] teamTable")
    PrintTable(GamePlay.teamTable)
    print("GamePlay:OnGameRulesStateChange DOTA_GAMERULES_STATE_PRE_GAME")

    fireLeftNotify(0, false, "notify_pre_game", {})
    -- batchFireLeftNotify(0, false, "notify_secondary_mode", {}, 6)

    Timers:CreateTimer(2, function()
        --  fireLeftNotify(nil, false, "notify_legiontd_help", {})

        GameRules:SendCustomMessage("#notify_legiontd_help", 0, 0)
    end)

    Timers:CreateTimer(10, function()
        -- GameRules:SendCustomMessage("#DOTA_Chat_server_down", 0, 0)
    end)

    Timers:CreateTimer(5, function()
        if GamePlay:Mode("single_team") then
            fireLeftNotify(nil, false, "notify_game_pve", {})
            fireLeftNotify(nil, false, "notify_game_pve_1", {})
            fireLeftNotify(nil, false, "notify_game_pve_2", {})
            if #(Player:GoodPlayers()) == 0 then
                AddItemToUnit(GamePlay.kingGood, "item_rapier_x")
            else
                AddItemToUnit(GamePlay.kingBad, "item_rapier_x")
            end
        end

        if not GamePlay:Mode("single_team") and GameRules:IsCheatMode() then
            fireLeftNotify(nil, false, "notify_game_cheat_enabled", {})
            fireLeftNotify(nil, false, "notify_game_pve_1", {})
            fireLeftNotify(nil, false, "notify_game_pve_2", {})
        end
    end)

    Timers:CreateTimer(1, function()
        GamePlay:PlaceKing()
    end)
    for i = 1, 8 do
        GamePlay.laneTable[i - 1] = {
            roundUnits = {},
            pid = Player:GetPlayerByLane(i - 1)
        }
    end

    Timers:CreateTimer(1, function()
        if GamePlay:isAllPlayerInited() then
            GamePlay:doChooseMode(0)
            Timers:CreateTimer(1, function()
                Storage:PlayerInfo(function(_, data, _)
                    GamePlay:handlePlayerInfo(data)
                end)
            end)
            return nil
        end
        return 1
    end)

    Timers:CreateTimer(0.1, function()
        Timers:CreateTimer(0, function()
            GamePlay:SyncNetTable()
        end)
        return 1
    end)
    Timers:CreateTimer(5, function()
        return GamePlay:CheckPlayerAllLeave()
    end)

    Timers:CreateTimer(1, function()
        GamePlay:SpawnVisionUnit()
    end)

    GamePlay.globalDummy = CreateUnitByName("npc_legiontd_global_dummy", Vector(0, 0, 256), false, nil, nil,
        DOTA_TEAM_NEUTRALS)

    Timers:CreateTimer(2, function()
        for index, pid in ipairs(Player:Ids()) do
            SafeCall(function()
                -- local t1=GameRules:GetGameTime()
                GamePlay:clearDuplicateHero(pid)
                -- print("clearDuplicateHero cost",GameRules:GetGameTime()-t1)
            end)
        end
        return 2
    end)


    local initTable = {}

    Timers:CreateTimer(FrameTime(), function()
        SafeCall(function()
            for i = 1, PlayerResource:GetPlayerCount(), 1 do
                local pid = i - 1
                if not initTable[pid] then
                    local inited = GamePlay:initPlayerResource(pid)
                    if inited then
                        initTable[pid] = true
                    end
                end
            end
        end)

        if GamePlay.state == "in-round" or IsInToolsMode() then
            GamePlay:SyncDamageTable()
        end
        return 1
    end)



    --check player connect
    Timers:CreateTimer(0.1, function()
        local unconnectedCount = 0
        for pid = 0, PlayerResource:GetPlayerCount() - 1, 1 do
            if not Player:IsConnected(pid) then
                unconnectedCount = unconnectedCount + 1
            end
        end
        if unconnectedCount > 0 then
            GameRules:SendCustomMessage("#DOTA_Chat_pre_game_unconnected", 0, unconnectedCount)
        end
        GamePlay.unconnectedCount = unconnectedCount
    end)

    SafeCall(function()
        --
        for pid = 0, PlayerResource:GetPlayerCount() - 1, 1 do
            if PlayerResource:IsValidPlayer(pid) then
                PlayerTables:CreateTable("web_profile_" .. pid, nil, { pid })
                PlayerTables:CreateTable("web_load_matches_" .. pid, nil, { pid })
            end
        end
    end)


end

function GamePlay:CheckPlayerAllLeave()
    local new_state = GameRules:State_Get()
    if new_state >= DOTA_GAMERULES_STATE_POST_GAME then
        return
    end

    if not CHECK_PLAYER_ALL_LEAVE then
        return
    end

    local teams = { DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS }

    local loseTeam = nil

    local allPlayerCount = PlayerResource:GetPlayerCount()

    for _, team in ipairs(teams) do
        local playerCount = 0
        local leaveCount = 0

        local ids = Player:Ids()
        for i = 1, #(ids) do
            local pid = ids[i]
            local pdata = Player:GetPData(pid)
            local gTeam = PlayerResource:GetTeam(pid)
            if gTeam == team then
                playerCount = playerCount + 1
                if pdata then
                    if pdata.kicked or pdata.abandoned then
                        leaveCount = leaveCount + 1
                    end
                end
            end
        end
        if playerCount ~= 0 and playerCount ~= allPlayerCount and leaveCount == playerCount then
            print("all leave ", team, playerCount, leaveCount)
            loseTeam = team
            break
        end
        -- print("check all leave ",team,playerCount,leaveCount)
    end
    if loseTeam then
        Timers:CreateTimer(0, function()
            GamePlay:StartTeamLoseCountDown(loseTeam)
        end)
        return nil
    end

    return 5
end

function GamePlay:StartTeamLoseCountDown(team)
    local countDown = 15
    print("StartTeamLoseCountDown")
    GamePlay.teamLoseCountDown = true
    GamePlay.teamLoseCountDownLoseTeam = team
    Timers:CreateTimer(0, function()
        if not GamePlay.teamLoseCountDown then
            return false
        end

        if countDown > 0 then
            countDown = countDown - 1
            if team == DOTA_TEAM_GOODGUYS then
                fireLeftNotify(0, false, "notify_game_lose_count_down_east_win", {
                    int1 = countDown
                })
            else
                fireLeftNotify(0, false, "notify_game_lose_count_down_west_win", {
                    int1 = countDown
                })
            end
            return 1
        else
            GamePlay:MakeTeamLose(team)
            return nil
        end
    end)
end

function GamePlay:MakeTeamLose(team)
    local tdata = GamePlay:GetTData(team)
    local king = tdata.king
    local enemyKing = GamePlay:GetEnemyKing(team)

    if IsActiveUnit(king) and IsActiveUnit(enemyKing) then
        king:Kill(nil, enemyKing)
        
    end
    
end

function GamePlay:OnGameRulesStateChange(keys)

    

    local new_state = GameRules:State_Get()
    print("OnGameRulesStateChange", new_state)

    SafeCall(function()
        Player:OnGameRulesStateChange(new_state)
    end)

    if new_state == DOTA_GAMERULES_STATE_STRATEGY_TIME then
        print("DOTA_GAMERULES_STATE_STRATEGY_TIME")
        for i = 0, PlayerResource:GetPlayerCount() - 1, 1 do
            Player:AddPlayer(i)
        end
    end
    if new_state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        print("DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP")
        -- PlayerTables:CreateTable("meta", self.metaKv, true)
    end
    if new_state == DOTA_GAMERULES_STATE_PRE_GAME then
        
        Timers:CreateTimer(1, function()
            GamePlay:doGamePre()
            GamePlay:SyncRoundTimer(PRE_GAME_TIME - 1)
        end)
    end
    if new_state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        
        GamePlay:doGameInProgress()
    end
end

local function autoSetupHero(pid)
    if PlayerResource:IsFakeClient(pid) then
        if PlayerResource:GetConnectionState(pid) ~= DOTA_CONNECTION_STATE_NOT_YET_CONNECTED then
            return false
        end
    else
        if PlayerResource:GetConnectionState(pid) ~= DOTA_CONNECTION_STATE_CONNECTED then
            return false
        end
    end

    if not Player:GetPData(pid) then
        return false
    end

    -- maybe nil
    local hero = PlayerResource:GetSelectedHeroEntity(pid)

    local heroName = "npc_dota_hero_rubick"
    if GamePlay.hostPickHeroName then
        heroName = GamePlay.hostPickHeroName
    end

    if not hero then
        
        return false
    end
    if hero and hero:GetName() == "npc_dota_hero_wisp" then
        local pdata = Player.players[pid]
        for _, node in ipairs(pdata.gamemodeChoose.value) do
            node.selected = heroName
        end
        GamePlay:ChooseHero(pid, heroName)
        CustomNetTables:SetTableValue("gamemode_choose", tostring(pid), pdata.gamemodeChoose)
    end
    return true
end


function GamePlay:doPreRound()
    local round = roundInfo[GamePlay.round]
    local preRoundTime = round.preRoundTime or 40
    if GameRules.fastRound then
        preRoundTime = 4
    end
    table.insert(GamePlay.roundList, {
        index = GamePlay.round,
        endFlag = false,
        teleported = {},
        round = round,
        players = {},
        playerDumps = {},
        roundName = round.name,
        preRoundTime = preRoundTime
    })
    local roundData = GamePlay:GetCurrentRoundData()
    Player:ForeanchPlayer(function(pid, pdata)
        roundData.players[pid] = {
            none = 1
        }
    end)
    ---
    SafeCall(function()
        Storage:MatchUpdate("pre")
    end)
    print("[legiontd] doRoundPre " .. GamePlay.round .. " " .. GameRules:GetGameTime())
    GamePlay:notifyRoundInfo(nil, GamePlay.round)
    if round and isTrue(round.hasTips) then
        local r = GamePlay.round
        Timers:CreateTimer(3, function()
            GameRules:SendCustomMessage("#notify_round_pre_" .. r, 0, 0)
        end)
    end

    local unitName = round.unit
    

    if GamePlay.round == 2 then
        Timers:CreateTimer(1, function()
            if (#(Player:GoodPlayers()) > 0 and #(Player:GoodPlayers()) == #(Player:BadPlayers())) then
                fireLeftNotify(nil, false, "notify_will_be_ranked", {})
            else
                fireLeftNotify(nil, false, "notify_will_be_not_ranked", {})
            end
        end)
    end

    Timers:CreateTimer(FrameTime(), function()
        GamePlay:updateBuildingAbility()
    end)

    if round and (isTrue(round.duel) or isTrue(round.allVision)) then
        GamePlay:openAllVision()
    else
        GamePlay:closeAllVision()
    end
    ---
    GamePlay.roundIndex = GamePlay.roundIndex + 1
    Timers:CreateTimer(FrameTime(), function()
        GamePlay:SyncNetTable()
    end)
    GamePlay.roundTimer = preRoundTime
    GamePlay:SyncRoundTimer(preRoundTime)
end



function GamePlay:finishFirstAutoTestTask()
    if #GamePlay.autoTasks <= 0 then
        return
    end
    local task = GamePlay.autoTasks[1]
    table.remove(GamePlay.autoTasks, 1)
    clearCreeps(task.goodCreeps)
    clearCreeps(task.badCreeps)
    local pos = Vector(0, 6656, 128)

    local units = FindUnitsInRadius(DOTA_TEAM_BADGUYS, pos, nil, 1200, DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_CREEP+DOTA_UNIT_TARGET_OTHER+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES +
        DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, 0, false)
    clearCreeps(units)

    task.goodCreeps = {}
    task.badCreeps = {} 
    playerSay(0,"finishFirstAutoTestTask "..task.index.." "..task.ability)
    Storage:AbilityTestEnd(task.ability)
end
function GamePlay:clearTooManyAutoTestCreeps()
    local pos = Vector(0, 6656, 128)
    local units = FindUnitsInRadius(DOTA_TEAM_BADGUYS, pos, nil, 1500, DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_CREEP+DOTA_UNIT_TARGET_OTHER+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES +
        DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, 0, false)
    if #units>150 then
        clearCreeps(units)       
    end
end

function GamePlay:autoTestTickFunc()
    if GamePlay.inAutoTest then
        print("startTestAbilityTick ",#GamePlay.autoTasks)
        -- if #GamePlay.autoTasks ==0 then
        -- end
        if #GamePlay.autoTasks > 0 then
            local task = GamePlay.autoTasks[1]
            if task.state == "idle" then
                task.state = "fight"
                task.startTime=GameRules:GetGameTime()
                Storage:AbilityTestStart(task.ability)
                playerSay(0,"autoTestTickFunc start "..task.index.." "..task.ability)
            elseif task.state == "fight" then
                
                GamePlay:clearTooManyAutoTestCreeps()
                
                if GameRules:GetGameTime() - task.startTime > task.maxRunTime then
                    task.state = "idle"
                    GamePlay:finishFirstAutoTestTask()
                else
                    local pos = Vector(0, 6656, 128)
                    removeDeadUnit(task.goodCreeps)
                    for i = 1, 3, 1 do
                        if #task.goodCreeps < 10 then
                            local team = PlayerResource:GetTeam(0)
                            local newPos = RandomPointInRadius(pos, 1000)
                            local unit = CreateUnitByName(task.creepName, newPos, true, nil, nil, team)
                            unit:SetControllableByPlayer(0, true)
                            unit.targetPos = pos
                            AddAbilityAndSetLevel(unit, "auto_test_passive", 1)
                            local newAb=AddAbilityAndSetLevel(unit, task.ability, 1)
                            if newAb ~= nil then
                                newAb:SetHidden(false)    
                            end
                            unit:AddNewModifier(unit, nil, "modifier_phased", {
                                duration = 0.3
                            })
                            table.insert(task.goodCreeps, unit)
                        end
                    end
                    removeDeadUnit(task.badCreeps)
                    for i = 1, 3, 1 do
                        if #task.badCreeps < 10 then
                            local team = DOTA_TEAM_BADGUYS
                            local newPos = RandomPointInRadius(pos, 1000)
                            local unitName= "npc_dota_creep_badguys_melee"
                            if RandomInt(1, 2)==1 then
                                unitName= "npc_dota_creep_badguys_ranged"
                            end
                            local unit = CreateUnitByName(unitName, newPos, true, nil, nil, team)
                            unit:SetControllableByPlayer(0, true)
                            Timers:CreateTimer(0.3, function()
                                moveAttack(unit, pos)
                            end)
                            unit:AddNewModifier(unit, nil, "modifier_phased", {
                                duration = 0.3
                            })
                            table.insert(task.badCreeps, unit)
                        end
                    end
                end
            end
        end
    end
end

function GamePlay:startTestAbilityTick()
    Timers:CreateTimer(FrameTime(), function()
        SafeCall(function()
            GamePlay:autoTestTickFunc()
        end)

        return 1
    end)
end

function GamePlay:startGameMainTick()
    GamePlay.round = 1
    GamePlay.halfTick = 0
    Timers:CreateTimer(FrameTime(), function()
        -- Idle while the game is over or paused
        if GamePlay.gameWinner or Convars:GetInt("dota_legiontd_paused") == 1 then
            if GamePlay.roundTimer ~= 0 then
                GamePlay:SyncRoundTimer(GamePlay.roundTimer)
            end
            return 0.5
        end
        GamePlay.halfTick = GamePlay.halfTick + 1
        if IsInToolsMode() then
            -- print("half tick ",GamePlay.halfTick,GamePlay.state)
        end
        while true do
            local jumpOut = true
            if GamePlay.state == "idle" then
                GamePlay.state = "pre-round"
                GamePlay.halfTick = 0
                jumpOut = false
            elseif GamePlay.state == "pre-round" then
                if GamePlay.roundTimer and GamePlay.halfTick % 2 == 0 and GamePlay.halfTick ~= 0 then
                    GamePlay.roundTimer = GamePlay.roundTimer - 1
                end
                if GamePlay.halfTick == 0 then
                    print("round pre", GamePlay.round, GamePlay.state)
                    SafeCall(function()
                        GamePlay:doPreRound()
                    end)
                end
                local roundData = GamePlay:GetCurrentRoundData()

                local bStart = false

                if GamePlay.directStart then
                    bStart = true
                else
                    if GamePlay.halfTick >= roundData.preRoundTime * 2 then
                        bStart = true
                    end
                end
                if bStart then
                    -- round start
                    GamePlay.state = "in-round"
                    GamePlay.halfTick = 0
                    jumpOut = false
                    GamePlay.directStart = false
                end
            elseif GamePlay.state == "in-round" then
                local roundData = GamePlay:GetCurrentRoundData()
                local rInfo = roundInfo[GamePlay.round]
                if GamePlay.halfTick == 0 then
                    print("round start", GamePlay.round, GamePlay.state)
                    SafeCall(function()
                        GamePlay:doRoundStart()
                    end)
                    GamePlay:SyncNetTable()
                    GamePlay:SyncRoundTimer(0)
                end
                local checkDelay = 5
                if GamePlay.halfTick >= checkDelay * 2 and not roundData.endFlag then
                    print("check round end")
                    SafeCall(function()
                        Player:ForeanchPlayer(function(pid, pdata)
                            GamePlay:TryMoveToTp(pid)
                        end)
                    end)
                    local waveEnd = GamePlay:CheckRoundEnd()
                    print("CheckRoundEnd", waveEnd)
                    local delay = 1
                    if isTrue(rInfo.duel) then
                        delay = 6
                    end
                    if waveEnd then
                        roundData.endFlag = true
                        roundData.endTick = delay * 2
                    end
                end
                if roundData.endFlag then
                    roundData.endTick = roundData.endTick - 1
                    if roundData.endTick <= 0 then
                        print("[legiontd] round end ")
                        GamePlay:closeAllVision()
                        SafeCall(function()
                            GamePlay:doRoundEnd()
                        end)
                        GamePlay.state = "idle"
                        GamePlay.halfTick = 0
                        jumpOut = false
                        GamePlay:SyncNetTable()
                    end
                end
            end
            if jumpOut then
                break
            end
        end
        return 0.5
    end)
end

function GamePlay:doGameInProgress()
    GamePlay:startGameMainTick()
    GamePlay:startTestAbilityTick()
    GamePlay:startCheatWatcher()

    Timers:CreateTimer(0.1, function()
        if GamePlay.secondaryModes["mo"] then
            GamePlay:openAllVision()
        end
    end)
    Timers:CreateTimer(0.1, function()
        for i = 0, PlayerResource:GetPlayerCount() - 1, 1 do
            local pid = i
            local success = autoSetupHero(pid)
            if not success then
                Timers:CreateTimer(1, function()
                    if autoSetupHero(pid) then
                        return nil
                    else
                        return 1
                    end
                end)
            end
        end
    end)
end

-- Warn everyone while cheat mode or the addon debug mode is on: the check runs
-- once a minute, so a server that enables either of them mid-match is caught.
function GamePlay:startCheatWatcher()
    if GamePlay.cheatWatcherStarted then
        return
    end
    GamePlay.cheatWatcherStarted = true

    Timers:CreateTimer(60, function()
        if GamePlay.gameEndFlag then
            return nil
        end

        if GameRules:IsCheatMode() then
            fireLeftNotify(nil, false, "notify_game_cheat_enabled", {})
        elseif Convars:GetInt("dota_legiontd_debug") == 1 then
            fireLeftNotify(nil, false, "notify_debug_mode_enabled", {})
        end

        return 60
    end)
end

function GamePlay:startHeroChoose()
    local mode = GamePlay.primaryMode
    local ids = {}
    for pid1 = 0, PlayerResource:GetPlayerCount() - 1, 1 do
        table.insert(ids, pid1)
    end
    if mode == "all_pick" then
        for _, pid in pairs(ids) do
            GamePlay:newHeroChoose(pid, "all")
        end
    elseif mode == "host_pick" then
        GamePlay:newHeroChoose(0, "host_pick")
    elseif mode == "all_prophet" then
        local tick = 0
        for _, pid in pairs(ids) do
            local hero = PlayerResource:GetSelectedHeroEntity(pid)
            if hero and IsActiveUnit(hero) and hero:GetUnitName() == "npc_dota_hero_rubick" then
                print("all_prophet already selected")
            else
                GamePlay:newHeroChoose(pid, "list", { "npc_dota_hero_rubick" })
            end
        end
    end
end

function GamePlay:doChooseMode(pid)
    if GamePlay.modeChoosed then
        return
    end
    local mode = GamePlay.primaryMode
    fireLeftNotify(pid, false, "notify_pick_mode", {
        str1 = mode
    })
    local tick = 0
    Timers:CreateTimer(1, function()
        if tick > 10 then
            if GamePlay.playerInfoLoaded then
                print("success random with player info")
                Player:makeRandomList()
            else
                print("fail random with player info")
            end
            GamePlay:startHeroChoose()
            return nil
        end
        tick = tick + 1
        return 1
    end)


    GamePlay.modeChoosed = true
end

function GamePlay:newHeroChoose(pid, type, heroList)
    if type == "all" then
        local allHeros = GamePlay:GetAllHeros(pid)
        GamePlay:newGamemodeChoose(pid, "choose_hero", allHeros)
    end
    if type == "host_pick" then
        local allHeros = GamePlay:GetAllHeros(pid)
        GamePlay:newGamemodeChoose(pid, "choose_hero", allHeros, {
            isHostPick = true
        })
    end
    if type == "list" then
        GamePlay:newGamemodeChoose(pid, "choose_hero", heroList)
    end
    if type == "random" then
        local allHeros = GamePlay:GetAllHeros(pid)
        local hero = PlayerResource:GetSelectedHeroEntity(pid)
        TableRemoveByValue(allHeros, hero:GetUnitName())
        heroList = {}
        local pdata = Player:GetPData(pid)
        for i = 1, 2, 1 do
            pdata.builderIndex = pdata.builderIndex + 1
            local newHero = pdata.builderList[pdata.builderIndex % (#pdata.builderList) + 1]
            table.insert(heroList, newHero)
        end
        GamePlay:newGamemodeChoose(pid, "choose_hero", heroList)
    end
end

function dumpRoundInfo()
    print("round,wave gold,creep count,creep gold,total gold")
    for _, round in ipairs(roundInfo) do
        local creepCount = round.count or 0
        local creepGold = 0
        if round.unit then
            local BountyGoldMin = GetUnitKV(round.unit, "BountyGoldMin", 1)
            local BountyGoldMax = GetUnitKV(round.unit, "BountyGoldMax", 1)
            creepGold = (BountyGoldMin + BountyGoldMax) / 2
        end
        print(round.name .. "," .. round.waveGold .. "," .. creepCount .. "," .. math.ceil(creepGold) .. "," ..
            math.ceil(round.waveGold + creepCount * creepGold))
    end
end

local function calCreepStack(count)
    local maxCount = CREEP_STACK_COUNT

    if GamePlay:Mode("creep_champion") then
        maxCount = maxCount - 3
    end

    local res = {}
    for i = 0, count - 1, 1 do
        local pos = i % (maxCount)
        if not res[pos + 1] then
            table.insert(res, 0)
        end
        res[pos + 1] = res[pos + 1] + 1
    end
    return res
end

function GamePlay:spawnWave(wave)
    local count = roundInfo[wave].count or 1
    local timeGap = 0.1
    local laneMatch = GamePlay:calLaneMatch()
    Player:ForeanchPlayer(function(pid, pdata)
        if pdata.kicked then
            return
        end

        if pdata.disableSpawnWave then
            return
        end

        local spawnCount = count


        if IsInToolsMode() and GamePlay.devCreepCount then
            spawnCount = math.min(count, GamePlay.devCreepCount)
        end
        local unitMerge = false
        if GamePlay.secondaryModes["hc"] and spawnCount > 20 then
            unitMerge = true
            spawnCount = math.ceil(spawnCount / 2)
        end
        --
        if GamePlay.secondaryModes["x2"] then
            spawnCount = spawnCount * 2
        end

        local championInfo = roundInfo[wave].champion

        if not GamePlay:Mode("creep_champion") then
            championInfo = nil
        end

        local championLeakCount = 0

        if championInfo then
            spawnCount = math.ceil(spawnCount * 0.5)
            championLeakCount = math.floor(spawnCount * 0.5 / championInfo.count)
        end

        local creepStack = {}
        for i = 1, spawnCount, 1 do
            table.insert(creepStack, 1)
        end
        if GamePlay.secondaryModes["creep_stack"] then
            creepStack = calCreepStack(spawnCount)
        end
        --
        local lane = pdata.laneIndex
        local laneData = GamePlay.laneTable[lane]


        --add champion
        local waveCreepList = {}
        local mergedList = {}
        --
        for _, stackCount in ipairs(creepStack) do
            table.insert(waveCreepList, {
                unit = roundInfo[wave].unit,
                stack = stackCount,
                isChampion = false,
                leakCount = 1
            })
        end
        if championInfo then
            local championCreepList = {}
            local championCount = championInfo.count

            --

            local eliteCount = championInfo.eliteCount or 0


            if GamePlay.secondaryModes["x2"] then
                championCount = championCount * 2
                eliteCount = eliteCount * 2
            end

            for i = 1, championCount, 1 do
                local newNode = {
                    unit = championInfo.unit,
                    stack = 1,
                    isChampion = true,
                    isElite = false,
                    leakCount = championLeakCount
                }
                if eliteCount > 0 then
                    newNode.isElite = true
                    eliteCount = eliteCount - 1
                end
                table.insert(championCreepList, newNode)
                championCreepList = Shuffle(championCreepList)
            end
            --
            local gapCount = math.ceil(#waveCreepList / #championCreepList)
            local i1 = 1
            for _, node in ipairs(championCreepList) do
                table.insert(mergedList, node)
                for i = 1, gapCount, 1 do
                    if waveCreepList[i1] then
                        table.insert(mergedList, waveCreepList[i1])
                    end
                    i1 = i1 + 1
                end
            end
        else
            mergedList = waveCreepList
        end
        --
        -- PrintTable(mergedList)
        -- start timer task
        --
        local fromPid = nil
        for key, value in pairs(laneMatch) do
            if value == lane then
                fromPid = key
            end
        end
        local c = 0
        local delay = roundInfo[wave].delay or 0
        Timers:CreateTimer(delay, function()
            local spawnNode = mergedList[c + 1]
            local unitName = spawnNode.unit
            local posIndex = nil
            local fixedPos = isTrue(roundInfo[wave].fixedPos)
            -- if GamePlay.secondaryModes["creep_stack"] then
            --     fixedPos = true
            -- end
            if fixedPos then
                posIndex = c
            end
            --
            local unit = GamePlay:spawnWaveUnit(unitName, lane, 0, posIndex, {
                death_spawn = spawnNode.stack,
                targetPid = pid,
                type = "wave",
                fromPid = fromPid,
            })
            --
            if unit then
                unit.leakCount = spawnNode.leakCount
                table.insert(laneData.roundUnits, unit)
                if unitMerge then
                    Timers:CreateTimer(FrameTime() * 10, function()
                        SimpleAddHealth(unit, unit:GetMaxHealth())
                        unit:SetBaseDamageMin(2 * unit:GetBaseDamageMin())
                        unit:SetBaseDamageMax(2 * unit:GetBaseDamageMax())
                        unit.goldBountyMultiplier = 2
                        unit:AddNewModifier(unit, nil, "modifier_hc", {})
                    end)
                end

                if spawnNode.isChampion then
                    if spawnNode.isElite then
                        AddAbilityAndSetLevel(unit, "ability_wave_elite", 1)
                        -- for _, ab in ipairs(spawnNode.appendAbility) do
                        --     AddAbilityAndSetLevel(unit,ab,1)
                        -- end
                    else
                        unit:RemoveAbility(championInfo.eliteAbility)
                    end
                end

            end
            c = c + 1
            if c >= #mergedList then
                return nil
            end
            return timeGap
        end)
    end)
end

function GamePlay:OnEvent_gamemode_choose(nothing, data)
    print("OnEvent_gamemode_choose")
    local type = data.type
    local item = data.item
    local index = data.index
    -- data.PlayerID
    local pid = data.targetPlayerId
    -- PrintTable(data)
    local sourcePid = data.PlayerID
    
    GamePlay:doGamdemodeChoose(pid, type, item, index)
end

function GamePlay:OnEvent_game_setting(nothing, data)
    print("OnEvent_game_setting")
    local pid = data.PlayerID
    local player = PlayerResource:GetPlayer(pid)

    if player and GameRules:PlayerHasCustomGameHostPrivileges(player) then
        if data.game_mode then
            GamePlay.primaryMode = data.game_mode
        end
        if data.sell_mode then
            if GetMapName() ~= "legiontd_ns" then
                if data.sell_mode == "normal_sell" then
                    GamePlay.secondaryModes["ls"] = false
                    GamePlay.secondaryModes["fs"] = false
                end
                if data.sell_mode == "free_sell" then
                    GamePlay.secondaryModes["ls"] = false
                    GamePlay.secondaryModes["fs"] = true
                end
                if data.sell_mode == "last_sell" then
                    GamePlay.secondaryModes["ls"] = true
                    GamePlay.secondaryModes["fs"] = false
                end
            else
                data.sell_mode = "normal_sell"
                GamePlay.secondaryModes["ls"] = false
                GamePlay.secondaryModes["fs"] = false
            end
            -- GamePlay.primaryMode=data.game_mode
        end
        if data.mind_open then
            GamePlay.secondaryModes["mo"] = (data.mind_open ~= 0)
        end
        if data.half_creep then
            GamePlay.secondaryModes["hc"] = (data.half_creep ~= 0)
            if GamePlay.secondaryModes["hc"] then
                GamePlay.secondaryModes["x2"] = false
                data.x2 = 0

                GamePlay.secondaryModes["creep_stack"] = false
                data.creep_stack = 0
            end
        end
        if data.x2 then
            GamePlay.secondaryModes["x2"] = (data.x2 ~= 0)
            if GamePlay.secondaryModes["x2"] then
                if PlayerResource:GetPlayerCount() > 4 then
                    GamePlay.secondaryModes["creep_stack"] = true
                    data.creep_stack = 1
                end
                GamePlay.secondaryModes["hc"] = false
                data.hc = 0
            end
        end

        if data.creep_stack then
            GamePlay.secondaryModes["creep_stack"] = (data.creep_stack ~= 0)
            if GamePlay.secondaryModes["creep_stack"] then
                GamePlay.secondaryModes["hc"] = false
                data.hc = 0
            else
                if PlayerResource:GetPlayerCount() > 4 then
                    GamePlay.secondaryModes["x2"] = false
                    data.x2 = 0
                end
            end
        end

        if data.fighter_stack then
            GamePlay.secondaryModes["fighter_stack"] = (data.fighter_stack ~= 0)
        end
        if data.limited_income then
            GamePlay.secondaryModes["limited_income"] = (data.limited_income ~= 0)
        end
        if data.dark_mode then
            GamePlay.secondaryModes["dark_mode"] = (data.dark_mode ~= 0)
        end
        -- PrintTable(data)
        CustomGameEventManager:Send_ServerToAllClients("game_setting", data)

        GamePlay:SyncGameSettings()
    end
end


function GamePlay:canBeUpgraded(unit)
    if IsActiveUnit(unit) then
        local unitMeta = GamePlay.metaKv.units[unit:GetUnitName()]
        if unitMeta then
            return (unitMeta.upgrades["1"]) == nil
        end
        return true
    end
    return false
end

-- Look up the builder entry for a race
function GamePlay:GetBuilderByRace(race)
    if not GamePlay.metaKv then
        return nil
    end

    if not GamePlay.metaKv.builders then
        return nil
    end

    -- Walk every builder and pick the one matching the race
    for index, builder in pairs(GamePlay.metaKv.builders) do
        if builder.race == race then
            return builder
        end
    end

    return nil
end

function GamePlay:canBeVoteKicked(kickedPid)
    if not kickedPid then
        return false
    end
    local pdataKicked = Player:GetPData(kickedPid)

    if not pdataKicked then
        return false
    end

    if Player:HasAbandoned(kickedPid) then
        return true
    end

    if PlayerResource:IsFakeClient(kickedPid) then
        return true
    end
    if pdataKicked.leakCount >= MAX_LEAK_FOR_KICK then
        return true
    end

    return false
end

function GamePlay:tryKick(pid, kickedPid)
    local pdata = Player:GetPData(pid)
    local pdataKicked = Player:GetPData(kickedPid)

    if not pdata then
        return
    end
    if not pdataKicked then
        return
    end
    if pdata.team ~= pdataKicked.team then
        return
    end
    local canKick = false
    if pdataKicked.leakCount >= MAX_LEAK_FOR_KICK then
        canKick = true
    end

    if canKick then
        if GamePlay.state == "in-round" then
            table.insert(GamePlay.kickList, { pid, kickedPid })
            GameRules:SendCustomMessage("#notify_inround_kick", kickedPid, 0)
        else
            GamePlay:kick(pid, kickedPid)
        end
    end
end

function GamePlay:forceKick(pid, kickedPid)
    local pdata = Player:GetPData(pid)
    local pdataKicked = Player:GetPData(kickedPid)

    if not pdata then
        return
    end
    if not pdataKicked then
        return
    end
    if GamePlay.state == "in-round" then
        table.insert(GamePlay.kickList, { pid, kickedPid })
        GameRules:SendCustomMessage("#notify_inround_kick", kickedPid, 0)
    else
        GamePlay:kick(pid, kickedPid)
    end
end

function GamePlay:doPlayerTp(pid)
    local pdata = Player:GetPData(pid)
    GamePlay.roundList[GamePlay.roundIndex].teleported[pid] = true
    for _, unit in ipairs(pdata.creeps) do
        if unit and not unit.isInDefense then
            playTeleportEffect(unit, 2)
            GamePlay:tpToDefense(unit)
        end
    end
    pdata.defenseModeMoved = true
end

function GamePlay:tryTp(pid)
    if GamePlay.state == "in-round" then
        local pdata = Player:GetPData(pid)
        local round = GamePlay:getRoundInfo(GamePlay.round)
        local lane = pdata.laneIndex
        local laneData = GamePlay.laneTable[lane]
        local leakCount = GamePlay:getCenterLeakedCreepCount(lane)
        local nonLeakCount = GamePlay:getNonCenterLeakedCreepCount(lane)

        local doTp = false
        if not isTrue(round.duel) and leakCount > 0 then
            doTp = true
        end
        if not isTrue(round.duel) and nonLeakCount == 0 then
            doTp = true
        end
        if round.name == 31 then
            doTp = true
        end
        if doTp then
            GamePlay:doPlayerTp(pid)
        else
            SendErrorMessage(pid, "error_cant_tp_now", { leakCount })
        end
    else
        SendErrorMessage(pid, "error_cant_tp_now", {})
    end
end

function GamePlay:tryVoteKick(pid, kickedPid)
    if PlayerResource:GetTeam(pid) ~= PlayerResource:GetTeam(kickedPid) then
        SendErrorMessage(pid, "error_cant_kick")
        return
    end

    local pdata = Player:GetPData(kickedPid)
    if not pdata then
        return
    end

    if pdata.kicked then
        return
    end

    local kicked = false

    -- check vote condition

    if GamePlay:canBeVoteKicked(kickedPid) then
        if not TableContainsValue(pdata.kickedVoteList, pid) then
            table.insert(pdata.kickedVoteList, pid)
        end
    else
        SendErrorMessage(pid, "error_cant_kick")
        return false
    end


    local activePids = Player:GetActivePlayerInTeam(PlayerResource:GetTeam(kickedPid))

    TableRemoveByValue(activePids, kickedPid)
    local count = #activePids
    if count < 0 then
        return
    end
    local voteCount = 0
    for _, votePid in pairs(pdata.kickedVoteList) do
        local votePdata = Player:GetPData(votePid)
        if votePdata and (not votePdata.kicked) then
            voteCount = voteCount + 1
        end
    end
    if voteCount >= count then
        kicked = true
        fireLeftNotify(kickedPid, true, "notify_votekick_success", {
            int1 = voteCount,
            int2 = count
        })
    else
        fireLeftNotify(kickedPid, true, "notify_votekick_votes", {
            int1 = voteCount,
            int2 = count
        })
    end

    if kicked then
        if GamePlay.state == "in-round" then
            table.insert(GamePlay.kickList, { pid, kickedPid })
        else
            GamePlay:kick(pid, kickedPid)
        end
    end
end

function GamePlay:autoHeal(pid)
    local pdata = Player:GetPData(pid)
    if pid and pdata then
        local hero = PlayerResource:GetSelectedHeroEntity(pid)
        if hero and not hero:IsStunned() then
            local holyLight = hero:FindItemInInventory("item_holy_light")
            if holyLight then
                GamePlay:holyLight(hero, pid, holyLight)
                return true
            end
        end
    end
    return false
end

function GamePlay:holyLight(caster, orderPlayerId, item)
    local pid = caster:GetPlayerOwnerID()

    local king = GamePlay:GetKing(caster:GetTeamNumber())
    local heal = 10000

    if GamePlay.secondaryModes["x2"] then
        heal = 2 * heal
    end

    king:Heal(heal, caster)

    fireLeftNotify(pid, false, "notify_holy_light", {})
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, king, heal, nil)
    EmitSoundOn("Hero_Omniknight.Purification", king)
    EmitSoundOn("Hero_Omniknight.Purification", caster)
    local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf",
        PATTACH_CUSTOMORIGIN_FOLLOW, king)
    ParticleManager:SetParticleControl(fx, 0, king:GetAbsOrigin())
    ParticleManager:SetParticleControl(fx, 1, Vector(200, 200, 200))
    ParticleManager:ReleaseParticleIndex(fx)

    if item then
        item:SpendCharge(0)
        if item:GetCurrentCharges() == 0 then
            caster:TakeItem(item)
        end
    end
end

function GamePlay:transferHolyLight(fromPid)
    local hero = PlayerResource:GetSelectedHeroEntity(fromPid)
    if not hero then
        return
    end
    local targetPid = nil
    for _, pid in ipairs(Player:Ids()) do
        if fromPid ~= pid and PlayerResource:GetTeam(fromPid) == PlayerResource:GetTeam(pid) then
            local pdata = Player:GetPData(pid)
            if not pdata.kicked then
                local h = PlayerResource:GetSelectedHeroEntity(pid)
                if h and not h:FindItemInInventory("item_holy_light") then
                    targetPid = pid
                    break
                end
            end
        end
    end
    if not targetPid then
        return
    end
    local targetHero = PlayerResource:GetSelectedHeroEntity(targetPid)
    if not targetHero then
        return
    end
    local item = hero:FindItemInInventory("item_holy_light")
    if not item then
        return
    end
    local charge = item:GetCurrentCharges()

    if charge > 0 then
        local targetItem = targetHero:FindItemInInventory("item_holy_light")
        if targetItem then
            targetItem:SetCurrentCharges(targetItem:GetCurrentCharges() + 1)
        else
            AddItemToUnit(targetHero, "item_holy_light")
        end
        EmitSoundOn("Hero_Omniknight.Purification", targetHero)
        local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf",
            PATTACH_CUSTOMORIGIN_FOLLOW, targetHero)
        ParticleManager:SetParticleControl(fx, 0, targetHero:GetAbsOrigin())
        ParticleManager:SetParticleControl(fx, 1, Vector(200, 200, 200))
        ParticleManager:ReleaseParticleIndex(fx)
    end
    hero:TakeItem(item)
end

function GamePlay:clearKickedPlayer()
    for key, pid in pairs(Player:Ids()) do
        local pdata = Player:GetPData(pid)
        if pdata and pdata.kicked then
            for k, v in pairs(pdata.buildings) do
                if IsActiveUnit(v) then
                    v:AddEffects(EF_NODRAW)
                    v:Kill(nil, nil)
                end
            end
            pdata.buildings = {}
            for k, v in pairs(pdata.towers) do
                if IsActiveUnit(v) then
                    BuildingHelper:RemoveBuilding(v, true)
                    v:AddEffects(EF_NODRAW)
                    v:Kill(nil, nil)
                end
            end
            pdata.towers = {}
            for k, v in pairs(pdata.creeps) do
                if IsActiveUnit(v) then
                    v:AddEffects(EF_NODRAW)
                    v:Kill(nil, nil)
                end
            end
            pdata.creeps = {}
        end
    end
end

function GamePlay:kick(pid, kickedPid)
    local pdata = Player:GetPData(pid)
    local pdataKicked = Player:GetPData(kickedPid)

    if not pdata then
        return
    end
    if not pdataKicked then
        return
    end
    if pdataKicked.kicked then
        return
    end

    -- GamePlay:autoHeal(kickedPid)

    GamePlay:transferHolyLight(kickedPid)

    pdataKicked.kicked = true

    pdataKicked.kickedTime = GameRules:GetGameTime()

    for k, v in pairs(pdataKicked.buildings) do
        if IsActiveUnit(v) then
            v:AddEffects(EF_NODRAW)
            v:Kill(nil, nil)
        end
    end
    pdataKicked.buildings = {}
    for k, v in pairs(pdataKicked.towers) do
        BuildingHelper:RemoveBuilding(v, true)
        if IsActiveUnit(v) then
            v:AddEffects(EF_NODRAW)
            v:Kill(nil, nil)
        end
    end
    pdataKicked.towers = {}
    for k, v in pairs(pdataKicked.creeps) do
        if IsActiveUnit(v) then
            v:AddEffects(EF_NODRAW)
            v:Kill(nil, nil)
        end
    end
    pdataKicked.creeps = {}

    for k, v in pairs(pdataKicked.barrackUnits) do
        if IsActiveUnit(v) then
            v:AddEffects(EF_NODRAW)
            v:Kill(nil, nil)
        end
    end
    pdataKicked.barrackUnits = {}

    local hero = PlayerResource:GetSelectedHeroEntity(kickedPid)
    if hero then
        PlayEffOnUnit("particles/econ/items/axe/ti9_jungle_axe/ti9_jungle_axe_culling_blade_kill_b.vpcf", hero, {
            cps = { 0, 1, 2, 3, 4 }
        })
        PlayEffOnUnit("particles/econ/items/axe/ti9_jungle_axe/ti9_jungle_axe_culling_blade_pool.vpcf", hero, {
            cps = { 0, 1, 2, 3, 4 }
        })
        EmitSoundOn("Hero_Axe.Culling_Blade_Success", hero)

        hero:AddNewModifier(hero, nil, "modifier_stunned", {})
    end
    GameRules:SendCustomMessage("#DOTA_Chat_Kicked", kickedPid, 0)

    fireLeftNotify(kickedPid, false, "notify_kicked", {
    })

end

function GamePlay:spawnWaveUnit(unitName, line, subLine, posIndex, params)
    subLine = subLine or 0
    if not params then
        params = {}
    end
    --
    if GamePlay.paths[line + 1] and GamePlay.paths[line + 1][subLine + 1] and GamePlay.paths[line + 1][subLine + 1][1] then
        local spawnPos = GamePlay.paths[line + 1][subLine + 1][1]
        local finalSpawnPos = Vector(spawnPos.x, spawnPos.y, spawnPos.z)
        local width = 768

        if posIndex then
            posIndex = posIndex % 11
            local posOff = 0
            if posIndex % 2 == 0 then
                posOff = (width / 10) * posIndex / 2
            else
                posOff = -1 * (width / 10) * (posIndex + 1) / 2
            end
            finalSpawnPos.x = spawnPos.x + posOff
        else
            finalSpawnPos.x = spawnPos.x - width / 2 + (RandomInt(0, width))
        end
        local tUnit = CreateUnitByName(unitName, finalSpawnPos, false, nil, nil, DOTA_TEAM_CUSTOM_1)

        local eff = "particles/units/heroes/hero_lycan/lycan_summon_wolves_spawn.vpcf"
        local particle = SimpleCreateParticle(eff, tUnit)
        SimpleSetControlEnt(particle, 0, tUnit, PATTACH_POINT_FOLLOW)
        ParticleManager:ReleaseParticleIndex(particle)
        tUnit:AddNewModifier(nil, nil, "modifier_phased", {
            duration = 0.1
        })
        tUnit.path = line
        tUnit.subPath = subLine
        -- init creep gold
        local angels = { -90, 90, -90, 90, -90, 90, -90, 90 }
        tUnit:SetAngles(0, angels[line + 1], 0)

        tUnit.zoneIndex = 1

        GamePlay:moveCreep(tUnit, line, subLine)
        --
        if params.death_spawn and params.death_spawn > 1 then
            AddAbilityAndSetLevel(tUnit, "death_spawn", params.death_spawn - 1)
        end

        --
        return tUnit
    end
end

function GamePlay:moveCreep(unit, pathIndex, subPath, checkStartPoint)
    if pathIndex == nil then
        return
    end

    if unit.pathList == nil then
        local rawPath = GamePlay.paths[pathIndex + 1][subPath + 1]
        unit.pathList = {}
        unit.wayStep = 1
        unit.waypoints = {}
        for k, pos in pairs(rawPath) do
            local newPos = Vector(pos.x, pos.y, pos.z)
            if k == 2 then
                newPos = Vector(unit:GetAbsOrigin().x, RandomInt(pos.y - 384, pos.y + 64), pos.z)
            end

            if k == 3 then
                local prePos = unit.pathList[2]
                newPos = Vector(RandomInt(pos.x - 256, pos.x + 256), prePos.y, pos.z)
            end

            if k == 4 then
                local prePos = unit.pathList[3]
                newPos = Vector(prePos.x, pos.y, pos.z)
            end

            if k == 5 then
                local prePos = unit.pathList[4]
                newPos = Vector(prePos.x, pos.y, pos.z)
            end

            table.insert(unit.pathList, newPos)
            if k > 1 then
                table.insert(unit.waypoints, newPos)
            end
        end
    end
    local path = unit.pathList
    local waypoints = unit.waypoints

    local startIndex = 2
    if checkStartPoint then
        startIndex = GamePlay:getStartPoint(unit:GetAbsOrigin(), waypoints)
        unit.wayStep = startIndex
    end

end

function GamePlay:getStartPoint(pos, path)
    for i = 1, #path - 1 do
        -- Compare the X coordinates
        local point1 = path[i]
        local point2 = path[i + 1]
        if math.abs(point2.x - point1.x) > 200 then
            local dis = distanceFromPointToLine(pos, point1, point2)
            if dis < 200 then
                return i + 1
            end
        end
        if math.abs(point2.y - point1.y) > 200 then
            local dis = distanceFromPointToLine(pos, point1, point2)
            if dis < 200 then
                return i + 1
            end
        end
    end
    return 2
end

function GamePlay:getSlaveTradeGold(pid)
    local pdata = Player:GetPData(pid)

    if not pdata then
        return 0
    end

    local bHasSlaveMaster = false
    for k, unit in pairs(pdata.creeps) do
        if IsActiveUnit(unit) and unit:GetUnitName() == "demi_human_slavemaster" then
            bHasSlaveMaster = true
            break
        end
    end
    if not bHasSlaveMaster then
        return 0
    end
    local gold = 0
    for k, unit in pairs(pdata.creeps) do
        if IsActiveUnit(unit) and unit:GetUnitName() == "demi_human_slavemaster" then
            local bonusGold = 8
            if unit:GetLevel() == 2 then
                bonusGold = bonusGold + 8
            end
            gold = gold + bonusGold
            PopupGoldGain(unit, bonusGold, {
                usePos = true,
                pid = pid
            })
        end
        if IsActiveUnit(unit) and unit:GetUnitName() == "demi_human_servant" then
            local bonusGold = 4
            gold = gold + bonusGold
            PopupGoldGain(unit, bonusGold, {
                usePos = true,
                pid = pid
            })
        end
    end
    return gold
end

function GamePlay:awardWaveSuccess(wave)
    if wave < 33 then
        local round = roundInfo[GamePlay.round]
        if isTrue(round.duel) then
            Player:ForeanchPlayer(function(pid, pdata)
                if pdata.kicked then
                    return
                end
                --
                local getGold = 0
                --
                if GamePlay.duelWinner == pdata.team then
                    getGold = getGold + (roundInfo[wave].waveGold or 0)
                    if GamePlay:Mode("x2") then
                        getGold = (roundInfo[wave].x2_waveGold or roundInfo[wave].waveGold or 0)
                    end
                    fireLeftNotify(pid, false, "notify_award_duel", {
                        int1 = getGold
                    })
                end
                Player:ModifyGold(pid, getGold)
                SendOverheadEventMessage(PlayerResource:GetPlayer(pid), OVERHEAD_ALERT_GOLD,
                    PlayerResource:GetSelectedHeroEntity(pid), getGold, nil)
            end)
        else
            local gold1 = roundInfo[wave].waveGold
            for key, pid in pairs(Player:Ids()) do
                local pdata = Player:GetPData(pid)
                if pdata and not pdata.kicked then
                    local slaveTradeGold = GamePlay:getSlaveTradeGold(pid)
                    local tdata = GamePlay:GetTData(pdata.team)
                    local opponentTdata = GamePlay:GetOpponentTData(pdata.team)
                    local playerCount = math.max(1, Player:GetNonKickedPlayerCountByTeam(pdata.team))
                    local kingGoldShare = math.ceil((tdata.kingGold * 0.5 + opponentTdata.kingGold * 0.5) / playerCount)
                    local income = pdata.income

                    --
                    fireLeftNotify(pid, true, "msg_round_get_gold", {
                        int1 = gold1,
                        int2 = income
                    })
                    if slaveTradeGold and slaveTradeGold > 0 then
                        fireLeftNotify(pid, true, "msg_get_gold_from_slave", {
                            int1 = slaveTradeGold
                        })
                    end
                    if kingGoldShare > 0 then
                        fireLeftNotify(pid, false, "msg_get_gold_from_king", {
                            int1 = kingGoldShare
                        })
                    end
                    local getGold = gold1 + income + slaveTradeGold + kingGoldShare
                    Player:ModifyGold(pid, getGold)
                    SendOverheadEventMessage(PlayerResource:GetPlayer(pid), OVERHEAD_ALERT_GOLD,
                        PlayerResource:GetSelectedHeroEntity(pid), getGold, nil)
                end
            end
            for key, tdata in pairs(GamePlay.teamTable) do
                tdata.kingGold = 0
            end
        end
    end
end

function GamePlay:calLaneMatch()
    local players = {}

    local goodIds = {}
    local badIds = {}

    local function isLaneUsed(lane)
        for _, l in pairs(players) do
            if l == lane then
                return true
            end
        end
        return false
    end

    local function findEmptyOpponentLane(pid)
        local pdata = Player:GetPData(pid)
        local team = pdata.team

        for pid1, lane1 in pairs(players) do
            local pdata1 = Player:GetPData(pid1)
            if team ~= pdata1.team and not isLaneUsed(pdata1.laneIndex) then
                return pdata1.laneIndex
            end
        end
        return nil
    end

    Player:ForeanchPlayer(function(pid, pdata)
        if pdata.kicked then
            return
        end
        if pdata.team == DOTA_TEAM_GOODGUYS then
            players[pid] = -1
        else
            players[pid] = -1
        end
    end)
    -- fill simple match
    for pid, _ in pairs(players) do
        local pdata = Player:GetPData(pid)
        if pdata then
            local laneIndex = pdata.laneIndex
            local targetLane = (laneIndex + 4) % 8
            local targetPid = Player:GetPlayerByLane(targetLane)
            if targetPid then
                players[pid] = targetLane
            end
        end
    end
    -- find empty
    for pid, lane in pairs(players) do
        local pdata = Player:GetPData(pid)
        if pdata and lane == -1 then
            if pdata.team == DOTA_TEAM_GOODGUYS then
                table.insert(goodIds, pid)
            else
                table.insert(badIds, pid)
            end
        end
    end
    -- match by empty
    table.sort(goodIds)
    table.sort(badIds)
    for i = 1, math.min(#goodIds, #badIds), 1 do
        local pid1 = goodIds[i]
        local pid2 = badIds[i]
        players[pid1] = Player:GetPData(pid2).laneIndex
        players[pid2] = Player:GetPData(pid1).laneIndex
    end
    return players
end

function GamePlay:GetEnemyLanes(pid)
    local res = {}
    for pid1 = 0, PlayerResource:GetPlayerCount() - 1, 1 do
        local pdata1 = Player:GetPData(pid1)
        if pdata1 and not pdata1.kicked and PlayerResource:GetTeam(pid) ~= PlayerResource:GetTeam(pid1) then
            table.insert(res, pdata1.laneIndex)
        end
    end
    return res
end

function GamePlay:saveSendUnit(laneIndex, unitName)
    local roundNode = GamePlay:GetCurrentRoundData()
    if not roundNode then
        return
    end
    for _, pid in ipairs(Player:Ids()) do
        local pdata = Player:GetPData(pid)
        local pstats = roundNode.players[pid]

        if pstats then
            if not pstats.receivedUnits then
                pstats.receivedUnits = {}
            end
        end
        if not pdata.kicked then
            if pstats and pdata.laneIndex == laneIndex then
                table.insert(pstats.receivedUnits, unitName)
                return
            end
        end
    end
end

function GamePlay:spawnBarrackUnitInWave()
    local laneMatch = GamePlay:calLaneMatch()

    Player:ForeanchPlayer(function(pid, pdata)
        if pdata.kicked then
            return
        end
        local laneIndex = pdata.laneIndex
        local c = 0
        local targetLane = (laneIndex + 4) % 8
        --
        local enemyLanes = {}
        if laneMatch[pid] ~= -1 and laneMatch[pid] then
            enemyLanes = { laneMatch[pid] }
        else
            enemyLanes = GamePlay:GetEnemyLanes(pid)
            if #enemyLanes == 0 then
                enemyLanes = { targetLane }
            end
        end
        for _, barrackUnit in ipairs(pdata.barrackUnits) do
            barrackUnit.sendFlag = true
        end

        if Convars:GetInt("dota_legiontd_send_to_self") == 1 then
            enemyLanes = { laneIndex }
        end
        --
        Timers:CreateTimer(1.5, function()
            if #pdata.barrackUnits > 0 then
                local unit = pdata.barrackUnits[1]
                if not unit.sendFlag then
                    return nil
                end

                local targetLanes = enemyLanes
                if unit.sendToSelf then
                    targetLanes = { laneIndex }
                end

                table.remove(pdata.barrackUnits, 1)
                local unitName = unit:GetUnitName()
                unit:AddEffects(EF_NODRAW)
                unit:Kill(nil, nil)
                local finalLane = targetLanes[1 + (c) % (#targetLanes)]
                local newUnit = GamePlay:spawnWaveUnit(unitName, finalLane, 0, c, {
                    fromPid = pid,
                    type = "barrack"
                })
                table.insert(GamePlay.laneTable[finalLane].roundUnits, newUnit)
                GamePlay:saveSendUnit(finalLane, unitName)
                c = c + 1
                return 0.1
            else
                return nil
            end
        end)
    end)
end

--
function GamePlay:spawnBarrackUnit(pid, unitName)
    local pdata = Player:GetPData(pid)

    if not pdata then
        return
    end

    local pos = nil
    local hero = PlayerResource:GetSelectedHeroEntity(pid)
    if pdata.team == DOTA_TEAM_GOODGUYS then
        pos = getRandomPosInTrigger("island_good")
    else
        pos = getRandomPosInTrigger("island_bad")
    end
    local creep = CreateUnitByName(unitName, pos, false, hero, hero, pdata.team)
    table.insert(pdata.barrackUnits, creep)
    creep:SetAngles(0, RandomInt(-180, 180), 0)
    creep:AddNewModifier(nil, nil, "modifier_phased", {
        duration = 0.1
    })

    return creep
end

local unitEffMap = {
    ["barrack_demon"] = {
        particle = "particles/econ/items/terrorblade/terrorblade_back_ti8/terrorblade_sunder_ti8.vpcf",
        sound = "Hero_Terrorblade.Sunder.Target"
    },
    ["barrack_infernal"] = {
        particle = "particles/units/heroes/hero_warlock/warlock_rain_of_chaos_start.vpcf",
        sound = "Hero_Warlock.RainOfChaos"
    },
    ["barrack_kraken"] = {
        particle =
        "particles/econ/items/kunkka/divine_anchor/hero_kunkka_dafx_skills/kunkka_spell_torrent_splash_fxset.vpcf",
        sound = "Ability.Torrent"
    },
    ["barrack_behemoth"] = {
        particle = "particles/units/heroes/hero_tidehunter/tidehunter_spell_ravage.vpcf",
        sound = "Ability.Ravage",
        effType = "ravage"
    },
    ["barrack_gargoyle"] = {
        particle = "particles/units/heroes/hero_visage/visage_summon_familiars.vpcf",
        sound = "Hero_Visage.SummonFamiliars.Cast"
    },
    ["barrack_pudge"] = {
        particle = "particles/units/heroes/hero_pudge/pudge_rot.vpcf",
        sound = "Hero_Pudge.Swallow",
        effType = "radius"
    },
    ["barrack_shaman"] = {
        particle = "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf",
        sound = "Hero_OgreMagi.Bloodlust.Cast"
    },
    ["barrack_ballista"] = {
        particle = "particles/econ/creeps/creep_2021_radiant/creep_2021_radiant_siege_death.vpcf",
        sound = "Creep_Siege_Radiant.Destruction"
    },
    ["barrack_pandaren"] = {
        particle = "particles/units/heroes/hero_ursa/ursa_earthshock.vpcf",
        effType = "radius",
        sound = "Hero_Ursa.Earthshock"
    },
    ["barrack_warlock"] = {
        particle = "particles/econ/items/lion/fish_stick/fish_stick_spell_fish.vpcf",
        sound = "Hero_Lion.Voodoo"
    },
    ["barrack_ice_troll"] = {
        particle = "particles/units/heroes/hero_troll_warlord/troll_warlord_rampage_resistance_buff.vpcf",
        sound = "Hero_TrollWarlord.Pick"
    },
    ["barrack_frost_wolf"] = {
        particle = "particles/units/heroes/hero_lycan/lycan_howl_cast.vpcf",
        sound = "Hero_Lycan.Howl"
    },
    ["barrack_blood_orc"] = {
        particle = "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodritual_ring_lv.vpcf",
        sound = "hero_bloodseeker.bloodRage",
        effType = "radius"
    },
    ["barrack_chariot"] = {
        particle = "particles/siege_fx/siege_bad_death_01.vpcf",
        sound = "Creep_Siege_Dire.Destruction"
    },
    ["barrack_wyvern"] = {
        particle = "particles/units/heroes/hero_visage/visage_grave_chill_tgt.vpcf",
        sound = "Hero_Visage.GraveChill.Target"
    },
    ["barrack_furbolg"] = {
        particle = "particles/neutral_fx/ursa_thunderclap.vpcf",
        sound = "Hero_Brewmaster.ThunderClap",
        effType = "radius"
    },
    ["barrack_commander"] = {
        particle = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_linger.vpcf",
        sound = "Hero_Snapfire.MortimerBlob.Impact"
    },
    ["barrack_dino"] = {
        particle = "particles/neutral_fx/roshan_slam.vpcf",
        sound = "n_creep_Thunderlizard_Big.Stomp"
    },
    ["barrack_hermit"] = {
        particle = "particles/econ/items/witch_doctor/wd_ti10_immortal_weapon/wd_ti10_immortal_voodoo.vpcf",

        sound = "Hero_WitchDoctor.Voodoo_Restoration"
    },
    ["barrack_whelp"] = {
        particle = "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green.vpcf",
        sound = "Hero_DragonKnight.ElderDragonForm"
    },
    ["barrack_warrior"] = {
        particle = "particles/econ/items/spirit_breaker/spirit_breaker_weapon_ti8/spirit_breaker_bash_ti8.vpcf",
        sound = "Hero_Slardar.Bash"
    },
    ["barrack_ghoul"] = {
        particle = "particles/econ/items/lifestealer/ls_ti9_immortal/ls_ti9_open_wounds.vpcf",
        sound = "Hero_LifeStealer.OpenWounds.Cast"
    },
    ["barrack_bowman"] = {
        particle = "particles/econ/items/drow/drow_arcana/drow_v2_arcana_revenge_kill_effect_caster.vpcf",
        sound = "Hero_DrowRanger.FrostArrows"
    }
}


function GamePlay:SetUnitPrecacheStatus(unitName, status, source)
    if not unitName then
        return nil
    end

    GamePlay.precachedMap = GamePlay.precachedMap or {}
    local precachedMap = GamePlay.precachedMap
    local record = precachedMap[unitName] or {}

    if not record.startTime then
        record.startTime = GameRules:GetGameTime()
    end

    record.status = status
    record.source = source or record.source

    if status == "loaded" then
        record.endTime = GameRules:GetGameTime()
    end

    precachedMap[unitName] = record

    return record
end

function GamePlay:IsUnitPrecacheFinished(unitName)
    local record = GamePlay.precachedMap and GamePlay.precachedMap[unitName]
    return record and record.status == "loaded"
end

function GamePlay:IsUnitPrecacheInProgress(unitName)
    local record = GamePlay.precachedMap and GamePlay.precachedMap[unitName]
    return record and record.status == "loading"
end

function GamePlay:precacheUnitByNameSync(unitName, context, source)
    if GamePlay:IsUnitPrecacheFinished(unitName) then
        return false
    end

    GamePlay:SetUnitPrecacheStatus(unitName, "loading", source or "sync")

    if context then
        PrecacheUnitByNameSync(unitName, context)
    end

    GamePlay:SetUnitPrecacheStatus(unitName, "loaded", source or "sync")

    return true
end


function GamePlay:ShouldPrecacheUnit(unitKV, unitName, isFighter)
    -- Check whether Creature.AttachWearables looks usable
    if not unitKV.Creature then
        return false  -- no Creature table, skip the precache
    end

    if not unitKV.Creature.AttachWearables then
        return false  -- no AttachWearables inside Creature, skip the precache
    end

    -- Is AttachWearables empty?
    local hasWearables = false
    for k, v in pairs(unitKV.Creature.AttachWearables) do
        hasWearables = true
        break
    end

    -- Without wearables there is nothing to load
    if not hasWearables then
        return false
    end

    -- Only fighters (race units) need the active/summoned check
    if isFighter then
        -- Is it an active fighter?
        local isActive = false
        if gActiveFighters and gActiveFighters.units and unitName then
            isActive = gActiveFighters.units[unitName] ~= nil
        end

        -- Is it a summoned unit?
        local isSummoned = false
        if unitKV.IsSummoned then
            isSummoned = (unitKV.IsSummoned == 1 or unitKV.IsSummoned == "1")
        end

        -- Load active fighters
        if isActive then
            return true
        end

        -- Load summoned units
        if isSummoned then
            return true
        end

        -- A fighter that is neither active nor summoned is skipped
        return false
    else
        -- Non-fighter units such as buildings only need wearables
        return true
    end
end

function GamePlay:precacheAllBuildings(context, counter)
    local kvs = LoadKeyValues("scripts/npc/units/npc_units_building.txt")
    local scanned = 0
    for key, value in pairs(kvs) do
        scanned = scanned + 1
        if GamePlay:ShouldPrecacheUnit(value, key, false) then
            counter.count = counter.count + 1
            print(string.format("[%d/%d] ✓ precached building: %s", counter.count, scanned, key))
            GamePlay:precacheUnitByNameSync(key, context, "sync")
        else
            print(string.format("[scanned:%d] ✗ skipped building: %s (does not match the precache rules)", scanned, key))
        end
    end
end

function GamePlay:GetUnitDependencyUnits(unitName, printResult)
    local result = {}
    local visited = {}

    local function collect(name)
        if not name or visited[name] then
            return
        end

        visited[name] = true
        table.insert(result, name)

        local unitMeta = GamePlay.metaKv and GamePlay.metaKv.units and GamePlay.metaKv.units[name]
        if not unitMeta then
            print("[ProphetMode] dependency unit meta not found: " .. tostring(name))
            return
        end

        if unitMeta.upgrades then
            for _, upgradeName in pairs(unitMeta.upgrades) do
                collect(upgradeName)
            end
        end
    end

    collect(unitName)
    if printResult then
        print("[ProphetMode] Dependencies for " .. tostring(unitName) .. ": " .. table.concat(result, ", "))
    end
    return result
end

function GamePlay:precacheProphetFighterPoolByTier(context, counter)
    if not GamePlay.prophetFighterPoolByTier then
        print("[ProphetMode] prophetFighterPoolByTier is not initialised, skipping the prophet precache")
        return
    end

    local scanned = 0
    for tier = 1, 6 do
        local fighters = GamePlay.prophetFighterPoolByTier[tier] or {}
        for _, fighter in ipairs(fighters) do
            scanned = scanned + 1
            if fighter.name then
                local dependencyUnits = GamePlay:GetUnitDependencyUnits(fighter.name)
                for _, unitName in ipairs(dependencyUnits) do
                    if GamePlay:precacheUnitByNameSync(unitName, context, "prophet") then
                        counter.count = counter.count + 1
                        print(string.format("[%d/%d] ✓ precached prophet dependency, tier %d: %s -> %s (%s)", counter.count, scanned, tier, fighter.name, unitName, fighter.source or "unknown"))
                    else
                        print(string.format("[scanned:%d] ○ prophet dependency already loaded, tier %d: %s -> %s (%s)", scanned, tier, fighter.name, unitName, fighter.source or "unknown"))
                    end
                end
            else
                print(string.format("[scanned:%d] ✗ skipped prophet unit, tier %d: empty unit name", scanned, tier))
            end
        end
    end
end

function GamePlay:precacheExtraUnits(context, counter)
    local fileList = {
        "scripts/npc/units/npc_units_wave.txt",
        "scripts/npc/units/npc_units_barrack.txt"
    }

    for _, fileName in ipairs(fileList) do
        local kvs = LoadKeyValues(fileName)
        if kvs then
            local category = fileName:match("npc_units_(%w+)%.txt") or "Extra"
            -- foulfell is a race and counts as a fighter; wave and barrack do not
            local isFighter = (category == "foulfell")
            local scanned = 0
            for unitName, value in pairs(kvs) do
                scanned = scanned + 1
                if GamePlay:ShouldPrecacheUnit(value, unitName, isFighter) then
                    counter.count = counter.count + 1
                    print(string.format("[%d/%d] ✓ precached unit, %s: %s", counter.count, scanned, category, unitName))
                    GamePlay:precacheUnitByNameSync(unitName, context, "sync")
                else
                    print(string.format("[scanned:%d] ✗ skipped unit, %s: %s (does not match the precache rules)", scanned, category, unitName))
                end
            end
        end
    end
end

local SUMMONED_UNIT_PRECACHE_FILES = {
    "scripts/npc/units/npc_dota_custom_illusion_base.txt",
    "scripts/npc/units/npc_units_arctic.txt",
    "scripts/npc/units/npc_units_barrack.txt",
    "scripts/npc/units/npc_units_beast.txt",
    "scripts/npc/units/npc_units_building.txt",
    "scripts/npc/units/npc_units_demi_human.txt",
    "scripts/npc/units/npc_units_element.txt",
    "scripts/npc/units/npc_units_elf.txt",
    "scripts/npc/units/npc_units_foulfell.txt",
    "scripts/npc/units/npc_units_gameplay.txt",
    "scripts/npc/units/npc_units_ghost.txt",
    "scripts/npc/units/npc_units_goblin.txt",
    "scripts/npc/units/npc_units_hybrid.txt",
    "scripts/npc/units/npc_units_marine.txt",
    "scripts/npc/units/npc_units_mech.txt",
    "scripts/npc/units/npc_units_nature.txt",
    "scripts/npc/units/npc_units_orc.txt",
    "scripts/npc/units/npc_units_other_fighter.txt",
    "scripts/npc/units/npc_units_paladin.txt",
    "scripts/npc/units/npc_units_radiant.txt",
    "scripts/npc/units/npc_units_shadow.txt",
    "scripts/npc/units/npc_units_undead.txt",
    "scripts/npc/units/npc_units_wave.txt",
}

function GamePlay:precacheSummonedUnits(context, counter)
    for _, fileName in ipairs(SUMMONED_UNIT_PRECACHE_FILES) do
        local kvs = LoadKeyValues(fileName)
        if kvs then
            local category = fileName:match("npc_units_(%w+)%.txt") or "summoned"
            local scanned = 0
            for unitName, value in pairs(kvs) do
                scanned = scanned + 1
                local isSummoned = value.IsSummoned == 1 or value.IsSummoned == "1"
                if isSummoned then
                    if GamePlay:precacheUnitByNameSync(unitName, context, "summoned") then
                        counter.count = counter.count + 1
                        print(string.format("[%d/%d] ✓ precached summoned unit, %s: %s", counter.count, scanned, category, unitName))
                    else
                        print(string.format("[scanned:%d] ○ summoned unit already loaded, %s: %s", scanned, category, unitName))
                    end
                end
            end
        else
            print("[SummonedPrecache] could not read the unit file: " .. fileName)
        end
    end
end

function GamePlay:InitProphetFighterPoolByTier()
    math.randomseed(math.floor(GameRules:GetGameTime() * 100000) + RandomInt(1, 1000000))

    local fighterPoolByTier = {}

    for tier = 1, 6 do
        fighterPoolByTier[tier] = {}
    end

    local function addFighter(unitName, tier, source)
        local tierNum = tonumber(tier)
        if not unitName or not tierNum or not fighterPoolByTier[tierNum] then
            return
        end
        table.insert(fighterPoolByTier[tierNum], {
            name = unitName,
            tier = tierNum,
            source = source
        })
    end

    if GamePlay.metaKv and GamePlay.metaKv.builders then
        for _, builder in pairs(GamePlay.metaKv.builders) do
            local raceName = builder.race
            if raceName and raceName ~= "prophet" and raceName ~= "hybrid" and builder.buildings then
                for tier, unitName in pairs(builder.buildings) do
                    addFighter(unitName, tier, raceName)
                end
            end
        end
    end

    if GamePlay.metaKv and GamePlay.metaKv.otherFighters and GamePlay.metaKv.otherFighters.building then
        for _, fighter in pairs(GamePlay.metaKv.otherFighters.building) do
            addFighter(fighter.name, fighter.tier, "otherFighters")
        end
    end

    for tier = 1, 6 do
        table.sort(fighterPoolByTier[tier], function(a, b)
            if a.source == b.source then
                return a.name < b.name
            end
            return a.source < b.source
        end)
    end

    print("[ProphetMode] Fighter pool by tier initialized")
    for tier = 1, 6 do
        local names = {}
        for _, fighter in ipairs(fighterPoolByTier[tier]) do
            table.insert(names, fighter.name .. "(" .. fighter.source .. ")")
        end
        print("[ProphetMode] Tier " .. tier .. " fighters [" .. #fighterPoolByTier[tier] .. "]: " .. table.concat(names, ", "))
    end

    local selectedCount = PROPHET_AVAILABLE_RACES_COUNT or 8
    local selectedFighterPoolByTier = {}
    for tier = 1, 6 do
        local shuffledFighters = Shuffle(fighterPoolByTier[tier])
        selectedFighterPoolByTier[tier] = {}
        for i = 1, selectedCount do
            if shuffledFighters[i] then
                table.insert(selectedFighterPoolByTier[tier], shuffledFighters[i])
            end
        end
        selectedFighterPoolByTier[tier] = Shuffle(selectedFighterPoolByTier[tier])
    end

    GamePlay.prophetFighterPoolByTier = selectedFighterPoolByTier

    print("[ProphetMode] Selected fighter pool by tier")
    for tier = 1, 6 do
        local names = {}
        for _, fighter in ipairs(selectedFighterPoolByTier[tier]) do
            table.insert(names, fighter.name .. "(" .. fighter.source .. ")")
        end
        print("[ProphetMode] Selected Tier " .. tier .. " fighters [" .. #selectedFighterPoolByTier[tier] .. "]: " .. table.concat(names, ", "))
    end
end

function GamePlay:RegenerateProphetPoolsAndResetHeroes()
    print("[ProphetMode] Regenerate prophet fighter pools and reset prophet heroes")

    GamePlay:InitProphetFighterPoolByTier()

    local resetCount = 0
    for _, pid in pairs(Player:Ids()) do
        local pdata = Player:GetPData(pid)
        if pdata then
            Player:initPlayerProphetAbilities(pid)

            local hero = PlayerResource:GetSelectedHeroEntity(pid)
            if hero then
                GamePlay:ChooseHero(pid, "npc_dota_hero_rubick")
            else
                GamePlay:newHeroChoose(pid, "list", { "npc_dota_hero_rubick" })
            end

            resetCount = resetCount + 1
        end
    end

    return resetCount
end

function GamePlay:Precache(context)
    print("========================================")
    print("Starting the unit precache flow...")
    print("========================================")

    GamePlay:InitProphetFighterPoolByTier()

    local counter = { count = 0 }
    if ENABLE_UNIT_PRECACHE then
        print("\n[1/4] Precaching building units...")
        GamePlay:precacheAllBuildings(context, counter)

        print("\n[2/4] Precaching the prophet unit pool...")
        GamePlay:precacheProphetFighterPoolByTier(context, counter)

        print("\n[3/4] Precaching summoned units...")
        GamePlay:precacheSummonedUnits(context, counter)

        print("\n[4/4] Precaching extra units...")
        GamePlay:precacheExtraUnits(context, counter)

        print("\n========================================")
        print(string.format("Unit precache complete! %d units precached", counter.count))
        print("========================================")
    else
        print("Unit precache disabled (ENABLE_UNIT_PRECACHE = false)")
    end

    print("\nPrecaching unit effects...")
    local effectCount = 0
    for key, value in pairs(unitEffMap) do
        if value.particle then
            PrecacheResource("particle", value.particle, context)
            effectCount = effectCount + 1
        end
    end
    print(string.format("Effect precache complete! %d effects precached", effectCount))
end

function GamePlay:getRoundByName(name)
    for k, v in ipairs(roundInfo) do
        if v.name == name then
            return k
        end
    end
end

function GamePlay:getLogicRound()
    local r = GamePlay.round
    if r <= 10 then
        return r
    end
    if r <= 21 then
        return r - 1
    end
    return r - 2
end

function GamePlay:getBuyRound(round)
    if GamePlay.state == "in-round" then
        round = round + 1
    end
    return round
end

function GamePlay:updateBuildingAbility()
    for index, pid in ipairs(Player:Ids()) do
        local pdata = Player:GetPData(pid)
        if pdata and pdata.buildings then
            for _, building in ipairs(pdata.buildings) do
                if IsActiveUnit(building) then
                    local abilityCount = building:GetAbilityCount() or 0
                    for i = 0, abilityCount - 1 do
                        local ab = building:GetAbilityByIndex(i)
                        if ab and ab.onRoundUpdate then
                            ab:onRoundUpdate()
                        end
                    end
                end
            end
        end
    end
end

function GamePlay:canSendBarrack(caster, ability)
    if Convars:GetInt("dota_legiontd_send_free") == 1 then
        return true
    end
    local need_round = ability:GetSpecialValueFor("need_round")
    if need_round and need_round > GamePlay:getBuyRound(GamePlay.round) then
        local orderPlayerId = ability.lastOrderPlayerId
        return false
    end
    return true
end

function GamePlay:updateSendAbility(caster, ability)
    if GamePlay:canSendBarrack(caster, ability) then
        ability:SetActivated(true)
    else
        ability:SetActivated(false)
    end
end

function GamePlay:buyBarrackUnitStart(caster, ability)
    if not IsServer() then
        return true
    end

    local pid = caster:GetPlayerOwnerID()

    if not GamePlay:canSendBarrack(caster, ability) then
        local orderPlayerId = ability.lastOrderPlayerId
        SendErrorMessage(orderPlayerId, "error_need_round")
        return false
    end
    local res = teckTree:UseResource(ability:GetCaster(), ability, nil, {
    })
    return res
end

function GamePlay:buyBarrackUnit(caster, ability)
    if not IsServer() then
        return
    end
    local pid = caster:GetPlayerOwnerID()
    local unitName = string.sub(ability:GetAbilityName(), 5, string.len(ability:GetAbilityName()))
    GamePlay:spawnBarrackUnit(caster:GetPlayerOwnerID(), unitName)
    local income = ability:GetSpecialValueFor("income")
    Player:ModifyIncome(caster:GetPlayerOwnerID(), income)
    fireLeftNotify(caster:GetPlayerOwnerID(), true, "notify_summon_barrack", {
        str1 = unitName
    })
    --

    local hero = PlayerResource:GetSelectedHeroEntity(pid)
    local sound = "ui.npe_badge"
    if ENABLE_BUILDING_PARTICLE then
        local eff = "particles/econ/events/spring_2021/blink_dagger_spring_2021_start_lvl2.vpcf"
        local effType = nil

        if unitEffMap[unitName] then
            eff = unitEffMap[unitName].particle or eff
            sound = unitEffMap[unitName].sound or sound
            effType = unitEffMap[unitName].effType
        end
        local sendParticle = nil
        if effType == "radius" then
            sendParticle = ParticleManager:CreateParticle(eff, PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl(sendParticle, 0, hero:GetAbsOrigin())
            ParticleManager:SetParticleControl(sendParticle, 1, Vector(300, 300, 300))
        elseif effType == "ravage" then
            sendParticle = ParticleManager:CreateParticle(eff, PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl(sendParticle, 0, hero:GetAbsOrigin())
            ParticleManager:SetParticleControl(sendParticle, 1, Vector(250, 1, 1))
            ParticleManager:SetParticleControl(sendParticle, 2, Vector(500, 1, 1))
            ParticleManager:SetParticleControl(sendParticle, 3, Vector(750, 1, 1))
            ParticleManager:SetParticleControl(sendParticle, 4, Vector(1000, 1, 1))
            ParticleManager:SetParticleControl(sendParticle, 5, Vector(1250, 1, 1))
        else
            sendParticle = ParticleManager:CreateParticle(eff, PATTACH_ABSORIGIN_FOLLOW, hero)
            ParticleManager:SetParticleControlEnt(sendParticle, 0, hero, PATTACH_ABSORIGIN_FOLLOW, nil,
                hero:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(sendParticle, 1, hero, PATTACH_ABSORIGIN_FOLLOW, nil,
                hero:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(sendParticle, 2, hero, PATTACH_ABSORIGIN_FOLLOW, nil,
                hero:GetAbsOrigin(), true)
        end

        hero:StartGesture(ACT_DOTA_ATTACK)

        if caster.sendParticle then
            ParticleManager:DestroyParticle(caster.sendParticle, false)
            ParticleManager:ReleaseParticleIndex(caster.sendParticle)
            caster.sendParticle = nil
        end
        caster.sendParticle = sendParticle

        Timers:CreateTimer(5, function()
            ParticleManager:DestroyParticle(sendParticle, false)
            ParticleManager:ReleaseParticleIndex(sendParticle)
        end)
    end
    -- EmitSoundOn("ui.npe_badge", caster)
    EmitSoundOnLocationForAllies(caster:GetAbsOrigin(), sound, caster)
    local pdata = Player:GetPData(pid)
    local buyForRound = GamePlay:getBuyRound(GamePlay.round)

    table.insert(pdata.summons, { round = buyForRound, unit = unitName })

end

function GamePlay:fighterLevelUp(caster)
    if not IsServer() then return end
    local pid = caster:GetPlayerOwnerID()
    caster:CreatureLevelUp(1)
    caster:StartGesture(ACT_DOTA_ATTACK)
    local meta = GamePlay:FighterGetMeta(caster.fighterId)
    if meta then
        meta.level = caster:GetLevel()
    end
   

    Timers:CreateTimer(FrameTime(), function()
        
        local ab = caster:FindItemInInventory("item_legiontd_aghanims_scepter")
        if ab then
            ab:updateState()
        end
    end)
    Player:UpdateCreepValue(caster:GetPlayerOwnerID())
    PlayUpgradeParticle(caster, {
        sound = "Item.TomeOfKnowledge",
        particle = "particles/generic_hero_status/hero_levelup_fallback.vpcf"
    })
end

function GamePlay:tpToDefense(unit)
    if IsActiveUnit(unit) then
        -- print("tpToDefense",unit:GetUnitName(),unit:HasGroundMovementCapability())
        local pid = unit:GetPlayerOwnerID()
        local pdata = Player:GetPData(pid)
        local triggerName = "ent_king_defense_good"
        local yOff = 1
        if pdata.team == DOTA_TEAM_BADGUYS then
            triggerName = "ent_king_defense_bad"
            yOff = -1
        end

        SimpleMoveUnit(unit, getRandomPosInTrigger(triggerName))

        WayPointClear(unit)

        local pos = unit:GetAbsOrigin()
        unit.isInDefense = true

        local t_order = {
            UnitIndex = unit:entindex(),
            OrderType = DOTA_UNIT_ORDER_STOP,
            TargetIndex = nil,
            AbilityIndex = 0,
            Position = pos,
            Queue = false
        }
        unit:SetContextThink(DoUniqueString("order"), function()
            ExecuteOrderFromTable(t_order)
        end, 0.01)
        playTeleportEndEffect(unit)
    end
end

function GamePlay:teleportDefense(unit)
    local pid = unit:GetPlayerOwnerID()
    if pid >= 0 then
        local pdata = Player:GetPData(pid)
        local lane = pdata.laneIndex
        local laneData = GamePlay.laneTable[lane]
        unit.inTeleportDefense = true
        --
        removeDeadUnit(laneData.roundUnits)
        --
        if TableContainsValue(pdata.creeps, unit) and #laneData.roundUnits == 0 then
            playTeleportEffect(unit, 2)
            unit:AddNewModifier(unit, nil, "modifier_phased", {
                duration = 2
            })
            GamePlay:tpToDefense(unit)
        end
    end
end

function GamePlay:notifyLeak(unit)
    local lane = unit.path
    local pid = Player:GetPlayerByLane(lane)
    if pid and lane >= 0 and pid >= 0 then
        fireLeftNotify(pid, false, "notify_creep_no_gold", {})
        fireLeftNotify(pid, false, "notify_creep_no_gold_1", {})
        -- minimapNotice(pid, unit:GetAbsOrigin())
        PingAlert(PlayerResource:GetSelectedHeroEntity(pid), 5, unit:GetAbsOrigin())
    end
end

local function getUnitLeakCount(unit)
    if IsActiveUnit(unit) then
        local ab = unit:FindAbilityByName("death_spawn")
        if ab then
            return 1 + ab:GetLevel()
        elseif unit.leakCount then
            return unit.leakCount
        end
        return 1
    else
        return 0
    end
end

function GamePlay:makeLeaked(unit)
    if unit.path and not unit:HasModifier("modifier_gameplay_nogold") then
        --
        local unitLeakCount = getUnitLeakCount(unit)

        local lane = unit.path
        if lane and lane >= 0 then
            local pid = Player:GetPlayerByLane(lane)
            if pid and pid >= 0 then
                local pdata = Player:GetPData(pid)

                if pdata.leakCount < MAX_LEAK_FOR_KICK and pdata.leakCount + unitLeakCount >= MAX_LEAK_FOR_KICK then
                    fireLeftNotify(pid, true, "notify_kick_ready", {
                        int1 = pid,
                        int2 = MAX_LEAK_FOR_KICK
                    })
                    GameRules:SendCustomMessage("#DOTA_Chat_kick_ready", pid, pid)
                end

                pdata.leakCount = pdata.leakCount + unitLeakCount
                local tdata = GamePlay:GetTData(pdata.team)
                if tdata.leakCount == 0 then
                    GamePlay:notifyLeak(unit)
                end

                tdata.leakCount = tdata.leakCount + unitLeakCount

                --record round data
                local roundNode = GamePlay.roundList[#(GamePlay.roundList)]
                if roundNode then
                    local pstats = roundNode.players[pid]
                    if pstats then
                        pstats.leakCount = pstats.leakCount + unitLeakCount
                    end
                end
            end
        end
        --
        unit:AddNewModifier(unit, nil, "modifier_gameplay_nogold", {})
        local round = roundInfo[GamePlay.round]
        local mod = unit:FindModifierByName("modifier_gameplay_nogold")
        if mod then
            mod:SetStackCount(0)
        end
        if mod and round and round.value and round.value > 0 and lane and lane >= 0 then
            local factorValue = 1
            local pid = Player:GetPlayerByLane(lane)
            local pdata = Player:GetPData(pid)
            if pdata then
                factorValue = pdata.creepValue / (0.8 * round.value)
                factorValue = math.max(0, factorValue)
                factorValue = math.min(1, factorValue)
                --
                local factorLeak = (150 - pdata.leakCount) / 150
                factorLeak = math.max(0, factorLeak)
                factorLeak = math.min(1, factorLeak)
                mod:SetStackCount(math.floor(factorLeak * factorValue * 100))
            end
        end
        --
        local playerIdList = {}
        if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
            playerIdList = Player:BadPlayers()
        else
            playerIdList = Player:GoodPlayers()
        end
        for _, pid in pairs(playerIdList) do
            local hero = PlayerResource:GetSelectedHeroEntity(pid)
            if hero then
                unit:AddNewModifier(hero, nil, "modifier_provides_fow_position", {})
            end
        end
    end
end

function GamePlay:triggerCenterLeak(unit, triggerName)
    if IsActiveUnit(unit) then
        GamePlay:makeLeaked(unit)
        -- leak in center
        unit.centerLeaked = true
    end
end

function GamePlay:getHomePos(pid)
    if not pid then
        return nil
    end
    local pdata = Player:GetPData(pid)
    local lane = pdata.laneIndex
    local ent = Entities:FindByName(nil, "ent_player_" .. lane)
    return ent:GetAbsOrigin()
end

function GamePlay:teleportToHome(unit, triggerName)
    if unit:IsNull() or (not unit:IsAlive() or (not unit:IsHero())) then
        return
    end
    local pid = unit:GetPlayerOwnerID()
    if pid >= 0 then
        local pdata = Player:GetPData(pid)
        local lane = pdata.laneIndex
        local ent = Entities:FindByName(nil, "ent_player_" .. lane)
        SimpleMoveUnit(unit, ent:GetAbsOrigin())
        playTeleportEffect(unit, 2)
        GamePlay:MoveCamera(pid, unit:GetAbsOrigin(), 1)
        Timers:CreateTimer(0.1, function()
            if (not unit:IsNull()) and unit:IsAlive() then
                local pos = unit:GetAbsOrigin()
                unit:Stop()
            end
        end)
    end
end

function GamePlay:teleportToLane(unit, triggerName)
    if unit:IsNull() or (not unit:IsAlive() or (not unit:IsHero())) then
        return
    end
    local triggerLane = tonumber(string.sub(triggerName, 19, 19))
    if triggerLane == nil then
        return
    end
    local pid = unit:GetPlayerOwnerID()
    local pdata = Player:GetPData(pid)
    if pid >= 0 and pdata then
        local lane = pdata.laneIndex
        if lane == triggerLane then
            return
        end
        local ent = Entities:FindByName(nil, "ent_player_" .. lane)
        SimpleMoveUnit(unit, ent:GetAbsOrigin())
        playTeleportEffect(unit, 2)
        GamePlay:MoveCamera(pid, unit:GetAbsOrigin(), 1)
        Timers:CreateTimer(0.1, function()
            if (not unit:IsNull()) and unit:IsAlive() then
                local pos = unit:GetAbsOrigin()
                unit:Stop()
            end
        end)
    end
end

function GamePlay:getNonCenterLeakedCreepCount(lane)
    local laneData = GamePlay.laneTable[lane]
    if laneData then
        local nonLeakCount = 0
        removeDeadUnit(laneData.roundUnits)
        for _, unit in ipairs(laneData.roundUnits) do
            if unit and not unit.centerLeaked then
                nonLeakCount = nonLeakCount + 1
            end
        end
        return nonLeakCount
    end
    return 0
end

function GamePlay:getCenterLeakedCreepCount(lane)
    local laneData = GamePlay.laneTable[lane]
    if laneData then
        local leakCount = 0
        removeDeadUnit(laneData.roundUnits)
        for _, unit in ipairs(laneData.roundUnits) do
            if unit and unit.centerLeaked then
                leakCount = leakCount + 1
            end
        end
        return leakCount
    end
    return 0
end

-- move to tp zone
function GamePlay:TryMoveToTp(pid)
    local tped = GamePlay.roundList[GamePlay.roundIndex].teleported[pid]
    if tped then
        return
    end
    local pdata = Player:GetPData(pid)

    if pdata.kicked then
        return
    end

    local round = roundInfo[GamePlay.round]
    local lane = pdata.laneIndex
    local laneData = GamePlay.laneTable[lane]
    if not round.duel then
        local nonLeakCount = GamePlay:getNonCenterLeakedCreepCount(lane)
        if nonLeakCount == 0 then
            local ent = Entities:FindByName(nil, "ent_path_" .. lane .. "_0_0")
            for k, unit in pairs(pdata.creeps) do
                if (not unit:IsNull()) and unit:IsAlive() and not unit.isInDefense then
                    if unit.inTeleportDefense then
                        playTeleportEffect(unit, 2)
                        GamePlay:tpToDefense(unit)
                    else
                        --unit:MoveToPositionAggressive(ent:GetAbsOrigin())
                        WayPointClear(unit)
                        WayPointAdd(unit, GamePlay:getMoveTpPos(unit))
                    end
                end
            end
            pdata.defenseModeMoved = true
        end
    end
end

function GamePlay:getMoveTpPos(unit)
    if not IsActiveUnit(unit) then
        return
    end
    local pid = unit:GetPlayerOwnerID()
    local pdata = Player:GetPData(pid)
    if not pdata then
        return
    end
    local lane = pdata.laneIndex
    local ent = Entities:FindByName(nil, "ent_path_" .. lane .. "_0_0")
    local pos = ent:GetAbsOrigin()
    local unitPos = unit:GetAbsOrigin()
    local newPos = Vector(pos.x, pos.y, pos.z)
    if unitPos.x < pos.x + 640 and unitPos.x > pos.x - 640 then
        newPos.x = unitPos.x
    end

    return newPos
end

function GamePlay:moveToTp(pid)
    local pdata = Player:GetPData(pid)
    if not pdata then
        return
    end

    local round = roundInfo[GamePlay.round]
    local lane = pdata.laneIndex
    local laneData = GamePlay.laneTable[lane]
    local ent = Entities:FindByName(nil, "ent_path_" .. lane .. "_0_0")
    for k, unit in pairs(pdata.creeps) do
        if IsActiveUnit(unit) and not unit.isInDefense then
            WayPointClear(unit)
            WayPointAdd(unit, GamePlay:getMoveTpPos(unit))
        end
    end
end

function GamePlay:getRoundInfo(rIndex)
    return roundInfo[rIndex]
end

function GamePlay:SyncRoundTimer(time)
    CustomGameEventManager:Send_ServerToAllClients("round_timer", {
        time = time
    })
end

function GamePlay:spawnRound()
    local round = roundInfo[GamePlay.round]
    local preRoundTime = round.preRoundTime or 40
    local checkDelay = 5
    if GameRules.fastRound then
        preRoundTime = 4
    end
    --
    table.insert(GamePlay.roundList, {
        index = GamePlay.round,
        endFlag = false,
        teleported = {},
        round = round,
        players = {},
        playerDumps = {},
        roundName = round.name
    })
    local roundData = GamePlay:GetCurrentRoundData()
    Player:ForeanchPlayer(function(pid, pdata)
        roundData.players[pid] = {
            none = 1
        }
    end)
    -- pre wave
    GamePlay.state = "pre-round"
    GamePlay:doRoundPre()

    GamePlay.roundIndex = GamePlay.roundIndex + 1


    print("[legiontd] pre wave" .. GamePlay.round .. " pre time " .. preRoundTime)

    Timers:CreateTimer(FrameTime(), function()
        GamePlay:SyncNetTable()
    end)

    GamePlay.roundTimer = preRoundTime

    Timers:CreateTimer(1, function()
        if Convars:GetInt("dota_legiontd_paused") == 1 and GamePlay.roundTimer ~= 0 then
            GamePlay:SyncRoundTimer(GamePlay.roundTimer)
            return 1
        end

        GamePlay.roundTimer = GamePlay.roundTimer - 1
        if GamePlay.roundTimer <= 0 then
            GamePlay.state = "in-round"
            GamePlay:doRoundStart()
            GamePlay:SyncNetTable()
            --
            GamePlay:SyncRoundTimer(0)
            Timers:CreateTimer(checkDelay, function()
                Player:ForeanchPlayer(function(pid, pdata)
                    GamePlay:TryMoveToTp(pid)
                end)
                --
                local waveEnd = GamePlay:CheckRoundEnd()
                print("CheckRoundEnd", waveEnd)
                if waveEnd then
                    local delay = 1
                    if isTrue(roundInfo[GamePlay.round].duel) then
                        delay = 6
                    end
                    GamePlay.roundList[GamePlay.roundIndex].endFlag = true
                    Timers:CreateTimer(delay, function()
                        print("[legiontd] round end ")
                        GamePlay:closeAllVision()
                        GamePlay:doRoundEnd()
                        GamePlay.state = "idle"
                        GamePlay:SyncNetTable()
                    end)
                    return nil
                else
                    return 1
                end
            end)

            return nil
        else
            return 1
        end
    end)
    GamePlay:SyncRoundTimer(preRoundTime)
end



function GamePlay:getRoundCreepValue(roundIndex)
    local round = roundInfo[roundIndex]
    if not round then
        return 0
    end

    local value = round.value or 0
    if GamePlay:Mode("x2") then
        value = value * 2
    end
    return value
end

function GamePlay:getRoundCreepCount(roundIndex)
    local round = roundInfo[roundIndex]
    if not round then
        return 0
    end
    local spawnCount = round.count

    if spawnCount == nil then
        return 0
    end

    if GamePlay.secondaryModes["hc"] and spawnCount > 20 then
        spawnCount = math.ceil(spawnCount / 2)
    end

    if GamePlay.secondaryModes["x2"] then
        spawnCount = spawnCount * 2
    end

    return spawnCount
end

function GamePlay:doRoundPre()
    local round = roundInfo[GamePlay.round]

    SafeCall(function()
        Storage:MatchUpdate("pre")
    end)

    print("[legiontd] doRoundPre " .. GamePlay.round .. " " .. GameRules:GetGameTime())
    GamePlay:notifyRoundInfo(nil, GamePlay.round)
    if round and isTrue(round.hasTips) then
        local r = GamePlay.round
        Timers:CreateTimer(3, function()
            GameRules:SendCustomMessage("#notify_round_pre_" .. r, 0, 0)
        end)
    end

    local unitName = round.unit

    if GamePlay.round == 2 then
        Timers:CreateTimer(1, function()
            if (#(Player:GoodPlayers()) > 0 and #(Player:GoodPlayers()) == #(Player:BadPlayers())) then
                fireLeftNotify(nil, false, "notify_will_be_ranked", {})
            else
                fireLeftNotify(nil, false, "notify_will_be_not_ranked", {})
            end
        end)
    end

    Timers:CreateTimer(FrameTime(), function()
        GamePlay:updateBuildingAbility()
    end)

    if round and (isTrue(round.duel) or isTrue(round.allVision)) then
        GamePlay:openAllVision()
    else
        GamePlay:closeAllVision()
    end
end

function GamePlay:updateKingAbility(round)
    -- add ability
    local addAbilityTabel = {}
    addAbilityTabel[4] = { "king_shockwave", "king_war_stomp", "king_permanent_immolation", "king_firestorm",
        "king_entangle" }
    addAbilityTabel[15] = { "king_command_aura" }
    addAbilityTabel[20] = { "king_devotion_aura" }
    addAbilityTabel[26] = { "king_endurance_aura" }
    --
    for teamNum, tdata in pairs(GamePlay.teamTable) do
        local king = tdata.king
        local addAbility = addAbilityTabel[round]

        if addAbility and IsActiveUnit(king) then
            local abName = addAbility[RandomInt(1, #addAbility)]
            AddAbilityAndSetLevel(king, abName, 1)
            if round == 4 then
                king:SwapAbilities(abName, "ability_empty", true, false)
            end
            local ids = Player:IdsByTeam(teamNum)
            if #(ids) > 0 then
                fireLeftNotify(ids[1], true, "notify_king_get_ability", {
                    ability = abName
                })
            end
        end
    end
end

function GamePlay:updateKingWhenRoundEnd()
    --  king_bouns
    local round = roundInfo[GamePlay.round]
    if isFalse(round.duel) then
        for teamNum, tdata in pairs(GamePlay.teamTable) do
            local king = tdata.king
            -- king:CreatureLevelUp(1+round.name-king:GetLevel())
            if IsActiveUnit(king) then
                local ab = king:FindAbilityByName("king_bouns")
                if ab and ab.updateBonusLevel then
                    ab:updateBonusLevel()
                end
            end
        end
    end
    GamePlay:updateKingAbility(GamePlay.round)
end

function GamePlay:tryEditUnitInToolsMode(unit)
    if IsInToolsMode() then
        local unitName = unit:GetUnitName()
        if UNIT_EDITOR and UNIT_EDITOR[unitName] then
            local editor = UNIT_EDITOR[unitName]
            if editor["attack"] and editor["attack"] ~= 0 then
                local mod = unit:AddNewModifier(unit, nil, "modifier_dev_attack", {})
                mod:SetStackCount(100 + editor["attack"])
            end

            if editor["attack_speed"] and editor["attack_speed"] ~= 0 then
                local mod = unit:AddNewModifier(unit, nil, "modifier_dev_attack_speed", {})
                mod:SetStackCount(100 + (editor["attack_speed"]))
            end

            if editor["attack_range"] and editor["attack_range"] ~= 0 then
                local mod = unit:AddNewModifier(unit, nil, "modifier_dev_attack_range", {})
                mod:SetStackCount(100 + math.floor(editor["attack_range"]) / 10)
            end

            if editor["mana_cost"] and editor["mana_cost"] ~= 0 then
                local mod = unit:AddNewModifier(unit, nil, "modifier_dev_mana_cost", {})
                mod:SetStackCount(100 + math.floor(editor["mana_cost"]))
            end

            if editor["health"] and editor["health"] ~= 0 then
                local mod = unit:AddNewModifier(unit, nil, "modifier_dev_health", {})
                mod:SetStackCount(100 + editor["health"])
            end
            if editor.removeAbilities then
                for index, ab in ipairs(editor.removeAbilities) do
                    unit:RemoveAbility(ab)
                end
            end
        end
    end
end

function GamePlay:saveRoundResult()
    local roundNode = GamePlay:GetCurrentRoundData()
    Player:ForeanchPlayer(function(pid, pdata)
        local pstats = roundNode.players[pid]
        if pdata.kicked then
            return
        end
        if pstats then
            pstats.aliveFighterCount = 0
            pstats.aliveCreepValue = 0
            for k, unit in pairs(pdata.creeps) do
                if IsActiveUnit(unit) and not unit:IsSummoned() then
                    pstats.aliveFighterCount = pstats.aliveFighterCount + 1

                    local hp = unit:GetHealthPercent() / 100
                    pstats.aliveCreepValue = pstats.aliveCreepValue + math.floor((unit.gold or 0) * hp)
                end
            end

            if IsInToolsMode() then
                if GamePlay.devRoundResult and GamePlay.devRoundResult[pid] then
                    local oldStat = GamePlay.devRoundResult[pid]

                    local msg = nil
                    if pstats.aliveCreepValue > oldStat.aliveCreepValue then
                        msg =
                        "round result pid {0} leak {1}->{2} alive {3} aliveValue {4}-><font color='#00ff00'>{5}</font>"
                    elseif pstats.aliveCreepValue < oldStat.aliveCreepValue then
                        msg =
                        "round result pid {0} leak {1}->{2} alive {3} aliveValue {4}-><font color='#ff0000'>{5}</font>"
                    else
                        msg =
                        "round result pid {0} leak {1}->{2} alive {3} aliveValue {4}-><font color='#ffffff'>{5}</font>"
                    end

                    GameRules:SendCustomMessage(
                        Format(msg, pid, oldStat.leakCount, pstats.leakCount, pstats.aliveFighterCount,
                            oldStat.aliveCreepValue, pstats.aliveCreepValue), 0, 0)
                else
                    GameRules:SendCustomMessage(
                        Format("round result pid {0} leak {1} alive {2} aliveValue {3}", pid, pstats.leakCount,
                            pstats.aliveFighterCount, pstats.aliveCreepValue), 0, 0)
                end
            end
        end
    end)
end

function GamePlay:getLanePos(laneIndex)
    local lane = laneIndex
    local posEnt = Entities:FindByName(nil, "ent_player_" .. lane)
    return posEnt:GetAbsOrigin()
end

function GamePlay:doRoundEnd()
    print("[legiontd] doRoundEnd " .. GamePlay.round .. " " .. GameRules:GetGameTime())
    fireLeftNotify(nil, false, "notify_round_end", {})

    Player:ForeanchPlayer(function(pid, pdata)
        if pdata.kicked then
            return
        end
        for k, tower in pairs(pdata.creeps) do
            if IsActiveUnit(tower) then
                GamePlay:saveFighterAbilityStateAtRoundEnd(tower)
            end
        end
    end)

    local round = roundInfo[GamePlay.round]

    GamePlay:awardWaveSuccess(GamePlay.round)

    GamePlay:saveRoundResult()

    GameRules:SetTimeOfDay(0)

    Timers:CreateTimer(1, function()
        GamePlay:SyncDamageTable()
    end)

    local roundNode = GamePlay.roundList[#(GamePlay.roundList)]

    Player:ForeanchPlayer(function(pid, pdata)
        local pstats = roundNode.players[pid]
        if pdata.kicked then
            return
        end
        GamePlay:creepClear(pid)
        GamePlay:towerDisplay(pid)
        --
        local hero = PlayerResource:GetSelectedHeroEntity(pid)
        local lane = pdata.laneIndex
        local posEnt = Entities:FindByName(nil, "ent_player_" .. lane)
        --
        if isTrue(round.duel) then
            SimpleMoveUnit(hero, posEnt:GetAbsOrigin())
            GamePlay:MoveCamera(pid, posEnt:GetAbsOrigin(), 1)
        end
    end)
    for k, unit in pairs(GamePlay.roundGoodCreeps) do
        if unit and not unit:IsNull() and not UTIL:IsKing(unit) then
            unit:AddEffects(EF_NODRAW)
            unit:Kill(nil, nil)
        end
    end
    GamePlay.roundGoodCreeps = {}
    for k, unit in pairs(GamePlay.roundBadCreeps) do
        if unit and not unit:IsNull() and not UTIL:IsKing(unit) then
            unit:AddEffects(EF_NODRAW)
            unit:Kill(nil, nil)
        end
    end
    GamePlay.roundBadCreeps = {}

    if isTrue(round.duel) then
        -- EnableFogOfWar(true)
        if GamePlay.duelWinner == DOTA_TEAM_GOODGUYS then
            EmitAnnouncerSoundForTeam("RoundSuccess", DOTA_TEAM_GOODGUYS)
            EmitAnnouncerSoundForTeam("RoundEnd", DOTA_TEAM_BADGUYS)
            fireLeftNotify(nil, false, "notify_duel_win_good", {})

            if GamePlay.round == 33 then
                Timers:CreateTimer(1, function()
                    GamePlay:openAllVision()
                    GamePlay:DoGameEnd(DOTA_TEAM_GOODGUYS)
                end)
            end
        elseif GamePlay.duelWinner == DOTA_TEAM_BADGUYS then
            EmitAnnouncerSoundForTeam("RoundSuccess", DOTA_TEAM_BADGUYS)
            EmitAnnouncerSoundForTeam("RoundEnd", DOTA_TEAM_GOODGUYS)
            fireLeftNotify(nil, false, "notify_duel_win_bad", {})
            if GamePlay.round == 33 then
                Timers:CreateTimer(1, function()
                    GamePlay:openAllVision()
                    GamePlay:DoGameEnd(DOTA_TEAM_BADGUYS)
                end)
            end
        else
            EmitAnnouncerSoundForTeam("RoundEnd", DOTA_TEAM_GOODGUYS)
            EmitAnnouncerSoundForTeam("RoundEnd", DOTA_TEAM_BADGUYS)
            fireLeftNotify(nil, false, "notify_duel_draw", {})
        end
    else
        EmitGlobalSound("RoundSuccess")
    end

    -- Report the duel result to the server
    if isTrue(round.duel) then
        SafeCall(function()
            local goodPlayerCount, badPlayerCount = Player:GetNonKickedPlayerCount()
            Storage:DuelResult(
                GamePlay.duelWinner,  -- winning team (DOTA_TEAM_GOODGUYS=2, DOTA_TEAM_BADGUYS=3, 0=draw)
                goodPlayerCount,       -- number of west side players who were not kicked
                badPlayerCount,        -- number of east side players who were not kicked
                GamePlay.round         -- round number
            )
            print(string.format("[DuelResult] Round %d: winner=%s, good=%d, bad=%d",
                GamePlay.round,
                GamePlay.duelWinner or "draw",
                goodPlayerCount,
                badPlayerCount))
        end)
    end

    GamePlay:clearKickedPlayer()
    for _, node in pairs(GamePlay.kickList) do
        Timers:CreateTimer(0.5, function()
            GamePlay:kick(node[1], node[2])
        end)
    end
    GamePlay.kickList = {}
    GamePlay:updateKingWhenRoundEnd()
    SafeCall(function()
        Storage:MatchUpdate("end")
    end)
    print("[legiontd] wave end" .. GamePlay.round)
    if not DISABLE_ROUND_STEP then
        GamePlay.round = GamePlay.round + 1
    end
    -- clear some data
    Player:ForeanchPlayer(function(pid, pdata)
        pdata.summons = {}
    end)
    --
   
end

function GamePlay:notifyRoundInfo(pid, round)
    local creepCount = GamePlay:getRoundCreepCount(round)
    local creepValue = GamePlay:getRoundCreepValue(round)

    local roundData = GamePlay:getRoundInfo(round)

    if pid then
        fireLeftNotify(pid, true, "notify_round_" .. round, {
            int1 = creepCount,
            int2 = creepValue,
            str1 = roundData.unit
        })
    else
        fireLeftNotify(nil, false, "notify_round_" .. round, {
            int1 = creepCount,
            int2 = creepValue,
            str1 = roundData.unit
        })
    end
end

function GamePlay:initFighter(unit)
    if not IsActiveUnit(unit) then
        return
    end

    if ENABLE_FIGHTER_LEVEL_UP and GamePlay:canBeUpgraded(unit) then
        if unit:GetLevel() == 1 then
            if not unit:FindItemInInventory("item_fighter_level_up") then
                unit:AddItemByName("item_fighter_level_up")
            end
        end
    end
    if unit:GetLevel() > 1 then
        local meta = GamePlay:FighterGetMeta(unit.fighterId)
        if meta and meta.learnUltimateAbility then
            local abName = GetUnitKV(unit:GetUnitName(), "scepterAbility", 1)
            if abName and not unit:HasAbility(abName) then
                AddAbilityAndSetLevel(unit, abName, 1)
            end
            local abName1 = GetUnitKV(unit:GetUnitName(), "scepterAbility1", 1)
            if abName1 and not unit:HasAbility(abName1) then
                AddAbilityAndSetLevel(unit, abName1, 1)
            end
            unit:AddNewModifier(unit, nil, "modifier_generic_agh_scepter", {
            })
            -- PlayEffOnUnit("particles/items4_fx/scepter_aura.vpcf", unit)
        end
    end
end

function GamePlay:toggleDebuffMaker(unit)
    if IsActiveUnit(unit) then
        local ab = unit:FindAbilityByName("toggle_debuff_maker")
        if ab then
            ab:ToggleAbility()
        end
    end
end

function GamePlay:GetUnitCreepValue(unit)
    if not IsActiveUnit(unit) then
        return nil
    end
    for _, round in ipairs(roundInfo) do
        if round.unit == unit:GetUnitName() then
            return math.floor(round.value / round.count)
        end
    end
    return nil
end


function GamePlay:unlockKing()
    if IsActiveUnit(GamePlay.kingGood) then
        GamePlay.kingGood:RemoveModifierByName("modifier_building")
        GamePlay.kingGood:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
        GamePlay.kingGood:SetNeverMoveToClearSpace(false)
    end
    if IsActiveUnit(GamePlay.kingBad) then
        GamePlay.kingBad:RemoveModifierByName("modifier_building")
        GamePlay.kingBad:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
        GamePlay.kingBad:SetNeverMoveToClearSpace(false)
    end
end

function GamePlay:doRoundStart()
    -- spawn units
    print("[legiontd] doRoundStart" .. GamePlay.round .. " " .. GameRules:GetGameTime())
    local round = roundInfo[GamePlay.round]


    GamePlay.roundStartTime = GameRules:GetGameTime()
    GameRules:SetTimeOfDay(0.25)
    local roundNode = GamePlay.roundList[#(GamePlay.roundList)]

    SafeCall(function()
        Player:ForeanchPlayer(function(pid, pdata)
            if pdata.kicked then
                return
            end
            for k, tower in pairs(pdata.towers) do
                if IsActiveUnit(tower) then
                    GamePlay:saveFighterAbilityState(tower)
                end
            end
        end)
    end)

    SafeCall(function()
        roundNode.playerDumps = Storage:collectPlayerInfo()
    end)
    SafeCall(function()
        Storage:MatchUpdate("start")
    end)

    GamePlay:notifyRoundInfo(nil, GamePlay.round)

    if GamePlay.round == 1 then
        Timers:CreateTimer(2, function()
            GamePlay:notifyCenterArmor()
        end)

        if GamePlay.secondaryModes["hc"] then
            MAX_LEAK_FOR_KICK = MAX_LEAK_FOR_KICK / 2
            MAX_LEAK_FOR_GOLD_REDUCE = MAX_LEAK_FOR_GOLD_REDUCE / 2
            print("config half creep", MAX_LEAK_FOR_KICK, MAX_LEAK_FOR_GOLD_REDUCE)
        end
    end
    GameRules.damageTable = {}
    -- save round player data
    Player:ForeanchPlayer(function(pid, pdata)
        if not roundNode.players[pid] then
            roundNode.players[pid] = {}
        end

        local pstats = roundNode.players[pid]
        if pdata.kicked then
            return
        end
        local hero = PlayerResource:GetSelectedHeroEntity(pid)
        if hero then
            BuildingHelper:ClearQueue(hero)
        end
        GamePlay:creepClear(pid)
        pdata.defenseModeMoved = false

        pstats.income = pdata.income
        pstats.lumberWoker = pdata.lumberWoker
        pstats.woodCollect = pdata.woodCollect
        pstats.creepValue = pdata.creepValue
        pstats.kills = 0
        pstats.leakCount = 0
        pstats.gold = Player:GetGold(pid)
        pstats.food = Player:GetFood(pid)
        pstats.wood = Player:GetWood(pid)
    end)
    if isTrue(round.duel) then
        -- GamePlay:openAllVision()
        EmitGlobalSound("RoundStart")

        -- fireLeftNotify(nil, false, "tip_duel_timeout", {
        -- })

        GameRules:SendCustomMessage("#tip_duel_timeout", 0, 0)



        Player:ForeanchPlayer(function(pid, pdata)
            if pdata.kicked then
                return
            end
            GamePlay:towerHide(pid)
            GamePlay:towerSpawn(pid)
        end)

        -- spawn duel compensation unit
        local goodCount, badCount = Player:GetNonKickedPlayerCount()
        local duelCompensationList = {
            [1] = { unitName = "wave_draenei_chieftain_10", addUnitCount = 3 },
            [2] = { unitName = "wave_dragon_turtle_20", addUnitCount = 3 },
            [3] = { unitName = "wave_magnataur_30", addUnitCount = 3 },
        }
        local duelIndex = 0
        for i = 1, GamePlay.round, 1 do
            if roundInfo[i] and isTrue(roundInfo[i].duel) then
                duelIndex = duelIndex + 1
            end
        end
        local compensationConfig = duelCompensationList[duelIndex] or duelCompensationList[3]
        local addUnitCount = compensationConfig.addUnitCount
        local DUEL_UNIT_NAME = compensationConfig.unitName

        if GamePlay.secondaryModes["x2"] then
            addUnitCount = addUnitCount * 2
        end

        if addUnitCount > 0 then
            if goodCount > badCount then
                local count = (goodCount - badCount) * addUnitCount
                for i = 1, count do
                    local creep = CreateUnitByName(DUEL_UNIT_NAME, Vector(0, 6271, 160), false, nil, nil,
                        DOTA_TEAM_BADGUYS)
                    creep:AddNewModifier(creep, nil, "modifier_phased", {
                        duration = 0.1
                    })
                    table.insert(GamePlay.roundBadCreeps, creep)
                end
            elseif badCount > goodCount then
                local count = (badCount - goodCount) * addUnitCount
                for i = 1, count do
                    local creep = CreateUnitByName(DUEL_UNIT_NAME, Vector(0, 6271, 160), false, nil, nil,
                        DOTA_TEAM_GOODGUYS)
                    creep:AddNewModifier(creep, nil, "modifier_phased", {
                        duration = 0.1
                    })
                    table.insert(GamePlay.roundGoodCreeps, creep)
                end
            end
        end
        if isTrue(round.includeKing) then
            GamePlay:unlockKing()
            table.insert(GamePlay.roundGoodCreeps, GamePlay.kingGood)
            table.insert(GamePlay.roundBadCreeps, GamePlay.kingBad)
        end
        print("moveCreepToDuel")
        Timers:CreateTimer(2, function()
            GamePlay:moveCreepToDuel()
        end)
    else
        EmitGlobalSound("RoundStart")
        GamePlay:spawnWave(GamePlay.round)
        GamePlay:spawnBarrackUnitInWave()
        Player:ForeanchPlayer(function(pid, pdata)
            if pdata.kicked then
                return
            end
            GamePlay:towerHide(pid)
            GamePlay:towerSpawn(pid)
        end)
        local roundIndex = GamePlay.roundIndex
    end
end

function legionOnAbilityPhaseStart(caster, ability)
    if not IsServer() then
        return
    end
    local max_count = ability:GetSpecialValueFor("max_count")
    if not max_count then
        return true
    end

    local pid = caster:GetPlayerOwnerID()
    local pdata = Player:GetPData(pid)
    local UnitName = ability:GetAbilityKeyValues()['UnitName']
    if pdata then
        local c = 0
        for _, unit in pairs(pdata.towers) do
            if IsActiveUnit(unit) and unit:GetUnitName() == UnitName then
                c = c + 1
            end
        end
        if c < max_count then
            return true
        else
            local orderPlayerId = ability.lastOrderPlayerId
            SendErrorMessage(orderPlayerId, "error_max_build_count")
            return false
        end
    end
    return false
end

-- new fighter Pos 1
function GamePlay:OnConstructionStarted(fighter)
    local pid = fighter:GetPlayerOwnerID()
    local pdata = Player:GetPData(pid)
    table.insert(pdata.towers, fighter)

    print("OnConstructionStarted")
    GamePlay:FighterRegister(fighter)
    GamePlay:SetBuildingForwardVector(fighter)

    GamePlay:toggleDebuffMaker(fighter)

    GamePlay:initFighter(fighter)

    local meta = GamePlay:FighterGetMeta(fighter.fighterId)
    if meta then
        meta.gold = fighter.gold
        meta.wood = fighter.wood
        meta.food = fighter.food
    end
end

-- new fighter Pos 2
function hybridUpgradeBuilding(caster, building_name)
    if caster == nil or caster:IsNull() then
        return
    end
    if not IsCustomBuilding(caster) then
        return nil
    end
    local pid = caster:GetPlayerOwnerID()

    local food = 0
    local wood = 0
    local gold = 0

    local pdata = Player:GetPData(pid)

    local pos = caster:GetAbsOrigin()
    TableRemoveByValue(pdata.towers, caster)
    if caster and not caster:IsNull() then
        -- PlayerResource:RemoveFromSelection(orderPlayerId, caster)
        caster:AddEffects(EF_NODRAW)
        caster:Kill(nil, nil)
    end
    print("hybridUpgradeBuilding",building_name)
    local newBuilding = BuildingHelper:PlaceBuilding(pid, building_name, pos, nil, nil, nil, pdata.team)
    -- update resource cost
    newBuilding.food = food + caster.food
    newBuilding.wood = wood + caster.wood
    newBuilding.gold = gold + caster.gold
    newBuilding:SetAngles(0, -90, 0)
    newBuilding.buildRound = GamePlay.round
    newBuilding.isLastBuilding = caster.isLastBuilding
    newBuilding.buildingKv = caster.buildingKv
    newBuilding.sellTag = caster.sellTag

    GamePlay:FighterUpdate(caster.fighterId, newBuilding)

    table.insert(pdata.towers, newBuilding)
    Player:UpdateCreepValue(pid)
    newBuilding:AddNewModifier(newBuilding, nil, "modifier_tower", {})
    emitVoiceSound(newBuilding, "spawn", pid)
    GamePlay:SetBuildingForwardVector(newBuilding)

    newBuilding.buildingKv.isHybrid = true

    PlayEffOnUnit("particles/units/heroes/hero_morphling/morphling_replicate.vpcf", newBuilding)

    GamePlay:toggleDebuffMaker(newBuilding)
    GamePlay:initFighter(newBuilding)

    local meta = GamePlay:FighterGetMeta(newBuilding.fighterId)
    if meta then
        meta.gold = newBuilding.gold
        meta.wood = newBuilding.wood
        meta.food = newBuilding.food
    end

    return newBuilding
end

-- new fighter Pos 3
function legionUpgradeBuilding(caster, ability)
    if caster == nil or caster:IsNull() then
        return
    end
    if not IsCustomBuilding(caster) then
        return
    end
    local ability_name = ability:GetAbilityName()
    local pid = caster:GetPlayerOwnerID()
    local building_name = ability:GetAbilityKeyValues()['UnitName']

    local hero = PlayerResource:GetSelectedHeroEntity(pid)

    local orderPlayerId = ability.lastOrderPlayerId


    local food = ability:GetSpecialValueFor("food") or 0
    local wood = ability:GetSpecialValueFor("wood") or 0
    local gold = ability:GetSpecialValueFor("gold") or 0

    local pdata = Player:GetPData(pid)

    if teckTree:UseResource(caster, ability) then
        local pos = caster:GetAbsOrigin()
        TableRemoveByValue(pdata.towers, caster)
        if caster and not caster:IsNull() then
            -- PlayerResource:RemoveFromSelection(orderPlayerId, caster)
            caster:AddEffects(EF_NODRAW)
            caster:Kill(nil, nil)
            
        end
        local newBuilding = BuildingHelper:PlaceBuilding(pid, building_name, pos, nil, nil, nil, pdata.team)
        -- update resource cost
        newBuilding.food = food + caster.food
        newBuilding.wood = wood + caster.wood
        newBuilding.gold = gold + caster.gold
        newBuilding:SetAngles(0, -90, 0)
        newBuilding.buildRound = GamePlay.round
        newBuilding.isLastBuilding = caster.isLastBuilding
        newBuilding.buildingKv = caster.buildingKv

        newBuilding.sellTag = caster.sellTag
        GamePlay:FighterUpdate(caster.fighterId, newBuilding)

        table.insert(pdata.towers, newBuilding)

        Player:UpdateCreepValue(pid)
       
        newBuilding:AddNewModifier(newBuilding, nil, "modifier_tower", {})
   
        PlayUpgradeParticle(newBuilding, {
            playerSound = true
        })
        if orderPlayerId then
            GamePlay:SelectUnit(orderPlayerId, newBuilding, false)
        end
        emitVoiceSound(newBuilding, "spawn", pid)
        GamePlay:SetBuildingForwardVector(newBuilding)

        GamePlay:toggleDebuffMaker(newBuilding)

        GamePlay:initFighter(newBuilding)

        local meta = GamePlay:FighterGetMeta(newBuilding.fighterId)
        if meta then
            meta.gold = newBuilding.gold
            meta.wood = newBuilding.wood
            meta.food = newBuilding.food
        end
        return newBuilding
    end
end

function upgradeBuilding(event)
    GamePlay:upgradeBuilding(event)
end

function GamePlay:upgradeBuilding(event)
    if not IsServer() then
        return
    end
    local caster = event.caster
    if not IsCustomBuilding(caster) then
        return
    end
    local ability = event.ability
    legionUpgradeBuilding(caster, ability)
end

function GamePlay:SyncGameSettings()
    local data = {
        secondaryModes = GamePlay.secondaryModes,
        primaryMode = GamePlay.primaryMode,
        westAlive = 0,
        eastAlive = 0,
        badMaxAlive = 1,
        goodMaxAlive = 1,
        westKingMaxHp = 5000,
        round = 1,
        westKingHp = 5000,
        eastKingHp = 5000,
        eastKingMaxHp = 5000,
        state = GamePlay.state
    }
    -- PrintTable(data)
    CustomNetTables:SetTableValue("gameplay", "all", data)
end

function GamePlay:SyncNetTable()
    local westAlive = 0
    for i = 0, 3 do
        local roundUnits = GamePlay.laneTable[i].roundUnits
        westAlive = westAlive + #roundUnits
    end
    local eastAlive = 0
    for i = 4, 7 do
        local roundUnits = GamePlay.laneTable[i].roundUnits
        eastAlive = eastAlive + #roundUnits
    end
    local round = roundInfo[GamePlay.round]

    local westKingHp = 0
    local westKingMaxHp = 1
    if IsActiveUnit(GamePlay.kingGood) then
        westKingHp = GamePlay.kingGood:GetHealth()
        westKingMaxHp = GamePlay.kingGood:GetMaxHealth()
    end
    local eastKingHp = 0
    local eastKingMaxHp = 0
    if IsActiveUnit(GamePlay.kingBad) then
        eastKingHp = GamePlay.kingBad:GetHealth()
        eastKingMaxHp = GamePlay.kingBad:GetMaxHealth()
    end
    local goodMaxAlive = 1
    local badMaxAlive = 1
    local goodPlayerCount, badPlayerCount = Player:GetNonKickedPlayerCount()
    if round then
        goodMaxAlive = (round.count or 1) * goodPlayerCount
        badMaxAlive = (round.count or 1) * badPlayerCount

        if goodMaxAlive == 0 then
            goodMaxAlive = 1
        end
        if badMaxAlive == 0 then
            badMaxAlive = 1
        end
    end
    local data = {
        westAlive = westAlive,
        eastAlive = eastAlive,
        badMaxAlive = badMaxAlive,
        goodMaxAlive = goodMaxAlive,
        westKingMaxHp = westKingMaxHp,
        round = GamePlay.round,
        westKingHp = westKingHp,
        eastKingHp = eastKingHp,
        eastKingMaxHp = eastKingMaxHp,
        state = GamePlay.state,
        mindOpen = GamePlay.secondaryModes["mo"],
        secondaryModes = GamePlay.secondaryModes,
        primaryMode = GamePlay.primaryMode,
        gameWinner = GamePlay.gameWinner
    }
    -- PrintTable(data)
    CustomNetTables:SetTableValue("gameplay", "all", data)
    --
end

function GamePlay:SyncDamageTable()
    if ENABLE_DAMAGE_TABLE then
        -- PrintTable(GameRules.damageTable)
        CustomNetTables:SetTableValue("damage_table", "all", GameRules.damageTable)
    end
end

function GamePlay:newGamemodeChoose(pid, type, items, params)
    local pdata = Player.players[pid]

    if not pdata then
        return
    end

    local chooseNode = {
        type = type,
        items = items,
        index = #(pdata.gamemodeChoose.value) + 1,
        selected = false
    }
    if params then
        chooseNode.isHostPick = params.isHostPick
    end

    table.insert(pdata.gamemodeChoose.value, chooseNode)
    CustomNetTables:SetTableValue("gamemode_choose", tostring(pid), pdata.gamemodeChoose)
end

function GamePlay:doGamdemodeChoose(pid, type, item, index)
    print("doGamdemodeChoose", pid)
    local pdata = Player.players[pid]
    local choose = nil
    for i = 1, #(pdata.gamemodeChoose.value) do
        if pdata.gamemodeChoose.value[i].index == index then
            choose = pdata.gamemodeChoose.value[i]
            break
        end
    end
    if choose and not choose.selected then
        choose.selected = item
        CustomNetTables:SetTableValue("gamemode_choose", tostring(pid), pdata.gamemodeChoose)
        if choose.type == "choose_hero" then
            fireLeftNotify(pid, false, "notify_pick_hero", {
                str1 = item
            })
            GamePlay:ChooseHero(pid, (item))
            if choose.isHostPick then
                GamePlay.hostPickHeroName = item
                for _, otherPid in pairs(Player:Ids()) do
                    if otherPid ~= pid then
                        GamePlay:newHeroChoose(otherPid, "list", { item })
                    end
                end
            end
        end
        if choose.type == "choose_mode" then
            GamePlay:doChooseMode(pid, item)
        end
    end
end

function GamePlay:notifyCenterArmor()
    local goodEnts = { "ent_notify_center_0", "ent_notify_center_1" }
    local badEnts = { "ent_notify_center_2", "ent_notify_center_3" }
    Player:ForeanchTeam(function(team, pid, hero)
        local entNames = badEnts
        if team == DOTA_TEAM_GOODGUYS then
            entNames = goodEnts
        end
        if pid then
            local tdata = GamePlay:GetTData(team)
            for key, entName in pairs(entNames) do
                local posEnt = Entities:FindByName(nil, entName)
                minimapNotice(pid, posEnt:GetAbsOrigin())
            end
            --fireLeftNotify(pid, true, "notify_center_armor", {})
        end
    end)
    GameRules:SendCustomMessage("#notify_center_armor", 0, 0)
end

function GamePlay:getAllBuildingsByTier()
    local abilityList = { {}, {}, {}, {}, {}, {} }
    if GamePlay.metaKv and GamePlay.metaKv.builders then
        for _, builder in pairs(GamePlay.metaKv.builders) do
            if builder.buildings then
                for i = 1, 6 do
                    local tier = tostring(i)
                    if builder.buildings[tier] then
                        table.insert(abilityList[i], builder.buildings[tier])
                    end
                end
            end
        end
    end
    return abilityList
end

function GamePlay:refreshProphet(pid)
    local hero = PlayerResource:GetSelectedHeroEntity(pid)
    local abilityCount = hero:GetAbilityCount() or 0
    for i = 0, abilityCount - 1 do
        local ability = hero:GetAbilityByIndex(i)
        if ability then
            hero:RemoveAbility(ability:GetAbilityName())
        end
    end
    local pdata = Player:GetPData(pid)
    pdata.prophetIndex = pdata.prophetIndex + 1
    local aList = pdata.prophetList[pdata.prophetIndex % (#pdata.prophetList) + 1]
    for i = 1, #aList do
        
        AddAbilityAndSetLevel(hero, aList[i], 1)
        Player:setFighterUsed(pid, aList[i])
    end

    Player:syncFighterPool(pid)

    AddAbilityAndSetLevel(hero, "ability_invulnerable", 1)



    Timers:CreateTimer(0.1, function()
        GamePlay:tryPunishPlayer(pid)
    end)

    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(pid), "open_fighter_pool", {
    })
    -- AddAbilityAndSetLevel(hero, "hero_ambient_effects", 1)
end

local function getHolyLightChargeFromHero(hero)
    if not hero then
        return 0
    end
    local item = hero:FindItemInInventory("item_holy_light")
    if item then
        return item:GetCurrentCharges()
    else
        return 0
    end
end



function GamePlay:clearDuplicateHero(pid)
    local pdata = Player:GetPData(pid)
    local hero = PlayerResource:GetSelectedHeroEntity(pid)

    if not pdata then
        return
    end
    if not hero then
        return
    end

    if not Player:IsConnected(pid) then
        return
    end

    if not hero:IsAlive() then
        hero:RespawnUnit()
    end
    local units = FindUnitsInRadius(pdata.team, hero:GetAbsOrigin(), nil, 1200, DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES +
        DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, 0, false)

    local otherHero = nil
    for _, unit in ipairs(units) do
        if unit:IsRealHero() and unit:GetPlayerOwnerID() == hero:GetPlayerOwnerID() and unit ~= hero then
            otherHero = unit
            break
        end
    end
    if otherHero and otherHero:HasModifier("modifier_builder") then
        local otherHeroName = otherHero:GetUnitName()
        print("clearDuplicateHero", hero:GetUnitName(), otherHeroName, hero, otherHero)
        otherHero:RemoveSelf()
        GamePlay:ChooseHero(pid, otherHeroName)
    end
end

function GamePlay:precacheUnitByNameAsync(unitName)
    if GamePlay:IsUnitPrecacheFinished(unitName) or GamePlay:IsUnitPrecacheInProgress(unitName) then
        return
    end

    local record = GamePlay:SetUnitPrecacheStatus(unitName, "loading", "async")
    print("PrecacheUnitByNameAsync start ", unitName, record.startTime)
    PrecacheUnitByNameAsync(unitName, function()
        local loadedRecord = GamePlay:SetUnitPrecacheStatus(unitName, "loaded", "async")
        print("PrecacheUnitByNameAsync end ", unitName, loadedRecord.endTime - loadedRecord.startTime)
    end)
end

function GamePlay:ChooseHero(pid, builderType)
    local heroName = builderType
    if startWith(builderType, "npc_dota_hero") then
        heroName = builderType
    else
        -- builderType is a race name, resolve it through GetBuilderByRace
        local builder = GamePlay:GetBuilderByRace(builderType)
        if builder then
            heroName = builder.name
        end
    end
    if not heroName then
        return
    end

    local pdata = Player:GetPData(pid)

    if not pdata then
        return
    end

    if pdata.kicked then
        return SendErrorMessage(pid, "ui_kicked_cant_choose_hero")
    end

    if pdata.builderIndex == 0 then
        ArrayRemoveValue(pdata.builderList, heroName)
        table.insert(pdata.builderList, 1, heroName)
        pdata.builderIndex = 1
    end

    pdata.heroName = heroName



    local oldHero = PlayerResource:GetSelectedHeroEntity(pid)
    if not oldHero then
        return
    end

    local holyLightCharge = getHolyLightChargeFromHero(oldHero)

    if oldHero:GetUnitName() == "npc_dota_hero_wisp" then
        holyLightCharge = 1
    end
    print("holyLightCharge", holyLightCharge)

    print("ReplaceHeroWith", pid, heroName)
    PlayerResource:ReplaceHeroWith(pid, heroName, 0, 0)
    local hero = PlayerResource:GetSelectedHeroEntity(pid)

    Timers:CreateTimer(0.1, function()
        GamePlay:tryPunishPlayer(pid)
    end)

    -- Hide the tusk_tag_team ability
    if hero and hero:HasAbility("tusk_tag_team") then
        local ability = hero:FindAbilityByName("tusk_tag_team")
        if ability then
            ability:SetHidden(true)
        end
    end

    Timers:CreateTimer(0.1, function()
        PlayChooseHeroParticle(hero)
    end)

    if heroName == "npc_dota_hero_rubick" then
        GamePlay:refreshProphet(pid)
    end

    if heroName == "npc_dota_hero_morphling" then
        fireLeftNotify(pid, true, "notify_npc_dota_hero_morphling", {})
    end



    for _, fighter in ipairs(pdata.towers) do
        if IsActiveUnit(fighter) then
            fighter:SetOwner(hero)
        end
    end

    if pdata.creeps then
        for _, fighter in ipairs(pdata.creeps) do
            if IsActiveUnit(fighter) then
                fighter:SetOwner(hero)
            end
        end
    end
    for _, building in ipairs(pdata.buildings) do
        if IsActiveUnit(building) then
            building:SetOwner(hero)
        end
    end
    for _, barrackUnit in ipairs(pdata.barrackUnits) do
        if IsActiveUnit(barrackUnit) then
            barrackUnit:SetOwner(hero)
        end
    end

    -- Clear every item of the hero
    for i = 0, 16 do
        local item = hero:GetItemInSlot(i)
        if item then
            hero:RemoveItem(item)
        end
    end

    local initItems = {}
    for i = 1, #initItems do
        local item = CreateItem(initItems[i], hero, hero)
        hero:AddItem(item)
    end
    hero:SetAbilityPoints(0)
    teckTree:updateAbility(hero:GetPlayerOwnerID())

    -- move camera
    print("ent_player_" .. Player:GetPData(pid).laneIndex)
    local posEnt = Entities:FindByName(nil, "ent_player_" .. Player:GetPData(pid).laneIndex)
 
    hero:AddNewModifier(hero, nil, "modifier_phased", {
        duration = 0.03
    })

    hero:AddNewModifier(hero, nil, "modifier_generic_invisible_lua", {
        duration = 1
    })

    hero:AddNewModifier(hero, nil, "modifier_builder", {})

    AddItemToUnit(hero, "item_unstuck")

    if holyLightCharge > 0 then
        AddItemToUnit(hero, "item_holy_light")
        local holyLightItem = hero:FindItemInInventory("item_holy_light")
        if holyLightItem then
            holyLightItem:SetCurrentCharges(holyLightCharge)
        end
    end
    --
    if heroName == "npc_dota_hero_rubick" then
        AddItemToUnit(hero, "item_gameplay_prophet_remake")
        local item = hero:FindItemInInventory("item_gameplay_prophet_remake")
        if item then
            item:SetCurrentCharges(pdata.prophetRandomCharge)
        end
    else
        AddItemToUnit(hero, "item_gameplay_remake")
        local item = hero:FindItemInInventory("item_gameplay_remake")
        if item then
            item:SetCurrentCharges(pdata.changeBuilderCharge)
        end
    end

    --
    local gameplay_remake = hero:FindItemInInventory("item_gameplay_remake")
    if gameplay_remake then
        if pdata.changeBuilderCharge <= 0 then
            DeleteItemOfUnit(hero, "item_gameplay_remake")
        else
            gameplay_remake:SetCurrentAbilityCharges(pdata.changeBuilderCharge)
            gameplay_remake:SetLevel(6 - pdata.changeBuilderCharge)
        end
    end

    local gameplay_prophet_remake = hero:FindItemInInventory("item_gameplay_prophet_remake")
    if gameplay_prophet_remake then
        if pdata.prophetRandomCharge <= 0 then
            DeleteItemOfUnit(hero, "item_gameplay_prophet_remake")
        else
            gameplay_prophet_remake:SetCurrentAbilityCharges(pdata.prophetRandomCharge)
            gameplay_prophet_remake:SetLevel(6 - pdata.prophetRandomCharge)
        end
    end

    DeleteItemOfUnit(hero, "item_tpscroll")

    hero:SetAbsOrigin(posEnt:GetAbsOrigin())

    GamePlay:MoveCamera(pid, posEnt:GetAbsOrigin(), 0.01)
    if IsInToolsMode() then
        AddAbilityAndSetLevel(hero, "test_build_beast_ogre_spawn_of_dragon", 1)
    end

    -- Force the selection, otherwise the chosen hero behaves like a dummy
    Timers:CreateTimer(0.1, function()
        GamePlay:SelectUnit(pid, hero, true)
    end)

end

function GamePlay:MoveCamera(pid, target, lerp)
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(pid), "move_camera", {
        cameraTarget = target,
        lerp = lerp
    })
end

function GamePlay:SetCamera(pid, targetEnt)
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(pid), "set_camera", {
        target = targetEnt:entindex()
    })
end

function GamePlay:CameraLookat(pid, targetEnt)
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(pid), "camera_lookat", {
        target = targetEnt:entindex()
    })
end

function GamePlay:SelectUnit(pid, targetEnt, bSingle)
    Timers:CreateTimer(FrameTime(), function()
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(pid), "select_unit", {
            target = targetEnt:entindex(),
            single = bSingle
        })
    end)
end

function GamePlay:moveTowerSpawnUnit(unit)
    local pid = unit:GetPlayerOwnerID()
    if not pid then
        return
    end
    if pid < 0 then
        return
    end

    local pdata = Player:GetPData(pid)
    local round = roundInfo[GamePlay.round]
    local lane = pdata.laneIndex
    local laneData = GamePlay.laneTable[lane]

    if pdata and round and isFalse(round.duel) then
        local ent = Entities:FindByName(nil, "ent_path_" .. lane .. "_0_0")
        if TableContainsValue(pdata.creeps, unit) then
            if (not unit:IsNull()) and unit:IsAlive() then
                if unit.isInDefense then
                    local pos = unit:GetAbsOrigin()
                    pos.y = -4736
                    

                    WayPointClear(unit)
                    WayPointAdd(unit, pos)
                else
                    WayPointClear(unit)
                    WayPointAdd(unit, GamePlay:getMoveTpPos(unit))

                    
                end
            end
        end
    end
end

function GamePlay:towerSpawn(pid)
    local angles = { 90, -90, 90, -90, 90, -90, 90, -90 }
    local pdata = Player:GetPData(pid)

    if not pdata then
        return
    end
    local laneIndex = pdata.laneIndex
    removeDeadUnit(pdata.towers)
    table.sort(pdata.towers, function(a, b)
        if a.fighterId and b.fighterId then
            return a.fighterId < b.fighterId
        end
        return a.entindex() < b.entindex()
    end)
    for k, tower in pairs(pdata.towers) do
        local creep = tower
        if IsActiveUnit(creep) then
            creep:RemoveModifierByName("modifier_building")
            creep:RemoveModifierByName("modifier_tower")
            creep:SetNeverMoveToClearSpace(false)
            creep:SetControllableByPlayer(-1, true)
            GamePlay:removeBuildingAbility(creep)
            table.insert(pdata.creeps, creep)
            refreshUnit(creep)
            creep:AddNewModifier(nil, nil, "modifier_phased", {
                duration = 1
            })
            if creep:HasModifier("modifier_demi_human_guardian_spirit") then
                local mod = creep:FindModifierByName("modifier_demi_human_guardian_spirit")
                if mod then
                    mod:trigger()
                end
            end
            creep:RemoveModifierByName("modifier_animation")
            -- creep:AddNewModifier(creep, nil, "modifier_tower_root", {
            --     duration = 1
            -- })
            creep:Stop()
            --
            creep:AddNewModifier(creep, nil, "modifier_ai_freeze", {
                duration = 1
            })
            local order = {
                UnitIndex = creep:entindex(),
                OrderType = DOTA_UNIT_ORDER_STOP,
                Queue = false
            }
            creep:SetContextThink(DoUniqueString("order"), function()
                ExecuteOrderFromTable(order)
            end, FrameTime())



            creep:Purge(true, true, false, true, false)


            if GamePlay.whosyourdaddy then
                local mod = creep:AddNewModifier(creep, nil, "modifier_attack", {})
                mod:SetStackCount(10000)
            end

            GamePlay:tryEditUnitInToolsMode(creep)
        end
    end
    pdata.towers = {}
    --


    Timers:CreateTimer(1.5, function()
        local pdata = Player:GetPData(pid)
        if not pdata then
            return
        end
        for k, creep in pairs(pdata.creeps) do
            GamePlay:autocastFighterAbility(creep, k)
        end
    end)
end

function GamePlay:afterWaveCreepSummon(caster, newUnit)
    if not caster then
        return
    end
    if not newUnit then
        return
    end

    local function copyModifier(fromUnit, toUnit, modifierList)
        for _, modName in ipairs(modifierList) do
            local mod = fromUnit:FindModifierByName(modName)
            if mod then
                local mod1 = toUnit:AddNewModifier(mod:GetCaster(), mod:GetAbility(), modName, {
                })
                mod1:SetStackCount(mod:GetStackCount())
            end
        end
    end

    newUnit:SetOwner(caster:GetOwner())

    copyModifier(caster, newUnit,
        { "modifier_gameplay_nogold", "modifier_center_zone", "modifier_provides_fow_position" })

    local lane = caster.path
    local laneData = GamePlay.laneTable[lane]

    newUnit.wayStep = caster.wayStep
    newUnit.waypoints = caster.waypoints
    newUnit.zoneIndex = caster.zoneIndex
    --
    newUnit.path = lane
    newUnit.subPath = 0
    if laneData then
        table.insert(laneData.roundUnits, newUnit)
    end
end

function GamePlay:openAllVision()
    if GamePlay.allVisionFlag then
        return
    end
    GamePlay.allVisionFlag = true
    Timers:CreateTimer(0, function()
        if GamePlay.allVisionFlag then
            for x = -8192, 8192, 3000 do
                for y = -8192, 8192, 3000 do
                    AddFOWViewer(DOTA_TEAM_GOODGUYS, Vector(x, y, 512), 2500, 1.1, false)
                    AddFOWViewer(DOTA_TEAM_BADGUYS, Vector(x, y, 512), 2500, 1.1, false)
                end
            end
            return 1
        else
            return nil
        end
    end)
end

function GamePlay:closeAllVision()
    if GamePlay.secondaryModes["mo"] then
        return
    end
    GamePlay.allVisionFlag = false
end

function GamePlay:markLastBuilding(tower)
    local pid = tower:GetPlayerOwnerID()
    local pdata = Player:GetPData(pid)
    if tower and pid and pdata then
        for _, t in pairs(pdata.towers) do
            t.isLastBuilding = false
        end
        tower.isLastBuilding = true
    end
end

function GamePlay:saveFighterAbilityState(fighter)
    if not IsActiveUnit(fighter) then
        return
    end

    local meta = GamePlay:FighterGetMeta(fighter.fighterId)

    if meta then
        local autoCastList = {
            "demi_human_inject_steroids",
            "mech_tree_grap",
        }
        for i, abName in ipairs(autoCastList) do
            if fighter:HasAbility(abName) then
                local ab = fighter:FindAbilityByName(abName)
                meta.abilityAutocastMap[abName] = ab:GetAutoCastState()
            end
        end

        local modifierStackList = {
            "modifier_shadow_necromastery",
            "modifier_element_morph_agi_passive",
            "modifier_element_morph_str_passive",
        }
        for i, abName in ipairs(modifierStackList) do
            if fighter:HasModifier(abName) then
                local ab = fighter:FindModifierByName(abName)
                meta.modifierStack[abName] = ab:GetStackCount()
            end
        end

        local abilityCount = fighter:GetAbilityCount() or 0
        for i = 0, abilityCount - 1 do
            local ab = fighter:GetAbilityByIndex(i)
            if ab and ab:IsToggle() then
                meta.abilityToggleMap[ab:GetAbilityName()] = ab:GetToggleState()
            end
        end
        meta.castAbilities = {}
        if fighter:HasModifier("modifier_mech_tree_grap") then
            table.insert(meta.castAbilities, "mech_tree_grap")
        end
        if fighter:HasModifier("modifier_demi_human_inject_steroids") then
            table.insert(meta.castAbilities, "demi_human_inject_steroids")
        end
    end
end

function GamePlay:saveFighterAbilityStateAtRoundEnd(fighter)
    if not IsActiveUnit(fighter) then
        return
    end
    local meta = GamePlay:FighterGetMeta(fighter.fighterId)
    if meta then
        local modifierStackList = {
            "modifier_shadow_necromastery"
        }
        for i, modName in ipairs(modifierStackList) do
            if fighter:HasModifier(modName) then
                local mod = fighter:FindModifierByName(modName)
                if mod then
                    meta.modifierStack[modName] = mod:GetStackCount()
                end
            end
        end
    end
end

function GamePlay:autocastFighterAbility(fighter, indexInArray)
    if not IsActiveUnit(fighter) then
        return
    end
    local meta = GamePlay:FighterGetMeta(fighter.fighterId)
    local autoCastList = {
        "demi_human_inject_steroids",
        "mech_tree_grap",
    }
    if meta then
        for i, abName in ipairs(autoCastList) do
            if fighter:HasAbility(abName) then
                local ab = fighter:FindAbilityByName(abName)
                if ab:GetAutoCastState() then
                    print(fighter.fighterId)
                    local delay = indexInArray * FrameTime()
                    Timers:CreateTimer(delay, function()
                        fighter:CastAbilityNoTarget(ab, fighter:GetPlayerOwnerID())
                    end)
                end
            end
        end
    end
end

function GamePlay:GetFighterName(unit)
    if IsActiveUnit(unit) then
        local rawName = GetUnitKV(unit:GetUnitName(), "include_keys_from", 1)
        if rawName then
            return rawName
        end
        return unit:GetUnitName()
    end
    return nil
end

function GamePlay:towerHide(pid)
    local pdata = Player:GetPData(pid)

    if not pdata then
        return
    end

    local laneIndex = pdata.laneIndex
    pdata.towersList = {}
    removeDeadUnit(pdata.towers)
    for k, tower in pairs(pdata.towers) do
        if tower and not tower:IsNull() then
            local towerInfo = {
                unitName = GamePlay:GetFighterName(tower),
                gold = tower.gold,
                wood = tower.wood,
                food = tower.food,
                pos = tower:GetAbsOrigin(),
                forward = tower:GetForwardVector(),
                isLastBuilding = tower.isLastBuilding,
                modifier = nil,
                buildRound = tower.buildRound,
                buildingKv = tower.buildingKv,
                fighterId = tower.fighterId,
            }
            table.insert(pdata.towersList, towerInfo)
            BuildingHelper:RemoveBuilding(tower, true)
        end
    end
end

function GamePlay:creepClear(pid)
    local pdata = Player:GetPData(pid)
    if not pdata then
        return
    end
    for k, unit in pairs(pdata.creeps) do
        if IsActiveUnit(unit) then
            unit:AddEffects(EF_NODRAW)
            unit:Kill(nil, nil)
        end
    end
    pdata.creeps = {}
end

function GamePlay:moveCreepToDuel()
    local teamCreepMap = {
        [DOTA_TEAM_GOODGUYS] = { {}, {} },
        [DOTA_TEAM_BADGUYS] = { {}, {} }
    }
    --
    for team, tdata in pairs(GamePlay.teamTable) do
        --
        for pidIndex, pid in ipairs(Player:IdsByTeam(team)) do
            local pdata = Player:GetPData(pid)
            if pdata and not pdata.kicked then
                for k, unit in pairs(pdata.barrackUnits) do
                    refreshUnit(unit)
                    table.insert(pdata.creeps, unit)
                end
                pdata.barrackUnits = {}
                removeDeadUnit(pdata.creeps)
                for _, fighter in ipairs(pdata.creeps) do
                    if fighter:GetAttackCapability() == DOTA_UNIT_CAP_RANGED_ATTACK then
                        table.insert(teamCreepMap[team][2], fighter)
                    else
                        table.insert(teamCreepMap[team][1], fighter)
                    end
                    fighter:SetBaseMoveSpeed(300)
                    if fighter:HasAbility("cant_move") then
                        fighter:RemoveAbility("cant_move")
                    end
                end
            end
        end
    end

    removeDeadUnit(GamePlay.roundGoodCreeps)
    for key, unit in pairs(GamePlay.roundGoodCreeps) do
        if unit:GetAttackCapability() == DOTA_UNIT_CAP_RANGED_ATTACK then
            table.insert(teamCreepMap[DOTA_TEAM_GOODGUYS][2], unit)
        else
            table.insert(teamCreepMap[DOTA_TEAM_GOODGUYS][1], unit)
        end
    end
    --
    removeDeadUnit(GamePlay.roundBadCreeps)
    for key, unit in pairs(GamePlay.roundBadCreeps) do
        if unit:GetAttackCapability() == DOTA_UNIT_CAP_RANGED_ATTACK then
            table.insert(teamCreepMap[DOTA_TEAM_BADGUYS][2], unit)
        else
            table.insert(teamCreepMap[DOTA_TEAM_BADGUYS][1], unit)
        end
    end
    local originPosMap = {
        [DOTA_TEAM_GOODGUYS] = Entities:FindByName(nil, "ent_duel_good"):GetAbsOrigin(),
        [DOTA_TEAM_BADGUYS] = Entities:FindByName(nil, "ent_duel_bad"):GetAbsOrigin()
    }
    local directionMap = {
        [DOTA_TEAM_GOODGUYS] = -1,
        [DOTA_TEAM_BADGUYS] = 1
    }
    --
    local cellWidth = 128
    local lineCellCount = 13

    for team, node in pairs(teamCreepMap) do
        local originPos = originPosMap[team]
        local meleeCreeps = node[1]
        local rangedCreeps = node[2]

        table.sort(meleeCreeps, function(a, b)
            if a:GetMaxHealth() ~= b:GetMaxHealth() then
                return a:GetMaxHealth() > b:GetMaxHealth()
            else
                return a:GetUnitName() < b:GetUnitName()
            end
        end)
        table.sort(rangedCreeps, function(a, b)
            if a:GetBaseAttackRange() ~= b:GetBaseAttackRange() then
                return a:GetBaseAttackRange() < b:GetBaseAttackRange()
            else
                return a:GetUnitName() < b:GetUnitName()
            end
        end)

        local function moveCreeps(startPos, creeps)
            for index, fighter in ipairs(creeps) do
                local xdir = directionMap[team]

                local cellIndex = (index - 1) % lineCellCount
                local lineIndex = math.floor((index - 1) / lineCellCount)

                local posY = 0
                if cellIndex >= 0 then
                    if cellIndex % 2 == 1 then
                        posY = math.ceil((cellIndex) / 2) * cellWidth
                    else
                        posY = -math.ceil((cellIndex) / 2) * cellWidth
                    end
                end
                local posX = lineIndex * cellWidth * xdir
                posX = posX + startPos.x
                posY = posY + startPos.y
                --
                fighter:SetAcquisitionRange(3000)

                fighter:AddNewModifier(fighter, nil, "modifier_ai_freeze", {
                    duration = 1
                })

                local spawnPos = Vector(posX, posY, originPos.z)
                SimpleMoveUnit(fighter, spawnPos)
                local fighterPos = fighter:GetAbsOrigin()
                fighter:SetForwardVector(Vector(-directionMap[team], 0, 0))
                local targetPos = Vector(fighterPos.x - directionMap[team] * 5000, fighterPos.y, fighterPos.z)
                GamePlay:orderDuelAttackToSingle(fighter, targetPos)
                --
            end
        end
        moveCreeps(originPos, meleeCreeps)
        local rangedOriginPos = Vector(originPos.x, originPos.y, originPos.z)
        rangedOriginPos.x = directionMap[team] * (math.ceil((#meleeCreeps) / lineCellCount) * cellWidth + 128) +
            originPos.x
        moveCreeps(rangedOriginPos, rangedCreeps)
    end

    for team, tdata in pairs(GamePlay.teamTable) do
        local originPos = originPosMap[team]
        for pidIndex, pid in ipairs(Player:IdsByTeam(team)) do
            local pdata = Player:GetPData(pid)
            if not pdata.kicked then
                local lane = pdata.laneIndex
                local hero = PlayerResource:GetSelectedHeroEntity(pid)
                if hero then
                    local ent = Entities:FindByName(nil, "ent_fight_" .. lane)
                    SimpleMoveUnit(hero, ent:GetAbsOrigin())
                    GamePlay:MoveCamera(pid, originPos, 1)
                    hero:SetForwardVector(Vector(-directionMap[team], 0, 0))
                    -- hero:PatrolToPosition(ent:GetAbsOrigin())
                end
            end
        end
    end
end

function GamePlay:orderDuelAttackToSingle(unit, pos)
    local vscripts = GetUnitKV(unit:GetUnitName(), "vscripts")
    --
    if vscripts then
        unit.wayStep = 1
        unit.waypoints = {}
        --table.insert(unit.waypoints, pos)
        local pos2 = Vector(unit:GetAbsOrigin().x, unit:GetAbsOrigin().y, unit:GetAbsOrigin().z)
        -- table.insert(unit.waypoints, pos2)

        for i = 1, 10, 1 do
            if i % 2 == 1 then
                table.insert(unit.waypoints, pos)
            else
                table.insert(unit.waypoints, pos2)
            end
        end
    else
        
        local pos2 = Vector(unit:GetAbsOrigin().x, unit:GetAbsOrigin().y, unit:GetAbsOrigin().z)
        

        Timers:CreateTimer(2, function()
            for i = 1, 10, 1 do
                local p = pos
                if i % 2 == 0 then
                    p = pos2
                end
                local t_order = {
                    UnitIndex = unit:entindex(),
                    OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
                    TargetIndex = nil,
                    AbilityIndex = 0,
                    Position = p,
                    Queue = true
                }
                ExecuteOrderFromTable(t_order)
            end
        end)
    end
end

function GamePlay:towerDisplaySingle(pid, tower)
    local pdata = Player:GetPData(pid)
    if not pdata then
        return
    end
    local unitName = tower.unitName
    local pos = tower.pos

    local fighterMeta = GamePlay:FighterGetMeta(tower.fighterId)
    if fighterMeta then
        if fighterMeta.age then
            fighterMeta.age = fighterMeta.age + 1
        end
    end

    local newBuilding = BuildingHelper:PlaceBuilding(pid, unitName, pos, nil, nil, nil, pdata.team)
    newBuilding:AddNewModifier(newBuilding, nil, "modifier_tower", {})

    newBuilding.gold = tower.gold
    newBuilding.food = tower.food
    newBuilding.wood = tower.wood
    newBuilding.buildRound = tower.buildRound
    newBuilding.isLastBuilding = nil
    newBuilding.buildingKv = tower.buildingKv

    GamePlay:FighterUpdate(tower.fighterId, newBuilding)


    if GamePlay.secondaryModes['ls'] then
        newBuilding.isLastBuilding = tower.isLastBuilding
    end

    

    if fighterMeta then
        local abilityCount = newBuilding:GetAbilityCount() or 0
        for i = 0, abilityCount - 1 do
            local ab = newBuilding:GetAbilityByIndex(i)
            if ab and ab:IsToggle() then
                if fighterMeta.abilityToggleMap[ab:GetAbilityName()] ~= ab:GetToggleState() then
                    ab:ToggleAbility()
                end
            end
        end

        if fighterMeta.level then
            newBuilding:CreatureLevelUp(1)
        end
    end
    table.insert(pdata.towers, newBuilding)
    newBuilding:SetForwardVector(tower.forward)

    GamePlay:initFighter(newBuilding)
end

function GamePlay:towerDisplay(pid)
    local pdata = Player:GetPData(pid)
    if not pdata then
        return
    end

    for index, tower in pairs(pdata.towersList) do
        --Timers:CreateTimer(0.1*index,function ()
        GamePlay:towerDisplaySingle(pid, tower)
        -- end)
    end
    pdata.towersList = {}
end

function GamePlay:SetBuildingForwardVector(building)
    local pid = building:GetPlayerOwnerID()

    local pdata = Player:GetPData(pid)

    if pdata then
        building:SetForwardVector(LANE_META[pdata.laneIndex].forwardVector)
    end
end

function GamePlay:replaceFighterAbility(fighter)
    if GamePlay:Mode("hc") then
        local changeMap = MODE_ABILITY_MODIFIER["hc"]
        if changeMap and changeMap[fighter:GetUnitName()] then
            local abList = changeMap[fighter:GetUnitName()]
            for oldAbName, newAbName in pairs(abList) do
                --fighter:RemoveAbility(oldAbName)
                AddAbilityAndSetLevel(fighter, newAbName, 1)
                fighter:SwapAbilities(oldAbName, newAbName, false, true)
            end
        end
    end
end

function GamePlay:OnDragDummyCreated(building)
    GamePlay:SetBuildingForwardVector(building)
end

function GamePlay:initPlayerResource(pid)
    local hero = PlayerResource:GetSelectedHeroEntity(pid)

    if PlayerResource:IsValidPlayer(pid) and IsActiveUnit(hero) then
        Player:AddPlayer(pid)
        local pdata = Player:GetPData(pid)

        local team = PlayerResource:GetTeam(pid)
        if team == DOTA_TEAM_GOODGUYS then
            pdata.laneIndex = GamePlay.nextGoodLane
            GamePlay.nextGoodLane = GamePlay.nextGoodLane + 1
        else
            pdata.laneIndex = GamePlay.nextBadLane
            GamePlay.nextBadLane = GamePlay.nextBadLane + 1
        end

        print("initPlayerResource", pid)
        -- Player:ModifyGold(pid, 300)
        Player:ModifyWood(pid, 100)
        Player:AddFood(pid, 15)
        Player:ModifyGold(pid, 300)
        -- Player:ModifyFood(i,-15)
        GamePlay:MovePlayerHero(pid)
        GamePlay:PlacePlayerBuilding(pid)

        if GamePlay.secondaryModes["x2"] then
            Player:ModifyGold(pid, 100)
        end


        table.sort(pdata.racePool)
        Timers:CreateTimer(FrameTime(), function()
            GamePlay:updateBuildingAbility()
        end)

        return true
    end
    return false
end

function GamePlay:DebugSetPlayerLumberWorker(pid, count)
    local pdata = Player:GetPData(pid)
    for index, thinker in ipairs(pdata.treeThinkers) do
        thinker:Destroy()
    end
    pdata.treeThinkers = {}
    local point = Entities:FindByName(nil, "ent_tree_" .. Player:GetPData(pid).laneIndex)
        :GetAbsOrigin()
    local trees = GridNav:GetAllTreesAroundPoint(point, 500, false)
    for i = 1, #trees do
        trees[i].cuted = nil
    end

    local town = nil
    for index, building in ipairs(pdata.buildings) do
        if building:GetUnitName() == "building_town" then
            town = building
        end
    end
    local ab = town:FindAbilityByName("upgrade_lumber_farm")
    for i = 1, count, 1 do
        ab:startTreeCutter(ab:GetCaster(), pid)
    end
    --
    ab:SetLevel(count)
    pdata.lumberWoker = count
end

function GamePlay:DebugSetPlayerLumberSpeed(pid, speed)
    local pdata = Player:GetPData(pid)
    local town = nil
    for index, building in ipairs(pdata.buildings) do
        if building:GetUnitName() == "building_town" then
            town = building
        end
    end
    local ab = town:FindAbilityByName("upgrade_lumber_farm_speedup")

    if not ab then
        ab = town:FindAbilityByName("upgrade_lumber_farm_speedup_x2")
    end
    --
    ab:SetLevel(speed - 1)
    pdata.woodCollect = speed
end

function GamePlay:PlacePlayerBuilding(pid)
    local pdata = Player:GetPData(pid)
    for j = 0, 3 do
        local buildingNames = { "building_town", "building_advanced_barracks", "building_barracks", "building_farm" }

        -- "particles/radiant_fx/good_barracks_ranged001_amb.vpcf"
        local effMap = { nil, nil, nil, nil }

        local infoEnt = Entities:FindByName(nil, "ent_" .. pdata.laneIndex .. "_building_" .. j)
        if infoEnt and buildingNames[j + 1] then
            local building = BuildingHelper:PlaceBuilding(pid, buildingNames[j + 1], infoEnt:GetAbsOrigin(), nil, nil,
                nil, pdata.team)
            if effMap[j + 1] then
                local eff = ParticleManager:CreateParticle(effMap[j + 1], PATTACH_ABSORIGIN_FOLLOW, building)
                ParticleManager:SetParticleControlEnt(eff, 0, building, PATTACH_ABSORIGIN_FOLLOW, nil,
                    building:GetAbsOrigin(), true)
                ParticleManager:SetParticleControl(eff, 1, Vector(500, 500, 500))
            end

            -- print(buildingNames[j + 1])

            if buildingNames[j + 1] == "building_advanced_barracks" then
                -- print("buildingNames",123)
                building:SetForwardVector(Vector(-1, 0, 0))
            end

            if building:GetUnitName() == "building_farm" then
                if GamePlay:Mode("x2") then
                    building:SwapAbilities("upgrade_farm", "upgrade_farm_x2", false, true)
                else
                    building:RemoveAbility("upgrade_farm_x2")
                end
                local prop = SpawnEntityFromTableSynchronous("prop_dynamic", {
                    model = "models/props_gameplay/divine_sentinel/divine_sentinel.vmdl",
                    DefaultAnim = "divine_sentinel_closed_idle",
                })
                local pos = building:GetAbsOrigin()
                prop:SetAbsOrigin(Vector(pos.x, pos.y, pos.z + 10))
                prop:SetModelScale(0.6)
            end

            if building:GetUnitName() == "building_town" then
                if GamePlay:Mode("x2") then
                    building:SwapAbilities("upgrade_lumber_farm_speedup", "upgrade_lumber_farm_speedup_x2", false, true)
                    building:SwapAbilities("king_hit_points", "king_hit_points_x2", false, true)
                    building:SwapAbilities("king_attack", "king_attack_x2", false, true)
                    building:SwapAbilities("king_regeneration", "king_regeneration_x2", false, true)
                else
                    building:RemoveAbility("upgrade_lumber_farm_speedup_x2")
                    building:RemoveAbility("king_hit_points_x2")
                    building:RemoveAbility("king_attack_x2")
                    building:RemoveAbility("king_regeneration_x2")
                end
            end

            table.insert(pdata.buildings, building)
        end
    end
end

function GamePlay:MovePlayerHero(pid)
    local pdata = Player:GetPData(pid)

    if not pdata then
        return
    end

    local hero = PlayerResource:GetSelectedHeroEntity(pid)
    if hero then
        local ent = Entities:FindByName(nil, "ent_player_" .. pdata.laneIndex)
        SimpleMoveUnit(hero, ent:GetAbsOrigin())
        GamePlay:MoveCamera(pid, ent:GetAbsOrigin(), 0.01)
    end
end

function GamePlay:upKingInX2()
    local kings = { GamePlay.kingGood, GamePlay.kingBad }
    for index, king in ipairs(kings) do
        if GamePlay.secondaryModes["x2"] then
            king:CreatureLevelUp(1)
        end
    end
end

-- GamePlay:upKingInX2()

function GamePlay:PlaceKing()
    local goodEnt = Entities:FindByName(nil, "ent_king_good")
    local kingGood = BuildingHelper:PlaceBuilding(nil, "king_good", goodEnt:GetAbsOrigin(), nil, nil, nil,
        DOTA_TEAM_GOODGUYS)

    kingGood:SetAngles(0, 90, 0)
    GamePlay.kingGood = kingGood
    GamePlay.teamTable[DOTA_TEAM_GOODGUYS].king = kingGood
    local ab = kingGood:FindAbilityByName("king_bouns")
    if ab then
        ab:SetLevel(0)
    end

    local badEnt = Entities:FindByName(nil, "ent_king_bad")
    local kingBad = BuildingHelper:PlaceBuilding(nil, "king_bad", badEnt:GetAbsOrigin(), nil, nil, nil,
        DOTA_TEAM_BADGUYS)

    kingBad:SetAngles(0, 90, 0)
    local ab1 = kingBad:FindAbilityByName("king_bouns")
    if ab1 then
        ab1:SetLevel(0)
    end
    GamePlay.kingBad = kingBad
    GamePlay.teamTable[DOTA_TEAM_BADGUYS].king = kingBad
    GamePlay:upKingInX2()
end

print("GamePlay load")
