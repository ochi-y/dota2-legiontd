LinkLuaModifier( "modifier_death_spawn", "ability/death_spawn.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if death_spawn == nil then
	death_spawn = class({})
end
function death_spawn:GetIntrinsicModifierName()
	return "modifier_death_spawn"
end
---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_death_spawn = class({
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    IsDebuff = function(self)
        return false
    end,
    IsBuff = function(self)
        return true
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_NONE
    end
})
function modifier_death_spawn:AllowIllusionDuplicate()
    return false
end

function modifier_death_spawn:OnCreated(params)
    if not self:GetAbility() then return end
	local ability=self:GetAbility()

    self.bonus_base_damage=ability:GetSpecialValueFor("bonus_base_damage")  
	self.model_scale=ability:GetSpecialValueFor("model_scale")  
	self.bonus_base_damage_fly=ability:GetSpecialValueFor("bonus_base_damage_fly")  

    self:SetStackCount(ability:GetLevel())
end

function modifier_death_spawn:OnRefresh(params)
    if not self:GetAbility() then return end
	local ability=self:GetAbility()

    self.bonus_base_damage=ability:GetSpecialValueFor("bonus_base_damage")  
	self.model_scale=ability:GetSpecialValueFor("model_scale")  
	self.bonus_base_damage_fly=ability:GetSpecialValueFor("bonus_base_damage_fly")  

    self:SetStackCount(ability:GetLevel())
end

function modifier_death_spawn:DeclareFunctions()
    local funcs = {
    MODIFIER_EVENT_ON_DEATH, 
    MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    MODIFIER_PROPERTY_MODEL_SCALE}
    return funcs
end

function modifier_death_spawn:GetModifierModelScale()
	return  self.model_scale
end

function modifier_death_spawn:CheckState()
    return {}
end
-- TEMP DIAGNOSTIC: prints which damage getters the unit actually exposes.
-- Remove together with the block inside GetModifierBaseAttack_BonusDamage once
-- the GetBaseDamageMin question is settled.
local damageApiDiagCount = 0
local damageApiDiagMisses = {}

local function probeCall(fn)
    local ok, value = pcall(fn)
    if not ok then
        return "error: " .. tostring(value)
    end
    return tostring(value)
end

function modifier_death_spawn:GetModifierBaseAttack_BonusDamage()
    local parent = self:GetParent()
    local res = 0
    if self.flag then
        return 0
    end

    self.flag = true
    --melee 0.4
    --range 0.4
    --fly   0.6
    local damage=self.bonus_base_damage
    if parent:HasFlyMovementCapability() then
        damage=self.bonus_base_damage_fly
    end
    if damageApiDiagCount < 3 then
        damageApiDiagCount = damageApiDiagCount + 1
        print("[death_spawn][diag] unit=" .. tostring(parent:GetUnitName())
            .. " entindex=" .. tostring(parent:entindex())
            .. " class=" .. probeCall(function() return parent:GetClassname() end)
            .. " IsBuilding=" .. probeCall(function() return parent:IsBuilding() end)
            .. " flyCapable=" .. probeCall(function() return parent:HasFlyMovementCapability() end)
            .. " GetBaseDamageMin=" .. probeCall(function() return parent:GetBaseDamageMin() end)
            .. " GetBaseDamageMax=" .. probeCall(function() return parent:GetBaseDamageMax() end)
            .. " GetDamageMin=" .. probeCall(function() return parent:GetDamageMin() end)
            .. " GetDamageMax=" .. probeCall(function() return parent:GetDamageMax() end)
            .. " GetAttackDamage=" .. probeCall(function() return parent:GetAttackDamage() end))
    end
    -- Anything that really is missing the damage getters is reported once per
    -- unit, so the culprit is visible without flooding the console.
    if not parent.GetBaseDamageMin or not parent.GetBaseDamageMax then
        local key = tostring(parent:GetUnitName()) .. "#" .. tostring(parent:entindex())
        if not damageApiDiagMisses[key] then
            damageApiDiagMisses[key] = true
            print("[death_spawn][diag][MISSING] unit=" .. key
                .. " class=" .. probeCall(function() return parent:GetClassname() end)
                .. " IsBuilding=" .. probeCall(function() return parent:IsBuilding() end)
                .. " IsHero=" .. probeCall(function() return parent:IsHero() end)
                .. " IsIllusion=" .. probeCall(function() return parent:IsIllusion() end)
                .. " IsSummoned=" .. probeCall(function() return parent:IsSummoned() end)
                .. " GetDamageMin=" .. probeCall(function() return parent:GetDamageMin() end)
                .. " GetDamageMax=" .. probeCall(function() return parent:GetDamageMax() end)
                .. " GetAttackDamage=" .. probeCall(function() return parent:GetAttackDamage() end)
                .. " parent=" .. tostring(parent))
        end
    end
    res = math.floor((damage/100) * (parent:GetBaseDamageMin() + parent:GetBaseDamageMax()) / 2)
    self.flag = false
    return res
end


local function copyModifier(fromUnit,toUnit,modifierList)
    for _, modName in ipairs(modifierList) do
        local mod=fromUnit:FindModifierByName(modName)
        if mod then
            local mod1=toUnit:AddNewModifier(mod:GetCaster(),mod:GetAbility(),modName,{
            })
            mod1:SetStackCount(mod:GetStackCount())
        end
    end
end



function modifier_death_spawn:OnDeath(params)
    if IsServer() then
        if params.unit == self:GetCaster() then
            local caster = self:GetParent()

            local attacker = params.attacker

            if attacker and attacker == self:GetCaster() then
                return
            end
            local pos = caster:GetAbsOrigin()
            local lane = caster.path
            local laneData = GamePlay.laneTable[lane]

            local splitUnitName = caster:GetUnitName()
            local pid = caster:GetPlayerOwnerID()
            local hero = PlayerResource:GetSelectedHeroEntity(pid)

            local spawnDistance=200
            local dir=(- caster:GetForwardVector():Normalized())
            if lane and LANE_META[lane] and LANE_META[lane].zoneDirections[caster.zoneIndex] then
                dir=LANE_META[lane].zoneDirections[caster.zoneIndex]
            end
            local pos1=pos + dir * spawnDistance
            local newPos = pos1
            local tUnit = CreateUnitByName(splitUnitName, newPos, false, hero, hero, caster:GetTeamNumber())
            -- SimpleMoveUnit(tUnit,pos)
            tUnit:AddNewModifier(nil, nil, "modifier_phased", {
                duration = 0.1
            })
            -- 
            copyModifier(caster,tUnit,{"modifier_gameplay_nogold","modifier_center_zone","modifier_provides_fow_position"})
            -- 
            alignAngle(tUnit, caster)
            
            local level = self:GetAbility():GetLevel()
            if level > 1 then
				AddAbilityAndSetLevel(tUnit,"death_spawn",level-1)
            end

            copyManaAndCD(caster,tUnit)
            PlayEffOnUnit("particles/units/heroes/hero_lycan/lycan_summon_wolves_spawn.vpcf", tUnit)

            --
            tUnit.wayStep = caster.wayStep
            tUnit.waypoints = caster.waypoints
            tUnit.zoneIndex = caster.zoneIndex
            -- 
            tUnit.path = lane
            tUnit.subPath = 0
            -- GamePlay:moveCreep(tUnit, lane, 0,true)
            table.insert(laneData.roundUnits, tUnit)
        end
    end
    return 0
end
