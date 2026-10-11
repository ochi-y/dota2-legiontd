require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    self:SetContextThink("init_think", function()
        self.aiThink = aiThinkStandardSkill
        self.abilities = {}
        self.abilities[1] = self:FindAbilityByName("demi_human_mend")
        if self.abilities[1] then
            self.abilities[1].Skill = function(entity, ability)
                local units = AiFindAbilityTarget(entity,ability,{})
                units=AiOrderByHealthPct(units,true)
                units = AiFilterNoModifier(units, "modifier_demi_human_motar_tag")
                -- 
                local target=units[1]
                if target and target:GetHealthPercent()<70 then
                    target:AddNewModifier(entity, ability, "modifier_demi_human_motar_tag", {duration=1})
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return true
                end
                return false
            end
            self.abilities[1].SkillTrigger = CheckFriendLowHpAbilityRange
        end
        -- self.abilities[1].CustomAffectRadius = self.abilities[1]:GetSpecialValueFor("wave_width") -- Very suboptimal, should check rectangle from caster instead
        self.FindNewAttackTarget = StandardFindNewAttackTarget
        self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
    end, 0)
end
