LinkLuaModifier( "modifier_beast_gnoll_posion", "ability/beast_gnoll_posion.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if beast_gnoll_posion == nil then
	beast_gnoll_posion = class({})
end
function beast_gnoll_posion:GetIntrinsicModifierName()
	return "modifier_beast_gnoll_posion"
end
---------------------------------------------------------------------
--Modifiers
if modifier_beast_gnoll_posion == nil then
	modifier_beast_gnoll_posion = class({})
end
function modifier_beast_gnoll_posion:OnCreated(params)
	if IsServer() then
	end
end
function modifier_beast_gnoll_posion:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_beast_gnoll_posion:OnDestroy()
	if IsServer() then
	end
end
function modifier_beast_gnoll_posion:DeclareFunctions()
	return {
	}
end