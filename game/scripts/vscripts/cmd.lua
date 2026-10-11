if not Cmd then
    Cmd = class({})
end

-- Constants
local MAX_WAVE_COUNT = 33
local DEBUG_COLOR_TAG = "<font color='#FC270C'>[Debug]</font>"
local DUMP_COLOR_TAG = "<font color='#00D4FF'>[Dump]</font>"

-- Fight test globals
FightTest = FightTest or {
    active = false,
    teamA = {},
    teamB = {},
    timer = nil,
    startTime = 0,
    creepAName = "",
    creepBName = "",
    initialCountA = 0,
    initialCountB = 0
}

-- Attack type and armor type enums
local ATTACK_TYPES = { "normal", "pierce", "siege", "magic", "chaos", "hero" }
local ARMOR_TYPES = { "light", "medium", "heavy", "fortified", "unarmored", "hero" }

-- Helper: query waves by condition
function Cmd:queryWavesByCondition(playerID, filterFunc)
    local waves = GamePlay.metaKv.waves
    for i = 1, MAX_WAVE_COUNT, 1 do
        local wave = waves[tostring(i)]
        if wave and filterFunc(wave) then
            local rindex = GamePlay:getRoundByName(wave.name)
            GamePlay:notifyRoundInfo(playerID, rindex)
        end
    end
end

-- Helper: heal the king
function Cmd:healKing(king, notifyMessage)
    if not IsActiveUnit(king) then
        return
    end

    local heal = 30000
    king:Heal(heal, king)
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, king, heal, nil)
    EmitSoundOn("Hero_Omniknight.Purification", king)
    local fx = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_omniknight/omniknight_purification.vpcf",
        PATTACH_CUSTOMORIGIN_FOLLOW, king)
    ParticleManager:SetParticleControl(fx, 0, king:GetAbsOrigin())
    ParticleManager:SetParticleControl(fx, 1, Vector(200, 200, 200))
    ParticleManager:ReleaseParticleIndex(fx)

    if notifyMessage then
        fireLeftNotify(nil, false, DEBUG_COLOR_TAG .. " " .. notifyMessage, {
            rawText = true
        })
    end
end

-- Helper: send a debug notification
function Cmd:sendDebugNotify(message, params)
    params = params or {}
    params.rawText = true
    fireLeftNotify(nil, false, DEBUG_COLOR_TAG .. " " .. message, params)
end

-- Helper: parse the command arguments
function Cmd:parseCommand(text)
    local tokens = mysplit(text, " ")
    local command = tokens[1] or ""
    return command, tokens
end

function Cmd:parseCallArg(value)
    if value == "true" then
        return true
    end
    if value == "false" then
        return false
    end
    if value == "nil" or value == "null" then
        return nil
    end

    local num = tonumber(value)
    if num ~= nil then
        return num
    end

    return value
end

function Cmd:handleGamePlayCallCommand(text, playerID, tokens)
    if not startWith(text, "-call ") then
        return false
    end

    if not IsInToolsMode() or Convars:GetInt("dota_legiontd_debug") ~= 1 then
        Cmd:sendDebugNotify("-call requires tools mode and dota_legiontd_debug 1")
        return true
    end

    local methodName = tokens[2]
    if not methodName or methodName == "" then
        Cmd:sendDebugNotify("usage: -call FunctionName [args...]")
        return true
    end

    local method = GamePlay[methodName]
    if type(method) ~= "function" then
        Cmd:sendDebugNotify("GamePlay:" .. methodName .. " is not a function")
        return true
    end

    local args = {}
    local argCount = 0
    for i = 3, #tokens do
        argCount = argCount + 1
        args[argCount] = Cmd:parseCallArg(tokens[i])
    end

    print("[Debug] -call GamePlay:" .. methodName)
    local ok, result = xpcall(function()
        return method(GamePlay, unpack(args, 1, argCount))
    end, debug.traceback)

    if ok then
        Cmd:sendDebugNotify("called GamePlay:" .. methodName)
        if result ~= nil then
            print("[Debug] -call result:", result)
        end
    else
        Cmd:sendDebugNotify("GamePlay:" .. methodName .. " failed, check console")
        print("[Debug] -call failed:", result)
    end

    return true
end

function Cmd:Init()
    ListenToGameEvent("player_chat", Dynamic_Wrap(Cmd, 'OnPlayerChat'), self)
end

function Cmd:OnPlayerChat(keys)
    local team_only = keys.teamonly
    local userID = keys.userid
    local playerID = keys.playerid
    local text = keys.text

    local pdata = Player:GetPData(playerID)

    if pdata then
        if (not pdata.kicked or IsInToolsMode()) then
            Timers:CreateTimer(FrameTime(), function()
                Cmd:ProcessCommand(playerID, text)
            end)
        else
            SendErrorMessage(playerID, "error_illegal_operation")
        end
    end
end

function Cmd:ProcessCommand(playerID, text)
    -- Split once here so the handlers can reuse the tokens
    local tokens = mysplit(text, " ")
    local command = tokens[1] or ""

    Cmd:handleNormalCommands(text, playerID, tokens)

    if Cmd:IsDebugEnabled() then
        Cmd:handleDebugCommands(text, playerID, tokens)
        Cmd:handleDevCommands(text, playerID, tokens)
    end
end

function Cmd:IsDebugEnabled()
    return Convars:GetInt("dota_legiontd_debug") == 1 or IsInToolsMode()
end

function Cmd:handleNormalCommands(text, playerID, tokens)
    -- the tokens were already split in ProcessCommand

    if startWith(text, "-info ") then
        if #tokens >= 2 then
            local wave = (tokens[2] + 0)
            if wave ~= nil and wave > 0 and wave <= 31 then
                if wave > 20 then
                    wave = wave + 2
                elseif wave > 10 then
                    wave = wave + 1
                end
                GamePlay:notifyRoundInfo(playerID, wave)
            end
        end
    end

    if text == "-next" then
        if GamePlay.round then
            local roundIndex = GamePlay.round
            if GamePlay.state == "in-round" then
                roundIndex = roundIndex + 1
            end
            GamePlay:notifyRoundInfo(playerID, roundIndex)
        end
    end

    if text == "-king" then
        GamePlay:tryControlKing(playerID)
    end

    if text == "-air" then
        Cmd:queryWavesByCondition(playerID, function(wave)
            return wave.MovementCapabilities == "DOTA_UNIT_CAP_MOVE_FLY"
        end)
    end

    if text == "-range" then
        Cmd:queryWavesByCondition(playerID, function(wave)
            return wave.AttackCapabilities == "DOTA_UNIT_CAP_RANGED_ATTACK"
        end)
    end

    if text == "-boss" then
        Cmd:queryWavesByCondition(playerID, function(wave)
            return wave.isBoss == 1
        end)
    end

    -- Attack types come from the constants above
    for index, attackType in ipairs(ATTACK_TYPES) do
        if text == "-" .. attackType then
            Cmd:queryWavesByCondition(playerID, function(wave)
                return wave.AttackType == "attack_" .. attackType
            end)
        end
    end

    -- Armor types come from the constants above
    for index, armorType in ipairs(ARMOR_TYPES) do
        if text == "-" .. armorType then
            Cmd:queryWavesByCondition(playerID, function(wave)
                return wave.ArmorType == "armor_" .. armorType
            end)
        end
    end

    if text == "-help" then
        batchFireLeftNotify(playerID, true, "notify_legiontd_help", {}, 6)
    end

    -- if text == "-cheatcodes" then
    --     batchFireLeftNotify(playerID, true, "notify_legiontd_cheatlist", {}, 10)
    -- end

    if text == "-tp" then
        GamePlay:tryTp(playerID)
    end

    if startWith(text, "-kick ") then
        if #tokens >= 2 then
            local pid = (tokens[2] + 0)
            GamePlay:tryKick(playerID, pid)
        end
    end

    if startWith(text, "-zoom ") then
        if #tokens >= 2 then
            local zoom = (tokens[2] + 0)
            zoom = math.max(50, zoom)
            zoom = math.min(450, zoom)
            local player = PlayerResource:GetPlayer(playerID)
            if player then
                CustomGameEventManager:Send_ServerToPlayer(player, "player_camera_zoom", { zoom = zoom })
            end
        end
    end

    if startWith(text, "-votekick ") then
        if #tokens >= 2 then
            local pid = (tokens[2] + 0)
            GamePlay:tryVoteKick(playerID, pid)
        end
    end


    if text == "-debug" then
        if GamePlay:Mode("single_team") or GameRules:IsCheatMode() then
            Convars:SetInt("dota_legiontd_debug", 1)
            fireLeftNotify(nil, false, "notify_debug_mode_enabled", {})
            fireLeftNotify(nil, false, "notify_debug_mode_enabled_1", {})
            fireLeftNotify(nil, false, "notify_debug_mode_enabled_2", {})

            CustomNetTables:SetTableValue("dev", "dota_legiontd_debug", {
                value = Convars:GetInt("dota_legiontd_debug")
            })
        end
    end

    if startWith(text, "-debug ") then
        if GamePlay:Mode("single_team") or GameRules:IsCheatMode() then
            if #tokens >= 2 then
                local value = tonumber((tokens[2]))
                if value == 1 then
                    fireLeftNotify(nil, false, "notify_debug_mode_enabled", {})
                    fireLeftNotify(nil, false, "notify_debug_mode_enabled_1", {})
                    fireLeftNotify(nil, false, "notify_debug_mode_enabled_2", {})
                end
                Convars:SetInt("dota_legiontd_debug", value)

                CustomNetTables:SetTableValue("dev", "dota_legiontd_debug", {
                    value = Convars:GetInt("dota_legiontd_debug")
                })
            end
        end
    end
end

function Cmd:handleDebugCommands(text, playerID, tokens)
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    -- the tokens were already split in ProcessCommand

    if Cmd:handleGamePlayCallCommand(text, playerID, tokens) then
        return
    end

    if startWith(text, "-fast ") then
        local p1 = tonumber((tokens[2]))
        GameRules.fastRound = (p1 ~= 0)
        Notifications:NotifyMessage(0, "fast " .. tostring(GameRules.fastRound), {})
        Convars:SetInt("dota_legiontd_fast_round", (tonumber(tokens[2])))
    end

    if tokens[1] == "-start" then
        if GamePlay.state == "pre-round" then
            Convars:SetInt("dota_legiontd_paused", 0)
            GamePlay.directStart = true
        end
    end

    if text == "-pause" or text == "-p" then
        Convars:SetInt("dota_legiontd_paused", 1)
        fireLeftNotify(nil, false, "<font color='#FC270C'>[Debug]</font> Round paused", {
            rawText = true
        })
    end

    if text == "-resume" then
        Convars:SetInt("dota_legiontd_paused", 0)
        fireLeftNotify(nil, false, "<font color='#FC270C'>[Debug]</font> Round resumed", {
            rawText = true
        })
    end


    if startWith(text, "-gold") then
        if #tokens == 2 then
            local gold = (tokens[2] or 1) + 0
            Player:ModifyGold(playerID, gold - Player:GetGold(playerID))
            Cmd:sendDebugNotify("gold is set to {d:int_value}", { int1 = gold })
        end
    end

    if startWith(text, "-lumber") then
        if #tokens == 2 then
            local lumber = (tokens[2] or 1) + 0
            Player:ModifyWood(playerID, lumber - Player:GetWood(playerID))
            Cmd:sendDebugNotify("lumber is set to {d:int_value}", { int1 = lumber })
        end
    end

    if startWith(text, "-food") then
        if #tokens == 2 then
            local food = (tokens[2] or 1) + 0
            local pdata = Player:GetPData(playerID)
            local pop = pdata.maxFood - pdata.food
            pdata.maxFood = math.max(0, food)
            pdata.food = pdata.maxFood - pop
            Cmd:sendDebugNotify("food is set to {d:int_value}", { int1 = food })
        end
    end

    if startWith(text, "-income") then
        if #tokens == 2 then
            local income = (tokens[2] or 1) + 0
            Player:ModifyIncome(playerID, income - Player:GetIncome(playerID))
            Cmd:sendDebugNotify("income is set to {d:int_value}", { int1 = income })
        end
    end

    if text == "-buildall" then
        GamePlay.buildallEnabled = true
        Cmd:sendDebugNotify("You can now build in other players'areas")
    end

    if text == "-clear" or text == "-c" then
        for laneIndex, laneData in pairs(GamePlay.laneTable) do
            for _, unit in ipairs(laneData.roundUnits) do
                if IsActiveUnit(unit) then
                    unit:ForceKill(false)
                end
            end
        end

        local round = roundInfo[GamePlay.round]
        if round and isTrue(round.duel) then
            for index, pid in ipairs(Player:Ids()) do
                local pdata = Player:GetPData(pid)
                if PlayerResource:GetTeam(pid) ~= PlayerResource:GetTeam(playerID) then
                    for _, unit in ipairs(pdata.creeps) do
                        unit:ForceKill(false)
                    end
                    pdata.creeps = {}
                end
            end
            if PlayerResource:GetTeam(playerID) == DOTA_TEAM_GOODGUYS then
                for _, unit in ipairs(GamePlay.roundBadCreeps) do
                    unit:ForceKill(false)
                end
                GamePlay.roundBadCreeps = {}
            else
                for _, unit in ipairs(GamePlay.roundGoodCreeps) do
                    unit:ForceKill(false)
                end
                GamePlay.roundGoodCreeps = {}
            end
        end
        Cmd:sendDebugNotify("All enemies are cleared")
    end

    if text == "-heal" then
        local teams = { DOTA_TEAM_BADGUYS, DOTA_TEAM_GOODGUYS }
        for _, team in ipairs(teams) do
            local king = GamePlay:GetKing(team)
            Cmd:healKing(king, nil)
        end
        Cmd:sendDebugNotify("All kings are healed")
    end

    if text == "-healw" then
        local king = GamePlay:GetKing(DOTA_TEAM_GOODGUYS)
        Cmd:healKing(king, "West king are healed")
    end

    if text == "-heale" then
        local king = GamePlay:GetKing(DOTA_TEAM_BADGUYS)
        Cmd:healKing(king, "East king are healed")
    end

    if startWith(text, "-endscreen") then
        local param = tokens[2] or "1"

        if param == "0" or param == "close" or param == "hide" then
            -- Hide the end screen
            CustomGameEventManager:Send_ServerToAllClients("show_end_screen", {
                show = 0
            })
            fireLeftNotify(nil, false, "<font color='#FC270C'>[Debug]</font> End screen hidden", {
                rawText = true
            })
        else
            -- Show the end screen (for testing)
            CustomGameEventManager:Send_ServerToAllClients("show_end_screen", {
                winTeam = DOTA_TEAM_GOODGUYS,
                show = 1
            })
            fireLeftNotify(nil, false, "<font color='#FC270C'>[Debug]</font> End screen displayed", {
                rawText = true
            })
        end
    end

    if text == "-clearw" then
        for laneIndex, laneData in pairs(GamePlay.laneTable) do
            if laneIndex < 4 then
                for _, unit in ipairs(laneData.roundUnits) do
                    unit:ForceKill(true)
                end
            end
        end
        Cmd:sendDebugNotify("West enemies are cleared")
    end

    if text == "-cleare" then
        for laneIndex, laneData in pairs(GamePlay.laneTable) do
            if laneIndex >= 4 then
                for _, unit in ipairs(laneData.roundUnits) do
                    unit:ForceKill(true)
                end
            end
        end
        Cmd:sendDebugNotify("East enemies are cleared")
    end

    if startWith(text, "-round ") then
        local round = (tokens[2] + 0)
        local roundName = round
        if not round then
            return
        end

        if GamePlay.state == "pre-round" then
            round = GamePlay:getRoundByName(round)
            Cmd:sendDebugNotify("Next round is set to {d:int_value}", { int1 = roundName })
            GamePlay.round = round
            GamePlay:doRoundPre()
            GamePlay:SyncNetTable()
            Storage:MatchUpdate()
        end
    end

    if startWith(text, "-abil ") then
        if #tokens == 2 then
            local abiIndex = tonumber(tokens[2] + 0)
            local map = { 4, 15, 20, 26 }
            if map[abiIndex] then
                Cmd:sendDebugNotify("Added a new ability to king")
                GamePlay:updateKingAbility(map[abiIndex])
            end
        end
    end

    if startWith(text, "-duel ") then
        local duel = (tokens[2] + 0)
        local round = nil

        if duel == 1 then
            round = 11
        elseif duel == 2 then
            round = 22
        elseif duel == 3 then
            round = 33
        end

        if not round then
            return
        end

        if round > 0 then
            GamePlay.round = round
        end

        Cmd:sendDebugNotify("Next round is set to duel {d:int_value}", { int1 = duel })

        GamePlay:doRoundPre()
    end

    if startWith(text, "-builder") then
        if #tokens == 1 then
            GamePlay:newHeroChoose(playerID, "all")
        else
            local pid = tonumber(tokens[2])
            GamePlay:newHeroChoose(pid, "all")
        end
    end

    if text == "-prophetpool" then
        local resetCount = GamePlay:RegenerateProphetPoolsAndResetHeroes()
        Cmd:sendDebugNotify("Prophet pools regenerated for {d:int_value} players", { int1 = resetCount })
    end

    if text == "-repick" then
        GamePlay:newHeroChoose(playerID, "all")
        Cmd:sendDebugNotify("Choose a new builder")
    end

    if text == "-whosyourdaddy" then
        GamePlay.whosyourdaddy = true
    end

    if startWith(text, "-whosyourdaddy ") then
        if #tokens >= 2 then
            GamePlay.whosyourdaddy = (tokens[2] == "1")
        end
    end

    if text == "-kingmax" then
        for _, tid in pairs({ 2, 3 }) do
            local tdata = GamePlay:GetTData(tid)
            local king = tdata.king
            king:AddNewModifier(king, nil, "modifier_king_regeneration", {})
            local mod = king:FindModifierByName("modifier_king_regeneration")
            mod:SetStackCount(20)

            king:AddNewModifier(king, nil, "modifier_king_attack", {})
            local mod1 = king:FindModifierByName("modifier_king_attack")
            mod1:SetStackCount(30)

            king:AddNewModifier(king, nil, "modifier_king_hit_points", {})
            local mod2 = king:FindModifierByName("modifier_king_hit_points")
            mod2:SetStackCount(20)
            king:SetBaseMaxHealth(100000)
            king:SetMaxHealth(100000)
            king:Heal(100000, king)
        end
        Notifications:NotifyMessage(0, "kingmax", {})
    end

    if startWith(text, "-westwin") then
        local tdata = GamePlay:GetTData(3)
        local king = tdata.king

        if IsActiveUnit(king) then
            for k, pid in pairs(Player:Ids()) do
                local pdata = Player:GetPData(pid)
                if pdata and pdata.team == DOTA_TEAM_GOODGUYS then
                    local hero = PlayerResource:GetSelectedHeroEntity(pid)
                    if hero and IsActiveUnit(hero) then
                        king:Kill(nil, hero)
                    end
                end
            end
        end
    end

    if startWith(text, "-eastwin") then
        local tdata = GamePlay:GetTData(2)
        local king = tdata.king
        if IsActiveUnit(king) then
            for k, pid in pairs(Player:Ids()) do
                local pdata = Player:GetPData(pid)
                if pdata and pdata.team == DOTA_TEAM_BADGUYS then
                    local hero = PlayerResource:GetSelectedHeroEntity(pid)
                    if hero and IsActiveUnit(hero) then
                        king:Kill(nil, hero)
                    end
                end
            end
        end
    end

    if startWith(text, "-end ") then
        if #tokens >= 2 then
            local winTeam = tonumber(tokens[2])
            if winTeam == 2 or winTeam == 3 then
                -- Clear game_end_result
                CustomNetTables:SetTableValue("game_end_result", "value", {})
                GamePlay:DoGameEnd(winTeam)
                Cmd:sendDebugNotify("Game ended, team {d:int_value} wins", { int1 = winTeam })
            else
                Cmd:sendDebugNotify("Team must be 2 (west) or 3 (east)")
            end
        end
    end

    if startWith(text, "-s ") then
        if #tokens >= 2 then
            local scale = tonumber(tokens[2])
            if scale and scale > 0 then
                if HeroDemo.selectedUnits and #HeroDemo.selectedUnits > 0 then
                    local unit = HeroDemo.selectedUnits[1]
                    unit:SetModelScale(scale)
                    Cmd:sendDebugNotify("Model scale is set to {d:float_value}", { float1 = scale })
                else
                    Cmd:sendDebugNotify("No valid unit selected")
                end
            else
                Cmd:sendDebugNotify("Invalid scale value, must be a positive number")
            end
        end
    end
end

function Cmd:handleDevCommands(text, playerID, tokens)
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    -- the tokens were already split in ProcessCommand

    if text == "-send_self" then
        if Convars:GetInt("dota_legiontd_send_to_self") == 1 then
            Convars:SetInt("dota_legiontd_send_to_self", 0)
        else
            Convars:SetInt("dota_legiontd_send_to_self", 1)
        end
        fireLeftNotify(nil, false, "notify_debug_toggle",
            { int1 = Convars:GetInt("dota_legiontd_send_to_self"), str1 = "send_self" })
    end

    if text == "-send_free" then
        if Convars:GetInt("dota_legiontd_send_free") == 1 then
            Convars:SetInt("dota_legiontd_send_free", 0)
        else
            Convars:SetInt("dota_legiontd_send_free", 1)
        end
        GamePlay:updateBuildingAbility()
        fireLeftNotify(nil, false, "notify_debug_toggle",
            { int1 = Convars:GetInt("dota_legiontd_send_free"), str1 = "send_free" })
    end

    if startWith(text, "-send ") then
        local unitName = tokens[2]

        for k, pid in pairs(Player:Ids()) do
            local pdata = Player:GetPData(pid)

            if not pdata.disableSpawnWave then
                local creep = GamePlay:spawnBarrackUnit(pid, unitName)
                creep.sendToSelf = true
            end
        end
    end

    if text == "-r" then
        print("reload script")
        Timers:CreateTimer(0.1, function()
            SendToServerConsole("script_reload")
        end)
        Timers:CreateTimer(0.2, function()
            SendToServerConsole("cl_script_reload")
        end)
    end

    if text == "-rkv" then
        print("reload kv")
        GameRules:Playtesting_UpdateAddOnKeyValues()
    end

    if startWith(text, "-greedisgood") then
        local gold = (tokens[2] or 1) + 0
        local wood = (tokens[3] or 1) + 0
        local food = (tokens[4] or 1) + 0

        Player:ModifyGold(playerID, gold)
        Player:ModifyWood(playerID, wood)
        Player:AddFood(playerID, food)
    end

    if startWith(text, "-forcekick ") then
        if #tokens >= 2 then
            local pid = (tokens[2] + 0)
            GamePlay:forceKick(playerID, pid)
        end
    end

    if text == "-killcreep" then
        for k, pid in pairs(Player:Ids()) do
            local pdata = Player:GetPData(pid)
            local c = 0
            while #pdata.creeps > 0 do
                pdata.creeps[1]:ForceKill(false)
                c = c + 1
                if c > 1000 then
                    break
                end
            end
        end
    end

    if startWith(text, "-abandon ") then
        if #tokens >= 2 then
            local pid = (tokens[2] + 0)
            Player:directAbandon(pid)
        end
    end

    if startWith(text, "-act ") then
        if #tokens >= 2 then
            local act = (tokens[2])
            for _, unit in ipairs(HeroDemo.selectedUnits) do
                unit:StartGesture(loadstring("return " .. act)())
            end
        end
    end

    if startWith(text, "-sound ") then
        if #tokens >= 2 then
            local sound = (tokens[2])
            for _, unit in ipairs(HeroDemo.selectedUnits) do
                EmitSoundOn(sound, unit)
            end
        end
    end

    if tokens[1] == "-playerid" then
        local steamId = PlayerResource:GetSteamAccountID(0)
        print("steamid", steamId)
        Say(PlayerResource:GetSelectedHeroEntity(0), "steamid " .. steamId, true)
    end

    if tokens[1] == "-gohome" then
        local pids = {}
        if tokens[2] == "all" then
            pids = Player.ids
        elseif tokens[2] == nil then
            pids = { 0 }
        else
            pids = { tonumber(tokens[2]) }
        end
        for index, pid in ipairs(pids) do
            local hero = PlayerResource:GetSelectedHeroEntity(pid)
            GamePlay:teleportToHome(hero, "")
        end
    end

    if tokens[1] == "-add" then
        Cmd:sendDebugNotify("Usage: -add [player id|all] [unit name] [count (optional)]")

        local pids = {}
        if tokens[2] and tokens[3] then
        else
            SendErrorMessage(playerID, "no params")
            return
        end
        if tokens[2] == "all" then
            pids = Player:Ids()
        else
            pids = { tonumber(tokens[2]) }
        end
        local c = tonumber(tokens[4]) or 1
        local name = tokens[3]
        local unitName, unitKv = findUnitByNpcName(name)

        local totalPlaced = 0
        for _, pid in ipairs(pids) do
            local hero = PlayerResource:GetSelectedHeroEntity(pid)
            local p1 = hero:GetAbsOrigin()
            p1.x = 64 * (math.floor(p1.x / 64))
            p1.y = 64 * (math.floor(p1.y / 64))
            local pdata = Player:GetPData(pid)
            local homePos = GamePlay:getHomePos(pid)
            local yv = 1
            if homePos.y < 0 then
                yv = -1
            end
            local posList = {}
            for index = 0, 100, 1 do
                local i = index % (10)
                local j = math.floor(index / (10))
                local pos = Vector(p1.x + 128 * i, p1.y + yv * 128 * j, p1.z)
                local gridNav = GridNav:FindPathLength(pos, pos)
                if gridNav > 1 then
                    table.insert(posList, pos)
                end
            end
            local placedCount = 0
            for i = 1, c do
                if #posList > 0 then
                    local pos = table.remove(posList, 1)
                    local newBuilding = BuildingHelper:PlaceBuilding(pid, unitName, pos, nil, nil, nil, pdata.team)
                    newBuilding.gold = unitKv.creepValue
                    newBuilding.food = unitKv.creepFood
                    newBuilding.wood = 0
                    GamePlay:OnConstructionStarted(newBuilding)
                    placedCount = placedCount + 1
                end
            end
            totalPlaced = totalPlaced + placedCount
            Player:UpdateCreepValue(pid)
        end
    end

    if startWith(text, "-ptest") then
        local count = tonumber(tokens[2]) or 15  -- 15 by default

        Cmd:sendDebugNotify(string.format("Usage: -ptest [count] (random units for every player, 15 by default) | current: %d", count))

        local allUnitsInfo = GamePlay:DumpAllUnitsInfo()
        local units = {}

        for key, _ in pairs(allUnitsInfo) do
            for _, unitName in ipairs(allUnitsInfo[key]) do
                table.insert(units, unitName)
            end
        end

        -- Work out a reasonable row/column layout
        local cols = math.ceil(math.sqrt(count))
        local rows = math.ceil(count / cols)

        local playerCount = 0
        local totalPlaced = 0
        for _, pid in pairs(Player:Ids()) do
            local hero = PlayerResource:GetSelectedHeroEntity(pid)
            local p1 = hero:GetAbsOrigin()
            local pdata = Player:GetPData(pid)

            local unitIndex = 0
            for i = 1, rows do
                for j = 1, cols do
                    if unitIndex < count then
                        local unitName = units[RandomInt(1, #units)]
                        local pos = Vector(p1.x + 100 * (j - math.ceil(cols/2)), p1.y + 100 * (i - math.ceil(rows/2)), p1.z)
                        local newBuilding = BuildingHelper:PlaceBuilding(pid, unitName, pos, nil, nil, nil, pdata.team)
                        newBuilding.gold = 100
                        newBuilding.food = 1
                        newBuilding.wood = 0
                        GamePlay:OnConstructionStarted(newBuilding)
                        unitIndex = unitIndex + 1
                        totalPlaced = totalPlaced + 1
                    end
                end
            end
            playerCount = playerCount + 1
        end

        Cmd:sendDebugNotify(string.format("Placed %d units for each of %d players, %d in total!", playerCount, count, totalPlaced))
    end

    if startWith(text, "-lc_add ") then
        print("========================================")
        print("[lc_add] command start")
        print("[lc_add] player id:", playerID)
        print("[lc_add] raw command:", text)

        if #tokens < 2 then
            print("[lc_add] error: not enough arguments")
            Cmd:sendDebugNotify("Usage: -lc_add [unit name] [count (optional, 1 by default)]")
            return
        end

        local name = tokens[2]
        local count = tonumber(tokens[3]) or 1
        print(string.format("[lc_add] parsed args - unit: %s, count: %d", name, count))

        local unitName, unitKv = findUnitByNpcName(name)

        if not unitName or not unitKv then
            print("[lc_add] error: unit not found: " .. name)
            Cmd:sendDebugNotify("Error: unit not found: " .. name)
            return
        end

        print("[lc_add] unit resolved:", unitName)
        print("[lc_add] unit values - creepValue:", unitKv.creepValue, "creepFood:", unitKv.creepFood)

        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
        if not hero then
            print("[lc_add] error: player hero not found")
            Cmd:sendDebugNotify("Error: your hero was not found")
            return
        end

        local p1 = hero:GetAbsOrigin()
        print(string.format("[lc_add] hero position: (%.2f, %.2f, %.2f)", p1.x, p1.y, p1.z))

        p1.x = 64 * (math.floor(p1.x / 64))
        p1.y = 64 * (math.floor(p1.y / 64))
        print(string.format("[lc_add] snapped position: (%.2f, %.2f, %.2f)", p1.x, p1.y, p1.z))

        local pdata = Player:GetPData(playerID)
        local homePos = GamePlay:getHomePos(playerID)
        local yv = 1
        if homePos.y < 0 then
            yv = -1
        end
        print("[lc_add] Y direction:", yv)

        print("[lc_add] placing units...")

        -- Work out a reasonable row/column layout
        local cols = math.ceil(math.sqrt(count))
        local rows = math.ceil(count / cols)
        print(string.format("[lc_add] layout: %d rows x %d columns", rows, cols))

        local placedCount = 0
        local unitIndex = 0
        for i = 1, rows do
            for j = 1, cols do
                if unitIndex < count then
                    local offsetX = (j - math.ceil(cols/2)) * 128
                    local offsetY = yv * (i - 1) * 128
                    local pos = Vector(p1.x + offsetX, p1.y + offsetY, p1.z)

                    print(string.format("[lc_add] placing unit %d/%d at (%.2f, %.2f, %.2f)", unitIndex + 1, count, pos.x, pos.y, pos.z))

                    local newBuilding = BuildingHelper:PlaceBuilding(playerID, unitName, pos, nil, nil, nil, pdata.team)
                    newBuilding.gold = unitKv.creepValue
                    newBuilding.food = unitKv.creepFood
                    newBuilding.wood = 0
                    GamePlay:OnConstructionStarted(newBuilding)
                    placedCount = placedCount + 1
                    unitIndex = unitIndex + 1

                    print(string.format("[lc_add] unit placed - EntIndex: %d", newBuilding:entindex()))
                end
            end
        end

        Player:UpdateCreepValue(playerID)
        print(string.format("[lc_add] done - %d units placed", placedCount))
        print("========================================")

        Cmd:sendDebugNotify(string.format("Placed %d x %s for you!", placedCount, name))
    end

    if text == "-pclear" then
        GamePlay.fighterMap = {}
        if GamePlay.state ~= "in-round" then
            for _, pid in pairs(Player:Ids()) do
                local hero = PlayerResource:GetSelectedHeroEntity(pid)
                local p1 = hero:GetAbsOrigin()
                local pdata = Player:GetPData(pid)

                local towerList = {}
                for _, tower in ipairs(pdata.towers) do
                    table.insert(towerList, tower)
                end
                for _, tower in ipairs(towerList) do
                    if IsActiveUnit(tower) then
                        local ab = tower:FindAbilityByName("sell_building")
                        if ab then
                            tower:CastAbilityNoTarget(ab, tower:GetPlayerOwnerID())
                        else
                            tower:RemoveModifierByName("modifier_building")
                            tower:Kill(nil, hero)
                        end
                    end
                end
            end
        end
    end

    if tokens[1] == "-unit" then
        local unitName = (tokens[2]) or "npc_dota_creep_goodguys_melee"
        local unitCount = tonumber(tokens[3]) or 1
        local hero = PlayerResource:GetSelectedHeroEntity(0)

        if hero then
            for i = 1, unitCount do
                local randomAngle = RandomFloat(0, 360) * math.pi / 180
                local offset = Vector(math.cos(randomAngle), math.sin(randomAngle), 0) * 200
                local spawnPos = hero:GetAbsOrigin() + offset
                local creep = CreateUnitByName(unitName, spawnPos, true, hero, hero, hero:GetTeam())
                if creep then
                    creep:SetControllableByPlayer(hero:GetPlayerID(), true)
                    creep:AddNewModifier(hero, nil, "modifier_phased", {
                        duration = 0.1
                    })
                end
            end
        end
    end

    if startWith(text, "-unit_all ") then
        local fileName = tokens[2]
        if not fileName then
            SendErrorMessage(playerID, "Usage: -unit_all <filename>")
            return
        end

        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
        if not hero then
            SendErrorMessage(playerID, "No hero selected")
            return
        end

        -- Build the file path
        local filePath = "scripts/npc/units/npc_units_" .. fileName .. ".txt"

        -- Read and parse the file
        local unitData = LoadKeyValues(filePath)
        if not unitData then
            Cmd:sendDebugNotify("Failed to load file: " .. filePath)
            return
        end

        -- Collect every unit name
        local unitNames = {}
        for unitName, unitInfo in pairs(unitData) do
            if unitName ~= "Version" and type(unitInfo) == "table" then
                table.insert(unitNames, unitName)
            end
        end

        if #unitNames == 0 then
            Cmd:sendDebugNotify("No units found in file")
            return
        end

        -- Work out the rows and columns of the block
        local totalUnits = #unitNames
        local cols = math.ceil(math.sqrt(totalUnits))
        local rows = math.ceil(totalUnits / cols)

        -- Start position, with the block centred on the hero
        local heroPos = hero:GetAbsOrigin()
        local spacing = 256
        local startX = heroPos.x - (cols - 1) * spacing / 2
        local startY = heroPos.y - (rows - 1) * spacing / 2

        -- Create the units
        local index = 1
        local successCount = 0
        for row = 0, rows - 1 do
            for col = 0, cols - 1 do
                if index <= totalUnits then
                    local unitName = unitNames[index]
                    local pos = Vector(startX + col * spacing, startY + row * spacing, heroPos.z)

                    local creep = CreateUnitByName(unitName, pos, true, hero, hero, hero:GetTeam())
                    if creep then
                        creep:SetControllableByPlayer(hero:GetPlayerID(), true)
                        FindClearSpaceForUnit(creep, pos, true)
                        successCount = successCount + 1
                    end

                    index = index + 1
                end
            end
        end

        fireLeftNotify(playerID, false, string.format(DEBUG_COLOR_TAG .. " Created %d/%d units from %s in formation", successCount, totalUnits, fileName), {
            rawText = true
        })
    end

    if tokens[1] == "-unitr" then
        local nameReg = (tokens[2])
        local unitList = {}
        for name, v in pairs(KeyValues.UnitKV) do
            if name~="Version" and not v.isMergedFromHero then
                if string.match(name, nameReg) then
                    print("match", name, nameReg)
                    table.insert(unitList, name)
                end
            end
            -- print(v)
        end
        local page = tonumber(tokens[3]) or 1
        local length = tonumber(tokens[4]) or 30
        table.sort(unitList, function(a, b)
            return a < b
        end);
        for index, value in ipairs(unitList) do
            print(index, value)
        end
        local start = (page - 1) * length
        for i = start, start + length, 1 do
            local unitName = unitList[i]

            print(i, start, length, unitName)

            local creep = CreateUnitByName(unitName, hero:GetAbsOrigin(), true, hero, hero, hero:GetTeam())
            if creep then
                creep:SetControllableByPlayer(hero:GetPlayerID(), true)
                FindClearSpaceForUnit(creep, creep:GetAbsOrigin(), true)
                -- SimpleMoveUnit(creep, RandomPointInRadius(hero:GetAbsOrigin(), 400))
            end
        end
    end

    if tokens[1] == "-bot" then
        local c = tonumber(tokens[2])
        Convars:SetInt("dota_legiontd_bot", c)
        print("bot", Convars:GetInt("dota_legiontd_bot"))
    end
    if tokens[1]=="-enemy" then
        local unitName = (tokens[2])
        local unitCount = tonumber(tokens[3]) or 1
        local hero = PlayerResource:GetSelectedHeroEntity(0)
        for i = 1, unitCount do
            local creep = CreateUnitByName(unitName, hero:GetAbsOrigin(), true, hero, hero, DOTA_TEAM_BADGUYS)
            if creep then
                creep:SetControllableByPlayer(hero:GetPlayerID(), true)
                creep:AddNewModifier(hero, nil, "modifier_phased", {
                    duration = 0.1
                })
                SimpleMoveUnit(creep, RandomPointInRadius(hero:GetAbsOrigin(), 400))
            end
        end
    end
    if text == "-tele" then
        if HeroDemo.selectedUnits then
            local posMap = PlayerTables:GetTableValue("demo_core_player", playerID)
            local newPos = Vector(posMap.posX, posMap.posY, posMap.posZ)
            for _, unit in ipairs(HeroDemo.selectedUnits) do
                --SimpleMoveUnit(unit,newPos)
                FindClearSpaceForUnit(unit, newPos, true)
            end
            ResolveNPCPositions(newPos, 300)
        end
        GameRules:SetUseBaseGoldBountyOnHeroes(true)
    end
    if (text == "-control") then
        local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0, 0, 0), nil, -1, DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES +
            DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, 0, false)
        for i = 1, #units do
            print(units[i]:GetUnitName())

            if units[i] == hero or units[i]:HasModifier("modifier_out_of_world") then
            else
                units[i]:SetControllableByPlayer(hero:GetPlayerOwnerID(), true)
            end
        end
    end
    if text == "-day" then
        GameRules:SetTimeOfDay(0.25)
    end

    if text=="-test" then
        
        PrintTable(GamePlay:getAllBuildingsByTier())
    end
    

    if (text == "-restart") then
        print("reload script")
        Timers:CreateTimer(0.1, function()
            SendToServerConsole("restart")
        end)
    end
    if startWith(text, "-ab ") then
        local abilityName = (tokens[2])
        local level = (tokens[3] or 1) + 0
        print(#HeroDemo.selectedUnits)
        if HeroDemo.selectedUnits then
            for _, unit in ipairs(HeroDemo.selectedUnits) do
                print(unit:GetUnitName(), abilityName, level)

                unit:RemoveAbility(abilityName)

                AddAbilityAndSetLevel(unit, abilityName, level)
                local ab = unit:FindAbilityByName(abilityName)

                if not ab then
                    SendErrorMessage(playerID, "invalid ability", {})
                    return
                end

                ab:SetHidden(false)
                if not unit.abList then
                    unit.abList = {}
                end
                table.insert(unit.abList, {
                    name = abilityName,
                    level = level
                })
            end
        end
    end

    if text == "-dump" then
        if HeroDemo.selectedUnits and #HeroDemo.selectedUnits > 0 then
            local unit = HeroDemo.selectedUnits[1]
            local unitName = unit:GetUnitName()

            print("========================================")
            print("[Unit dump]")
            print("========================================")

            -- Unit name
            print("✦ unit: " .. unitName)
            fireLeftNotify(nil, false, DUMP_COLOR_TAG .. " unit: " .. unitName, {
                rawText = true
            })

            -- Unit position
            local position = unit:GetAbsOrigin()
            print(string.format("✦ position: X=%.2f, Y=%.2f, Z=%.2f", position.x, position.y, position.z))
            fireLeftNotify(nil, false, string.format(DUMP_COLOR_TAG .. " position: (%.2f, %.2f, %.2f)", position.x, position.y, position.z), {
                rawText = true
            })

            -- Ability list
            print("----------------------------------------")
            print("[Abilities]")
            local abilityCount = 0
            local slotCount = unit:GetAbilityCount() or 0
            for i = 0, slotCount - 1 do
                local ability = unit:GetAbilityByIndex(i)
                if ability then
                    local abilityName = ability:GetAbilityName()
                    local abilityLevel = ability:GetLevel()
                    local isHidden = ability:IsHidden()

                    abilityCount = abilityCount + 1
                    print(string.format("  [ability %d] %s", abilityCount, abilityName))
                    print(string.format("    level: %d | hidden: %s", abilityLevel, tostring(isHidden)))
                end
            end
            if abilityCount == 0 then
                print("  (no abilities)")
            end
            fireLeftNotify(nil, false, string.format(DUMP_COLOR_TAG .. " abilities: %d", abilityCount), {
                rawText = true
            })

            -- Modifier list
            print("----------------------------------------")
            print("[Modifiers]")
            local modifierCount = unit:GetModifierCount()

            if modifierCount > 0 then
                for i = 0, modifierCount - 1 do
                    local modifier = unit:GetModifierNameByIndex(i)
                    local modifierInstance = unit:FindModifierByName(modifier)

                    if modifierInstance then
                        local caster = modifierInstance:GetCaster()
                        local ability = modifierInstance:GetAbility()
                        local stackCount = modifierInstance:GetStackCount()
                        local duration = modifierInstance:GetDuration()
                        local remainingTime = modifierInstance:GetRemainingTime()

                        local casterName = "none"
                        if caster then
                            casterName = caster:GetUnitName()
                        end

                        local abilityName = "none"
                        if ability then
                            abilityName = ability:GetAbilityName()
                        end

                        print(string.format("  [Mod%d] %s", i + 1, modifier))
                        print(string.format("    caster: %s | ability: %s", casterName, abilityName))
                        print(string.format("    stacks: %d | duration: %.1fs | remaining: %.1fs", stackCount, duration, remainingTime))
                    end
                end
            else
                print("  (no modifiers)")
            end
            fireLeftNotify(nil, false, string.format(DUMP_COLOR_TAG .. " modifiers: %d", modifierCount), {
                rawText = true
            })

            print("========================================")
        else
            Cmd:sendDebugNotify("Select a unit first")
        end
    end

    if text == "-modifiers" or text == "-mods" then
        if HeroDemo.selectedUnits and #HeroDemo.selectedUnits > 0 then
            local unit = HeroDemo.selectedUnits[1]
            local unitName = unit:GetUnitName()
            local modifierCount = unit:GetModifierCount()

            print("========================================")
            print("[Modifier Debug] unit: " .. unitName)
            print("[Modifier Debug] total modifiers: " .. modifierCount)
            print("========================================")

            Cmd:sendDebugNotify("unit: " .. unitName .. " | modifiers: " .. modifierCount)

            for i = 0, modifierCount - 1 do
                local modifier = unit:GetModifierNameByIndex(i)
                local modifierInstance = unit:FindModifierByName(modifier)

                if modifierInstance then
                    local caster = modifierInstance:GetCaster()
                    local ability = modifierInstance:GetAbility()
                    local stackCount = modifierInstance:GetStackCount()
                    local duration = modifierInstance:GetDuration()
                    local remainingTime = modifierInstance:GetRemainingTime()

                    local casterName = "none"
                    if caster then
                        casterName = caster:GetUnitName()
                    end

                    local abilityName = "none"
                    if ability then
                        abilityName = ability:GetAbilityName()
                    end

                    print(string.format("[%d] %s", i + 1, modifier))
                    print("  - caster: " .. casterName)
                    print("  - ability: " .. abilityName)
                    print("  - stacks: " .. stackCount)
                    print("  - duration: " .. duration .. "s")
                    print("  - remaining: " .. remainingTime .. "s")
                    print("----------------------------------------")
                end
            end

            print("========================================")
        else
            Cmd:sendDebugNotify("Select a unit first")
        end
    end



    if text == "-ptest2" then
        Cmd:sendDebugNotify("Usage: -ptest2 (place 15 units per race for every player)")

        local allUnitsInfo = GamePlay:DumpAllUnitsInfo()
        local heros = {}
        for key, _ in pairs(allUnitsInfo) do
            table.insert(heros, key)
        end
        local start = RandomInt(1, 100)
        local creepCount = 15
        start = 8
        local pc = 0
        local totalPlaced = 0
        for _, pid in pairs(Player:Ids()) do
            local hero = PlayerResource:GetSelectedHeroEntity(pid)
            local p1 = hero:GetAbsOrigin()
            p1.x = 64 * (math.floor(p1.x / 64))
            p1.y = 64 * (math.floor(p1.y / 64))

            local pdata = Player:GetPData(pid)
            local units = allUnitsInfo[heros[(start + pc) % #heros + 1]]
            if not pdata.kicked then
                for c = 1, creepCount do
                    local unitName = units[c % (#units) + 1]
                    local i = c % (8)
                    local j = math.floor(c / (8))
                    local yv = 1
                    local homePos = GamePlay:getHomePos(pid)
                    if homePos.y < 0 then
                        yv = -1
                    end
                    local pos = Vector(p1.x + 128 * i, p1.y + yv * 128 * j, p1.z)

                    local newBuilding = BuildingHelper:PlaceBuilding(pid, unitName, pos, nil, nil, nil, pdata.team)
                    local unitKv = GamePlay.metaKv.units[unitName]
                    newBuilding.gold = unitKv.creepValue
                    newBuilding.food = unitKv.creepFood
                    newBuilding.wood = 0
                    GamePlay:OnConstructionStarted(newBuilding)
                    totalPlaced = totalPlaced + 1
                end
            end
            Player:UpdateCreepValue(pid)
            pc = pc + 1
        end
    end

    -- Fight test command: -ft
    if startWith(text, "-ft ") then
        if #tokens >= 4 then
            local creepA = tokens[2]
            local creepB = tokens[3]
            local value = tonumber(tokens[4])

            if not value or value <= 0 then
                fireLeftNotify(nil, false, "<font color='#FFD700'>[Fight Test]</font>Error: the value must be a positive number!", {
                    rawText = true
                })
                return
            end

            -- Unit KV data
            local metaKv = GamePlay.metaKv
            if not metaKv or not metaKv.units then
                fireLeftNotify(nil, false, "<font color='#FFD700'>[Fight Test]</font>Error: could not read the unit metadata!", {
                    rawText = true
                })
                return
            end

            local unitKvA = metaKv.units[creepA]
            local unitKvB = metaKv.units[creepB]

            if not unitKvA then
                fireLeftNotify(nil, false, "<font color='#FFD700'>[Fight Test]</font>Error: unit not found: " .. creepA, {
                    rawText = true
                })
                return
            end

            if not unitKvB then
                fireLeftNotify(nil, false, "<font color='#FFD700'>[Fight Test]</font>Error: unit not found: " .. creepB, {
                    rawText = true
                })
                return
            end

            local creepValueA = tonumber(unitKvA.creepValue)
            local creepValueB = tonumber(unitKvB.creepValue)

            if not creepValueA or creepValueA <= 0 then
                fireLeftNotify(nil, false, "<font color='#FFD700'>[Fight Test]</font>Error: " .. creepA .. " has an invalid creepValue (0 or missing)!", {
                    rawText = true
                })
                return
            end

            if not creepValueB or creepValueB <= 0 then
                fireLeftNotify(nil, false, "<font color='#FFD700'>[Fight Test]</font>Error: " .. creepB .. " has an invalid creepValue (0 or missing)!", {
                    rawText = true
                })
                return
            end

            -- Work out the unit counts
            local countA = math.floor(value / creepValueA)
            local countB = math.floor(value / creepValueB)

            if countA <= 0 or countB <= 0 then
                fireLeftNotify(nil, false, "<font color='#FFD700'>[Fight Test]</font>Error: the unit count must be greater than 0!", {
                    rawText = true
                })
                return
            end

            -- Clean up any test already running
            if FightTest.active then
                Cmd:CleanupFightTest()
            end

            -- Set up the fight test
            -- 1. Move player 0 hero to the test area
            local hero = PlayerResource:GetSelectedHeroEntity(0)
            if not hero then
                fireLeftNotify(nil, false, "<font color='#FFD700'>[Fight Test]</font>Error: player 0 has no hero!", {
                    rawText = true
                })
                return
            end

            local testPosition = Vector(0, 6400, 128)
            FindClearSpaceForUnit(hero, testPosition, true)
            fireLeftNotify(nil, false, "<font color='#FFD700'>[Fight Test]</font>Hero teleported to the test area", {
                rawText = true
            })

            -- 2. Disable the armor type rules
            HERO_DEMO_ATTACK_ARMOR_TYPE_DISABLED = true
            fireLeftNotify(nil, false, "<font color='#FFD700'>[Fight Test]</font>Armor type rules disabled", {
                rawText = true
            })

            -- Sync the UI state into CustomNetTables
            CustomNetTables:SetTableValue("game_global", "ui_defaults", {
                WTFEnabled = Convars:GetInt("dota_ability_debug"),
                SpawnCreepsEnabled = HERO_DEMO_SPAWN_CREEPS_ENABLED and 1 or 0,
                TowersEnabled = HERO_DEMO_TOWERS_ENABLED and 1 or 0,
                AttackArmorTypeDisabled = HERO_DEMO_ATTACK_ARMOR_TYPE_DISABLED and 1 or 0,
                AIDisabled = HERO_DEMO_AI_DISABLED and 1 or 0
            })

            -- The hero position is the centre of the battlefield
            local centerPos = hero:GetAbsOrigin()

            -- Clear the unit lists
            FightTest.teamA = {}
            FightTest.teamB = {}
            FightTest.creepAName = creepA
            FightTest.creepBName = creepB
            FightTest.initialCountA = countA
            FightTest.initialCountB = countB

            -- Spawn team A (DOTA_TEAM_GOODGUYS, 600 down)
            local posA = Vector(centerPos.x, centerPos.y + 600, centerPos.z)
            for i = 1, countA do
                local row = math.floor((i - 1) / 10)
                local col = (i - 1) % 10
                local totalRows = math.ceil(countA / 10)
                local isLastRow = (row == totalRows - 1)
                local unitsInRow = 10
                if isLastRow then
                    local remainder = countA % 10
                    unitsInRow = (remainder == 0) and 10 or remainder
                end

                -- Centre each row with an offset
                local offsetX = (col - (unitsInRow - 1) / 2) * 100
                local offsetY = row * 100
                local spawnPos = Vector(posA.x + offsetX, posA.y + offsetY, posA.z)

                local unit = CreateUnitByName(creepA, spawnPos, true, nil, nil, DOTA_TEAM_GOODGUYS)
                if unit then
                    FindClearSpaceForUnit(unit, spawnPos, true)
                    unit:SetForwardVector(Vector(0, -1, 0))
                    unit:SetControllableByPlayer(0, true)
                    table.insert(FightTest.teamA, unit)
                end
            end

            -- Spawn team B (DOTA_TEAM_BADGUYS, 600 up)
            local posB = Vector(centerPos.x, centerPos.y - 600, centerPos.z)
            for i = 1, countB do
                local row = math.floor((i - 1) / 10)
                local col = (i - 1) % 10
                local totalRows = math.ceil(countB / 10)
                local isLastRow = (row == totalRows - 1)
                local unitsInRow = 10
                if isLastRow then
                    local remainder = countB % 10
                    unitsInRow = (remainder == 0) and 10 or remainder
                end

                -- Centre each row with an offset
                local offsetX = (col - (unitsInRow - 1) / 2) * 100
                local offsetY = row * -100
                local spawnPos = Vector(posB.x + offsetX, posB.y + offsetY, posB.z)

                local unit = CreateUnitByName(creepB, spawnPos, true, nil, nil, DOTA_TEAM_BADGUYS)
                if unit then
                    FindClearSpaceForUnit(unit, spawnPos, true)
                    unit:SetForwardVector(Vector(0, 1, 0))
                    unit:SetControllableByPlayer(0, true)
                    table.insert(FightTest.teamB, unit)
                end
            end

            -- Mark the test as active
            FightTest.active = true
            FightTest.startTime = GameRules:GetGameTime()

            -- Send the notifications
            fireLeftNotify(nil, false, "<font color='#FFD700'>[Fight Test]</font>The storm is rising, the battle begins!", {
                rawText = true
            })
            fireLeftNotify(nil, false, string.format("<font color='#7CFC00'>[Tianquan Army]</font>%s × %d (value: %.0f)", creepA, countA, creepValueA * countA), {
                rawText = true
            })
            fireLeftNotify(nil, false, string.format("<font color='#FF6347'>[Liyue Army]</font>%s × %d (value: %.0f)", creepB, countB, creepValueB * countB), {
                rawText = true
            })

            -- Send both sides into attack-move after 1 second
            Timers:CreateTimer(1.0, function()
                for _, unit in ipairs(FightTest.teamA) do
                    if IsActiveUnit(unit) then
                        ExecuteOrderFromTable({
                            UnitIndex = unit:entindex(),
                            OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
                            Position = posB
                        })
                    end
                end

                for _, unit in ipairs(FightTest.teamB) do
                    if IsActiveUnit(unit) then
                        ExecuteOrderFromTable({
                            UnitIndex = unit:entindex(),
                            OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
                            Position = posA
                        })
                    end
                end
            end)

            -- Start the fight status timer
            FightTest.timer = Timers:CreateTimer(1.0, function()
                return Cmd:CheckFightTestStatus()
            end)
        else
            fireLeftNotify(nil, false, "<font color='#FFD700'>[Fight Test]</font>Usage: -ft <unit A> <unit B> <value>", {
                rawText = true
            })
        end
    end

    -- Close the fight test
    if text == "-ft_close" then
        if FightTest.active then
            Cmd:CleanupFightTest()
            fireLeftNotify(nil, false, "<font color='#FFD700'>[Fight Test]</font>The fight has been stopped and every unit cleared!", {
                rawText = true
            })
        else
            fireLeftNotify(nil, false, "<font color='#FFD700'>[Fight Test]</font>There is no fight test running", {
                rawText = true
            })
        end
    end
end

-- Poll the fight state
function Cmd:CheckFightTestStatus()
    if not FightTest.active then
        return nil
    end

    -- Living strength: health ratio, initial units only
    local powerA = 0
    local powerB = 0
    local aliveA = 0
    local aliveB = 0

    for _, unit in ipairs(FightTest.teamA) do
        if IsActiveUnit(unit) and unit:IsAlive() then
            aliveA = aliveA + 1
            local hpPercent = unit:GetHealth() / unit:GetMaxHealth()
            powerA = powerA + hpPercent
        end
    end

    for _, unit in ipairs(FightTest.teamB) do
        if IsActiveUnit(unit) and unit:IsAlive() then
            aliveB = aliveB + 1
            local hpPercent = unit:GetHealth() / unit:GetMaxHealth()
            powerB = powerB + hpPercent
        end
    end

    -- Strength percentage based on the initial count
    local powerPercentA = (powerA / FightTest.initialCountA) * 100
    local powerPercentB = (powerB / FightTest.initialCountB) * 100

    local elapsed = GameRules:GetGameTime() - FightTest.startTime

    -- Report the current strength
    fireLeftNotify(nil, false, string.format("<font color='#87CEEB'>[Battle Status]</font>%.0f s | <font color='#7CFC00'>Tianquan%.1f%%</font> vs <font color='#FF6347'>Liyue%.1f%%</font>",
        elapsed, powerPercentA, powerPercentB), {
        rawText = true
    })

    -- Player 0 hero position is the search centre
    local hero = PlayerResource:GetSelectedHeroEntity(0)
    if not hero then
        return 1.0
    end
    local centerPos = hero:GetAbsOrigin()

    -- Every unit within 2000 range, to see whether any fight unit is still alive
    local units = FindUnitsInRadius(
        DOTA_TEAM_GOODGUYS,
        centerPos,
        nil,
        2000,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        FIND_ANY_ORDER,
        false
    )

    -- Count the units actually alive, heroes and invulnerable units excluded
    local hasGoodGuys = false
    local hasBadGuys = false

    for _, unit in pairs(units) do
        if IsActiveUnit(unit) and unit:IsAlive() and not unit:IsHero() then
            if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
                hasGoodGuys = true
            elseif unit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
                hasBadGuys = true
            end
        end
    end

    -- Check whether one side has been wiped out
    if not hasGoodGuys or not hasBadGuys then
        local winner = ""
        local winnerColor = ""

        if hasGoodGuys then
            winner = string.format("<font color='#7CFC00'>[Tianquan Army]</font>%s wins!", FightTest.creepAName)
            winnerColor = "Tianquan"
        elseif hasBadGuys then
            winner = string.format("<font color='#FF6347'>[Liyue Army]</font>%s wins!", FightTest.creepBName)
            winnerColor = "Liyue"
        else
            winner = "<font color='#FFD700'>[Draw]</font>Both sides wiped each other out!"
            winnerColor = "Draw"
        end

        fireLeftNotify(nil, false, "<font color='#FFD700'>[Battle Over]</font>————————————————", {
            rawText = true
        })
        fireLeftNotify(nil, false, winner, {
            rawText = true
        })
        fireLeftNotify(nil, false, string.format("<font color='#7CFC00'>[Tianquan Army]</font>%s remaining: %d/%d (strength: %.1f%%)",
            FightTest.creepAName, aliveA, FightTest.initialCountA, powerPercentA), {
            rawText = true
        })
        fireLeftNotify(nil, false, string.format("<font color='#FF6347'>[Liyue Army]</font>%s remaining: %d/%d (strength: %.1f%%)",
            FightTest.creepBName, aliveB, FightTest.initialCountB, powerPercentB), {
            rawText = true
        })
        fireLeftNotify(nil, false, string.format("<font color='#87CEEB'>[Duration]</font>%.1f s", elapsed), {
            rawText = true
        })
        fireLeftNotify(nil, false, "<font color='#FFD700'>[Note]</font>Cleaning the battlefield in 3 seconds...", {
            rawText = true
        })

        -- Clean the test up after 3 seconds
        Timers:CreateTimer(3.0, function()
            Cmd:CleanupFightTest()
        end)

        return nil
    end

    -- Keep polling
    return 1.0
end

-- Clean up the fight test
function Cmd:CleanupFightTest()
    -- Player 0 hero position is the search centre
    local hero = PlayerResource:GetSelectedHeroEntity(0)
    if hero then
        local centerPos = hero:GetAbsOrigin()

        -- Every unit within 2000 range
        local units = FindUnitsInRadius(
            DOTA_TEAM_GOODGUYS,
            centerPos,
            nil,
            2000,
            DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_ANY_ORDER,
            false
        )

        -- Clear every fight unit, heroes and invulnerable units excluded
        for _, unit in pairs(units) do
            if IsActiveUnit(unit) and not unit:IsHero() and not unit:IsInvulnerable() then
                if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS or unit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
                    unit:ForceKill(false)
                end
            end
        end
    end

    -- Clear the timer
    if FightTest.timer then
        Timers:RemoveTimer(FightTest.timer)
        FightTest.timer = nil
    end

    -- Reset the state
    FightTest.active = false
    FightTest.teamA = {}
    FightTest.teamB = {}
    FightTest.creepAName = ""
    FightTest.creepBName = ""
    FightTest.initialCountA = 0
    FightTest.initialCountB = 0
end
