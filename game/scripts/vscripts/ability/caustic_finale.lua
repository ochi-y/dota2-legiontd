caustic_finale = class({})
LinkLuaModifier( "modifier_caustic_finale", "ability/caustic_finale", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_caustic_finale_debuff", "ability/caustic_finale", LUA_MODIFIER_MOTION_NONE )


wave_3_champion_caustic_finale=caustic_finale


--------------------------------------------------------------------------------
-- Passive Modifier
function caustic_finale:GetIntrinsicModifierName()
	return "modifier_caustic_finale"
end


modifier_caustic_finale = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_caustic_finale:IsHidden()
	return true
end

function modifier_caustic_finale:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_caustic_finale:OnCreated( kv )
	self.duration = self:GetAbility():GetSpecialValueFor( "caustic_finale_duration" ) -- special value
end

function modifier_caustic_finale:OnRefresh( kv )
	self.duration = self:GetAbility():GetSpecialValueFor( "caustic_finale_duration" ) -- special value	
end

function modifier_caustic_finale:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_caustic_finale:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
	}

	return funcs
end

function modifier_caustic_finale:GetModifierProcAttack_Feedback( params )
	if IsServer() then

		if self:GetParent():PassivesDisabled() then 
		   return 
		end

		if self:GetAbility():GetLevel()<1 then
           return
		end

		if params.target:GetTeamNumber()==self:GetParent():GetTeamNumber() then 
		   return 
		end

		if params.target:IsMagicImmune() then 
		   return 
		end

		-- add debuff if not present
		local modifier = params.target:FindModifierByNameAndCaster( "modifier_caustic_finale_debuff", self:GetParent() )
		if not modifier then
            
            local bHasTalent = false
			local hTalent = self:GetCaster():FindAbilityByName("special_bonus_unique_sand_king_6")
		    if hTalent and hTalent:GetLevel() > 0 then
		       bHasTalent = true
		    end
			params.target:AddNewModifier(
				self:GetParent(), -- player source
				self:GetAbility(), -- ability source
				"modifier_caustic_finale_debuff", -- modifier name
				{ duration = self.duration, has_talent=bHasTalent } -- kv
			)
		else
			modifier:SetDuration(self.duration, true)
		end
	end
end

modifier_caustic_finale_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_caustic_finale_debuff:IsHidden()
	return false
end

function modifier_caustic_finale_debuff:IsDebuff()
	return true
end

function modifier_caustic_finale_debuff:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
function modifier_caustic_finale_debuff:OnCreated( kv )
	self.radius = self:GetAbility():GetSpecialValueFor( "caustic_finale_radius" ) 
	self.base_damage = self:GetAbility():GetSpecialValueFor( "caustic_finale_damage_base" ) 
	self.pct_damage = self:GetAbility():GetSpecialValueFor( "caustic_finale_damage_pct" ) 
	self.slow = self:GetAbility():GetSpecialValueFor( "caustic_finale_slow" )
	if kv.has_talent then
	  self.slow = self.slow -8
    end

    if IsServer() then
		ParticleManager:ReleaseParticleIndex( ParticleManager:CreateParticle( "particles/units/heroes/hero_sandking/sandking_caustic_finale_debuff.vpcf", PATTACH_ABSORIGIN, self:GetParent() ) )
	end
end

function modifier_caustic_finale_debuff:OnRefresh( kv )
	
end

function modifier_caustic_finale_debuff:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_caustic_finale_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}

	return funcs
end


function modifier_caustic_finale_debuff:GetModifierMoveSpeedBonus_Percentage()    
	return self.slow
end

function modifier_caustic_finale_debuff:OnDeath( params )
	if IsServer() then
		if params.unit~=self:GetParent() then return end
		-- check if denied
		if params.unit:GetTeamNumber()==params.attacker:GetTeamNumber() then return end
		local unit=params.unit
		if not unit:IsIllusion() then
			self:Explode( params.unit )	
		end
	end
end

--------------------------------------------------------------------------------
-- Helper function
function modifier_caustic_finale_debuff:Explode( hVictim )
	-- find enemies
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),
		self:GetParent():GetOrigin(),
		nil,
		self.radius,	
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,
		0,
		false
	)

    
	for _,hEnemy in pairs(enemies) do       
        local damageTable = {
           victim = hEnemy,
		   attacker = self:GetCaster(),
		   damage = self.base_damage + hVictim:GetMaxHealth()*(self.pct_damage/100),
		   damage_type = DAMAGE_TYPE_MAGICAL,
		   ability = self:GetAbility(), --Optional.
	    }
		ApplyDamage(damageTable)
	end

	-- effects
	self:PlayEffects()

	-- destroy
	self:Destroy()
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_caustic_finale_debuff:GetEffectName()
	return "particles/units/heroes/hero_viper/viper_corrosive_debuff.vpcf"
end

function modifier_caustic_finale_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_caustic_finale_debuff:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_sandking/sandking_caustic_finale_explode.vpcf"
	local sound_cast = "Ability.SandKing_CausticFinale"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetParent() )
end