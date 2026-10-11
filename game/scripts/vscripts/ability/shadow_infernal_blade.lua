
LinkLuaModifier( "modifier_shadow_infernal_blade", "ability/shadow_infernal_blade.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_orb_effect_lua", "lua_abilities/generic/modifier_generic_orb_effect_lua", LUA_MODIFIER_MOTION_NONE )    

if shadow_infernal_blade == nil then
	shadow_infernal_blade = class({})
end

function shadow_infernal_blade:Spawn()
	if not IsServer() then return end
	self:ToggleAutoCast()
end
function shadow_infernal_blade:GetIntrinsicModifierName()
	return "modifier_generic_orb_effect_lua"
end
function shadow_infernal_blade:GetProjectileName()
    return "particles/econ/items/queen_of_pain/qop_2022_immortal/queen_2022_scream_of_pain_projectile.vpcf"
end

function shadow_infernal_blade:OnOrbFire( params )
    local sound_cast = "Hero_DoomBringer.InfernalBlade.PreAttack"
    EmitSoundOn( sound_cast, self:GetCaster() )
	self:StartCooldown(self:GetCooldown(1))
end

function shadow_infernal_blade:OnOrbImpact( params )
    if not IsServer() then return end
    local burn_duration=self:GetSpecialValueFor("burn_duration")
    local ministun_duration=self:GetSpecialValueFor("ministun_duration")

    local caster=self:GetCaster()
    local target=params.target
    -- local damageTable = {
    --     victim = target,
    --     attacker = caster,
    --     damage = damage*SimpleGetAttackFactor(caster,target),
    --     damage_type = DAMAGE_TYPE_PHYSICAL,
    --     ability = self
    -- }
    -- ApplyDamage(damageTable)
	EmitSoundOn("Hero_DoomBringer.InfernalBlade.Target", target)


	params.target:AddNewModifier(
		self:GetCaster(),
		self,
		"modifier_shadow_infernal_blade",
		{ duration = burn_duration }
	)

	params.target:AddNewModifier(
		self:GetCaster(),
		self,
		"modifier_stunned",
		{ duration = ministun_duration }
	)

end


modifier_shadow_infernal_blade = {}

function modifier_shadow_infernal_blade:IsHidden()
	return false
end

function modifier_shadow_infernal_blade:IsDebuff()
	return true
end

function modifier_shadow_infernal_blade:IsStunDebuff()
	return false
end

function modifier_shadow_infernal_blade:IsPurgable()
	return true
end

function modifier_shadow_infernal_blade:OnCreated( kv )
	if not IsServer() then return end

	self.damage = self:GetAbility():GetSpecialValueFor( "burn_damage" )
	self.damage_pct = self:GetAbility():GetSpecialValueFor( "burn_damage_pct" )
	self.boss_burn_damage_pct = self:GetAbility():GetSpecialValueFor( "boss_burn_damage_pct" )

	local interval = 1

	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self,
	}

	self:StartIntervalThink( interval )

	local effect_cast = ParticleManager:CreateParticle(
		"particles/units/heroes/hero_doom_bringer/doom_infernal_blade_impact.vpcf",
		PATTACH_ABSORIGIN_FOLLOW,
		self:GetParent()
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
	-- EmitSoundOn(  "Hero_DoomBringer.InfernalBlade.Target", self:GetParent() )
end

modifier_shadow_infernal_blade.OnRefresh = OnCreated

function modifier_shadow_infernal_blade:OnIntervalThink()

	local damage_pct=self.damage_pct
	if self:GetParent():IsAncient() then
		damage_pct=self.boss_burn_damage_pct
	end
	self.damageTable.damage = self.damage + (damage_pct/100)*self:GetParent():GetMaxHealth()

	ApplyDamage( self.damageTable )
end

function modifier_shadow_infernal_blade:GetEffectName()
	return "particles/units/heroes/hero_doom_bringer/doom_infernal_blade_debuff.vpcf"
end

function modifier_shadow_infernal_blade:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


