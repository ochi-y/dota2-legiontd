LinkLuaModifier( "modifier_undead_plagueundead_infectious_diseases", "ability/undead_plagueundead_infectious_diseases.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if undead_plagueundead_infectious_diseases == nil then
	undead_plagueundead_infectious_diseases = class({})
end
function undead_plagueundead_infectious_diseases:GetIntrinsicModifierName()
	return "modifier_undead_plagueundead_infectious_diseases"
end
---------------------------------------------------------------------
--Modifiers
if modifier_undead_plagueundead_infectious_diseases == nil then
	modifier_undead_plagueundead_infectious_diseases = class({})
end
function modifier_undead_plagueundead_infectious_diseases:OnCreated(params)
	if IsServer() then
	end
end
function modifier_undead_plagueundead_infectious_diseases:IsPurgable(params)
	return false
end
function modifier_undead_plagueundead_infectious_diseases:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_undead_plagueundead_infectious_diseases:OnDestroy()
	if IsServer() then
	end
end
function modifier_undead_plagueundead_infectious_diseases:DeclareFunctions()
	return {
	}
end