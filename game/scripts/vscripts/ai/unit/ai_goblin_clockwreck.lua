require("ai/ai_core")

function Spawn(entity)
    if not IsServer() then return end
    InitAI(thisEntity)
end

function InitAI(self)
    function self:ReloadAiAbility()
        self.abilities = {}
        local goblin_hookshot = self:FindAbilityByName("goblin_hookshot")
        if goblin_hookshot then
            table.insert(self.abilities, goblin_hookshot)
            goblin_hookshot.Skill = function(entity, ability)
                local units = AiFindAbilityTarget(entity, ability)
                units = AiFilterNotStunned(units)
                units = AiFilterNoTag(units, "goblin_hookshot")
                --
                local target = units[1]
                if target then
                    local affectedUnits = AiFindAbilityTarget(entity, ability, {
                        pos = target:GetAbsOrigin(),
                        radius = 175
                    })
                    for _, affectedUnit in ipairs(affectedUnits) do
                        UTIL:addUnitTag(affectedUnit, "goblin_hookshot", 1)
                    end
                    entity:CastAbilityOnPosition(target:GetAbsOrigin(), ability, -1)
                    return true
                end
                --
                return false
            end
            goblin_hookshot.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRange(ability, entity, 1, 1000)
            end
        end

        local goblin_defense_matrix = self:FindAbilityByName("goblin_defense_matrix")
        if goblin_defense_matrix then
            table.insert(self.abilities, goblin_defense_matrix)
            goblin_defense_matrix.Skill = function(entity, ability)
                entity:CastAbilityNoTarget(ability, -1)
                return 1
            end
            goblin_defense_matrix.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRange(ability, entity, 1, 800)
            end
        end
        

        local goblin_cluster_rockets = self:FindAbilityByName("goblin_cluster_rockets")
        if goblin_cluster_rockets then
            table.insert(self.abilities, goblin_cluster_rockets)

            goblin_cluster_rockets.Skill = function(entity, ability)
                local units = AiFindAbilityTarget(entity, ability)

                units = AiFilterNotStunned(units)
                units = AiFilterNoTag(units, "goblin_cluster_rockets")
                --
                local target = units[1]
                if target then
                    local radius = ability:GetSpecialValueFor("radius")

                    local affectedUnits = AiFindAbilityTarget(entity, ability, {
                        pos = target:GetAbsOrigin(),
                        radius = radius
                    })
                    for _, affectedUnit in ipairs(affectedUnits) do
                        UTIL:addUnitTag(affectedUnit, "goblin_cluster_rockets", 2)
                    end
                    entity:CastAbilityOnPosition(target:GetAbsOrigin(), ability, -1)
                    return true
                end
                --
                return false
            end
            goblin_cluster_rockets.SkillTrigger = function(ability, entity)
                return CheckEnemyCountInRange(ability, entity, 1, 200)
            end
        end
    end

    self:SetContextThink("init_think", function()
        self.aiThink = aiThinkStandardSkill
        self:ReloadAiAbility()
        --
        self.FindNewAttackTarget = StandardFindNewAttackTarget
        self:SetContextThink(DoUniqueString("ai"), Dynamic_Wrap(self, "aiThink"), 0)
    end, 0)
end
