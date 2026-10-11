-- Order Filter; order can be casting an ability, moving, clicking to attack, using scan (radar), glyph etc.
function barebones:OrderFilter(filter_table)
    

    local order = filter_table.order_type
    local units = filter_table.units
    local playerID = filter_table.issuer_player_id_const

    if playerID ~= nil then
        local pdata = Player:GetPData(playerID)
        local new_state = GameRules:State_Get()
        if pdata and new_state >= DOTA_GAMERULES_STATE_PRE_GAME then
            pdata.lastOrderTime = GameRules:GetGameTime()
        end
    end

    local pdata=Player:GetPData(playerID) 
    if pdata and pdata.kicked then
        SendErrorMessage(playerID, "error_player_kicked")
        return false
    end

    -- Example 1: If the order is an ability
    if order == DOTA_UNIT_ORDER_CAST_POSITION or order == DOTA_UNIT_ORDER_CAST_TARGET or order ==
        DOTA_UNIT_ORDER_CAST_NO_TARGET or order == DOTA_UNIT_ORDER_CAST_TOGGLE or order ==
        DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO then
        local ability_index = filter_table.entindex_ability
        local ability
        if ability_index then
            ability = EntIndexToHScript(ability_index)
        end
        local caster
        if units and units["0"] then
            caster = EntIndexToHScript(units["0"])
        end
        -- handle build command
        if ability then
            -- Remember the unit that issued the order
            ability.lastOrderPlayerId = filter_table.issuer_player_id_const
        end
    end


    -- Example 2: If the order is a simple move command
    if order == DOTA_UNIT_ORDER_MOVE_TO_POSITION and units then
        local destination_x = filter_table.position_x
        local destination_y = filter_table.position_y
        local unit_with_order
        if units["0"] then
            unit_with_order = EntIndexToHScript(units["0"])
        end
    end
    -- ban king stop and hold command
    if units then

        for _, unitIndex in pairs(units) do
            local unit=EntIndexToHScript(unitIndex)
            if unit and (unit:GetUnitName()=="king_good" or unit:GetUnitName()=="king_bad") then
                local whiteList={
                    DOTA_UNIT_ORDER_CAST_POSITION,
                    DOTA_UNIT_ORDER_CAST_TARGET,
                    DOTA_UNIT_ORDER_CAST_NO_TARGET,
                    DOTA_UNIT_ORDER_CAST_TOGGLE,
                    DOTA_UNIT_ORDER_CONTINUE,
                    DOTA_UNIT_ORDER_ATTACK_TARGET
                }
                if TableContainsValue(whiteList,order) then
                    return true
                end
                local blackList={
                    DOTA_UNIT_ORDER_STOP,
                    DOTA_UNIT_ORDER_HOLD_POSITION,
                }
                if TableContainsValue(blackList,order) then
                    return false
                end
                if not unit.orderList then
                    unit.orderList={}
                end
                local newList={}
                for _, item in ipairs(unit.orderList) do
                    if item.time>GameRules:GetGameTime()-1.5 then
                        table.insert(newList,item)
                    end
                end
                unit.orderList=newList
                if #unit.orderList>0 then
                    SendErrorMessage(playerID, "error_cant_stop_king")
                    return false
                else
                    table.insert(unit.orderList,{time=GameRules:GetGameTime()})
                end
                
            end
        end
        
    end
    
    return true
end

-- Damage filter function
function barebones:DamageFilter(keys)
    -- PrintTable(keys)

    local attacker
    local victim
    if keys.entindex_attacker_const and keys.entindex_victim_const then
        attacker = EntIndexToHScript(keys.entindex_attacker_const)
        victim = EntIndexToHScript(keys.entindex_victim_const)
    else
        return false
    end

    local damage_type = keys.damagetype_const
    local inflictor = keys.entindex_inflictor_const -- keys.entindex_inflictor_const is nil if damage is not caused by an ability
    local damage_after_reductions = keys.damage -- keys.damage is damage after reductions without spell amplifications

    local damaging_ability
    if inflictor then
        damaging_ability = EntIndexToHScript(inflictor)
    else
        damaging_ability = nil
    end

    -- Lack of entities handling (illusions error fix)
    if attacker:IsNull() or victim:IsNull() then
        return false
    end

    -- Update the gold bounty of the hero before he dies
    if USE_CUSTOM_HERO_GOLD_BOUNTY then
        if attacker:IsControllableByAnyPlayer() and victim:IsRealHero() and damage_after_reductions >=
            victim:GetHealth() then
            -- Get his killing streak
            local hero_streak = victim:GetStreak()
            -- Get his level
            local hero_level = victim:GetLevel()
            -- Adjust Gold bounty
            local gold_bounty
            if hero_streak > 2 then
                gold_bounty = HERO_KILL_GOLD_BASE + hero_level * HERO_KILL_GOLD_PER_LEVEL + (hero_streak - 2) *
                                  HERO_KILL_GOLD_PER_STREAK
            else
                gold_bounty = HERO_KILL_GOLD_BASE + hero_level * HERO_KILL_GOLD_PER_LEVEL
            end

            victim:SetMinimumGoldBounty(gold_bounty)
            victim:SetMaximumGoldBounty(gold_bounty)
        end
    end

    return true
end

-- Modifier (buffs, debuffs) filter function
function barebones:ModifierFilter(keys)
    -- PrintTable(keys)

    local unit_with_modifier = EntIndexToHScript(keys.entindex_parent_const)
    local modifier_name = keys.name_const
    local modifier_duration = keys.duration
    local modifier_caster
    if keys.entindex_caster_const then
        modifier_caster = EntIndexToHScript(keys.entindex_caster_const)
    end

    return true
end

-- Experience filter function
function barebones:ExperienceFilter(keys)
    -- PrintTable(keys)
    local experience = keys.experience
    local playerID = keys.player_id_const
    local reason = keys.reason_const


    return true
end

-- Tracking Projectile (attack and spell projectiles) filter function
function barebones:ProjectileFilter(keys)
    -- PrintTable(keys)

    local can_be_dodged = keys.dodgeable -- values: 1 for yes, 0 for no
    local ability_index = keys.entindex_ability_const -- value if not ability: -1
    local source_index = keys.entindex_source_const
    local target_index = keys.entindex_target_const
    local expire_time = keys.expire_time
    local is_an_attack_projectile = keys.is_attack -- values: 1 for yes or 0 for no
    local max_impact_time = keys.max_impact_time
    local projectile_speed = keys.move_speed

    return true
end

-- Bounty Rune Filter, can be used to modify Alchemist's Greevil Greed for example
function barebones:BountyRuneFilter(keys)
    -- PrintTable(keys)

    local gold_bounty = keys.gold_bounty
    local playerID = keys.player_id_const
    local xp_bounty = keys.xp_bounty -- value: 0

    return true
end

-- Healing Filter, can be used to modify how much hp regen and healing a unit is gaining
-- Triggers every time a unit gains health
function barebones:HealingFilter(keys)
    -- PrintTable(keys)

    local healing_target_index = keys.entindex_target_const
    local heal_amount = keys.heal -- heal amount of the ability or health restored with hp regen during server tick

    local healer_index
    if keys.entindex_healer_const then
        healer_index = keys.entindex_healer_const
    end

    local healing_ability_index
    if keys.entindex_inflictor_const then
        healing_ability_index = keys.entindex_inflictor_const
    end

    local healing_target = EntIndexToHScript(healing_target_index)

    -- Find the source of the heal - the healer
    local healer
    if healer_index then
        healer = EntIndexToHScript(healer_index)
    else
        healer = healing_target -- hp regen
    end

    -- Find healing ability
    -- Abilities that give bonus hp regen don't count as healing abilities!!!
    local healing_ability
    if healing_ability_index then
        healing_ability = EntIndexToHScript(healing_ability_index)
    else
        healing_ability = nil -- hp regen
    end

    return true
end

-- Gold filter, can be used to modify how much gold player gains/loses
function barebones:GoldFilter(keys)

    local gold = keys.gold
    local playerID = keys.player_id_const
    local reason = keys.reason_const
    local reliable = keys.reliable


    -- Disable all hero kill gold
    if DISABLE_ALL_GOLD_FROM_HERO_KILLS then
        if reason == DOTA_ModifyGold_HeroKill then
            return false
        end
    end
    if reason == DOTA_ModifyGold_AbandonedRedistribute then
        keys.gold = 0
        return false
    end
    -- Player:ModifyGold(playerID,gold)
    return false
end

function barebones:OnDamageFilter(keys)
    local ei_unit_attacked = keys.entindex_victim_const
    local attacked = EntIndexToHScript(ei_unit_attacked)

    -- print(unit_hAttacked:GetUnitName())
    local damage_amount = keys.damage
    if attacked:HasModifier("modifier_creep_reborn") then
        local health = attacked:GetHealth()
        if health - damage_amount <= 0 then
            local ability = attacked:FindAbilityByName("creep_reborn")
            if ability:IsCooldownReady() then
                local level = ability:GetLevel()
                ability:StartCooldown(ability:GetCooldown(level))
                local duration = ability:GetSpecialValueFor("duration") + 0
                attacked:AddNewModifier(attacked, ability, "modifier_creep_reborn_active", {
                    duration = duration
                })
                return false
            end
        end
    end
    return true
end

-- Inventory filter, triggers every time a unit picks up or buys an item, doesn't trigger when you change item's slot inside inventory
function barebones:InventoryFilter(keys)
    -- PrintTable(keys)

    local unit_with_inventory_index = keys.inventory_parent_entindex_const -- -1 if not defined
    local item_index = keys.item_entindex_const
    local owner_index = keys.item_parent_entindex_const -- -1 if not defined
    local item_slot = keys.suggested_slot -- slot in which the item should be put, usually its -1 meaning put in the first free slot


    local unit_with_inventory
    local unit_name
    if unit_with_inventory_index and unit_with_inventory_index ~= -1 then
        unit_with_inventory = EntIndexToHScript(unit_with_inventory_index)
        unit_name = unit_with_inventory:GetUnitName()
    end

    local item
    if item_index then
        item = EntIndexToHScript(item_index)
    end
    local item_name
    if item then
        item_name = item:GetName()
    end

    local owner_of_this_item
    if owner_index and owner_index ~= -1 then
        -- not reliable
        owner_of_this_item = EntIndexToHScript(owner_index)
    elseif item then
        owner_of_this_item = item:GetPurchaser()
    end

    local owner_name
    if owner_of_this_item then
        owner_name = owner_of_this_item:GetUnitName()
    end

    return true
end
