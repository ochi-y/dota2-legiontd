LinkLuaModifier( "modifier_essence_shift", "heroes/slark/essence_shift.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if essence_shift == nil then
	essence_shift = class({})
end
function essence_shift:GetIntrinsicModifierName()
	return "modifier_essence_shift"
end
---------------------------------------------------------------------
--Modifiers
if modifier_essence_shift == nil then
	modifier_essence_shift = class({})
end
function modifier_essence_shift:OnCreated(params)
	if IsServer() then
	end
end
function modifier_essence_shift:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_essence_shift:OnDestroy()
	if IsServer() then
	end
end
function modifier_essence_shift:DeclareFunctions()
	return {
	}
end