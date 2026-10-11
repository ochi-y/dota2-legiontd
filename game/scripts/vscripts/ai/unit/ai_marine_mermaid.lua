require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    self:SetContextThink(
        "init_think",
        function()
            self.aiThink = aiThinkStandardSkill
            self.abilities = {}
            self.abilities[1] = self:FindAbilityByName("marine_sphere")
            if self.abilities[1] then
                self.abilities[1].Skill = function(entity, ability)
                    local target = nil
                    local targetFighterId = GamePlay:FighterGetAbilityTarget(self.fighterId, ability:GetAbilityName())
                    local targetFighter = GamePlay:FighterGetUnit(targetFighterId)

                    if IsActiveUnit(targetFighter) and not targetFighter:HasModifier("modifier_marine_sphere_buff") and (targetFighter:GetAbsOrigin() - self:GetAbsOrigin()):Length2D() < 1200 then
                        target = targetFighter
                    else
                        -- search units
                        local units = AiFindFriends(entity, ability)
                        -- units filter
                        -- units = AiFilterHealthPct(units, 100)
                        units = AiFilterNoModifier(units, "modifier_marine_sphere_buff")
                        units = AiFilterNoModifier(units, "modifier_marine_sphere_tag")
                        -- units sort
                        units = AiOrderByHealth(units, false)
                        -- cast ability
                        target = units[1]
                    end
                    if target then
                        -- entity:CastAbilityOnTarget(target, ability, -1)
                        -- entity:CastAbilityOnPosition(target:GetAbsOrigin(), ability, -1)
                        target:AddNewModifier(entity, self.abilities[1], "modifier_marine_sphere_tag", { duration = 1 })
                        entity:CastAbilityOnTarget(target, ability, -1)
                        return 1
                    end
                    return nil
                end

                self.abilities[1].SkillTrigger = CheckFriendAbilityRange
            end

            --self.abilities[1].CustomAffectRadius = self.abilities[1]:GetSpecialValueFor("wave_width") -- Very suboptimal, should check rectangle from caster instead
            self.FindNewAttackTarget = StandardFindNewAttackTarget
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
        end,
        0
    )
end
