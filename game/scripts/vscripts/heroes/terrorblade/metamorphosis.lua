LinkLuaModifier( "modifier_metamorphosis", "heroes/terrorblade/metamorphosis.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if metamorphosis == nil then
	metamorphosis = class({})
end
function metamorphosis:GetIntrinsicModifierName()
	return "modifier_metamorphosis"
end
---------------------------------------------------------------------
--Modifiers
if modifier_metamorphosis == nil then
	modifier_metamorphosis = class({})
end
function modifier_metamorphosis:OnCreated(params)
	if IsServer() then
	end
end
function modifier_metamorphosis:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_metamorphosis:OnDestroy()
	if IsServer() then
	end
end
function modifier_metamorphosis:DeclareFunctions()
	return {
	}
end