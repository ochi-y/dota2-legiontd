LinkLuaModifier( "modifier_headshot", "heroes/sniper/headshot.lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if headshot == nil then
	headshot = class({})
end
function headshot:GetIntrinsicModifierName()
	return "modifier_headshot"
end
---------------------------------------------------------------------
--Modifiers
if modifier_headshot == nil then
	modifier_headshot = class({})
end
function modifier_headshot:OnCreated(params)
	if IsServer() then
	end
end
function modifier_headshot:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_headshot:OnDestroy()
	if IsServer() then
	end
end
function modifier_headshot:DeclareFunctions()
	return {
	}
end