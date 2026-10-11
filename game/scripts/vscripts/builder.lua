require("util")

local function IsUnitCountLimitReached(playerID, unitName)
    local limit = tonumber(GetUnitKV(unitName, "UnitCountLimit"))
    if not limit or limit <= 0 then
        return false
    end

    local count = BuildingHelper:GetBuildingCount(playerID, unitName, true)
    return count >= limit
end

-- A build ability is used (not yet confirmed)
function Build(event)
    -- PrintTable(event)

    local caster = event.caster
    local ability = event.ability

    local ability_name = ability:GetAbilityName()
    local building_name = ability:GetAbilityKeyValues()['UnitName']
    if building_name == "self" then
        building_name = caster:GetUnitName()
    end
    local gold_cost = ability:GetSpecialValueFor("gold")
    local hero = caster:IsRealHero() and caster or caster:GetOwner()
    local playerID = hero:GetPlayerID()
    local orderPlayerId = ability.lastOrderPlayerId
    event.orderPlayerId = orderPlayerId

    local food = ability:GetSpecialValueFor("food")
    local wood = ability:GetSpecialValueFor("wood")
    local gold = ability:GetSpecialValueFor("gold")

    if IsUnitCountLimitReached(playerID, building_name) then
        SendErrorMessage(orderPlayerId or playerID, "error_max_build_count")
        return
    end

    -- If the ability has an AbilityGoldCost, it's impossible to not have enough gold the first time it's cast
    -- Always refund the gold here, as the building hasn't been placed yet
    -- no need to refund
    -- hero:ModifyGold(gold_cost, false, 0)

    -- Makes a building dummy and starts panorama ghosting
    BuildingHelper:AddBuilding(event)

    -- Additional checks to confirm a valid building position can be performed here
    event:OnPreConstruction(function(vPos)
        if IsUnitCountLimitReached(playerID, building_name) then
            SendErrorMessage(orderPlayerId or playerID, "error_max_build_count")
            return false
        end
        -- Check for minimum height if defined
        if not BuildingHelper:MeetsHeightCondition(vPos) then
            BuildingHelper:print("Failed placement of " ..
            building_name .. " - Placement is below the min height required")
            SendErrorMessage(orderPlayerId, "error_invalid_build_position")
            return false
        end
        if not teckTree:checkResourceForBuild(caster, ability) then
            return false
        end
        if GamePlay.state == "in-round" then
            print("[legiontd] cant build in round")
            SendErrorMessage(orderPlayerId, "error_cant_build_in_round")
            return false
        end
        -- If not enough resources to queue, stop
        -- if PlayerResource:GetGold(playerID) < gold_cost then
        --     BuildingHelper:print("Failed placement of " .. building_name .." - Not enough gold!")
        --     SendErrorMessage(playerID, "error_not_enough_gold")
        --     return false
        -- end
        return true
    end)

    -- Position for a building was confirmed and valid
    event:OnBuildingPosChosen(function(vPos)
        -- Spend resources
        --hero:ModifyGold(-gold_cost, false, 0)
        Player:ModifyGold(playerID, -gold_cost)
        Player:ModifyFood(playerID, -food)
        Player:ModifyWood(playerID, -wood)
    end)

    -- The construction failed and was never confirmed due to the gridnav being blocked in the attempted area
    event:OnConstructionFailed(function()
        local playerTable = BuildingHelper:GetPlayerTable(playerID)
        local building_name = playerTable.activeBuilding
        if building_name then
            BuildingHelper:print("Failed placement of " .. building_name)
        end
    end)

    -- Cancelled due to ClearQueue
    event:OnConstructionCancelled(function(work)
        local building_name = work.name
        BuildingHelper:print("Cancelled construction of " .. building_name)

        -- Refund resources for this cancelled work
        if work.refund then
            --PlayerResource:ModifyGold(playerID,gold, false, 0)
            Player:ModifyGold(playerID, gold_cost)
            Player:ModifyFood(playerID, food)
            Player:ModifyWood(playerID, wood)
        end
    end)

    -- A building unit was created
    event:OnConstructionStarted(function(unit)
        BuildingHelper:print("Started construction of " .. unit:GetUnitName() .. " " .. unit:GetEntityIndex())
        -- Play construction sound
        -- If it's an item-ability and has charges, remove a charge or remove the item if no charges left
        if ability.GetCurrentCharges and not ability:IsPermanent() then
            local charges = ability:GetCurrentCharges()
            charges = charges - 1
            if charges == 0 then
                ability:RemoveSelf()
            else
                ability:SetCurrentCharges(charges)
            end
        end

        -- EmitSoundOn("DOTA_Item.SentryWard.Activate", unit)
        -- EmitSoundOnLocationForAllies(unit:GetAbsOrigin(),"DOTA_Item.SentryWard.Activate", unit)

        EmitSoundOnEntityForPlayer("DOTA_Item.SentryWard.Activate", unit, playerID)

        -- Units can't attack while building
        unit.original_attack = unit:GetAttackCapability()
        unit:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)

        -- Give item to cancel
        unit.item_building_cancel = CreateItem("item_building_cancel", hero, hero)
        if unit.item_building_cancel then
            unit:AddItem(unit.item_building_cancel)
            --unit.gold_cost = gold_cost
        end

        -- FindClearSpace for the builder
        FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
        caster:AddNewModifier(caster, nil, "modifier_phased", { duration = 0.03 })
        unit:AddNewModifier(caster, nil, "modifier_crafting", {})
        unit.gold = gold
        unit.wood = wood
        unit.food = food



        unit.buildingKv = {}
        -- Remove invulnerability on npc_dota_building baseclass
        -- unit:RemoveModifierByName("modifier_invulnerable")
        --buildTree:onBuild(unit)
        -- Play a sound
        EmitSoundOnClient("DOTA_Item.ObserverWard.Activate", PlayerResource:GetPlayer(playerID))

        GamePlay:OnConstructionStarted(unit)
    end)

    -- A building finished construction
    event:OnConstructionCompleted(function(unit)
        BuildingHelper:print("Completed construction of " .. unit:GetUnitName() .. " " .. unit:GetEntityIndex())
        -- Play construction complete sound
        if startWith(unit:GetUnitName(), "lieren_") then
            AddAbilityAndSetLevel(unit, "lieren_zhuanshen")
        end
        -- Remove the item
        if unit.item_building_cancel then
            UTIL_Remove(unit.item_building_cancel)
        end

        if unit.buildingRegenSave then
            unit:SetBaseHealthRegen(unit.buildingRegenSave)
        end


        --unit:StartGesture(ACT_DOTA_CUSTOM_TOWER_IDLE)
        unit:RemoveModifierByName("modifier_invulnerable")

        unit:RemoveModifierByName("modifier_crafting")
        -- Give the unit their original attack capability
        unit:SetAttackCapability(unit.original_attack)

        unit.buildRound = GamePlay.round
        unit.sellTag = true

        GamePlay:markLastBuilding(unit)

        Player:UpdateCreepValue(unit:GetPlayerOwnerID())
        local pdata = Player:GetPData(unit:GetPlayerOwnerID())




        emitVoiceSound(unit, "spawn", unit:GetPlayerOwnerID())
    end)

    -- These callbacks will only fire when the state between below half health/above half health changes.
    -- i.e. it won't fire multiple times unnecessarily.
    event:OnBelowHalfHealth(function(unit)
        BuildingHelper:print(unit:GetUnitName() .. " is below half health.")
    end)

    event:OnAboveHalfHealth(function(unit)
        BuildingHelper:print(unit:GetUnitName() .. " is above half health.")
    end)
end

function UpgradeStart(event)
    if not IsServer() then return end
    local hCaster = event.caster
    local _name = hCaster:GetUnitName()
    local ability = event.ability
    local id = hCaster:GetPlayerOwnerID()
    local gold = GetGold(id)
    local needGold = ability:GetSpecialValueFor("gold")
    if gold < needGold then
        SendErrorMessage(id, "#no_enough_gold")
        local t_order = {
            UnitIndex = hCaster:entindex(),
            OrderType = DOTA_UNIT_ORDER_STOP
        }
        hCaster:SetContextThink(DoUniqueString("order"), function() ExecuteOrderFromTable(t_order) end, FrameTime())
        return
    end
    if not IsActiveBuilding(hCaster) then
        local t_order = {
            UnitIndex = hCaster:entindex(),
            OrderType = DOTA_UNIT_ORDER_STOP
        }
        hCaster:SetContextThink(DoUniqueString("order"), function() ExecuteOrderFromTable(t_order) end, FrameTime())
        return
    end
    -- Player:ModifyGold( id,-needGold)
    hCaster:AddNewModifier(hCaster, ability, "modifier_levelup_channel_cast", { duration = 10000 })
end

function UpgradeRefund(event)
    if not IsServer() then return end
    local hCaster = event.caster
    local ability = event.ability
    local gold = ability:GetSpecialValueFor("gold")
    local id = hCaster:GetPlayerOwnerID()
    if not hCaster:HasModifier("modifier_levelup_channel_cast") then
        return
    end
    Player:ModifyGold(id, gold)
    --EmitSoundOnEntityForPlayer("General.CoinsBig", hCaster,id)
    EmitSoundOnLocationForAllies(hCaster:GetAbsOrigin(), "General.CoinsBig", hCaster)
    PopupGoldGain(hCaster, math.floor(gold), {
        team = PlayerResource:GetTeam(id)
    })
    hCaster:RemoveModifierByName("modifier_levelup_channel_cast")
end

function UpgradeFinished(event)
    if not IsServer() then return end
    local caster = event.caster
    local ability = event.ability
    local gold = ability:GetSpecialValueFor("gold")
    if not caster:HasModifier("modifier_levelup_channel_cast") then
        return
    end
    local levelTo = GetAbilityKV(ability:GetAbilityName(), "UpgradeToLevel", 1)
    if levelTo then
        levelTo = levelTo + 0
        for i = 1, (levelTo - caster:GetLevel()) do
            caster:CreatureLevelUp(1)
        end
    else
        caster:CreatureLevelUp(1)
    end
    caster.gold = caster.gold + gold
    caster:RemoveModifierByName("modifier_levelup_channel_cast")
end

-- Called when the Cancel ability-item is used
function CancelBuilding(keys)
    local building = keys.unit
    local hero = building:GetOwner()
    local playerID = building:GetPlayerOwnerID()
    BuildingHelper:print("CancelBuilding " .. building:GetUnitName() .. " " .. building:GetEntityIndex())
    -- Refund here
    -- if building.gold_cost then
    --     hero:ModifyGold(building.gold_cost, false, 0)
    -- end
    -- Eject builder
    local builder = building.builder_inside
    if builder then
        BuildingHelper:ShowBuilder(builder)
    end
    building:ForceKill(true) --This will call
end

function RefundBuilding(caster, building)
    local playerID = building:GetPlayerOwnerID()
    local food = building.food
    local wood = building.wood
    local gold = building.gold
    local factor = 1

    local isHybrid = false

    if building.buildingKv and building.buildingKv.isHybrid then
        isHybrid = true
    end

    if building:IsChanneling() then
        building:InterruptChannel()
    end

    if building.state == "complete" then
        factor = 0.5
    end
    local pdata = Player:GetPData(playerID)
    if building.isLastBuilding then
        factor = 1
    end
    if building:HasModifier("modifier_marine_delicacy") then
        factor = math.max(factor, 0.9)
    end
    if GamePlay.secondaryModes['fs'] then
        factor = 1
        if building:HasModifier("modifier_marine_delicacy") and building:FindModifierByName("modifier_marine_delicacy"):GetStackCount() >= 10 then
            factor=1.1
        end
    end

    if building.sellTag then
        if isHybrid then
            factor = 0.5
        else
            factor = 1
        end
    end

    local getGold = math.floor(factor * gold)
    Player:ModifyFood(playerID, food)
    Player:ModifyGold(playerID, math.floor(getGold))
    Player:ModifyWood(playerID, math.floor(wood * factor))
    local pts = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_CUSTOMORIGIN, building)
    ParticleManager:SetParticleControl(pts, 0, building:GetAbsOrigin() + Vector(0, 0, 100))
    ParticleManager:SetParticleControl(pts, 1, caster:GetAbsOrigin() + Vector(0, 0, 100))
    ParticleManager:ReleaseParticleIndex(pts)

    -- EmitSoundOnLocationForAllies(caster:GetAbsOrigin(),"General.CoinsBig", caster)

    EmitSoundOnLocationForPlayer("General.CoinsBig", caster:GetAbsOrigin(), caster:GetPlayerOwnerID())


    PopupGoldGain(building, math.floor(getGold), {
        team = PlayerResource:GetTeam(playerID)
    })
    return getGold
end

function SellBuilding(keys)
    local building = keys.target
    local caster = keys.caster
    if not caster:IsHero() then
        return
    end
    if not building or not IsCustomBuilding(building) then
        return
    end
    if caster:GetPlayerOwnerID() ~= building:GetPlayerOwnerID() then
        return
    end
    local hero = building:GetOwner()
    local playerID = building:GetPlayerOwnerID()
    BuildingHelper:print("SellBuilding " .. building:GetUnitName() .. " " .. building:GetEntityIndex())
    local gold = RefundBuilding(caster, building)
    NotifyUnitSelled(playerID, building:GetUnitName(), gold)
    building:ForceKill(true)
    Player:UpdateCreepValue(playerID)
end

function SellBuildingNoTarget(keys)
    local ability = keys.ability
    local orderPlayerId = ability.lastOrderPlayerId
    local building = keys.caster
    local caster = keys.caster
    if not building or not IsCustomBuilding(building) then
        return
    end

    local morphModifiers={
        "modifier_hybrid_morphs_tier_1_morphs",
        "modifier_hybrid_morphs_tier_2_morphs",
        "modifier_hybrid_morphs_tier_3_morphs",
        "modifier_hybrid_morphs_tier_4_morphs",
        "modifier_hybrid_morphs_tier_5_morphs",
        "modifier_hybrid_morphs_tier_6_morphs",
    }
    for index, value in ipairs(morphModifiers) do
        if building:HasModifier(value) then
            return
        end
    end
    
    local hero = building:GetOwner()
    local playerID = building:GetPlayerOwnerID()

    -- if orderPlayerId and orderPlayerId~=playerID and (
    --     PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_ABANDONED
    --     or
    --     PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_DISCONNECTED
    -- ) then
    --     SendErrorMessage(orderPlayerId, "error_cant_sell_ally_building")
    --     return
    -- end


    emitVoiceSound(building, "death", playerID)

    BuildingHelper:print("SellBuilding " .. building:GetUnitName() .. " " .. building:GetEntityIndex())
    local gold = RefundBuilding(hero, building)

    if not GamePlay.secondaryModes["fs"] then
        fireLeftNotify(playerID, true, "notify_tower_sell", {
            int1 = gold,
            ability = "",
            str1 = building:GetUnitName()
        })
    end
    GamePlay:FighterUnregister(building.fighterId)
    -- building:ForceKill(true)
    building:Kill(nil, nil)
    -- BuildingHelper:OnEntityKilled({
    -- })
    -- building:ForceKill(false)
    Player:UpdateCreepValue(playerID)
end
