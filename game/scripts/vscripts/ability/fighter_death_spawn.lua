LinkLuaModifier( "modifier_fighter_death_spawn", "ability/fighter_death_spawn.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if fighter_death_spawn == nil then
	fighter_death_spawn = class({})
end
function fighter_death_spawn:GetIntrinsicModifierName()
	return "modifier_fighter_death_spawn"
end
---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_fighter_death_spawn = class({
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
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})
function modifier_fighter_death_spawn:AllowIllusionDuplicate()
    return true
end


function modifier_fighter_death_spawn:OnCreated(params)

	local ability=self:GetAbility()
	self.bonus_base_damage=ability:GetSpecialValueFor("bonus_base_damage")  
	self.model_scale=ability:GetSpecialValueFor("model_scale")  
	self:SetStackCount(ability:GetLevel())
    
end

function modifier_fighter_death_spawn:OnRefresh(params)

	local ability=self:GetAbility()
	self.bonus_base_damage=ability:GetSpecialValueFor("bonus_base_damage")  
	self.model_scale=ability:GetSpecialValueFor("model_scale")  


	self:SetStackCount(ability:GetLevel())

end
function modifier_fighter_death_spawn:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH, MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_PROPERTY_MODEL_SCALE,
		-- MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
    }
    return funcs
end


function modifier_fighter_death_spawn:GetModifierModelScale()
    return self.model_scale
end

function modifier_fighter_death_spawn:CheckState()
    return {}
end
function modifier_fighter_death_spawn:GetModifierBaseAttack_BonusDamage()
    local parent = self:GetParent()
    local res = 0
    if self.flag then
        return 0
    end

    self.flag = true
    -- melee 0.4
    -- range 0.4
    -- fly   0.6
    local damage = self.bonus_base_damage
    if parent:HasFlyMovementCapability() then
        damage = self.bonus_base_damage
    end
    -- 
    res = math.floor((damage/100)  * (parent:GetBaseDamageMin() + parent:GetBaseDamageMax()) / 2)
    self.flag = false
    return res
end

local function copyModifier(fromUnit, toUnit, modifierList)
    for _, modName in ipairs(modifierList) do
        local mod = fromUnit:FindModifierByName(modName)
        if mod then
            local mod1 = toUnit:AddNewModifier(mod:GetCaster(), mod:GetAbility(), modName, {})
            mod1:SetStackCount(mod:GetStackCount())
        end
    end
end

function modifier_fighter_death_spawn:OnDeath(params)
    if IsServer() then

        local caster = self:GetParent()
        if caster:IsIllusion() then
            return
        end
        -- if caster:IsSummoned() then
        --     return
        -- end

        local unitBlackList={
           
        }

        if TableContainsValue(unitBlackList,caster:GetUnitName()) then
            return  
        end
        
        if params.unit == self:GetCaster() then
            
            local attacker = params.attacker
            
            local pos = caster:GetAbsOrigin()

            local splitUnitName = caster:GetUnitName()
            local pid = caster:GetPlayerOwnerID()
            local pdata = Player:GetPData(pid)
            local hero = PlayerResource:GetSelectedHeroEntity(pid)

            local spawnDistance = 200
            local pos1 = pos - caster:GetForwardVector():Normalized() * spawnDistance
            local newPos = RandomPointInRadius(pos1, 50)

            local tUnit = CreateUnitByName(splitUnitName, newPos, false, hero, hero, caster:GetTeamNumber())
            -- SimpleMoveUnit(tUnit,pos)
            tUnit:AddNewModifier(nil, nil, "modifier_phased", {
                duration = 0.1
            })

            if IsInToolsMode() and Convars:GetInt("dota_legiontd_debug")==1 then
                tUnit:SetControllableByPlayer(0,true)
            end

            copyModifier(caster, tUnit,
                {})

            -- 
            alignAngle(tUnit, caster)
            local level = self:GetAbility():GetLevel()
            if level > 1 then
				AddAbilityAndSetLevel(tUnit,"fighter_death_spawn",level-1)
                PlayChaosBoltNum(tUnit,level-1,0)
            end
			
			copyManaAndCD(caster,tUnit)

            tUnit.wayStep = caster.wayStep
            tUnit.waypoints = caster.waypoints

            PlayEffOnUnit("particles/units/heroes/hero_lycan/lycan_summon_wolves_spawn.vpcf", tUnit)
            if pdata then
                table.insert(pdata.creeps, tUnit)
            end
        end
    end
    return 0
end
