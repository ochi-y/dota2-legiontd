require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)

    function self:ReloadAiAbility()
        self.abilities = {}
        self.abilities[1] = self:FindAbilityByName("beast_battle_cry")
        if self.abilities[1] then 
            self.abilities[1].Skill = UseSkillNoTarget
            self.abilities[1].SkillTrigger = function (ability, entity)
                return CheckEnemyCountInRange(ability, entity,1,1000)
            end
        end
        
        self.abilities[2] = self:FindAbilityByName("beast_rejuvenation")
        if self.abilities[2] then
            self.abilities[2].Skill = function(entity, ability)
                entity:CastAbilityOnTarget(entity,ability,-1)
                return 1
            end
            self.abilities[2].SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRange(ability, entity, 1, 500) or entity:GetHealthPercent()<100
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
