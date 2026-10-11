require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}

        local orc_shapeshift = self:FindAbilityByName("orc_shapeshift")

        if orc_shapeshift then
            table.insert(self.abilities, orc_shapeshift)
            orc_shapeshift.Skill = UseSkillNoTarget
            orc_shapeshift.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRange(ability, entity, 1, 1000)
            end
        end


        local orc_summon_blood_wolf = self:FindAbilityByName("orc_summon_blood_wolf")

        if orc_summon_blood_wolf then
            table.insert(self.abilities, orc_summon_blood_wolf)
            orc_summon_blood_wolf.Skill = UseSkillNoTarget
            orc_summon_blood_wolf.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRange(ability, entity, 1, 1000)
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
