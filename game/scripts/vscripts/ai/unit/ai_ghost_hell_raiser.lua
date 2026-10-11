require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local ghost_nightmare = self:FindAbilityByName("ghost_nightmare")
        if ghost_nightmare then
            table.insert(self.abilities, ghost_nightmare)
            ghost_nightmare.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                units = AiFilterNotStunned(units)
                units = AiFilterNoModifier(units, "modifier_ghost_nightmare_debuff")
                units = AiFilterNoTag(units, "ghost_nightmare")
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, orc_storm_bolt, "modifier_orc_storm_bolt_tag", {duration=1})
                    UTIL:addUnitTag(target, "ghost_nightmare", 1)
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end
            ghost_nightmare.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, nil, nil)
            end
        end


        local ghost_cacophony = self:FindAbilityByName("ghost_cacophony")
        if ghost_cacophony then
            table.insert(self.abilities, ghost_cacophony)
            ghost_cacophony.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                -- units = AiFilterNoModifier(units, "modifier_stunned")
                -- ArrayOrderByMapFunc
                ArrayRemove(units, function(v)
                    return v:IsNightmared()
                end)
                -- units = AiFilterNoTag(units, "orc_storm_bolt")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, orc_storm_bolt, "modifier_orc_storm_bolt_tag", {duration=1})
                    -- UTIL:addUnitTag(target, "orc_storm_bolt", 1)
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end
            ghost_cacophony.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, nil, nil)
            end
        end
    end

    self:SetContextThink(
        "init_think",
        function()
            self.aiThink = aiThinkStandardSkill
            self:ReloadAiAbility()
            self.FindNewAttackTarget = StandardFindNewAttackTarget
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
        end,
        0
    )
end
