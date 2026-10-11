LinkLuaModifier( "modifier_bh_build", "buildinghelper/bh_build.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if bh_build == nil then
	bh_build = class({})
end
function bh_build:GetIntrinsicModifierName()
	return "modifier_bh_build"
end
---------------------------------------------------------------------
--Modifiers
if modifier_bh_build == nil then
	modifier_bh_build = class({})
end
function modifier_bh_build:OnCreated(params)
	if IsServer() then
	end
end
function modifier_bh_build:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_bh_build:OnDestroy()
	if IsServer() then
	end
end
function modifier_bh_build:DeclareFunctions()
	return {
	}
end