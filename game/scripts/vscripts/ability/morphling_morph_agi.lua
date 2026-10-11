LinkLuaModifier( "modifier_morphling_morph_agi", "ability/morphling_morph_agi.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if morphling_morph_agi == nil then
	morphling_morph_agi = class({})
end
function morphling_morph_agi:GetIntrinsicModifierName()
	return "modifier_morphling_morph_agi"
end
---------------------------------------------------------------------
--Modifiers
if modifier_morphling_morph_agi == nil then
	modifier_morphling_morph_agi = class({})
end
function modifier_morphling_morph_agi:OnCreated(params)
	if IsServer() then
	end
end
function modifier_morphling_morph_agi:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_morphling_morph_agi:OnDestroy()
	if IsServer() then
	end
end
function modifier_morphling_morph_agi:DeclareFunctions()
	return {
	}
end