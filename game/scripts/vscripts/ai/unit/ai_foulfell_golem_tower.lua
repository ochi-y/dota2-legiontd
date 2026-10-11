require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end

    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local foulfell_golem_tower_boulder_toss = self:FindAbilityByName("foulfell_golem_tower_boulder_toss")
        if foulfell_golem_tower_boulder_toss then
            table.insert(self.abilities, foulfell_golem_tower_boulder_toss)
            foulfell_golem_tower_boulder_toss.Skill = function(entity, ability)
                -- search units
                local units = AiFindAbilityTarget(entity, ability, {})
                -- units filter
                -- units sort
                -- cast ability
                local target = units[1]
                if target then
                    entity:CastAbilityOnPosition(target:GetAbsOrigin(), ability, -1)
                    return 1
                end
                return nil
            end
            foulfell_golem_tower_boulder_toss.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRangeEx(ability, entity, false, 1, 900, nil)
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
