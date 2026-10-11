ability_metamorphosis = {}

LinkLuaModifier( "modifier_ability_metamorphosis", "ability/ability_metamorphosis", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_ability_metamorphosis_attack", "ability/ability_metamorphosis", LUA_MODIFIER_MOTION_NONE )

ability_metamorphosis_elite=ability_metamorphosis

function ability_metamorphosis:GetIntrinsicModifierName()
	return "modifier_ability_metamorphosis_attack"
end

function ability_metamorphosis:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor( "duration" )
	caster:AddNewModifier(
		caster,
		self,
		"modifier_ability_metamorphosis",
		{ duration = duration }
	)

	EmitSoundOn( "Hero_Terrorblade.Metamorphosis", caster )
end

-------------------------------------------------------------------------------------------------------
modifier_ability_metamorphosis_attack = class({
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
function modifier_ability_metamorphosis_attack:AllowIllusionDuplicate()
	return false
end
function modifier_ability_metamorphosis_attack:OnCreated(params)
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true) 
	if not self:GetAbility() then return end

	local ability=self:GetAbility()
	self.attack_count=ability:GetSpecialValueFor("attack_count")
	self.duration=ability:GetSpecialValueFor("duration")
end
function modifier_ability_metamorphosis_attack:DeclareFunctions()
	return {
		--MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS 
	}
end


function modifier_ability_metamorphosis_attack:GetActivityTranslationModifiers()
	return "abysm"
end
function modifier_ability_metamorphosis_attack:CheckState()
	local state = {
	}
	return state
end

function modifier_ability_metamorphosis_attack:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target
	
	local ability=self:GetAbility()

	if self:GetParent():HasModifier("modifier_ability_metamorphosis") then
		return
	end

	if 1+self:GetStackCount()==self.attack_count then
		self:GetParent():AddNewModifier(
			self:GetParent(),
			ability,
			"modifier_ability_metamorphosis",
			{ duration = self.duration }
		)
		self:SetStackCount(0)
	elseif 1+self:GetStackCount()>self.attack_count then
	else
		self:IncrementStackCount()
	end
end
-------------------------------------------------------------------------------------------------------

modifier_ability_metamorphosis = {}

function modifier_ability_metamorphosis:IsHidden()
	return false
end

function modifier_ability_metamorphosis:IsDebuff()
	return false
end

function modifier_ability_metamorphosis:IsStunDebuff()
	return false
end

function modifier_ability_metamorphosis:IsPurgable()
	return false
end

function modifier_ability_metamorphosis:OnCreated( kv )
	if not self:GetAbility() then return end
	self.bat = self:GetAbility():GetSpecialValueFor( "base_attack_time" )
	self.range = self:GetAbility():GetSpecialValueFor( "bonus_range" )
	self.damage = self:GetAbility():GetSpecialValueFor( "bonus_damage" )
	self.slow = self:GetAbility():GetSpecialValueFor( "speed_loss" )
	self.model_scale = self:GetAbility():GetSpecialValueFor( "model_scale" )
	local delay = self:GetAbility():GetSpecialValueFor( "transformation_time" )

	self.projectile = 900

	if not IsServer() then return end

	local parent=self:GetParent()


	parent:RemoveModifierByName("modifier_attack_normal")
	parent:RemoveModifierByName("modifier_armor_heavy")

	parent:AddNewModifier(parent,nil,"modifier_attack_chaos",{})
	parent:AddNewModifier(parent,nil,"modifier_armor_unarmored",{})

	self.attack = self:GetParent():GetAttackCapability()
	if self.attack == DOTA_UNIT_CAP_RANGED_ATTACK then
		self.range = 0
		self.projectile = 0
	end
	self:GetParent():SetAttackCapability( DOTA_UNIT_CAP_RANGED_ATTACK )

	self:GetAbility():SetContextThink(DoUniqueString( "ability_metamorphosis" ), function()
		self:GetParent():StartGesture( ACT_DOTA_CAST_ABILITY_3 )
	end, FrameTime())

	self.stun = true
	self:StartIntervalThink( delay )

	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_transform.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	
end

function modifier_ability_metamorphosis:OnRefresh( kv )

	if not self:GetAbility() then return end
	self.bat = self:GetAbility():GetSpecialValueFor( "base_attack_time" )
	self.range = self:GetAbility():GetSpecialValueFor( "bonus_range" )
	self.damage = self:GetAbility():GetSpecialValueFor( "bonus_damage" )
	self.slow = self:GetAbility():GetSpecialValueFor( "speed_loss" )
	self.model_scale = self:GetAbility():GetSpecialValueFor( "model_scale" )

end

function modifier_ability_metamorphosis:OnDestroy()
	if not IsServer() then return end

	self:GetParent():SetAttackCapability( self.attack )

	self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_3_END)

	local parent=self:GetParent()


	PlayEffOnUnit("particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_transform_end.vpcf", parent)



	parent:RemoveModifierByName("modifier_attack_chaos")
	parent:RemoveModifierByName("modifier_armor_unarmored")

	parent:AddNewModifier(parent,nil,"modifier_attack_normal",{})
	parent:AddNewModifier(parent,nil,"modifier_armor_heavy",{})

end

function modifier_ability_metamorphosis:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_PROJECTILE_NAME,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
	}
end

function modifier_ability_metamorphosis:GetModifierModelScale()
	return self.model_scale
end

function modifier_ability_metamorphosis:GetModifierBaseAttack_BonusDamage()
	return self.damage
end

function modifier_ability_metamorphosis:GetModifierBaseAttackTimeConstant()
	return self.bat
end

function modifier_ability_metamorphosis:GetModifierMoveSpeedBonus_Constant()
	return self.slow
end

function modifier_ability_metamorphosis:GetModifierProjectileSpeedBonus()
	return self.projectile
end

function modifier_ability_metamorphosis:GetModifierAttackRangeBonus()
	return self.range
end

function modifier_ability_metamorphosis:GetModifierModelChange()
	if not IsServer() then return end
	local caster=self:GetCaster()
	if caster:GetUnitName()== "elf_crusader_skin_2" then
		return "models/items/terrorblade/tb_samurai_samurai_demon/tb_samurai_samurai_demon.vmdl"
	end
	if caster:GetUnitName()== "elf_crusader_skin_3" then
		return "models/items/terrorblade/knight_of_foulfell_demon/knight_of_foulfell_demon.vmdl"
	end
	return "models/heroes/terrorblade/demon.vmdl"
end


function modifier_ability_metamorphosis:GetModifierProjectileName()
	return "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_base_attack.vpcf"
end

function modifier_ability_metamorphosis:GetAttackSound()
	return "Hero_Terrorblade_Morphed.Attack"
end

function modifier_ability_metamorphosis:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = self.stun,
	}
end

function modifier_ability_metamorphosis:OnIntervalThink()
	self.stun = false
end

function modifier_ability_metamorphosis:GetEffectName()
	return "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis.vpcf"
end

function modifier_ability_metamorphosis:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
