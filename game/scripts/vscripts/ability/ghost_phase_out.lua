LinkLuaModifier( "modifier_ghost_phase_out", "ability/ghost_phase_out", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ghost_phase_out == nil then
	ghost_phase_out = class({})
end
function ghost_phase_out:GetIntrinsicModifierName()
	return "modifier_ghost_phase_out"
end
---------------------------------------------------------------------
--Modifiers
modifier_ghost_phase_out = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_ghost_phase_out:OnCreated(params)
	local ability=self:GetAbility()

	if not ability then
        return
    end   
	
	self.bonus_evasion=ability:GetSpecialValueFor("bonus_evasion")
end
function modifier_ghost_phase_out:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ghost_phase_out:IsPurgable(params)
	return false
end
function modifier_ghost_phase_out:OnDestroy()
	if IsServer() then
	end
end
function modifier_ghost_phase_out:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_EVASION_CONSTANT
	}
end

function modifier_ghost_phase_out:GetModifierEvasion_Constant()
	return self.bonus_evasion
end