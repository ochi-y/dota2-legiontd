LinkLuaModifier( "modifier_barrack_anti_king", "ability/barrack_anti_king.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if barrack_anti_king == nil then
	barrack_anti_king = class({})
end
function barrack_anti_king:GetIntrinsicModifierName()
	return "modifier_barrack_anti_king"
end
---------------------------------------------------------------------
--Modifiers
if modifier_barrack_anti_king == nil then
	modifier_barrack_anti_king = class({})
end
function modifier_barrack_anti_king:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.crit=ability:GetSpecialValueFor("crit")
	
	if IsServer() then
	end
end
function modifier_barrack_anti_king:IsPurgable(params)
	return false
end
function modifier_barrack_anti_king:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_barrack_anti_king:OnDestroy()
	if IsServer() then
	end
end
function modifier_barrack_anti_king:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
	}
end


function modifier_barrack_anti_king:GetModifierPreAttack_CriticalStrike( params )
	if not IsServer() then return end

	local attacker=params.attacker  
	local target=params.target  

	if target and target:HasModifier("modifier_king_bouns") then
		return self.crit
	end
end
