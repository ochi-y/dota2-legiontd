lifestealer_feast_lua = class({})
LinkLuaModifier( "modifier_lifestealer_feast_lua", "ability/lifestealer_feast_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function lifestealer_feast_lua:GetIntrinsicModifierName()
	return "modifier_lifestealer_feast_lua"
end


modifier_lifestealer_feast_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_lifestealer_feast_lua:IsHidden()
	return true
end

function modifier_lifestealer_feast_lua:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_lifestealer_feast_lua:OnCreated( kv )
	if not self:GetAbility() then return end
	-- references
	self.leech_percent = self:GetAbility():GetSpecialValueFor( "hp_leech_percent" )/100 -- special value
	self.hp_damage_percent = self:GetAbility():GetSpecialValueFor( "hp_damage_percent" )/100 -- special value

	self.boss_hp_leech_percent = self:GetAbility():GetSpecialValueFor( "boss_hp_leech_percent" )/100 -- special value
	self.boss_hp_damage_percent = self:GetAbility():GetSpecialValueFor( "boss_hp_damage_percent" )/100 -- special value


end

function modifier_lifestealer_feast_lua:OnRefresh( kv )
	if not self:GetAbility() then return end
	-- references
	self.leech_percent = self:GetAbility():GetSpecialValueFor( "hp_leech_percent" )/100 -- special value	
	self.hp_damage_percent = self:GetAbility():GetSpecialValueFor( "hp_damage_percent" )/100 -- special value

	self.boss_hp_leech_percent = self:GetAbility():GetSpecialValueFor( "boss_hp_leech_percent" )/100 -- special value
	self.boss_hp_damage_percent = self:GetAbility():GetSpecialValueFor( "boss_hp_damage_percent" )/100 -- special value
end

function modifier_lifestealer_feast_lua:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_lifestealer_feast_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
	}

	return funcs
end

function modifier_lifestealer_feast_lua:GetModifierProcAttack_BonusDamage_Physical( params )
	if IsServer() then
		if self:GetParent():PassivesDisabled() then return end

		local caster=self:GetParent()
		-- leech
		local leech = params.target:GetHealth() * self.leech_percent
		local damage=params.target:GetHealth() * self.hp_damage_percent

		if params.target:IsAncient() then
			leech = params.target:GetHealth() * self.boss_hp_leech_percent
			damage=params.target:GetHealth() * self.boss_hp_damage_percent
		end
		
		-- self:GetParent():Heal( leech, self:GetParent() )
		
		self:GetParent():HealWithParams(leech, self:GetAbility(), true, true,caster , false)

		SendOverheadEventMessage( nil, OVERHEAD_ALERT_HEAL, self:GetParent(), leech, nil )
		self:PlayEffects()
		return damage
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
-- function modifier_lifestealer_feast_lua:GetEffectName()
-- 	return "particles/string/here.vpcf"
-- end

-- function modifier_lifestealer_feast_lua:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end

function modifier_lifestealer_feast_lua:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/generic_gameplay/generic_lifesteal.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	-- ParticleManager:SetParticleControl( effect_cast, iControlPoint, vControlVector )
	-- ParticleManager:SetParticleControlEnt(
	-- 	effect_cast,
	-- 	iControlPoint,
	-- 	hTarget,
	-- 	PATTACH_NAME,
	-- 	"attach_name",
	-- 	vOrigin, -- unknown
	-- 	bool -- unknown, true
	-- )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end