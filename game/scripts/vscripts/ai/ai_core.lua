if not IsServer() then return end
require('util')

-- AI think interval constants
STANDARD_THINK_TIME = 0.3
OPTIMAL_SEARCH_RANGE = 100
WAYPOINT_DEFAULT_RADIUS = 200
AI_SKILL_RETURN_TIME = 0.3
GAME_OVER_THINK_TIME = 0.1
KING_THINK_TIME = 1.0
ERROR_RETRY_TIME = 1.0
UNSTUCK_RETURN_TIME = 1.0

-- Stuck detection: a unit that still has a move order but barely moved within
-- this time window is considered blocked.
STUCK_WINDOW_SECONDS = 1.5
STUCK_SAMPLE_COUNT = 6
STUCK_MIN_MOVE_DISTANCE = 32
STUCK_STAGE_RESET_TIME = 5.0
STUCK_MAX_STAGE = 3
STUCK_PHASED_DURATION = 0.25
STUCK_NUDGE_DISTANCE = 48

EXPORTS = {}

-- Shared AI pre-check helpers
function aiBaseCheck(self)
    if self:IsNull() then
        return false, nil
    end
    if GamePlay.gameWinner then
        return false, GAME_OVER_THINK_TIME
    end
    if HERO_DEMO_AI_DISABLED then
        return false, GAME_OVER_THINK_TIME
    end
    if self:HasModifier("modifier_unit_freeze_lua") or GameRules:IsGamePaused() or
        self:HasModifier("modifier_invulnerable") or not self:IsAlive() then
        return false, STANDARD_THINK_TIME
    end
    return true, nil
end

-- Building check, the king is excluded
function aiCheckBuildingSkip(self)
    if IsCustomBuilding(self) then
        if self:GetUnitName() ~= "king_good" and self:GetUnitName() ~= "king_bad" then
            return true, KING_THINK_TIME
        end
    end
    return false, nil
end

-- Path point check and movement
function aiCheckWaypoint(self)
    local wayPointRadius = self.wayPointRadius or WAYPOINT_DEFAULT_RADIUS
    if self.wayStep and ((self:GetAbsOrigin() - self.waypoints[self.wayStep]):Length2D() < wayPointRadius) then
        return true, NextWayPoint(self)
    end
    return false, nil
end

-- Shared helpers for stuck recovery: where the unit wants to go, how to order
-- it there, and the light "resume walking" step.
-- The point this unit is currently supposed to walk to, if any.
local function getMoveGoal(self)
    if self.wayStep and self.waypoints and self.waypoints[self.wayStep] then
        return self.waypoints[self.wayStep]
    end

    local target = self:GetAttackTarget()
    if IsActiveUnit(target) then
        return target:GetAbsOrigin()
    end
end

local function issueMoveOrder(self, position)
    ExecuteOrderFromTable({
        UnitIndex = self:entindex(),
        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
        Position = position,
        Queue = false
    })
end

-- A unit without orders (freshly spawned, just finished a fight) simply resumes
-- walking. That is not a stuck state, so it must never escalate to the heavier
-- recovery steps.
local function resumePatrol(self)
    local goal = getMoveGoal(self)
    if goal then
        issueMoveOrder(self, goal)
    end
    return UNSTUCK_RETURN_TIME
end

-- Stuck check and handling
function aiCheckAndHandleStuck(self)
    if CheckStuck(self) then
        Unstuck(self)
    elseif self:IsIdle() then
        resumePatrol(self)
    end
end

EXPORTS.Init = function(self)
    self:SetContextThink("init_think", function()
        self.aiThink = aiThinkStandard
        self.NextWayPoint = NextWayPoint
        self.Unstuck = Unstuck
        self:Unstuck()
        self:SetContextThink("ai_standard.aiThink", Dynamic_Wrap(self, "aiThink"), 0)
    end, 0)
end

function aiThinkStandard(self)
    if not IsServer() then return end

    local callComplete, thinkTime = SafeCall(function()
        -- Base checks
        local checkPassed, returnTime = aiBaseCheck(self)
        if not checkPassed then
            return returnTime
        end

        -- Is it a building?
        if IsCustomBuilding(self) then
            return KING_THINK_TIME
        end

        -- Is it stunned?
        if self:IsStunned() then
            return STANDARD_THINK_TIME
        end

        -- Path point check
        local hitWaypoint, waypointTime = aiCheckWaypoint(self)
        if hitWaypoint then
            return waypointTime
        end

        -- Stuck check and handling
        aiCheckAndHandleStuck(self)

        return STANDARD_THINK_TIME
    end)

    if not callComplete then
        -- The think callback threw and SafeCall swallowed it. Retry shortly
        -- instead of returning nil, which would stop this context think for
        -- good and freeze the unit's AI.
        return ERROR_RETRY_TIME
    end

    -- A nil thinkTime is deliberate: the unit is gone, so stop thinking.
    return thinkTime
end

function aiThinkStandardSkill(self)
    if not IsServer() then return end

    local callComplete, thinkTime = SafeCall(function()
        -- Base checks
        local checkPassed, returnTime = aiBaseCheck(self)
        if not checkPassed then
            return returnTime
        end

        -- Building check, the king is excluded
        local shouldSkip, skipTime = aiCheckBuildingSkip(self)
        if shouldSkip then
            return skipTime
        end

        -- Is the AI frozen?
        if self:HasModifier("modifier_ai_freeze") then
            return STANDARD_THINK_TIME
        end

        -- Is it stunned?
        if self:IsStunned() then
            return STANDARD_THINK_TIME
        end

        -- Try casting an ability
        if self.abilities then
            for i, v in ipairs(self.abilities) do
                if v and not v:IsNull() and v:IsFullyCastable() and v:IsActivated() and v:SkillTrigger(self) then
                    if v.Skill(self, v) then
                        return v:GetCastPoint() + AI_SKILL_RETURN_TIME
                    end
                end
            end
        end

        -- Look for a new attack target
        if self:IsIdle() and self:HasAttackCapability() and not self:IsDisarmed() and self.FindNewAttackTarget then
            local newTarget, bForce = self:FindNewAttackTarget()
            if newTarget then
                if bForce then
                    ExecuteOrderFromTable({
                        UnitIndex = self:entindex(),
                        OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                        TargetIndex = newTarget:entindex()
                    })
                    return STANDARD_THINK_TIME
                else
                    ExecuteOrderFromTable({
                        UnitIndex = self:entindex(),
                        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
                        Position = newTarget:GetAbsOrigin(),
                        Queue = false
                    })
                end
            end
        end

        -- Path point check
        local hitWaypoint, waypointTime = aiCheckWaypoint(self)
        if hitWaypoint then
            return waypointTime
        end

        -- Stuck check and handling
        aiCheckAndHandleStuck(self)

        return STANDARD_THINK_TIME
    end)

    if callComplete and thinkTime then
        return thinkTime
    else
        return ERROR_RETRY_TIME
    end
end

function aiThinkSwitchTarget(self)
    if not IsServer() then return end

    local callComplete, thinkTime = SafeCall(function()
        -- Base checks
        local checkPassed, returnTime = aiBaseCheck(self)
        if not checkPassed then
            return returnTime
        end

        -- Building check, the king is excluded
        local shouldSkip, skipTime = aiCheckBuildingSkip(self)
        if shouldSkip then
            return skipTime
        end

        -- Try casting an ability
        if self.abilities then
            for i, v in ipairs(self.abilities) do
                if v and not v:IsNull() and v:IsFullyCastable() and v:IsActivated() and v:SkillTrigger(self) then
                    if v.Skill(self, v) then
                        return v:GetCastPoint() + AI_SKILL_RETURN_TIME
                    end
                end
            end
        end

        -- Look for a target and switch to it
        if self.FindNewAttackTarget then
            local newTarget, bForce = self:FindNewAttackTarget()
            if newTarget then
                if bForce then
                    ExecuteOrderFromTable({
                        UnitIndex = self:entindex(),
                        OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                        TargetIndex = newTarget:entindex()
                    })
                elseif self:IsIdle() then
                    ExecuteOrderFromTable({
                        UnitIndex = self:entindex(),
                        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
                        Position = newTarget:GetAbsOrigin(),
                        Queue = false
                    })
                end
            end
        end

        -- Path point check
        local hitWaypoint, waypointTime = aiCheckWaypoint(self)
        if hitWaypoint then
            return waypointTime
        end

        -- Stuck check and handling
        aiCheckAndHandleStuck(self)

        return STANDARD_THINK_TIME
    end)

    if callComplete and thinkTime then
        return thinkTime
    else
        return ERROR_RETRY_TIME
    end
end

function aiThinkKing(self)
    if not IsServer() then return end

    local callComplete, thinkTime = SafeCall(function()
        -- Base checks, king only
        if self:IsNull() then
            return nil
        end
        if GamePlay.gameWinner then
            return GAME_OVER_THINK_TIME
        end
        if HERO_DEMO_AI_DISABLED then
            return GAME_OVER_THINK_TIME
        end
        if self:HasModifier("modifier_unit_freeze_lua") or GameRules:IsGamePaused() or
            self:HasModifier("modifier_invulnerable") or not self:IsAlive() then
            return STANDARD_THINK_TIME
        end

        -- Is it casting?
        if self:HasModifier("modifier_casting") then
            return GAME_OVER_THINK_TIME
        end

        -- Try casting an ability
        if self.abilities then
            for i, v in ipairs(self.abilities) do
                if v and not v:IsNull() and v.SkillTrigger and v.Skill and v:IsFullyCastable() and v:SkillTrigger(self) then
                    if v.Skill(self, v) then
                        return v:GetCastPoint() + AI_SKILL_RETURN_TIME
                    end
                end
            end
        end

        -- Look for a new attack target
        if not self:IsAttacking() and not self:IsChanneling() then
            local newTarget, bForce = self:FindNewAttackTarget()
            if newTarget then
                ExecuteOrderFromTable({
                    UnitIndex = self:entindex(),
                    OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
                    Position = newTarget:GetAbsOrigin(),
                    Queue = false
                })
            end
        end

        -- Path point check
        local hitWaypoint, waypointTime = aiCheckWaypoint(self)
        if hitWaypoint then
            return waypointTime
        end

        -- Stuck check and handling
        aiCheckAndHandleStuck(self)

        return KING_THINK_TIME
    end)

    if callComplete and thinkTime then
        return thinkTime
    else
        return KING_THINK_TIME * 3
    end
end

function CheckStuck(self)
    -- Stunned, rooted, busy casting or standing in an attack are legitimate
    -- states: the unit is simply not supposed to move right now.
    if self:IsStunned() or self:IsRooted() or CheckIfHasAggro(nil, self) then
        return false
    end
    if self:IsChanneling() or self:HasModifier("modifier_casting") or self:IsAttacking() then
        return false
    end
    -- Buildings never move, and a unit without orders is handled by resumePatrol.
    if IsCustomBuilding(self) or self:IsIdle() then
        return false
    end

    local now = GameRules:GetGameTime()
    local origin = self:GetAbsOrigin()

    local samples = self.stuckSamples
    if not samples then
        samples = {}
        self.stuckSamples = samples
        self.stuckSampleIndex = 0
    end

    local index = (self.stuckSampleIndex or 0) + 1
    if index > STUCK_SAMPLE_COUNT then
        index = 1
    end
    self.stuckSampleIndex = index
    samples[index] = { t = now, x = origin.x, y = origin.y }

    -- Judge against the oldest sample inside the window.
    local oldest = samples[1]
    for i = 2, STUCK_SAMPLE_COUNT do
        local sample = samples[i]
        if sample and sample.t < oldest.t then
            oldest = sample
        end
    end

    local windowAge = now - oldest.t
    if windowAge < STUCK_WINDOW_SECONDS * 0.8 or windowAge > STUCK_WINDOW_SECONDS * 2 then
        -- Either the window is still filling up, or the samples are stale (the
        -- unit was frozen or the game was paused): start over instead of judging
        -- on bad data.
        if windowAge > STUCK_WINDOW_SECONDS * 2 then
            self.stuckSamples = {}
            self.stuckSampleIndex = 0
        end
        return false
    end

    local dx = origin.x - oldest.x
    local dy = origin.y - oldest.y
    if (dx * dx + dy * dy) > (STUCK_MIN_MOVE_DISTANCE * STUCK_MIN_MOVE_DISTANCE) then
        -- The unit is moving: drop the recovery stage after a quiet period.
        if self.lastStuckTime and now - self.lastStuckTime > STUCK_STAGE_RESET_TIME then
            self.unstuckStage = 0
        end
        return false
    end

    self.lastStuckTime = now
    return true
end

function StandardFindNewAttackTarget(entity)
    local attackTarget = entity:GetAttackTarget()
    if IsActiveUnit(attackTarget)  then
        return attackTarget
    end
    if not attackTarget then
        local acquisitionRange = entity:GetAcquisitionRange()
        local vEnemies = FindUnitsInRadius(entity:GetTeamNumber(), entity:GetOrigin(), nil, acquisitionRange,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES +
                DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE+DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
        if #vEnemies > 0 then
            return vEnemies[1], false
        end
    end
end

function ForceAttackFindNewAttackTarget(entity)
    local attackTarget = entity:GetAttackTarget()
    if IsActiveUnit(attackTarget)  then
        return attackTarget
    end
    if not attackTarget then
        local acquisitionRange = entity:GetAcquisitionRange()
        local vEnemies = FindUnitsInRadius(entity:GetTeamNumber(), entity:GetOrigin(), nil, acquisitionRange,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES +
                DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE+DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
        if #vEnemies > 0 then
            return vEnemies[1], true
        end
    end
end

function FindNewAttackTargetNoModifier(entity,modifierName,magicImmune)
    local flag=DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE
    if magicImmune then
        flag=flag+DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end
    local acquisitionRange = entity:GetAcquisitionRange()
    local vEnemies = FindUnitsInRadius(entity:GetTeamNumber(), entity:GetOrigin(), nil, acquisitionRange,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, 
        flag, FIND_CLOSEST, false)
    for _, enemy in ipairs(vEnemies) do
        if not enemy:HasModifier(modifierName) then
            return enemy,true
        end            
    end
    if #vEnemies > 0 then
        return vEnemies[1], false
    end
end

function FindAttackTargetAirFirst(entity,modifierName,magicImmune)
    local flag=DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE
    if magicImmune then
        flag=flag+DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end
    local acquisitionRange = entity:GetAcquisitionRange()
    local vEnemies = FindUnitsInRadius(entity:GetTeamNumber(), entity:GetOrigin(), nil, acquisitionRange,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, 
        flag, FIND_CLOSEST, false)
    --
    stableSort(vEnemies,function (a,b)
        local v1=1
        local v2=1
        if a:HasFlyMovementCapability() then
            v1=0
        end
        if b:HasFlyMovementCapability() then
            v2=0
        end
        return v1<v2
    end)
    --
    for _, enemy in ipairs(vEnemies) do
        if not enemy:HasModifier(modifierName) then
            if enemy:HasFlyMovementCapability() then
                return enemy,true
            end
            return enemy,false
        end            
    end
    if #vEnemies > 0 then
        return vEnemies[1], false
    end
end


function UseSkillNoTarget(entity, ability)
    entity:CastAbilityNoTarget(ability, -1)
    return 1
end

function UseSkillOnTargetPosition(entity, ability)
    entity:CastAbilityOnPosition(entity:GetAggroTarget():GetAbsOrigin(), ability, -1)
    return 1
end
function UseSkillOnSelfPosition(entity, ability)
    entity:CastAbilityOnPosition(entity:GetAbsOrigin(), ability, -1)
    return 1
end
function UseSkillOnTarget(entity, ability)
    entity:CastAbilityOnTarget(entity:GetAggroTarget(), ability, -1)
    return 1
end

function UseSkillOnSelf(entity, ability)
    entity:CastAbilityOnTarget(entity, ability, -1)
    return 1
end

function UseSkillTargetPositionOptimalRadius(entity, ability)
    local Radius = ability:GetCastRange(Vector(0, 0, 0), entity) + OPTIMAL_SEARCH_RANGE
    local Units = FindUnitsInRadius(entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, Radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
    local TargetUnit
    local mostUnits = 0

    for i, v in pairs(Units) do
        local Radius = ability:GetSpecialValueFor("radius") or ability.CustomAffectRadius
        if not Radius then
            -- print("Tried to run UseSkillTargetPositionOptimalRadius without radius; returning")
            return 10
        end
        local Units = FindUnitsInRadius(entity:GetTeamNumber(), v:GetAbsOrigin(), nil, Radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
        if #Units > mostUnits then
            mostUnits = #Units
            TargetUnit = v
        end
    end

    if TargetUnit == nil then
        -- print("UseSkillTargetPositionOptimalRadius: Couldn't find target unit")
        return STANDARD_THINK_TIME
    end
    entity:CastAbilityOnPosition(TargetUnit:GetAbsOrigin(), ability, -1)
    return 1
end

function UseSkillTargetOptimalRadius(entity, ability)
    local Radius = ability:GetCastRange(Vector(0, 0, 0), entity) + OPTIMAL_SEARCH_RANGE
    local Units = FindUnitsInRadius(entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, Radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
    local TargetUnit
    local mostUnits = 0

    for i, v in pairs(Units) do
        local Radius = ability:GetSpecialValueFor("radius") or ability.CustomAffectRadius
        if not Radius then
            -- print("Tried to run UseSkillTargetOptimalRadius without radius; returning")
            return 10
        end
        local Units = FindUnitsInRadius(entity:GetTeamNumber(), v:GetAbsOrigin(), nil, Radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
        if #Units > mostUnits then
            mostUnits = #Units
            TargetUnit = v
        end
    end

    if TargetUnit == nil then
        -- print("UseSkillTargetOptimalRadius: Couldn't find target unit")
        return STANDARD_THINK_TIME
    end
    entity:CastAbilityOnTarget(TargetUnit, ability, -1)
    return 1
end

function UseSkillTargetOnClosest(entity, ability)
    local Radius = ability:GetCastRange(Vector(0, 0, 0), entity) + OPTIMAL_SEARCH_RANGE
    local Units = FindUnitsInRadius(entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, Radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
    local TargetUnit
    
    if #Units>0 then
        TargetUnit=Units[1]
    end
    if TargetUnit == nil then
        -- print("UseSkillTargetOptimalRadius: Couldn't find target unit")
        return STANDARD_THINK_TIME
    end
    entity:CastAbilityOnTarget(TargetUnit, ability, -1)
    return 1
end

function UseSkillTargetPositionOnClosest(entity, ability)
    local Radius = ability:GetCastRange(Vector(0, 0, 0), entity) + OPTIMAL_SEARCH_RANGE
    local Units = FindUnitsInRadius(entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, Radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
    local TargetUnit
    if #Units>0 then
        TargetUnit=Units[1]
    end
    if TargetUnit == nil then
        return STANDARD_THINK_TIME
    end
    entity:CastAbilityOnPosition(TargetUnit:GetAbsOrigin(), ability, -1)
    return 1
end

function UseSkillTargetNoModifier(entity, ability,modifierName,modifierName2) 
    local Radius = ability:GetCastRange(Vector(0, 0, 0), entity) + OPTIMAL_SEARCH_RANGE
    local Units = FindUnitsInRadius(entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, Radius,
    DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
    local TargetUnit = nil
    for i, v in pairs(Units) do
        if v~=entity and (not v:HasModifier(modifierName)) and (not v:HasModifier(modifierName2))  then
            TargetUnit=v
            break
        end
    end
    if TargetUnit == nil then
        return false
    end
    entity:CastAbilityOnTarget(TargetUnit, ability, -1)
    return true
end
--
function UseSkillTargetMostEHPPhysical(entity, ability)
    local Radius = ability:GetCastRange(Vector(0, 0, 0), entity) + OPTIMAL_SEARCH_RANGE
    local Units = FindUnitsInRadius(entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, Radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
    local TargetUnit
    local mostEHP = 0

    for i, v in pairs(Units) do
        local armor = v:GetPhysicalArmorValue(true)
        local EHP = v:GetHealth() / (1 - 0.06 * armor / (1 + (0.06 * math.abs(armor))))
        -- from http://dota2.gamepedia.com/Armor#Damage_multiplier
        if EHP > mostEHP then
            TargetUnit = v
            mostEHP = EHP
        end
    end

    if TargetUnit == nil then
        -- print("UseSkillTargetMostEHPPhysical: Couldn't find target unit")
        return STANDARD_THINK_TIME
    end
    entity:CastAbilityOnTarget(TargetUnit, ability, -1)
    return 1
end

function UseSkillTargetMostLowHpPctFriend(entity, ability)
    local Radius = ability:GetCastRange(Vector(0, 0, 0), entity) + OPTIMAL_SEARCH_RANGE
    local Units = FindUnitsInRadius(entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, Radius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
    local TargetUnit = nil
    local hpPct = 100

    for i, v in pairs(Units) do
        local hp1 = v:GetHealthPercent()
        if hp1 < hpPct then
            TargetUnit = v
            hpPct = hp1
        end
    end

    if TargetUnit == nil then
        -- print("UseSkillTargetMostEHPPhysical: Couldn't find target unit")
        return false
    end
    entity:CastAbilityOnTarget(TargetUnit, ability, -1)
    return true
end


function AiFindAbilityTarget(entity, ability,params)
    if not params then
        params={}
    end

    local findOrder = FIND_CLOSEST
    if params.findOrder then
        findOrder = params.findOrder
    end
    local radius=params.radius
    if radius==nil then
        radius=ability:GetCastRange(Vector(0, 0, 0), entity)
    end

    local pos=params.pos
    if not pos then
        pos=entity:GetAbsOrigin()
    end

    local targetTeam=params.targetTeam or ability:GetAbilityTargetTeam()
    local targetType=params.targetType or ability:GetAbilityTargetType()
    local targetFlag=params.targetFlag or ability:GetAbilityTargetFlags()

    local Units = FindUnitsInRadius(entity:GetTeamNumber(), pos, nil, radius,
    targetTeam, targetType, targetFlag, findOrder, false)

    return Units
end
function AiFindFriends(entity, ability,params)
    if not params then
        params={}
    end
    local Radius = ability:GetCastRange(Vector(0, 0, 0), entity) + OPTIMAL_SEARCH_RANGE
    local Units = FindUnitsInRadius(entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, Radius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
    return Units
end

function AiFilterNoModifier(units, modName)
    local res={}
    for i, v in pairs(units) do
        if (not v:HasModifier(modName)) then
            table.insert(res,v)
        end
    end
    return res
end

function AiFilterNotKing(units)
    local res={}
    for i, v in pairs(units) do
        if v:GetUnitName()~="king_good" and v:GetUnitName()~="king_bad" then
            table.insert(res,v)
        end
    end
    return res
end

function AiFilterNotStunned(units)
    local res={}
    for i, v in pairs(units) do
        if (not v:IsStunned()) then
            table.insert(res,v)
        end
    end
    return res
end

function AiFilterNoTag(units, tagName)
    local res={}
    for i, v in pairs(units) do
        if (not UTIL:checkUnitTag(v,tagName)) then
            table.insert(res,v)
        end
    end
    return res
end

function AiFilterNotBuilding(units)
    local res={}
    for i, v in pairs(units) do
        if (not IsCustomBuilding(v)) then
            table.insert(res,v)
        end
    end
    return res
end

function AiFilterMoveCapability(units, moveCap)
    local res={}
    for i, v in pairs(units) do
        if moveCap==DOTA_UNIT_CAP_MOVE_GROUND  and v:HasGroundMovementCapability() then
            table.insert(res,v)
        elseif moveCap==DOTA_UNIT_CAP_MOVE_FLY  and v:HasFlyMovementCapability() then
            table.insert(res,v)
        elseif moveCap==DOTA_UNIT_CAP_MOVE_NONE and not v:HasGroundMovementCapability() and not v:HasFlyMovementCapability() then
            table.insert(res,v)
        end
    end
    return res
end

function AiFilterHealthPct(units, pct)
    local res={}
    for i, v in pairs(units) do
        if (v:GetHealthPercent()<pct) then
            table.insert(res,v)
        end
    end
    return res
end

function AiFilterNotUnit(units, unit)
    local res={}
    for i, v in pairs(units) do
        if v~=unit then
            table.insert(res,v)
        end
    end
    return res
end

function AiOrderByHealthLose(units, bAsc)
    stableSort(units,function (a, b)
        local healLoseA=a:GetMaxHealth()-a:GetHealth()
        local healLoseB=b:GetMaxHealth()-b:GetHealth()
        if bAsc then
            return healLoseA<healLoseB
        else
            return healLoseA>healLoseB
        end
    end)
    return units
end


function AiOrderByHealth(units, bAsc)
    stableSort(units,function (a, b)
        if bAsc then
            return a:GetHealth()<b:GetHealth()
        else
            return a:GetHealth()>b:GetHealth()
        end
    end)
    return units
end

function AiOrderByAttackDamage(units, bAsc)
    stableSort(units,function (a, b)
        if bAsc then
            return a:GetAverageTrueAttackDamage(a)<b:GetAverageTrueAttackDamage(b)
        else
            return a:GetAverageTrueAttackDamage(a)>b:GetAverageTrueAttackDamage(b)
        end
    end)
    return units
end

function AiOrderByDps(units, bAsc)
    stableSort(units,function (a, b)
        local dpsA=a:GetAverageTrueAttackDamage(a)*a:GetAttacksPerSecond(true)
        local dpsB=b:GetAverageTrueAttackDamage(b)*b:GetAttacksPerSecond(true)
        if bAsc then
            return dpsA<dpsB
        else
            return dpsA>dpsB
        end
    end)
    return units
end

function AiOrderByNoModifier(units,modifierName, bAsc)

    if bAsc==nil then
        bAsc=true
    end

    stableSort(units,function (a, b)
        local hasA=bool_to_number(a:HasModifier(modifierName))
        local basB=bool_to_number(b:HasModifier(modifierName))
        if bAsc then
            return hasA<basB
        else
            return hasA>basB
        end
    end)
    return units
end



function AiOrderByHealthPct(units, bAsc)
    stableSort(units,function (a, b)
        if bAsc then
            return a:GetHealthPercent()<b:GetHealthPercent()
        else
            return a:GetHealthPercent()>b:GetHealthPercent()
        end
    end)
    return units
end

function AiOrderByAttack(units, bAsc)
    stableSort(units,function (a, b)
        if bAsc then
            return a:GetAverageTrueAttackDamage(a)<b:GetAverageTrueAttackDamage(b)
        else
            return a:GetAverageTrueAttackDamage(a)>b:GetAverageTrueAttackDamage(b)
        end
    end)
    return units
end

function AiOrderByAttackCap(units, bMeleeFirst)
    stableSort(units,function (a, b)
        if bMeleeFirst then
            return a:GetAttackCapability()<b:GetAttackCapability()
        else
            return a:GetAttackCapability()>b:GetAttackCapability()
        end
    end)
    return units
end

function UseSkillTargetFriendNoModifier(entity, ability,modifierName,modifierName2) 
    local Radius = ability:GetCastRange(Vector(0, 0, 0), entity) + OPTIMAL_SEARCH_RANGE
    local Units = FindUnitsInRadius(entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, Radius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
    local TargetUnit = nil
    for i, v in pairs(Units) do
        if v~=entity and (not v:HasModifier(modifierName)) and (not v:HasModifier(modifierName2)) then
            TargetUnit=v
            break
        end
    end
    if TargetUnit==nil and (not entity:HasModifier(modifierName)) and (not entity:HasModifier(modifierName2)) then
        TargetUnit=entity
    end
    
    if TargetUnit == nil then
        return false
    end
    entity:CastAbilityOnTarget(TargetUnit, ability, -1)
    return true
end

function NextWayPoint(self)
    if self.wayStep < #self.waypoints then
        self.wayStep = self.wayStep + 1
        ExecuteOrderFromTable({
            UnitIndex = self:entindex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
            TargetIndex = 0,
            AbilityIndex = 0,
            Position = self.waypoints[self.wayStep],
            Queue = 0
        })
    end
    return STANDARD_THINK_TIME
end

function Unstuck(self)
    local now = GameRules:GetGameTime()
    if self.unstuckCooldown and now < self.unstuckCooldown then
        return UNSTUCK_RETURN_TIME
    end

    -- Escalate the recovery step by step: re-issue the order first, then squeeze
    -- the unit out with a short phase, and only as a last resort ask the engine
    -- for a clear spot.
    local stage = math.min((self.unstuckStage or 0) + 1, STUCK_MAX_STAGE)
    self.unstuckStage = stage
    self.unstuckCooldown = now + UNSTUCK_RETURN_TIME * stage

    -- Reset the window, otherwise the samples collected while blocked would
    -- report "stuck" again on the very next think.
    self.stuckSamples = {}
    self.stuckSampleIndex = 0

    local goal = getMoveGoal(self)
    if not goal then
        return UNSTUCK_RETURN_TIME
    end

    local origin = self:GetAbsOrigin()
    local direction = goal - origin
    if direction:Length2D() < 1 then
        direction = self:GetForwardVector()
    else
        direction = direction:Normalized()
    end

    if stage == 1 then
        issueMoveOrder(self, goal)
    elseif stage == 2 then
        self:AddNewModifier(nil, nil, "modifier_phased", { duration = STUCK_PHASED_DURATION })
        issueMoveOrder(self, origin + direction * STUCK_NUDGE_DISTANCE)
    else
        FindClearSpaceForUnit(self, origin + direction * STUCK_NUDGE_DISTANCE, true)
    end

    if Convars:GetInt("dota_legiontd_debug") == 1 then
        print("[AI unstuck] " .. self:GetUnitName() .. " stage " .. stage
            .. " at " .. tostring(math.floor(origin.x)) .. "," .. tostring(math.floor(origin.y)))
    end

    return UNSTUCK_RETURN_TIME
end

function CheckIfHasAggroInRange(ability, entity)
    AggroTarget = entity:GetAggroTarget()
    if AggroTarget ~= nil then
        if CalcDistanceBetweenEntityOBB(entity, AggroTarget) < ability.SkillUseRange then
            return true
        end
    end
    return false
end

function CheckIfHasAggro(ability, entity)
    return entity:GetAggroTarget() ~= nil
end

function AiGetPresetCastTarget(ability,range)

    local caster=ability:GetCaster()
    if range==nil then
        range=ability:GetCastRange(Vector(0, 0, 0), caster)
    end
    local target = nil
    local targetFighterId = GamePlay:FighterGetAbilityTarget(caster.fighterId, ability:GetAbilityName())
    local targetFighter = GamePlay:FighterGetUnit(targetFighterId)
    if IsActiveUnit(targetFighter)
        and (targetFighter:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() < range
    then
        target = targetFighter
    end
    return target
end

function CheckEnemyCountInRange(ability, entity, count, range)
    local Radius = ability:GetCastRange(Vector(0, 0, 0), entity)
    if range then
        Radius=range
    end
    local Units = FindUnitsInRadius(entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, Radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_CREEP+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, 0, false)

    if #Units >= count then
        return true
    end
    return false
end

function CheckGroundEnemyCountInRange(ability, entity, count, range)
    local Radius = ability:GetCastRange(Vector(0, 0, 0), entity)
    if range then
        Radius=range
    end
    local Units = FindUnitsInRadius(entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, Radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_CREEP+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, 0, false)

    local c=0
    for _, unit in ipairs(Units) do
        if unit:HasGroundMovementCapability() then
            c=c+1
        end
    end    
    return c>=count
end

function GetUnitCountInRange(entity, range, groundOnly)
    local Units = FindUnitsInRadius(entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, range,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_CREEP+DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, 0, false)
    local c=0
    for _, unit in ipairs(Units) do
        if groundOnly and unit:HasGroundMovementCapability() then
            c=c+1
        elseif not groundOnly then
            c=c+1
        end
    end
    return c
end

function CheckEnemyCountInRangeEx(ability, entity, groundOnly, count, range, count2)
    if range==nil then
        range=ability:GetCastRange(Vector(0, 0, 0), entity)
    end
    local c1=GetUnitCountInRange(entity, range, groundOnly)
    if c1>=count then
        return true
    end
    if count2 then
        local radius=ability:GetSpecialValueFor("radius")
        local c2=GetUnitCountInRange(entity, radius, groundOnly)
        if c2>=count2 then
            return true
        end
    end
    return false
end

function CheckUnstunEnemyCountInRange(ability, entity, count, range)
    local Radius = ability:GetCastRange(Vector(0, 0, 0), entity)
    if range then
        Radius=range
    end
    local Units = FindUnitsInRadius(entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, Radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, 0, false)
    local c=0
    for _, unit in pairs(Units) do
        if not unit:IsStunned() then
            c=c+1
            if c>=count then
                return true
            end
        end
    end
    return false
end

function CheckFriendLowHpAbilityRange(ability, entity,pct)
    local Radius = ability:GetCastRange(Vector(0, 0, 0), entity)
    local Units = FindUnitsInRadius(entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, Radius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, 0, 0, false)
    for key, unit in pairs(Units) do
        if unit:GetHealthPercent() < 100 then
            return true
        end
    end
    return false
end

function CheckFriendAbilityRange(ability, entity)
    local Radius = ability:GetCastRange(Vector(0, 0, 0), entity)
    local Units = FindUnitsInRadius(entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, Radius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, 0, 0, false)

    if #Units > 0 then
        return true
    end
    return false
end

return EXPORTS
