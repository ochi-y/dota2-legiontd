LinkLuaModifier( "modifier_tiny_grow", "ability/tiny_grow.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if tiny_grow == nil then
	tiny_grow = class({})
end
function tiny_grow:GetIntrinsicModifierName()
	return "modifier_tiny_grow"
end
---------------------------------------------------------------------
--Modifiers
if modifier_tiny_grow == nil then
	modifier_tiny_grow = class({})
end
function modifier_tiny_grow:OnCreated(params)
	if IsServer() then
	end
end
function modifier_tiny_grow:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_tiny_grow:OnDestroy()
	if IsServer() then
	end
end
function modifier_tiny_grow:DeclareFunctions()
	return {
	}
end