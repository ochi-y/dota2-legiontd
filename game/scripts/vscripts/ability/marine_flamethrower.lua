LinkLuaModifier( "modifier_marine_flamethrower", "ability/marine_flamethrower.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if marine_flamethrower == nil then
	marine_flamethrower = class({})
end
function marine_flamethrower:GetIntrinsicModifierName()
	return "modifier_marine_flamethrower"
end
---------------------------------------------------------------------
--Modifiers
if modifier_marine_flamethrower == nil then
	modifier_marine_flamethrower = class({})
end
function modifier_marine_flamethrower:OnCreated(params)
	if IsServer() then
	end
end
function modifier_marine_flamethrower:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_marine_flamethrower:OnDestroy()
	if IsServer() then
	end
end
function modifier_marine_flamethrower:DeclareFunctions()
	return {
	}
end