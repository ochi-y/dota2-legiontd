LinkLuaModifier( "modifier_creep_split2", "ability/creep_split2.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if creep_split2 == nil then
	creep_split2 = class({})
end
function creep_split2:GetIntrinsicModifierName()
	return "modifier_creep_split2"
end
---------------------------------------------------------------------
--Modifiers
if modifier_creep_split2 == nil then
	modifier_creep_split2 = class({})
end
function modifier_creep_split2:OnCreated(params)
	if IsServer() then
	end
end
function modifier_creep_split2:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_creep_split2:OnDestroy()
	if IsServer() then
	end
end
function modifier_creep_split2:DeclareFunctions()
	return {
	}
end