LinkLuaModifier( "modifier_dummy_vision_ability", "ability/dummy_vision_ability.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if dummy_vision_ability == nil then
	dummy_vision_ability = class({})
end
function dummy_vision_ability:GetIntrinsicModifierName()
	return "modifier_dummy_vision_ability"
end
---------------------------------------------------------------------
--Modifiers
if modifier_dummy_vision_ability == nil then
	modifier_dummy_vision_ability = class({})
end
function modifier_dummy_vision_ability:OnCreated(params)
	if IsServer() then
	end
end
function modifier_dummy_vision_ability:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_dummy_vision_ability:OnDestroy()
	if IsServer() then
	end
end
function modifier_dummy_vision_ability:DeclareFunctions()
	return {
	}
end

function modifier_dummy_vision_ability:CheckState()
	local state = {
		[MODIFIER_STATE_FLYING] = true,
	}
	return state
end
