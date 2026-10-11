LinkLuaModifier( "modifier_nature_vulture_eye", "ability/nature_vulture_eye.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if nature_vulture_eye == nil then
	nature_vulture_eye = class({})
end
function nature_vulture_eye:GetIntrinsicModifierName()
	return "modifier_nature_vulture_eye"
end
---------------------------------------------------------------------
--Modifiers


modifier_nature_vulture_eye = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_nature_vulture_eye:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.chance=ability:GetSpecialValueFor("chance")
	self.crit=ability:GetSpecialValueFor("crit")

	if IsServer() then
	end
end
function modifier_nature_vulture_eye:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_nature_vulture_eye:OnDestroy()
	if IsServer() then
	end
end
function modifier_nature_vulture_eye:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
	}
end

function modifier_nature_vulture_eye:GetModifierPreAttack_CriticalStrike( params )
	if not IsServer() then return end

	local attacker=params.attacker  
	local target=params.target  


	if RandomInt(1, 100)<=self.chance and target and target:HasFlyMovementCapability() then
		return self.crit
	end
end
