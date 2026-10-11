LinkLuaModifier( "modifier_marine_brawl", "ability/marine_brawl.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if marine_brawl == nil then
	marine_brawl = class({})
end
function marine_brawl:GetIntrinsicModifierName()
	return "modifier_marine_brawl"
end
---------------------------------------------------------------------
--Modifiers


modifier_marine_brawl = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_marine_brawl:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.crit=ability:GetSpecialValueFor("crit")

	if IsServer() then
	end
end
function modifier_marine_brawl:IsPurgable(params)
	return false
end
function modifier_marine_brawl:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_marine_brawl:OnDestroy()
	if IsServer() then
	end
end
function modifier_marine_brawl:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
	}
end

function modifier_marine_brawl:GetModifierPreAttack_CriticalStrike( params )
	if not IsServer() then return end
	local attacker=params.attacker  
	local target=params.target  
	if target and target:HasFlyMovementCapability() then
		return self.crit
	end
end
