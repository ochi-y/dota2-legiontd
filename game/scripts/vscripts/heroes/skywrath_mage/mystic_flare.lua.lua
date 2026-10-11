LinkLuaModifier( "modifier_mystic_flare", "heroes/skywrath_mage/mystic_flare.lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if mystic_flare == nil then
	mystic_flare = class({})
end
function mystic_flare:GetIntrinsicModifierName()
	return "modifier_mystic_flare"
end
---------------------------------------------------------------------
--Modifiers
if modifier_mystic_flare == nil then
	modifier_mystic_flare = class({})
end
function modifier_mystic_flare:OnCreated(params)
	if IsServer() then
	end
end
function modifier_mystic_flare:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_mystic_flare:OnDestroy()
	if IsServer() then
	end
end
function modifier_mystic_flare:DeclareFunctions()
	return {
	}
end