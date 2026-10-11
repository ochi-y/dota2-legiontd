LinkLuaModifier("modifier_auto_test_passive", "ability/auto_test_passive.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_auto_test_passive_cd", "ability/auto_test_passive.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if auto_test_passive == nil then
	auto_test_passive = class({})
end
function auto_test_passive:GetIntrinsicModifierName()
	return "modifier_auto_test_passive"
end

---------------------------------------------------------------------
--Modifiers
if modifier_auto_test_passive == nil then
	modifier_auto_test_passive = class({})
end
function modifier_auto_test_passive:OnCreated(params)
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_auto_test_passive:OnRefresh(params)
	if IsServer() then
	end
end

function modifier_auto_test_passive:OnIntervalThink()
	if not self:GetAbility() then return end
	if not IsServer() then return end

	local caster = self:GetCaster()
	if caster:HasModifier("modifier_auto_test_passive_cd") then
		return
	end
	if caster.targetPos and caster:IsIdle() then
		moveAttack(caster,caster.targetPos)
	end
	local abilityCount = caster:GetAbilityCount() or 0
	for i = 0, abilityCount - 1 do
		local ab = caster:GetAbilityByIndex(i)
		if ab then
			local kv=GetAbilityKeyValuesByName(ab:GetAbilityName())
			local behav=kv.AbilityBehavior
			if ab:IsFullyCastable() then
				if string.find(behav,"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET") then
					local units = AiFindAbilityTarget(caster, ab,{})
					Shuffle(units)
					if #units>0 then
						caster:CastAbilityOnTarget(units[1], ab, -1)
						caster:AddNewModifier(caster, self:GetAbility(), "modifier_auto_test_passive_cd", {
							duration = 3
						})
					end
				elseif string.find(behav,"DOTA_ABILITY_BEHAVIOR_TOGGLE") then 
					caster:CastAbilityToggle(ab, -1)
					caster:AddNewModifier(caster, self:GetAbility(), "modifier_auto_test_passive_cd", {
							duration = 3
						})
				elseif string.find(behav,"DOTA_ABILITY_BEHAVIOR_NO_TARGET") then 
					caster:CastAbilityNoTarget(ab, -1)
					caster:AddNewModifier(caster, self:GetAbility(), "modifier_auto_test_passive_cd", {
							duration = 3
						})
				elseif string.find(behav,"DOTA_ABILITY_BEHAVIOR_POINT") then 
					local castPos = caster:GetForwardVector()*100+caster:GetAbsOrigin()
					caster:CastAbilityOnPosition(castPos,ab, -1)
					caster:AddNewModifier(caster, self:GetAbility(), "modifier_auto_test_passive_cd", {
							duration = 3
						})
				end	
			end
		else
			break
		end
	end
end

function modifier_auto_test_passive:OnDestroy()
	if IsServer() then
	end
end

function modifier_auto_test_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
end

function modifier_auto_test_passive:GetModifierConstantManaRegen()
	return 20
end
function modifier_auto_test_passive:OnAbilityFullyCast(keys)
	if IsServer() then
		local castAbility = keys.ability
		local ability=self:GetAbility()
		if castAbility then
			local unit=keys.unit
			local parent = self:GetParent()
			if unit==parent then
				if castAbility:GetCooldownTimeRemaining()>5 then
					castAbility:EndCooldown()
					castAbility:StartCooldown(5)
				end
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_auto_test_passive_cd = class({
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
function modifier_auto_test_passive_cd:AllowIllusionDuplicate()
	return false
end

function modifier_auto_test_passive_cd:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	if not IsServer() then return end
end

function modifier_auto_test_passive_cd:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_auto_test_passive_cd:DeclareFunctions()
	return {

	}
end

function modifier_auto_test_passive_cd:CheckState()
	local state = {

	}

	return state
end
