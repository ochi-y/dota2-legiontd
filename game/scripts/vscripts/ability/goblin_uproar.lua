LinkLuaModifier( "modifier_goblin_uproar", "ability/goblin_uproar.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if goblin_uproar == nil then
	goblin_uproar = class({})
end
function goblin_uproar:GetIntrinsicModifierName()
	return "modifier_goblin_uproar"
end
---------------------------------------------------------------------
--Modifiers
if modifier_goblin_uproar == nil then
	modifier_goblin_uproar = class({})
end
function modifier_goblin_uproar:OnCreated(params)
	if IsServer() then
	end
end
function modifier_goblin_uproar:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_goblin_uproar:OnDestroy()
	if IsServer() then
	end
end
function modifier_goblin_uproar:DeclareFunctions()
	return {
	}
end