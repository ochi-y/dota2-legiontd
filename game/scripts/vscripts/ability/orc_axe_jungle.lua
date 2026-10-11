LinkLuaModifier( "modifier_orc_axe_jungle", "ability/orc_axe_jungle.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if orc_axe_jungle == nil then
	orc_axe_jungle = class({})
end
function orc_axe_jungle:GetIntrinsicModifierName()
	return "modifier_orc_axe_jungle"
end
---------------------------------------------------------------------
--Modifiers
modifier_orc_axe_jungle = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_orc_axe_jungle:OnCreated(params)
	if IsServer() then
	end
end
function modifier_orc_axe_jungle:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_orc_axe_jungle:OnDestroy()
	if IsServer() then
	end
end
function modifier_orc_axe_jungle:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
	}
end

function modifier_orc_axe_jungle:GetAttackSound()
	return "Hero_Axe.Attack.Jungle"
end