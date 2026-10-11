require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local undead_ancient_apparition_ice_blast = self:FindAbilityByName("undead_ancient_apparition_ice_blast")
        if undead_ancient_apparition_ice_blast then
            table.insert(self.abilities, undead_ancient_apparition_ice_blast)
            undead_ancient_apparition_ice_blast.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {
                    radius = 1300
                })
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                units = AiFilterNoModifier(units, "modifier_undead_ancient_apparition_ice_blast")
                -- units = AiFilterNoModifier(units, "modifier_undead_ancient_apparition_ice_blast_tag")

                units = AiFilterNoTag(units, "undead_ancient_apparition_ice_blast")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, undead_ancient_apparition_ice_blast, "modifier_undead_ancient_apparition_ice_blast_tag", {duration=1})
                   --  UTIL:addUnitTagAOE(target, "undead_ancient_apparition_ice_blast", 2)

                    UTIL:addUnitTagAOE(ability, target:GetAbsOrigin(), 300, "undead_ancient_apparition_ice_blast", 3)

                    entity:CastAbilityOnPosition(target:GetAbsOrigin(), ability, -1)
                    return 1
                end
                return nil
            end
            undead_ancient_apparition_ice_blast.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, 2000, nil)
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
