if not Player then
    Player = class({})
end

function Player:Init()
    print("Player:Init")
    Player.players = {}
    Player.abandonList = {}

    ListenToGameEvent("entity_killed", Dynamic_Wrap(Player, "OnEntityKilled"), self)

    ListenToGameEvent('player_disconnect', Dynamic_Wrap(Player, 'OnDisconnect'), self)
    ListenToGameEvent("player_reconnected", Dynamic_Wrap(Player, 'OnPlayerReconnect'), self)
end

function Player:Ids()
    local res = {}
    for pid = 0, PlayerResource:GetPlayerCount() - 1, 1 do
        if Player.players[pid] then
            table.insert(res, pid)
        end
    end
    return res
end

function Player:IdsByTeam(team)
    local res = {}
    for pid = 0, PlayerResource:GetPlayerCount() - 1, 1 do
        if Player.players[pid] and PlayerResource:GetTeam(pid) == team then
            table.insert(res, pid)
        end
    end
    return res
end

-- Wrapper that looks up the builder entry for a race
function Player:GetBuilderByRace(race)
    if not gMetaKv then
        return nil
    end

    if not gMetaKv.builders then
        return nil
    end

    -- Walk every builder and pick the one matching the race
    for index, builder in pairs(gMetaKv.builders) do
        if builder.race == race then
            return builder
        end
    end

    return nil
end

function Player:GetNonKickedPlayerCount()
    local res1 = 0
    local res2 = 0
    for _, pid in pairs(Player:GoodPlayers()) do
        local pdata = Player:GetPData(pid)
        if pdata and not pdata.kicked and not pdata.disableSpawnWave then
            res1 = res1 + 1
        end
    end
    for _, pid in pairs(Player:BadPlayers()) do
        local pdata = Player:GetPData(pid)
        if pdata and not pdata.kicked and not pdata.disableSpawnWave then
            res2 = res2 + 1
        end
    end
    return res1, res2
end

function Player:GetNonKickedPlayerCountByTeam(team)
    local t1, t2 = Player:GetNonKickedPlayerCount()
    if team == DOTA_TEAM_GOODGUYS then
        return t1
    end
    if team == DOTA_TEAM_BADGUYS then
        return t2
    end
end

function Player:GetActivePlayerInTeam(team)
    local res = {}
    for index, pid in ipairs(Player:Ids()) do
        local pdata = Player:GetPData(pid)
        if pdata and pdata.team == team and not pdata.kicked and not pdata.abandoned then
            table.insert(res, pid)
        end
    end
    return res
end

function Player:OnDisconnect(params)
    -- The game is over, no need to handle disconnects
    if GamePlay.gameWinner then
        return
    end

    p("OnDisconnect")
    PrintTable(params)
    local pid = params.PlayerID
    local new_state = GameRules:State_Get()
    if new_state < DOTA_GAMERULES_STATE_PRE_GAME then
        return
    end
    local pdata = Player:GetPData(pid)
    if pdata then
        --GameRules:SendCustomMessage("#DOTA_Chat_DisconnectWaitForReconnect_legion", params.PlayerID, 0)
        local remainingMinute = math.ceil((ABANDON_TIMEOUT - (pdata.disconnectTotalTime)) / 60)
        if remainingMinute < 0 then
            remainingMinute = 0
        end
        if #Player.abandonList == 0 and not pdata.disconnectNotifyTable[remainingMinute] then
            GameRules:SendCustomMessage("#DOTA_Chat_DisconnectTimeRemaining_legion", pid, remainingMinute)
            pdata.disconnectNotifyTable[remainingMinute] = true
        end
        pdata.lastDisconnectTime = GameRules:GetGameTime()
    end
end

function Player:OnPlayerReconnect(params)
    -- The game is over, no need to handle reconnects
    if GamePlay.gameWinner then
        return
    end

    p("OnPlayerReconnect")
    PrintTable(params)
    local pid = params.PlayerID
    local new_state = GameRules:State_Get()
    if new_state < DOTA_GAMERULES_STATE_PRE_GAME then
        return
    end
    local pdata = Player:GetPData(pid)
    if pdata then
        --GameRules:SendCustomMessage("#DOTA_Chat_Reconnect", params.PlayerID, 0)
        if pdata.lastDisconnectTime then
            pdata.disconnectTotalTime = pdata.disconnectTotalTime + (GameRules:GetGameTime() - pdata.lastDisconnectTime)
            pdata.lastDisconnectTime = nil
            p("OnPlayerReconnect", pdata.disconnectTotalTime, pdata.lastDisconnectTime)
        end
    end
end

function Player:checkAbandon()
    --print("Player:checkAbandon")
    -- The game is over, stop checking for abandons
    if GamePlay.gameWinner then
        return
    end

    local ids = Player:Ids()
    for i = 1, #(ids) do
        local pid = ids[i]
        local pdata = Player:GetPData(pid)
        if pdata and not PlayerResource:IsFakeClient(pid) and not Player:HasAbandoned(pid) then
            local abandon = false
            local reason = ""
            -- left
            if PlayerResource:GetConnectionState(pid) == DOTA_CONNECTION_STATE_ABANDONED then
                Player:directAbandon(pid)
                abandon = true
            end
            -- disconnected
            if not abandon and PlayerResource:GetConnectionState(pid) == DOTA_CONNECTION_STATE_DISCONNECTED then
                local disconnectWaitTime = ABANDON_TIMEOUT
                local timeLeft = disconnectWaitTime -
                    ((GameRules:GetGameTime() - pdata.lastDisconnectTime) + pdata.disconnectTotalTime)
                local timeLeftInMinute = math.ceil(timeLeft / 60)
                if timeLeftInMinute < 0 then
                    timeLeftInMinute = 0
                end
                if pdata.lastDisconnectTime == nil then
                    pdata.lastDisconnectTime = GameRules:GetGameTime()
                end
                if #Player.abandonList == 0 and not pdata.disconnectNotifyTable[timeLeftInMinute] then
                    GameRules:SendCustomMessage("#DOTA_Chat_DisconnectTimeRemaining_legion", pid, timeLeftInMinute)
                    pdata.disconnectNotifyTable[timeLeftInMinute] = true
                end
                if timeLeft <= 0 then
                    p("DisconnectedTooLong", pid, (GameRules:GetGameTime() - pdata.lastDisconnectTime),
                        pdata.disconnectTotalTime)
                    Player:disconnectAbandon(pid)
                    abandon = true
                end
            end
            -- AFK
            local afkTime = ABANDON_TIMEOUT
            if not abandon and PlayerResource:GetConnectionState(pid) == DOTA_CONNECTION_STATE_CONNECTED and
                (GameRules:GetGameTime() - pdata.lastOrderTime) > afkTime then
                p("DisconnectedTooLong", pid, (GameRules:GetGameTime() - pdata.lastOrderTime))
                Player:afkAbandon(pid)
                abandon = true
            end
        end
    end
end

function Player:OnEntityKilled(event)
    -- The game is over, no need to track kills
    if GamePlay.gameWinner then
        return
    end

    local attacker_entity_index = event.entindex_attacker
    local killed = EntIndexToHScript(event.entindex_killed)
    if not killed then
        return
    end
    local killer
    if attacker_entity_index then
        killer = EntIndexToHScript(attacker_entity_index)
    end
    if not killer then
        return
    end
    local pid = killer:GetPlayerOwnerID()
    if pid >= 0 then
        local pdata = Player:GetPData(pid)
        if pdata and (not IsCustomBuilding(killed)) then
            pdata.kills = pdata.kills + 1
            --record round data
            local roundNode = GamePlay.roundList[#(GamePlay.roundList)]
            if roundNode then
                local pstats = roundNode.players[pid]
                if pstats then
                    if pstats.kills == nil then
                        pstats.kills = 0
                    end
                    pstats.kills = pstats.kills + 1
                end
            end
        end
    end
end

function Player:GoodPlayers()
    local res = {}
    for i = 1, PlayerResource:GetPlayerCount(), 1 do
        local pid = i - 1
        if PlayerResource:GetTeam(pid) == DOTA_TEAM_GOODGUYS then
            table.insert(res, pid)
        end
    end
    return res
end

function Player:BadPlayers()
    local res = {}
    for i = 1, PlayerResource:GetPlayerCount(), 1 do
        local pid = i - 1
        if PlayerResource:GetTeam(pid) == DOTA_TEAM_BADGUYS then
            table.insert(res, pid)
        end
    end
    return res
end



function Player:OnGameRulesStateChange(new_state)
    if new_state == DOTA_GAMERULES_STATE_PRE_GAME then
        Player:ForeanchPlayer(function(pid, pdata)
            Player:SyncNetTable(pid)
        end)

        Timers:CreateTimer(1, function()
            Timers:CreateTimer(0, function()
                Player:ForeanchPlayer(function(pid, pdata)
                    Player:SyncNetTable(pid)
                end)
            end)
            return 1
        end)

        Timers:CreateTimer(1, function()
            SafeCall(function()
                Player:checkAbandon()
            end)
            return 1
        end)
        --
        print("[legiontd] teams")
    end

    if new_state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then

    end

    if new_state == DOTA_GAMERULES_STATE_PRE_GAME then

    end
end

function Player:initPlayerProphetAbilities(pid)
    print("[Prophet] initialising the player prophet abilities, pid:", pid)
    local pdata = Player:GetPData(pid)

    if not pdata then
        print("[Prophet] no player data, pid:", pid)
        return
    end

    if not GamePlay.prophetFighterPoolByTier then
        print("[Warning] prophetFighterPoolByTier not initialized for player", pid)
    end

    pdata.racePool = {}

    pdata.prophetList = {}
    pdata.prophetIndex = 0
    --

    local fighterPool = { {}, {}, {}, {}, {}, {} }
    print("[Prophet] building the fighter pool from prophetFighterPoolByTier...")
    if GamePlay.prophetFighterPoolByTier then
        for tier = 1, #fighterPool do
            local tierFighters = GamePlay.prophetFighterPoolByTier[tier] or {}
            for _, fighter in ipairs(tierFighters) do
                if fighter.name then
                    table.insert(fighterPool[tier], "build_" .. fighter.name)
                end
            end
        end
    end

    print("[Prophet] fighter pool per tier:")
    for i = 1, #fighterPool do
        print("  tier", i, ":", #fighterPool[i], "units")
    end

    for i = 1, #fighterPool, 1 do
        fighterPool[i] = subrange(Shuffle(fighterPool[i]), 1, 6)
        fighterPool[i] = Shuffle(fighterPool[i])
    end


    local fighterPoolSave = { {}, {}, {}, {}, {}, {} }

    for i = 1, #fighterPool, 1 do
        fighterPoolSave[i] = {}
        for j = 1, #(fighterPool[i]), 1 do
            fighterPoolSave[i][j] = {
                unit = fighterPool[i][j],
                used = 0
            };
        end
    end

    print("fighterPoolSave")
    PrintTable(fighterPoolSave)

    pdata.fighterPoolSave = fighterPoolSave
    Player:syncFighterPool(pid)

    local abilityList = { {}, {}, {}, {}, {}, {} }
    for i = 1, #abilityList, 1 do
        abilityList[i] = Shuffle(fighterPool[i])
    end

    local len= #(fighterPool[1])
    print("[Prophet] ability list built, total:", len)
    for i = 1, len, 1 do
        local getList = {}
        for j = 1, #abilityList do
            local l = abilityList[j]
            if #l > 0 then
                table.insert(getList, l[i])
            else
                table.insert(getList, "ability_empty" .. j)
            end
        end
        table.insert(pdata.prophetList, getList)
    end
    print("initPlayerProphetAbilities")
    PrintTable(pdata.prophetList)
    print("[Prophet] initialisation done, pid:", pid)
end

function Player:setFighterUsed(pid, fighterAbility)
    local pdata = Player:GetPData(pid)
    for index, value in ipairs(pdata.fighterPoolSave) do
        for index2, value2 in ipairs(pdata.fighterPoolSave[index]) do
            if value2.unit == fighterAbility then
                value2.used = 1
            end
        end
    end
end

function Player:syncFighterPool(pid)
    local pdata = Player:GetPData(pid)
    PlayerTables:SetTableValue("legiontd_fighter_pool", pid, (pdata.fighterPoolSave))
end

function Player:initPlayerBuilderList(pid)
    local pdata = Player:GetPData(pid)
    if not pdata then
        return
    end
    pdata.builderList = {}
    pdata.builderIndex = 0
    --
    if GamePlay.metaKv and GamePlay.metaKv.builders then
        for _, builder in pairs(GamePlay.metaKv.builders) do
            table.insert(pdata.builderList, builder.name)
        end
    end
    --
    pdata.builderList = Shuffle(pdata.builderList)
end

function Player:AddPlayer(pid)
    if not Player.players[pid] then
        print("Player:AddPlayer", pid)
        Player.players[pid] = {
            pid = pid,
            playerName = PlayerResource:GetPlayerName(pid),
            steamId = PlayerResource:GetSteamAccountID(pid),
            abandoned = false,
            abandonedTime = nil,
            missCount = 0,
            gamemodeChoose = {
                value = {}
            },
            gold = 0,
            wood = 0,
            food = 0,
            maxFood = 0,
            income = 0,
            laneIndex = 0,
            -- building
            buildings = {},
            -- spawn building
            towers = {},     --unit
            towersList = {}, --unit info
            -- units
            creeps = {},
            team = PlayerResource:GetTeam(pid),
            barrackUnits = {},
            lumberWoker = 0,
            -- lumber efficiency
            woodCollect = 2,
            -- re-pick hero
            changeBuilderCharge = 5,
            -- prophet reroll
            prophetRandomCharge = 5,
            -- fighter value
            creepValue = 0,
            kills = 0,
            treeThinkers = {},
            disableSpawnWave = false,
            -- leaked creeps
            leakCount = 0,
            bhGhostUnits = {},
            kicked = false,
            kickedTime = nil,
            --king
            lastDisconnectTime = GameRules:GetGameTime(),
            disconnectTotalTime = 0,
            disconnectNotifyTable = {},
            lastOrderTime = GameRules:GetGameTime(),
            --
            summons = {},
            kickedVoteList = {},
            heroName = FORCE_PICKED_HERO,
            roundTowers = {},
            --
            defenseMode = "local",
            defenseModeMoved = false,
            prophetList = {},
            prophetIndex = 0,
            builderList = {},
            builderIndex = 0,
            ban_date = 0,
            banDateFormated = "",
            banned = false,
            cantGetElo = false,

            racePool = {}
            -- voiceEntity=nil,
            -- voiceName=nil
        }
        if Player.players[pid].steamId == 0 then
            Player.players[pid].steamId = pid
        end
        print("add player " .. pid)
    end
end

function Player:makeRandomList()
    for pid, pdata in pairs(Player.players) do
        Player:initPlayerProphetAbilities(pid)
        Player:initPlayerBuilderList(pid)
    end
end
function Player:SaveRoundTowers(pid)
    local pdata = Player:GetPData(pid)
    if not pdata then
        return
    end
    local round = GamePlay.round
    pdata.roundTowers[round] = {}
    for _, tower in ipairs(pdata.towers) do
        table.insert(pdata.roundTowers[round], { name = tower:GetUnitName() })
    end
end

function Player:SyncNetTable(pid)
    local pdata = Player:GetPData(pid)
    if pdata then
        local syncData = {
            food = pdata.food,
            maxFood = pdata.maxFood,
            wood = pdata.wood,
            gold = pdata.gold,
            income = pdata.income,
            creepValue = pdata.creepValue,
            lumberWoker = pdata.lumberWoker,
            kills = pdata.kills,
            woodCollect = pdata.woodCollect,
            rankInfo = pdata.rankInfo
        }
        --
        CustomNetTables:SetTableValue("player", tostring(pid), syncData)
        --
    end
end

function Player:ForeanchPlayer(func)
    for k, pid in pairs(Player:Ids()) do
        local pdata = Player:GetPData(pid)
        if pdata then
            SafeCall(function()
                func(pid, pdata)
            end)
        end
    end
end

function Player:ForeanchTeam(func)
    local goodPid = nil
    local goodHero = nil
    if #(Player:GoodPlayers()) > 0 then
        goodPid = (Player:GoodPlayers())[1]
        goodHero = PlayerResource:GetSelectedHeroEntity(goodPid)
    end
    SafeCall(function()
        func(DOTA_TEAM_GOODGUYS, goodPid, goodHero)
    end)

    local badPid = nil
    local badHero = nil
    if #(Player:BadPlayers()) > 0 then
        badPid = (Player:BadPlayers())[1]
        badHero = PlayerResource:GetSelectedHeroEntity(badPid)
    end
    SafeCall(function()
        func(DOTA_TEAM_BADGUYS, badPid, badHero)
    end)
end

function Player:UpdateCreepValue(id)
    if id < 0 then
        return
    end

    if GamePlay.state == "in-round" then
        return
    end

    local pdata = Player.players[id]
    if pdata then
        pdata.creepValue = 0
        for key, unit in pairs(pdata.towers) do
            if IsActiveUnit(unit) then
                unit.gold = unit.gold or 0
                pdata.creepValue = pdata.creepValue + unit.gold
            end
        end
        Player:SyncNetTable(id)
        print("[legiotd] UpdateCreepValue " .. id .. " " .. pdata.creepValue)
    end
end

function Player:GetIncome(id)
    local pdata = Player.players[id]
    return pdata.income
end

function Player:ModifyIncome(id, income)
    local pdata = Player.players[id]
    --
    if pdata then
        income = math.floor(income)
        pdata.income = pdata.income + income
        pdata.income = math.max(0, pdata.income)
        pdata.income = math.max(pdata.income, 0)
        Player:SyncNetTable(id)
    end
end

function Player:GetPlayerByLane(laneIndex)
    local res = nil
    Player:ForeanchPlayer(function(pid, pdata)
        if pdata.laneIndex == laneIndex and not pdata.kicked then
            res = pid
        end
    end)
    return res
end

function Player:ChangeLane(pid, newLane, newTeam)
    local pdata = Player:GetPData(pid)
    pdata.laneIndex = newLane
    pdata.team = newTeam
    local newTeam = newTeam
    PlayerResource:SetCustomTeamAssignment(pid, newTeam)
    local hero = PlayerResource:GetSelectedHeroEntity(pid)
    hero:SetTeam(newTeam)
    hero:SetPlayerID(pid)
    hero:SetOwner(PlayerResource:GetPlayer(pid))

    for index, building in ipairs(pdata.buildings) do
        building:SetTeam(newTeam)
        -- building:SetPlayerID(pid)
        building:SetOwner(hero)
    end

    local ent = Entities:FindByName(nil, "ent_player_" .. newLane)
    SimpleMoveUnit(hero, ent:GetAbsOrigin())
    GamePlay:MoveCamera(pid, hero:GetAbsOrigin(), 1)
end

function Player:ModifyGold(id, gold)
    local pdata = Player.players[id]
    if pdata then
        pdata.gold = math.max(0, pdata.gold + gold)
        Player:SyncNetTable(id)
    end
end

function Player:GetGold(id)
    local pdata = Player.players[id]
    if pdata then
        return pdata.gold
    else
        return 0
    end
end

function Player:AddFood(id, food)
    local pdata = Player.players[id]
    if pdata then
        pdata.maxFood = pdata.maxFood + food
        pdata.food = pdata.food + food
        pdata.food = math.min(pdata.food, pdata.maxFood)
        Player:SyncNetTable(id)
    end
end

function Player:ModifyFood(id, food)
    local pdata = Player.players[id]
    if pdata then
        pdata.food = pdata.food + food
        pdata.food = math.min(pdata.food, pdata.maxFood)
        pdata.food = math.max(pdata.food, 0)
        Player:SyncNetTable(id)
    end
end

function Player:GetFood(id)
    local pdata = Player.players[id]
    if pdata then
        return pdata.food
    else
        return 0
    end
end

function Player:GetWood(id)
    local pdata = Player.players[id]
    if pdata then
        return pdata.wood
    else
        return 0
    end
end

function Player:ModifyWood(id, wood)
    local pdata = Player.players[id]
    if pdata then
        pdata.wood = pdata.wood + wood
        pdata.wood = math.max(pdata.wood, 0)
        Player:SyncNetTable(id)
    end
end

function Player:GetPData(pid)
    return Player.players[pid]
end

function Player:afkAbandon(pid)
    if #Player.abandonList == 0 then
        GameRules:SendCustomMessage("#DOTA_Chat_PlayerAbandonedAFK", pid, 0)
    else
        GameRules:SendCustomMessage("#DOTA_Chat_PlayerLeftAFK", pid, 0)
    end
    local reason = "LeftAFK"
    Player:Abandon(pid, reason)
end

-- Say(nil,  ' threw an error on event ', false)
-- GameRules:SendCustomMessageToTeam("#DOTA_Chat_PlayerAbandonedAFK", -1,0,0)

function Player:disconnectAbandon(pid)
    if #Player.abandonList == 0 then
        GameRules:SendCustomMessage("#DOTA_Chat_PlayerAbandonedDisconnectedTooLong", pid, 0)
    else
        GameRules:SendCustomMessage("#DOTA_Chat_PlayerLeftDisconnectedTooLong", pid, 0)
    end
    local reason = "DisconnectedTooLong"
    Player:Abandon(pid, reason)
end

function Player:directAbandon(pid)
    if #Player.abandonList == 0 then
        GameRules:SendCustomMessage("#DOTA_Chat_PlayerAbandoned", pid, 0)
    else
        GameRules:SendCustomMessage("#DOTA_Chat_PlayerLeft", pid, 0)
    end
    local reason = "Left"
    Player:Abandon(pid, reason)
end

-- p(PlayerResource:GetConnectionState(1))


function Player:Abandon(pid, reason)
    local pdata = Player.players[pid]
    if pdata.abandoned then
        return
    end


    local pname = getPlayerName(pid)

    if not pdata.kicked then
        GameRules:SendCustomMessage("#DOTA_Chat_Abandon", pid, pid)
    end

    p("abandoning player ", pid, pname, reason)
    table.insert(Player.abandonList, {
        pid = pid,
        pname = pname,
        steamId = PlayerResource:GetSteamAccountID(pid),
        time = GameRules:GetGameTime(),
        reason = reason
    })
    if #(Player.abandonList) == 1 then
        -- GameRules:SendCustomMessage("#DOTA_Chat_CanQuitWithoutAbandon", 0, 0)
        -- GameRules:SendCustomMessage("#DOTA_Chat_RankedGameStillScoredleaversGetLoss", 0, 0)
    end
    if Player.isRankMatch and Storage.PlayerAbandon then
        -- Storage:PlayerAbandon((pid))
    end
    Timers:CreateTimer(FrameTime(), function()
        Storage:MatchUpdate()
    end)
    pdata.abandoned = true
    pdata.abandonedTime = GameRules:GetGameTime()
    pdata.abandonedRound = GamePlay.round
    pdata.abandonedReason=reason
end

function Player:HasAbandoned(pid)
    return Player.players[pid].abandoned
end

function Player:IsActive(pid)
    return Player:IsConnected(pid) and not Player:HasAbandoned(pid)
end

function Player:IsConnected(pid)
    if PlayerResource:IsFakeClient(pid) then
        return true
    end

    return PlayerResource:GetConnectionState(pid) == DOTA_CONNECTION_STATE_CONNECTED
end

function Player:GetAbandonList()
    local res = {}
    local ids = Player:Ids()
    for i = 1, #ids do
        local id = ids[i]
        if Player:HasAbandoned(id) then
            table.insert(res, id)
        end
    end
    return res
end

function Player:GetNotAbandonList()
    local res = {}
    local ids = Player:Ids()
    for i = 1, #ids do
        local id = ids[i]
        if not Player:HasAbandoned(id) then
            table.insert(res, id)
        end
    end
    return res
end

print("Player loaded")
