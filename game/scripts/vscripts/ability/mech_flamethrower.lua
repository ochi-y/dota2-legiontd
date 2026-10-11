LinkLuaModifier( "modifier_mech_flamethrower", "ability/mech_flamethrower", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mech_flamethrower_debuff", "ability/mech_flamethrower", LUA_MODIFIER_MOTION_NONE )
--Abilities
if mech_flamethrower == nil then
	mech_flamethrower = class({})
end
function mech_flamethrower:OnSpellStart()


	local duration=self:GetSpecialValueFor("duration")

	local caster=self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_mech_flamethrower", {
		duration=duration
	})


end
---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_mech_flamethrower = class({
	IsHidden = function(self)
		return false
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
function modifier_mech_flamethrower:AllowIllusionDuplicate()
	return false
end
function modifier_mech_flamethrower:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.damage_per_second=ability:GetSpecialValueFor("damage_per_second")
	self.width=ability:GetSpecialValueFor("width")
	self.length=ability:GetSpecialValueFor("length")
	self.unit_count=ability:GetSpecialValueFor("unit_count")
	self.debuff_linger_duration=ability:GetSpecialValueFor("debuff_linger_duration")
	if not IsServer() then return end
	local caster=self:GetCaster()
	EmitSoundOn("Hero_Shredder.Flamethrower", caster)

	self:StartIntervalThink(0.1)

	PlayEffOnUnit("particles/units/heroes/hero_shredder/shredder_flame_thrower.vpcf",caster,{
		mod=self,
		-- bind=PATTACH_POINT_FOLLOW,
		-- attach="attach_attack1"
	})
end
function modifier_mech_flamethrower:OnIntervalThink(params)

	local ability=self:GetAbility()
	local caster=self:GetCaster()
	local units=FindAbilityTarget(ability,caster:GetAbsOrigin(),ability:GetSpecialValueFor("length"),{})

	units=FilterUnitInSector(units, caster:GetAbsOrigin(), caster:GetForwardVector(), 75)

	units=subrange(units,1,self.unit_count)

	for _, unit in ipairs(units) do
		unit:AddNewModifier(caster, ability, "modifier_mech_flamethrower_debuff", {
			duration=self.debuff_linger_duration
		})
	end
end

function modifier_mech_flamethrower:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_mech_flamethrower:OnDestroy(params)
	local caster=self:GetCaster()
	StopSoundOn("Hero_Shredder.Flamethrower", caster)
end
function modifier_mech_flamethrower:DeclareFunctions()
	return {

	}
end

-------------------------------------------------------------------------------------------------------
modifier_mech_flamethrower_debuff = class({
	IsHidden = function(self)
		return false
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
function modifier_mech_flamethrower_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_mech_flamethrower_debuff:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.damage_per_second=ability:GetSpecialValueFor("damage_per_second")
	self.width=ability:GetSpecialValueFor("width")
	self.length=ability:GetSpecialValueFor("length")
	self.debuff_linger_duration=ability:GetSpecialValueFor("debuff_linger_duration")
	if not IsServer() then return end

	self:StartIntervalThink(0.5)

	self:OnIntervalThink()

end
function modifier_mech_flamethrower_debuff:OnRefresh(params)
	local ability=self:GetAbility()
	self.damage_per_second=ability:GetSpecialValueFor("damage_per_second")
	self.width=ability:GetSpecialValueFor("width")
	self.length=ability:GetSpecialValueFor("length")
	self.debuff_linger_duration=ability:GetSpecialValueFor("debuff_linger_duration")

end
function modifier_mech_flamethrower_debuff:OnIntervalThink()
	SimpleApplyDamage(self:GetAbility(), self:GetCaster(), self:GetParent(), 0.5*self.damage_per_second)
end
function modifier_mech_flamethrower_debuff:DeclareFunctions()
	return {
	}
end

function modifier_mech_flamethrower_debuff:GetEffectName()
	return "particles/units/heroes/hero_shredder/shredder_flame_thrower_debuff.vpcf"
end
function modifier_mech_flamethrower_debuff:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function modifier_mech_flamethrower_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_shredder_flame_thrower_debuff.vpcf"
end
function modifier_mech_flamethrower_debuff:StatusEffectPriority()
	return 3
end

