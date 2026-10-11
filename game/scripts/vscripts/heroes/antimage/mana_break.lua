LinkLuaModifier( "modifier_mana_break", "heroes/antimage/mana_break.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if mana_break == nil then
	mana_break = class({})
end
function mana_break:GetIntrinsicModifierName()
	return "modifier_mana_break"
end
---------------------------------------------------------------------
--Modifiers
if modifier_mana_break == nil then
	modifier_mana_break = class({})
end
function modifier_mana_break:OnCreated(params)
	if IsServer() then
	end
end
function modifier_mana_break:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_mana_break:OnDestroy()
	if IsServer() then
	end
end
function modifier_mana_break:DeclareFunctions()
	return {
	}
end