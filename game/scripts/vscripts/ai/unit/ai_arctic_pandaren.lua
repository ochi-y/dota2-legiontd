require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)

    function self:ReloadAiAbility()
        self.abilities = {}
        self.abilities[1] = self:FindAbilityByName("arctic_enrage_old")
        if self.abilities[1] then
            
            self.abilities[1].Skill = function (entity, ability)
                entity:CastAbilityOnTarget(entity, ability, -1)
                return 1
            end

            self.abilities[1].SkillTrigger = function (ability, entity)
                return CheckEnemyCountInRange(ability, entity,1,200)
            end
        end
    end
    self:SetContextThink(
        "init_think",
        function()
            self.aiThink = aiThinkStandardSkill
            self.FindNewAttackTarget = StandardFindNewAttackTarget
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
            self:ReloadAiAbility()
            self.Unstuck = Unstuck
            self.NextWayPoint = NextWayPoint
        end,
        0
    )
end
