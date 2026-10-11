LinkLuaModifier( "modifier_hookshot", "heroes/rattletrap/hookshot.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if hookshot == nil then
	hookshot = class({})
end
function hookshot:GetIntrinsicModifierName()
	return "modifier_hookshot"
end
---------------------------------------------------------------------
--Modifiers
if modifier_hookshot == nil then
	modifier_hookshot = class({})
end
function modifier_hookshot:OnCreated(params)
	if IsServer() then
	end
end
function modifier_hookshot:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_hookshot:OnDestroy()
	if IsServer() then
	end
end
function modifier_hookshot:DeclareFunctions()
	return {
	}
end