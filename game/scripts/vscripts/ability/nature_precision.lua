LinkLuaModifier( "modifier_nature_precision", "ability/nature_precision.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if nature_precision == nil then
	nature_precision = class({})
end
function nature_precision:GetIntrinsicModifierName()
	return "modifier_nature_precision"
end
---------------------------------------------------------------------
--Modifiers


modifier_nature_precision = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_nature_precision:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.chance=ability:GetSpecialValueFor("chance")
	self.crit=ability:GetSpecialValueFor("crit")
	if IsServer() then
	end
end
function modifier_nature_precision:IsPurgable(params)
	return false
end
function modifier_nature_precision:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_nature_precision:OnDestroy()
	if IsServer() then
	end
end
function modifier_nature_precision:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
	}
end


function modifier_nature_precision:GetModifierPreAttack_CriticalStrike( params )
	if not IsServer() then return end

	local attacker=params.attacker  
	local target=params.target  

	if RandomInt(1, 100)<=self.chance then
		return self.crit
	end
end
