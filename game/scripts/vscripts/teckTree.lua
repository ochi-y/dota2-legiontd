if not teckTree then
    teckTree = class({})
end

local teckData = {}

teckData["teck_example_1"] = "teck_example_2"

LinkLuaModifier("modifier_teck_channeling", "libraries/modifiers/modifier_teck_channeling", LUA_MODIFIER_MOTION_NONE)

function teckTree:Init()
    teckTree.buildMap = { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {} }
    -- teckTree.maxLimits={}

    ListenToGameEvent('npc_spawned', Dynamic_Wrap(teckTree, 'OnNPCSpawned'), self)
    ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(teckTree, 'OnGameRulesStateChange'), self)
end

function teckTree:OnGameRulesStateChange(keys)
    local new_state = GameRules:State_Get()
    if new_state == DOTA_GAMERULES_STATE_PRE_GAME then

    end
    if new_state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then

    end
end

function teckTree:OnNPCSpawned(keys)
    local unit = EntIndexToHScript(keys.entindex)
    local unit_owner = unit:GetOwner()
end

function teckTree:getDependency(hero, abilityName)

end

function teckTree:getRawUnitName(name)
    if not name then
        return nil
    end
    local tail = string.sub(name, #name - 1)
    if TableContainsValue(teckTree.tails, tail) then
        local raw = string.sub(name, 1, #name - 2)
        return raw
    end
    return name
end

function teckTree:setupBuilding(building)

end

function teckTree:onBuild(buildUnit)
    local playerId = buildUnit:GetPlayerOwnerID()
    if playerId < 0 then
        return
    end
    local ent = buildUnit:entindex()
    local buildName = buildUnit:GetUnitName()
    local idx = playerId + 1

    if teckTree.buildMap[idx][buildName] then
        teckTree.buildMap[idx][buildName] = teckTree.buildMap[idx][buildName] + 1
    else
        teckTree.buildMap[idx][buildName] = 1
    end
    teckTree:setupBuilding(buildUnit)
    teckTree:updateAbility(playerId)

    DebugPrint("onBuild " .. buildName .. " " .. teckTree.buildMap[idx][buildName])
end

function teckTree:onDestory(buildUnit)
    if not IsCustomBuilding(buildUnit) then
        return
    end
    local playerId = buildUnit:GetPlayerOwnerID()
    if playerId < 0 then
        return
    end
    local ent = buildUnit:entindex()
    local buildName = buildUnit:GetUnitName()
    local idx = playerId + 1
    if teckTree.buildMap[idx][buildName] then
        teckTree.buildMap[idx][buildName] = teckTree.buildMap[idx][buildName] - 1
        if teckTree.buildMap[idx][buildName] < 0 then
            teckTree.buildMap[idx][buildName] = 0
        end
    end
    teckTree:updateAbility(playerId)
    DebugPrint("onDestory " .. buildName .. " " .. (teckTree.buildMap[idx][buildName] or "0"))
end

function teckTree:getCountByRaw(playerId, abilityName)
    local buildUnitName = GetAbilityKV(abilityName, "UnitName")
    local count = 0
    count = count + (teckTree.buildMap[playerId + 1][buildUnitName] or 0)
    return count
end

-- print(teckTree.getCountByRaw(PlayerResource:GetSelectedHeroEntity(0),"tower_yemanren_hunzi"))

function teckTree:checkUnitCount(unit, unitName, level)
    local units = FindUnitsInRadius(unit:GetTeamNumber(), unit:GetAbsOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false)
    for i = 1, #units do
        if unit:GetTeamNumber() == units[i]:GetTeamNumber() and units[i]:GetUnitName() == unitName and
            units[i]:GetLevel() >= level then
            return true
        end
    end
    return false
end

function teckTree:getState(unit, abilityName)
    if (not unit) or (not abilityName) then
        return {
            result = true
        }
    end
    if GameRules.disableTech then
        return {
            result = true
        }
    end
    local playerId = unit:GetPlayerOwnerID()

    -- skip non-build skill
    if not abilityName then
        return {
            result = true
        }
    end
    local hero = GetHeroOfUnit(unit)
    local need = teckTree:getDependency(hero, abilityName)
    local res = {
        result = true
    }
    -- check tech dependency
    if playerId < 0 then
        return true
    end
    if need then
        local needUnit = need[1]
        local needLevel = need[2]
        -- TODO
        local checkRes = teckTree:checkUnitCount(unit, needUnit, needLevel)
        if checkRes then
            res.need = nil
        else
            res.need = needUnit
            res.needLevel = needLevel
        end
    end
    -- check count limit
    local buildUnitName = GetAbilityKV(abilityName, "UnitName")
    local idx = playerId + 1
    -- if teckTree.maxLimits[buildUnitName] then
    --     res.maxLimits = teckTree.maxLimits[buildUnitName]
    -- end
    -- res.count = teckTree:getCountByRaw(playerId, abilityName)
    -- if res.maxLimits then
    --     res.result = res.result and (res.count < res.maxLimits)
    -- end
    if res.need then
        res.result = res.result and (res.need == nil)
    end
    return res
end

function teckTree:updateUnitAbility(unit)
    local abilityCount = unit:GetAbilityCount() or 0
    for i = 0, abilityCount - 1 do
        local ab = unit:GetAbilityByIndex(i)
        if ab then
            local abn = ab:GetAbilityName()
            local res = teckTree:getState(unit, abn)
            if res.result then
                if ab:GetLevel() == 0 then
                    ab:SetLevel(1)
                end
            else
                ab:SetLevel(0)
            end
            -- Remove the level-restricted abilities
            -- local unitLevel = GetAbilityKV(abn, "UnitLevel", 1)
            -- if unitLevel and GetAbilityKV(abn, "UnitLevel", 1) then
            --     if unitLevel ~= unit:GetLevel() then
            --         unit:RemoveAbility(abn)
            --     end
            -- end
        end
    end
end

function teckTree:updateAbility(playerId)
    local hero = PlayerResource:GetSelectedHeroEntity(playerId)
    if not hero then
        return
    end
    teckTree:updateUnitAbility(hero)
    --
    -- local units = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY,
    --     DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false)
    -- if #units ~= 0 then
    --     for i = 1, #units do
    --         if units[i]:GetPlayerOwnerID() == playerId then
    --             teckTree:updateUnitAbility(units[i])
    --         end
    --     end
    -- end
end

function teckTree:traceContain(trace, unit)
    for i = 1, #trace do
        if trace[i]:GetUnitName() == unit:GetUnitName() then
            return trace
        end
    end
    return false
end

function teckTree:UseResource(unit, ability, cb, params)
    if params == nil then
        params = {}
    end

    if cb == nil then
        cb = function()
            return true
        end
    end
    if teckTree:checkResource(unit, ability) and cb() then
        teckTree:modifyResource(unit, ability)
        --
        if BehaviorContainsValue(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_CHANNELLED) then
            unit:AddNewModifier(unit, ability, "modifier_teck_channeling", { abilityName = ability:GetAbilityName() })
            -- EmitSoundOn("Hero_Tinker.Rearm", unit)
        end
        return true
    else
        ability:EndCooldown()
        if BehaviorContainsValue(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_CHANNELLED) then
            local t_order = {
                UnitIndex = unit:entindex(),
                OrderType = DOTA_UNIT_ORDER_STOP
            }
            Timers:CreateTimer(FrameTime(), function()
                ExecuteOrderFromTable(t_order)
            end)
        end
        return false
    end
end

function teckTree:OnChannelFinish(unit, ability, bInterrupted)
    if bInterrupted and unit:HasModifier("modifier_teck_channeling") then
        teckTree:refundResource(unit, ability)
    end
    unit:RemoveModifierByName("modifier_teck_channeling")
end

function teckTree:checkResourceForBuild(unit, ability)
    local food = ability:GetSpecialValueFor("food") or 0
    local wood = ability:GetSpecialValueFor("wood") or 0
    local orderPlayerId = ability.lastOrderPlayerId
    local playerID = unit:GetPlayerOwnerID()
    --
    print("checkResourceForBuild", Player:GetGold(playerID), ability:GetSpecialValueFor("gold"),
        Player:GetGold(playerID) < ability:GetSpecialValueFor("gold"))
    if Player:GetGold(playerID) < ability:GetSpecialValueFor("gold") then
        SendErrorMessage(orderPlayerId, "no_enough_gold")
        return false
    end

    if Player:GetFood(playerID) < food then
        SendErrorMessage(orderPlayerId, "no_enough_food")
        return false
    end
    if Player:GetWood(playerID) < wood then
        SendErrorMessage(orderPlayerId, "no_enough_wood")
        return false
    end
    return true
end

function teckTree:checkResource(unit, ability)
    local food = ability:GetSpecialValueFor("food") or 0
    local wood = ability:GetSpecialValueFor("wood") or 0
    local gold = ability:GetSpecialValueFor("gold") or 0

    local orderPlayerId = ability.lastOrderPlayerId 
    local playerID = unit:GetPlayerOwnerID()
    --

    if Player:GetFood(playerID) < food then
        if orderPlayerId then
            SendErrorMessage(orderPlayerId, "no_enough_food")
        end
        return false
    end
    if Player:GetWood(playerID) < wood then
        SendErrorMessage(orderPlayerId, "no_enough_wood")
        return false
    end
    if Player:GetGold(playerID) < gold then
        SendErrorMessage(orderPlayerId, "no_enough_gold")
        return false
    end
    return true
end

function teckTree:refundResource(unit, ability)
    local food = ability:GetSpecialValueFor("food") or 0
    local wood = ability:GetSpecialValueFor("wood") or 0
    local gold = ability:GetSpecialValueFor("gold") or 0
    local playerID = unit:GetPlayerOwnerID()
    Player:ModifyWood(playerID, wood)
    Player:ModifyFood(playerID, food)
    Player:ModifyGold(playerID, gold)
    --
end

function teckTree:modifyResource(unit, ability)
    local food = ability:GetSpecialValueFor("food") or 0
    local wood = ability:GetSpecialValueFor("wood") or 0
    local gold = ability:GetSpecialValueFor("gold") or 0
    --
    local playerID = unit:GetPlayerOwnerID()
    Player:ModifyWood(playerID, -wood)
    Player:ModifyFood(playerID, -food)
    Player:ModifyGold(playerID, -gold)
end

function teckResearchStart()
    print("teckResearchStart")
end

function teckResearchInterrupted()
    print("teckResearchInterrupted")
end

function teckResearchSucceeded()
    print("teckResearchSucceeded")
end

print("teckTree loaded")
