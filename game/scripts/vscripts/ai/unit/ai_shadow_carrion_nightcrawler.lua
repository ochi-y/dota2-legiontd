require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local shadow_time_lapse = self:FindAbilityByName("shadow_time_lapse")
        if shadow_time_lapse then

            table.insert(self.abilities,shadow_time_lapse)
            shadow_time_lapse.Skill = function(entity, ability)
                entity:CastAbilityNoTarget(ability, -1)
                return 1
            end
            shadow_time_lapse.SkillTrigger = function(ability, entity)
                return entity:GetHealthPercent() <= 25
            end
        end
    end

    self:SetContextThink(
        "init_think",
        function()
            self.aiThink = aiThinkSwitchTarget

            self:ReloadAiAbility()

            self.FindNewAttackTarget = function(entity)
                return StandardFindNewAttackTarget(entity)
            end
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)


            --
        end,
        0
    )
end
