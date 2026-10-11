LinkLuaModifier( "modifier_ghost_parting_shot", "ability/ghost_parting_shot.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ghost_parting_shot == nil then
	ghost_parting_shot = class({})
end
function ghost_parting_shot:GetIntrinsicModifierName()
	return "modifier_ghost_parting_shot"
end
---------------------------------------------------------------------
--Modifiers
if modifier_ghost_parting_shot == nil then
	modifier_ghost_parting_shot = class({})
end
function modifier_ghost_parting_shot:OnCreated(params)
	if IsServer() then
	end
end
function modifier_ghost_parting_shot:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ghost_parting_shot:OnDestroy()
	if IsServer() then
	end
end
function modifier_ghost_parting_shot:DeclareFunctions()
	return {
	}
end