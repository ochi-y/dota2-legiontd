require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}

        local shadow_mindwarp = self:FindAbilityByName("shadow_mindwarp")
        if shadow_mindwarp then
            table.insert(self.abilities, shadow_mindwarp)
            shadow_mindwarp.Skill = function(entity, ability)
                local target = nil
                local targetFighterId = GamePlay:FighterGetAbilityTarget(self.fighterId, ability:GetAbilityName())
                local targetFighter = GamePlay:FighterGetUnit(targetFighterId)
                if IsActiveUnit(targetFighter)
                    and not targetFighter:HasModifier("modifier_shadow_mindwarp_buff")
                    and (targetFighter:GetAbsOrigin() - self:GetAbsOrigin()):Length2D() < 1200
                then
                    target = targetFighter
                else
                    -- search units
                    local units = AiFindFriends(entity, ability)
                    -- units filter
                    -- units = AiFilterHealthPct(units, 100)
                    units = AiFilterNoTag(units, "shadow_mindwarp")
                    units = AiFilterNoModifier(units, "modifier_shadow_mindwarp_buff")
                    --
                    -- print("tag",#units)
                    -- units sort
                    units = AiOrderByDps(units, false)
                    -- cast ability
                    target = units[1]
                end
                if target then
                    -- target:AddNewModifier(entity, ability, "modifier_shadow_mindwarp_tag", { duration = 1 })
                    UTIL:addUnitTag(target, "shadow_mindwarp", 1)
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                --
                return nil
            end
            shadow_mindwarp.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, 800, nil)
            end
        end

        local shadow_decrepify = self:FindAbilityByName("shadow_decrepify")
        if shadow_decrepify then
            table.insert(self.abilities, shadow_decrepify)
            shadow_decrepify.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                units = AiFilterNoModifier(units, "modifier_shadow_decrepify")
                -- units = AiFilterNoModifier(units, "modifier_shadow_decrepify_tag")
                units = AiFilterNoTag(units, "shadow_decrepify")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, shadow_decrepify, "modifier_shadow_decrepify_tag", {duration=1})
                    UTIL:addUnitTag(target, "shadow_decrepify", 1)
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end
            shadow_decrepify.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, 400, nil)
            end
        end
    end

    self:SetContextThink("init_think", function()
        self.aiThink = aiThinkStandardSkill

        self:ReloadAiAbility()

        -- shadow_mindwarp.CustomAffectRadius = shadow_mindwarp:GetSpecialValueFor("wave_width") -- Very suboptimal, should check rectangle from caster instead
        self.FindNewAttackTarget = StandardFindNewAttackTarget
        self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
    end, 0)
end
