require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end
    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local nature_toss = self:FindAbilityByName("nature_toss")
        if nature_toss then
            table.insert(self.abilities, nature_toss)

            nature_toss.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {
                    findOrder=FIND_FARTHEST,
                    targetTeam=DOTA_UNIT_TARGET_TEAM_ENEMY,
                    targetType=DOTA_UNIT_TARGET_CREEP

                })
                -- units filter
                -- units = AiFilterHealthPct(units, 100)
                --  units = AiFilterNoModifier(units, "modifier_stunned")
                -- units = AiFilterNoModifier(units, "modifier_nature_toss_tag")
                units = AiFilterNoTag(units, "nature_toss")
                -- print("tag",#units)
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    -- target:AddNewModifier(entity, nature_toss, "modifier_nature_toss_tag", {duration=1})
                    UTIL:addUnitTag(target, "nature_toss", 1)
                    -- UTIL:addUnitTagAOE(ability, target:GetAbsOrigin(), 375, "nature_toss", 2)
                    entity:CastAbilityOnTarget(target, ability, -1)
                    return 1
                end
                return nil
            end
            nature_toss.SkillTrigger = function(ability, entity)
                local units = AiFindAbilityTarget(entity, ability, {
                    pos = entity:GetAbsOrigin(),
                    radius = 300,
                    targetTeam=DOTA_UNIT_TARGET_TEAM_BOTH,
                    targetType=DOTA_UNIT_TARGET_CREEP
                })
                units = AiFilterNotUnit(units, entity)
                if #units == 0 then
                    return false
                end
                local res= CheckEnemyCountInRangeEx(ability, entity, false, 1, 1000, nil)
                print("a123",res)
                return res
            end
        end
    end

    self:SetContextThink(
        "init_think",
        function()
            self.aiThink = aiThinkStandardSkill
            self:ReloadAiAbility()
            --
            self.FindNewAttackTarget = StandardFindNewAttackTarget
            self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
            --
        end,
        0
    )
end
