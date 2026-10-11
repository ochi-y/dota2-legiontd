require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)


    function self:ReloadAiAbility()
        self.abilities = {}
        self.abilities[1] = self:FindAbilityByName("elf_mirana_invis")
        if self.abilities[1] then 
            self.abilities[1].Skill = function(entity, ability)
                -- search units
                -- local units = AiFindAbilityTarget(entity, ability,{
                --     radius=ability:GetSpecialValueFor("pull_radius")
                -- })
                -- units filter 
                -- units = AiFilterHealthPct(units, 100)
                -- units = AiFilterNotStunned(units)
               -- units = AiFilterNoModifier(units, "modifier_orc_storm_bolt_tag")
                -- units = AiFilterNoTag(units, "demi_human_reverse_polarity")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                entity:CastAbilityNoTarget(ability, -1)
                return 1
            end
            self.abilities[1].SkillTrigger = function (ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity,false,1,600,nil)
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
