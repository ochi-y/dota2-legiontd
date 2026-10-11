LinkLuaModifier( "modifier_hero_ambient_effects", "ability/hero_ambient_effects.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if hero_ambient_effects == nil then
	hero_ambient_effects = class({})
end
function hero_ambient_effects:GetIntrinsicModifierName()
	return "modifier_hero_ambient_effects"
end
---------------------------------------------------------------------
--Modifiers
modifier_hero_ambient_effects = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_hero_ambient_effects:OnCreated(params)
	if IsServer() then
	end
end
function modifier_hero_ambient_effects:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_hero_ambient_effects:OnDestroy()
	if IsServer() then
	end
end
function modifier_hero_ambient_effects:DeclareFunctions()
	return {
	}
end
--------------------------------------------------------------------------------

function modifier_hero_ambient_effects:GetPriority()
	return MODIFIER_PRIORITY_ULTRA + 10001
end

-----------------------------------------------------------------------------------------

function modifier_hero_ambient_effects:GetEffectName()
	return "particles/gameplay/hero_ground_light.vpcf"
end
