LinkLuaModifier( "modifier_elder_dragon_form", "heroes/dragon_knight/elder_dragon_form.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if elder_dragon_form == nil then
	elder_dragon_form = class({})
end
function elder_dragon_form:GetIntrinsicModifierName()
	return "modifier_elder_dragon_form"
end
---------------------------------------------------------------------
--Modifiers
if modifier_elder_dragon_form == nil then
	modifier_elder_dragon_form = class({})
end
function modifier_elder_dragon_form:OnCreated(params)
	if IsServer() then
	end
end
function modifier_elder_dragon_form:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_elder_dragon_form:OnDestroy()
	if IsServer() then
	end
end
function modifier_elder_dragon_form:DeclareFunctions()
	return {
	}
end