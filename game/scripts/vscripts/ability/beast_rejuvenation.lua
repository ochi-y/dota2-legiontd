LinkLuaModifier( "modifier_beast_rejuvenation", "ability/beast_rejuvenation", LUA_MODIFIER_MOTION_NONE )
--Abilities
beast_rejuvenation = class({})
function beast_rejuvenation:OnSpellStart()
	if not IsServer() then return end
	local caster=self:GetCaster()
	local target=self:GetCursorTarget()
	local duration=self:GetSpecialValueFor("duration")
	target:AddNewModifier(caster, self, "modifier_beast_rejuvenation", {duration=duration})
	--
	EmitSoundOn("Hero_Treant.LeechSeed.Target", caster)

	caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)
end

---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_beast_rejuvenation = class({
	IsHidden = function(self)
		return false
	end,
	IsPurgable = function(self)
		return true
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
function modifier_beast_rejuvenation:AllowIllusionDuplicate()
	return false
end
function modifier_beast_rejuvenation:OnCreated(params)
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true) 

	local ability=self:GetAbility()
	self.duration=ability:GetSpecialValueFor("duration")
	self.hp_gained=ability:GetSpecialValueFor("hp_gained")

end
function modifier_beast_rejuvenation:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}
end
function modifier_beast_rejuvenation:GetModifierConstantHealthRegen()
	return self.hp_gained/self.duration
end

function modifier_beast_rejuvenation:CheckState()
	local state = {
	}
	return state
end
function modifier_beast_rejuvenation:GetEffectName()
	return "particles/econ/events/fall_major_2016/radiant_fountain_regen_fm06_lvl2.vpcf"
	--return "particles/items_fx/healing_flask.vpcf"
end
function modifier_beast_rejuvenation:GetEffectAttachType()
	return PATTACH_ROOTBONE_FOLLOW
end
