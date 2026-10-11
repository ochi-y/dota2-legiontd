LinkLuaModifier( "modifier_sunder", "heroes/terrorblade/sunder.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if sunder == nil then
	sunder = class({})
end
function sunder:GetIntrinsicModifierName()
	return "modifier_sunder"
end
---------------------------------------------------------------------
--Modifiers
if modifier_sunder == nil then
	modifier_sunder = class({})
end
function modifier_sunder:OnCreated(params)
	if IsServer() then
	end
end
function modifier_sunder:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_sunder:OnDestroy()
	if IsServer() then
	end
end
function modifier_sunder:DeclareFunctions()
	return {
	}
end