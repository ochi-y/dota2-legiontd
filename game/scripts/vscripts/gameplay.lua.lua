LinkLuaModifier( "modifier_gameplay", "gameplay.lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if gameplay == nil then
	gameplay = class({})
end
function gameplay:GetIntrinsicModifierName()
	return "modifier_gameplay"
end
---------------------------------------------------------------------
--Modifiers
if modifier_gameplay == nil then
	modifier_gameplay = class({})
end
function modifier_gameplay:OnCreated(params)
	if IsServer() then
	end
end
function modifier_gameplay:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_gameplay:OnDestroy()
	if IsServer() then
	end
end
function modifier_gameplay:DeclareFunctions()
	return {
	}
end