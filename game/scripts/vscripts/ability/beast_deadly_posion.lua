LinkLuaModifier( "modifier_beast_deadly_posion", "ability/beast_deadly_posion.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if beast_deadly_posion == nil then
	beast_deadly_posion = class({})
end
function beast_deadly_posion:GetIntrinsicModifierName()
	return "modifier_beast_deadly_posion"
end
---------------------------------------------------------------------
--Modifiers
if modifier_beast_deadly_posion == nil then
	modifier_beast_deadly_posion = class({})
end
function modifier_beast_deadly_posion:OnCreated(params)
	if IsServer() then
	end
end
function modifier_beast_deadly_posion:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_beast_deadly_posion:OnDestroy()
	if IsServer() then
	end
end
function modifier_beast_deadly_posion:DeclareFunctions()
	return {
	}
end