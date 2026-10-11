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
            if self:FindAbilityByName("elf_diabolic_edict") then
                self.abilities[1] = self:FindAbilityByName("elf_diabolic_edict")
                self.abilities[1].Skill = UseSkillNoTarget
                self.abilities[1].SkillTrigger = function (ability, entity)
                    return CheckEnemyCountInRange(ability, entity,1,500)
                end
            end
            self.FindNewAttackTarget = StandardFindNewAttackTarget
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
        end,
        0
    )
end
