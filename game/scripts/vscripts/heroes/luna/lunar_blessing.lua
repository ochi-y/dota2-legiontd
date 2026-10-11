LinkLuaModifier( "modifier_lunar_blessing", "heroes/luna/lunar_blessing.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if lunar_blessing == nil then
	lunar_blessing = class({})
end
function lunar_blessing:GetIntrinsicModifierName()
	return "modifier_lunar_blessing"
end
---------------------------------------------------------------------
--Modifiers
if modifier_lunar_blessing == nil then
	modifier_lunar_blessing = class({})
end
function modifier_lunar_blessing:OnCreated(params)
	if IsServer() then
	end
end
function modifier_lunar_blessing:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_lunar_blessing:OnDestroy()
	if IsServer() then
	end
end
function modifier_lunar_blessing:DeclareFunctions()
	return {
	}
end