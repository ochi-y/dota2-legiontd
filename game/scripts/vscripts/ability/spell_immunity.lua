LinkLuaModifier("modifier_spell_immunity", "ability/spell_immunity.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if spell_immunity == nil then
	spell_immunity = class({})
end
function spell_immunity:GetIntrinsicModifierName()
	return "modifier_spell_immunity"
end

---------------------------------------------------------------------
--Modifiers

modifier_spell_immunity = class({
	IsHidden      = function(self) return true end,
	IsPurgable    = function(self) return false end,
	IsDebuff      = function(self) return false end,
	IsBuff        = function(self) return true end,
	RemoveOnDeath = function(self) return true end,
	GetAttributes = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_spell_immunity:OnCreated(params)
	if IsServer() then
	end
end

function modifier_spell_immunity:OnRefresh(params)
	if IsServer() then
	end
end

function modifier_spell_immunity:OnDestroy()
	if IsServer() then
	end
end

function modifier_spell_immunity:DeclareFunctions()
	return {
	}
end

function modifier_spell_immunity:CheckState()
	return {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		
	}
end

