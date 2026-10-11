LinkLuaModifier("modifier_cant_move", "ability/cant_move.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if cant_move == nil then
	cant_move = class({})
end
function cant_move:GetIntrinsicModifierName()
	return "modifier_cant_move"
end
-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_cant_move = class({
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
function modifier_cant_move:AllowIllusionDuplicate()
	return false
end

function modifier_cant_move:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	if not IsServer() then return end
end

function modifier_cant_move:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_cant_move:DeclareFunctions()
	return {

	}
end

function modifier_cant_move:CheckState()
	local state = {
		[MODIFIER_STATE_ROOTED] = true,
	}
	return state
end
