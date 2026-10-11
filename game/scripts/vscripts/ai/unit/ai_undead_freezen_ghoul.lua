require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end
    InitAI(thisEntity)
end

function InitAI(self)

    function self:ReloadAiAbility()
        self.abilities = {}
        self.abilities[1] = self:FindAbilityByName("undead_rage")
        if self.abilities[1] then
            self.abilities[1].Skill = function(entity, ability)
                entity:CastAbilityNoTarget(ability,-1)
                return 1
            end
            self.abilities[1].SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRange(ability, entity, 1, 300)
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
