LinkLuaModifier( "modifier_element_focus_energy", "ability/element_focus_energy.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if element_focus_energy == nil then
	element_focus_energy = class({})
end
function element_focus_energy:GetIntrinsicModifierName()
	return "modifier_element_focus_energy"
end
---------------------------------------------------------------------
--Modifiers
modifier_element_focus_energy = class({
	IsHidden = function(self)
		return true
	end,
	IsPurgable = function(self)
		return false
	end,
	IsDebuff = function(self)
		return false
	end,
	IsBuff = function(self)
		return true
	end,
	RemoveOnDeath = function(self)
		return true
	end,
	GetAttributes = function(self)
		return MODIFIER_ATTRIBUTE_NONE
	end
})


function modifier_element_focus_energy:OnCreated(params)
	if IsServer() then
	end
	local ability=self:GetAbility()

	if not ability then
        return
    end   
	
	self.mana_multiplier=ability:GetSpecialValueFor("mana_multiplier")
	self:SetStackCount(1)
	self:StartIntervalThink(1)
end

function modifier_element_focus_energy:OnIntervalThink(params)

	if not IsServer() then return end

end

function modifier_element_focus_energy:OnRefresh(params)
	local ability=self:GetAbility()
	self.mana_multiplier=ability:GetSpecialValueFor("mana_multiplier")
end
function modifier_element_focus_energy:IsPurgable(params)
	return false
end
function modifier_element_focus_energy:OnDestroy()
	if IsServer() then
	end
end
function modifier_element_focus_energy:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end
function modifier_element_focus_energy:GetModifierPreAttack_BonusDamage()
	return self.mana_multiplier*(self:GetParent():GetMana())*(self:GetStackCount())
end

-------------------------------------------------------------------------------------------------------
