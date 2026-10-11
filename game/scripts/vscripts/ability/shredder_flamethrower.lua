LinkLuaModifier( "modifier_shredder_flamethrower", "ability/shredder_flamethrower", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_shredder_flamethrower_debuff", "ability/shredder_flamethrower", LUA_MODIFIER_MOTION_NONE )
--Abilities
if shredder_flamethrower == nil then
	shredder_flamethrower = class({})
end
function shredder_flamethrower:OnSpellStart()


	local duration=self:GetSpecialValueFor("duration")

	local caster=self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_shredder_flamethrower", {
		duration=duration
	})


end
---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_shredder_flamethrower = class({
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
function modifier_shredder_flamethrower:AllowIllusionDuplicate()
	return false
end
function modifier_shredder_flamethrower:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.damage_per_second=ability:GetSpecialValueFor("damage_per_second")
	self.width=ability:GetSpecialValueFor("width")
	self.length=ability:GetSpecialValueFor("length")
	self.debuff_linger_duration=ability:GetSpecialValueFor("debuff_linger_duration")
	if not IsServer() then return end
	local caster=self:GetCaster()
	EmitSoundOn("Hero_Shredder.Flamethrower", caster)


	self:StartIntervalThink(0.1)

	PlayEffOnUnit("particles/units/heroes/hero_shredder/shredder_flame_thrower.vpcf",caster,{
		mod=self
	})
end
function modifier_shredder_flamethrower:OnIntervalThink(params)

end

function modifier_shredder_flamethrower:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_shredder_flamethrower:OnDestroy(params)
	local caster=self:GetCaster()
	StopSoundOn("Hero_Shredder.Flamethrower", caster)
end
function modifier_shredder_flamethrower:DeclareFunctions()
	return {

	}
end

-------------------------------------------------------------------------------------------------------
modifier_shredder_flamethrower_debuff = class({
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
function modifier_shredder_flamethrower_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_shredder_flamethrower_debuff:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.goldCost=ability:GetSpecialValueFor("goldCost")
	if not IsServer() then return end
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true) 
end
function modifier_shredder_flamethrower_debuff:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_shredder_flamethrower_debuff:DeclareFunctions()
	return {

	}
end

