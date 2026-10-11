if not Storage then
    Storage = class({})
end

local function getTimeStamp()
    local pattern = "(%d+)/(%d+)/(%d+)"
    local timeToConvert = GetSystemDate()
    local month, day, year = timeToConvert:match(pattern)
    return (366 * year + 31 * month + day) * 24 * 3600 + math.ceil(GetSystemTimeMS() / 1000)
end

function Storage:Init()
    Storage.inited = true
    if IsInToolsMode() then
        Storage.fakeGameId = getTimeStamp()
    end
end

function Storage:OnScriptReload()
    print("Storage reload")
end

-- Storage server address. nil means no storage server is configured:
-- Every network call then returns quietly: no errors and no request logs
local sServerAddress = nil

function Storage:IsServerAvailable()
    return sServerAddress ~= nil and sServerAddress ~= ""
end

function Storage:Http(path, data, cb)
    if not Storage:IsServerAvailable() then
        return
    end
    local url = sServerAddress .. string.gsub(path, "^/", "")
    local request = CreateHTTPRequestScriptVM("POST", url)
    local serverKey = GetDedicatedServerKeyV2("legiontd") --
    -- print("serverKey", serverKey)
    request:SetHTTPRequestGetOrPostParameter("dedicated_server_key", serverKey);
    --
    local encodedData = tostring(JSON:encode(data))
    request:SetHTTPRequestGetOrPostParameter("v", encodedData)
    --
    print("[HTTP Request]")
    print("  Path: " .. url)
    print("  Body: " .. encodedData)
    --
    request:Send(function(result)
        print("[HTTP Response]")
        print("  Path: " .. path)
        print("  Status: " .. result.StatusCode)
        if result.Body then
            print("  Response: " .. result.Body)
        else
            print("  Response: (empty)")
        end
        if result.StatusCode == 200 and result.Body ~= nil then
            local body = JSON:decode(result.Body)
            if cb then
                cb(result.StatusCode, body, result.Body)
            end
        else
            if cb then
                cb(result.StatusCode, nil, nil)
            end
        end
    end)
    --
end

function Storage:ServerInfo()
    if not Storage:IsServerAvailable() then
        return
    end
    Storage:Http("/info", {
        a = {
            b = {
                c = {
                    d = {}
                }
            }
        }
    }, function(code, data)
        print(code)
        PrintTable(data)
    end)
end

function Storage:collectGameId()
    if IsInToolsMode() then
        return Storage.fakeGameId
    else
        return tostring(GameRules:Script_GetMatchID())
    end
end

function Storage:collectPlayerInfo(simple)
    local data = {}
    for i = 1, PlayerResource:GetPlayerCount() do
        local pid = i - 1
        if PlayerResource:IsValidPlayerID(pid) then
            local steamId = PlayerResource:GetSteamAccountID(pid)

            if steamId == 0 and PlayerResource:IsFakeClient(pid) then
                steamId = pid
            end
            local heroName = nil
            local hero = PlayerResource:GetSelectedHeroEntity(pid)
            if hero then
                heroName = hero:GetUnitName()
            end
            local team = PlayerResource:GetTeam(pid)
            local playerName = PlayerResource:GetPlayerName(pid)
            local playerInfo = {
                steamId = steamId,
                hero = heroName,
                team = team,
                playername = playerName,
                pid = pid,
                towers = {}
            }
            local pdata = Player:GetPData(pid)
            if pdata then
                playerInfo.income = pdata.income
                playerInfo.lumberWoker = pdata.lumberWoker
                playerInfo.woodCollect = pdata.woodCollect
                playerInfo.creepValue = pdata.creepValue
                playerInfo.kills = pdata.kills
                playerInfo.leakCount = pdata.leakCount
                playerInfo.gold = Player:GetGold(pid)
                playerInfo.food = Player:GetFood(pid)
                playerInfo.maxFood = pdata.maxFood
                playerInfo.wood = Player:GetWood(pid)
                playerInfo.summons = pdata.summons
                playerInfo.abandoned = pdata.abandoned
                playerInfo.abandonedTime = pdata.abandonedTime
                playerInfo.abandonedRound = pdata.abandonedRound
                playerInfo.abandonedReason = pdata.abandonedReason
                playerInfo.kicked = pdata.kicked
                playerInfo.kickedTime = pdata.kickedTime

                playerInfo.laneIndex = pdata.laneIndex

                playerInfo.roundTower = {}
                playerInfo.connectionState = PlayerResource:GetConnectionState(pid)
                playerInfo.cantGetElo = pdata.cantGetElo
            end

            function copyFighterData(fighterData)
                local res = {}
                for key, value in pairs(fighterData) do
                    if value and not isEmptyTable(value) then
                        res[key] = value
                    else
                    end
                end
                --
                return res
            end

            if pdata then
                if pdata.towers then
                    for _, tower in pairs(pdata.towers) do
                        if IsActiveUnit(tower) then
                            local fighter = GamePlay:FighterGetMeta(tower.fighterId)
                            if fighter then
                                local saveData = copyFighterData(fighter)
                                table.insert(playerInfo.towers, saveData)
                            end
                            -- local pos=tower:GetAbsOrigin()
                            -- table.insert(playerInfo.towers, {
                            --     unit = tower:GetUnitName(),
                            --     buildRound = tower.buildRound,
                            --     pos={pos.x,pos.y,pos.z}
                            -- })
                        end
                    end
                end
                if #playerInfo.towers == 0 and pdata.towersList then
                    for _, towerInfo in pairs(pdata.towersList) do
                        local fighter = GamePlay:FighterGetMeta(towerInfo.fighterId)
                        if fighter then
                            local saveData = copyFighterData(fighter)
                            table.insert(playerInfo.towers, saveData)
                        end
                        -- table.insert(playerInfo.towers, {
                        --     unit = towerInfo.unitName,
                        --     buildRound = towerInfo.buildRound,
                        --     pos={towerInfo.pos.x,towerInfo.pos.y,towerInfo.pos.z},
                        -- })
                    end
                end
            end
            table.insert(data, playerInfo)
        end
    end
    return data
end

function Storage:collectGameMode()
    local cheat = GameRules:IsCheatMode() or (Convars:GetInt("dota_legiontd_debug") == 1)
    local res = {
        primaryMode = GamePlay.primaryMode,
        secondaryModes = GamePlay.secondaryModes,
        map = GetMapName(),
        cheat = cheat,
        playerCount = PlayerResource:GetPlayerCount(),
        IsInToolsMode = IsInToolsMode(),
        unconnectedCount = GamePlay.unconnectedCount
    }
    if PlayerResource and PlayerResource.GetPlayerCount then
        res["playerCount"] = PlayerResource:GetPlayerCount()
    end
    return res
end

function Storage:collectGameEvents()
    return {
        -- events = GamePlay.events
    }
end

function Storage:collectRound()
    local round = GamePlay:GetCurrentRoundData()
    if round then
        return round
    end
    return {}
end

function Storage:collectGameInfo()
    local kingGoodHp = 0
    local westKingAbilities = {}
    if GamePlay.kingGood and not GamePlay.kingGood:IsNull() then
        kingGoodHp = GamePlay.kingGood:GetHealth()
        local abilityCount = GamePlay.kingGood:GetAbilityCount() or 0
        for i = 0, abilityCount - 1 do
            local ab = GamePlay.kingGood:GetAbilityByIndex(i)
            if ab then
                table.insert(westKingAbilities, ab:GetAbilityName())
            end
        end
    end
    local kingBadHp = 0
    local eastKingAbilities = {}
    if GamePlay.kingBad and not GamePlay.kingBad:IsNull() then
        kingBadHp = GamePlay.kingBad:GetHealth()
        local abilityCount = GamePlay.kingBad:GetAbilityCount() or 0
        for i = 0, abilityCount - 1 do
            local ab = GamePlay.kingBad:GetAbilityByIndex(i)
            if ab then
                table.insert(eastKingAbilities, ab:GetAbilityName())
            end
        end
    end
    -- local rounds={}
    -- for _, node in ipairs(GamePlay.roundList) do
    --     table.insert(
    --         rounds,{
    --             players=node.players,
    --             name=node.round.name
    --         }
    --     )
    -- end

    -- Collect the precache timing info
    local precacheStats = nil
    if _G.PRECACHE_TIME_STATS then
        precacheStats = {
            total_time = _G.PRECACHE_TIME_STATS.total_time,
            phases = {}
        }
        -- Copy the phase info
        for _, phase in ipairs(_G.PRECACHE_TIME_STATS.phases) do
            table.insert(precacheStats.phases, {
                name = phase.name,
                cost = phase.cost,
                count = phase.count
            })
        end
    end

    return {
        round = GamePlay.round,
        kingGoodHp = kingGoodHp,
        kingBadHp = kingBadHp,
        version = LEGIONTD_VERSION,
        releaseVersion = LEGIONTD_VERSION_RELEASE_VERSION,
        -- rounds=rounds,
        westKingAbilities = westKingAbilities,
        eastKingAbilities = eastKingAbilities,
        state = GamePlay.state,
        precache = precacheStats
    }
end

function Storage:MatchStart()
    if not Storage:IsServerAvailable() then
        return
    end
    local data = {}
    data.match_id = Storage:collectGameId()
    data.players = Storage:collectPlayerInfo()
    data.gamemode = Storage:collectGameMode()
    data.version = LEGIONTD_VERSION_RELEASE_VERSION
    Storage:Http("/api/legiontd/match_start", data, function(code, data)
    end)
end

function Storage:PlayerInfo(cb)
    if not Storage:IsServerAvailable() then
        return
    end
    local data = {}
    data.match_id = Storage:collectGameId()
    data.players = Storage:collectPlayerInfo()
    -- data.gamemode = Storage:collectGameMode()
    data.version = LEGIONTD_VERSION_RELEASE_VERSION
    Storage:Http("/api/legiontd/player_info", data, function(code, data, rawBody)
        if cb then
            cb(code, data, rawBody)
        end
    end)
end

-- Storage:MatchStart()
function Storage:MatchEnd(winnerTeam, cb)
    if not Storage:IsServerAvailable() then
        return
    end
    local data = {}
    data.match_id = Storage:collectGameId()
    data.cost_game_time = math.floor(GameRules:GetGameTime() * 1000)
    data.hp_remain = 0
    -- data.game_info = Storage:collectGameInfo()
    data.game_result = {
        winnerTeam = winnerTeam
    }
    data.version = LEGIONTD_VERSION_RELEASE_VERSION
    -- data.players = Storage:collectPlayerInfo()
    Storage:Http("/api/legiontd/match_end", data, function(code, data, rawBody)
        if cb then
            cb(code, data, rawBody)
        end
    end)
end

-- Storage:MatchEnd(false)
function Storage:MatchUpdate(type)
    if not Storage:IsServerAvailable() then
        -- With no storage server, still clear the event cache so it cannot grow forever
        GamePlay.events = {}
        return
    end
    local data = {}
    data.match_id = Storage:collectGameId()
    data.players = Storage:collectPlayerInfo()
    data.gamemode = Storage:collectGameMode()
    data.game_info = Storage:collectGameInfo()
    data.events = Storage:collectGameEvents()
    data.round = Storage:collectRound()
    data.type = type
    data.version = LEGIONTD_VERSION_RELEASE_VERSION
    GamePlay.events = {}
    Storage:Http("/api/legiontd/match_update", data, function(code, data)
    end)
end

-- Report the duel result
function Storage:DuelResult(duelWinner, goodPlayerCount, badPlayerCount, round)
    if not Storage:IsServerAvailable() then
        return
    end
    local data = {}
    data.match_id = Storage:collectGameId()
    data.duel_winner = duelWinner  -- winning team (DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS, or 0 for a draw)
    data.good_player_count = goodPlayerCount  -- west side players who were not kicked
    data.bad_player_count = badPlayerCount    -- east side players who were not kicked
    data.round = round  -- round number
    data.version = LEGIONTD_VERSION_RELEASE_VERSION
    Storage:Http("/api/legiontd/duel_result", data, function(code, data)
        if code == 200 then
            print("[DuelResult] Successfully reported duel result for round " .. round)
        else
            print("[DuelResult] Failed to report duel result, status code: " .. code)
        end
    end)
end

function Storage:LoadAbilityTestList(params,cb)
    if not Storage:IsServerAvailable() then
        return
    end
    local data = {}
    data.match_id = Storage:collectGameId()
    data.version = LEGIONTD_VERSION_RELEASE_VERSION
    data.desc=params.desc
    Storage:Http("/api/load_ability_test", data, function(code, d, rawBody)
        if cb then
            cb(code, d.data, rawBody)
        end
    end)
end

function Storage:AbilityTestStart(name, cb)
    if not Storage:IsServerAvailable() then
        return
    end
    local data = {}
    data.match_id = Storage:collectGameId()
    data.version = LEGIONTD_VERSION_RELEASE_VERSION
    data.name = name
    Storage:Http("/api/ability_test_start", data, function(code, d, rawBody)
        if cb then
            cb(code, d.data, rawBody)
        end
    end)
end


function Storage:AbilityTestEnd(name, isCancel, cb)
    if not Storage:IsServerAvailable() then
        return
    end
    local data = {}
    data.match_id = Storage:collectGameId()
    data.version = LEGIONTD_VERSION_RELEASE_VERSION
    data.name = name
    if isCancel then
        data.isCancel = 1
    end
    Storage:Http("/api/ability_test_end", data, function(code, d, rawBody)
        if cb then
            cb(code, d.data, rawBody)
        end
    end)
end

-- Storage:MatchUpdate()

function Storage:GetLeaderboard(steamid, season, cb)
    if not Storage:IsServerAvailable() then
        return
    end
    local data = {}
    data.steamid = steamid
    data.version = LEGIONTD_VERSION_RELEASE_VERSION
    data.season = season

    Storage:Http("/api/legiontd/leaderboard", data, function(code, data, rawBody)
        if cb then
            cb(code, data, rawBody)
        end
    end)
end

function Storage:GetProfile(steamid, cb)
    if not Storage:IsServerAvailable() then
        return
    end
    local data = {}
    data.steamid = steamid
    data.version = LEGIONTD_VERSION_RELEASE_VERSION

    Storage:Http("/api/legiontd/profile", data, function(code, data, rawBody)
        if cb then
            cb(code, data, rawBody)
        end
    end)
end

function Storage:LoadMatches(steamid, page, cb)
    if not Storage:IsServerAvailable() then
        return
    end
    local data = {}
    data.steamid = steamid
    data.version = LEGIONTD_VERSION_RELEASE_VERSION
    data.page = page
    Storage:Http("/api/legiontd/match_list", data, function(code, data, rawBody)
        if cb then
            cb(code, data, rawBody)
        end
    end)
end

if not Storage.inited then
    Storage:Init()
else
    Storage:OnScriptReload()
end
