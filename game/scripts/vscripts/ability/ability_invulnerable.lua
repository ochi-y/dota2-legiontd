LinkLuaModifier( "modifier_ability_invulnerable", "ability/ability_invulnerable.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ability_invulnerable == nil then
	ability_invulnerable = class({})
end
function ability_invulnerable:GetIntrinsicModifierName()
	return "modifier_ability_invulnerable"
end

---------------------------------------------------------------------
--Modifiers

modifier_ability_invulnerable = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_ability_invulnerable:OnCreated(params)
	if IsServer() then
	end
end
function modifier_ability_invulnerable:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ability_invulnerable:OnDestroy()
	if IsServer() then
	end
end
function modifier_ability_invulnerable:DeclareFunctions()
	return {

	}
end
function modifier_ability_invulnerable:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
	}

	return state
end
