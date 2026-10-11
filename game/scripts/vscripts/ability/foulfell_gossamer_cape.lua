LinkLuaModifier("modifier_foulfell_gossamer_cape", "ability/foulfell_gossamer_cape.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_foulfell_gossamer_cape_timer", "ability/foulfell_gossamer_cape.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
foulfell_gossamer_cape = class({})

foulfell_gossamer_cape_2 = foulfell_gossamer_cape


function foulfell_gossamer_cape:GetIntrinsicModifierName()
	return "modifier_foulfell_gossamer_cape"
end

-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_foulfell_gossamer_cape = class({
	IsHidden = function(self)
		return true
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
function modifier_foulfell_gossamer_cape:AllowIllusionDuplicate()
	return false
end

function modifier_foulfell_gossamer_cape:OnCreated(params)
	local ability = self:GetAbility()
	self.cooldown = ability:GetSpecialValueFor("cooldown")
end

function modifier_foulfell_gossamer_cape:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_foulfell_gossamer_cape:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_FAIL
	}
end

function modifier_foulfell_gossamer_cape:GetModifierEvasion_Constant(params)
	if not self:GetCaster():HasModifier("modifier_foulfell_gossamer_cape_timer") then
		return 100
	end
	return 0
end

function modifier_foulfell_gossamer_cape:OnAttackFail(params)
	local attacker = params.attacker
	local target = params.target
	local caster = self:GetCaster()
	if caster == target then
		if self:GetAbility():IsCooldownReady() then
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_foulfell_gossamer_cape_timer", {
				duration = self.cooldown
			})
			self:GetAbility():StartCooldown(self.cooldown)
		end
	end
end

-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_foulfell_gossamer_cape_timer = class({
	IsHidden = function(self)
		return true
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
function modifier_foulfell_gossamer_cape_timer:AllowIllusionDuplicate()
	return false
end

function modifier_foulfell_gossamer_cape_timer:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	if not IsServer() then return end
end

function modifier_foulfell_gossamer_cape_timer:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_foulfell_gossamer_cape_timer:DeclareFunctions()
	return {

	}
end
