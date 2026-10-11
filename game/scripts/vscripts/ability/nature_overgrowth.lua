
nature_overgrowth = class({})

LinkLuaModifier( "modifier_nature_overgrowth", "ability/nature_overgrowth", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_nature_overgrowth_thinker", "ability/nature_overgrowth", LUA_MODIFIER_MOTION_NONE )

----------------------------------------------------------------------------------------

function nature_overgrowth:Precache( context )
	PrecacheResource( "particle", "particles/dark_moon/darkmoon_creep_warning.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/treant_miniboss/entangle_vines.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/treant_protector/treant_ti10_immortal_head/treant_ti10_immortal_overgrowth_root.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/treant_protector/treant_ti10_immortal_head/treant_ti10_immortal_overgrowth_root_small.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_treant/treant_overgrowth_vines.vpcf", context )
	PrecacheResource( "particle", "particles/act_2/wyvern_generic_blast_pre.vpcf", context )
end

--------------------------------------------------------------------------------

-- function nature_overgrowth:OnAbilityPhaseStart()
-- 	if IsServer() then
-- 		self.radius = self:GetSpecialValueFor( "radius" )

-- 		local vCastPos = self:GetCursorPosition()

-- 		self.nPreviewFX = ParticleManager:CreateParticle( "particles/dark_moon/darkmoon_creep_warning.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
-- 		ParticleManager:SetParticleControlEnt( self.nPreviewFX, 0, self:GetCaster(), PATTACH_CUSTOMORIGIN, nil, vCastPos, true )
-- 		ParticleManager:SetParticleControl( self.nPreviewFX, 1, Vector( 100, 100, 100 ) )
-- 		ParticleManager:SetParticleControl( self.nPreviewFX, 15, Vector( 29, 55, 184 ) )

-- 		self.nTargetPosFX = ParticleManager:CreateParticle( "particles/act_2/wyvern_generic_blast_pre.vpcf", PATTACH_CUSTOMORIGIN, nil )
-- 		ParticleManager:SetParticleControl( self.nTargetPosFX, 0, GetGroundPosition( self:GetCursorPosition(), self:GetCaster() ) )
-- 		ParticleManager:SetParticleControl( self.nTargetPosFX, 1, Vector( self.radius, 2, 1 ) )
-- 		ParticleManager:SetParticleControl( self.nTargetPosFX, 15, Vector( 200, 30, 0 ) )
-- 		ParticleManager:SetParticleControl( self.nTargetPosFX, 16, Vector( 1, 0, 0 ) )
-- 		--EmitSoundOn( "n_creep_Ursa.Clap", self:GetCaster() )
-- 	end

-- 	return true
-- end

--------------------------------------------------------------------------------

-- function nature_overgrowth:OnAbilityPhaseInterrupted()
-- 	if IsServer() then
-- 		ParticleManager:DestroyParticle( self.nPreviewFX, false )

-- 		ParticleManager:DestroyParticle( self.nTargetPosFX, false )
-- 	end 
-- end

--------------------------------------------------------------------------------

function nature_overgrowth:OnSpellStart()
	if IsServer() then
		-- ParticleManager:DestroyParticle( self.nPreviewFX, false )

		-- ParticleManager:DestroyParticle( self.nTargetPosFX, false )

		local vCastPos = self:GetCaster():GetAbsOrigin()

		local root_duration = self:GetSpecialValueFor( "root_duration" )

		CreateModifierThinker( self:GetCaster(), self, "modifier_nature_overgrowth_thinker", { duration = root_duration }, vCastPos, self:GetCaster():GetTeamNumber(), false )

		EmitSoundOn( "Hero_Treant.Overgrowth.Cast", self:GetCaster() )
	end
end

--------------------------------------------------------------------------------

modifier_nature_overgrowth = class({})

-----------------------------------------------------------------------------

function modifier_nature_overgrowth:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_nature_overgrowth:GetEffectName()
	return "particles/units/heroes/hero_treant/treant_overgrowth_vines.vpcf"
end

--------------------------------------------------------------------------------

function modifier_nature_overgrowth:StatusEffectPriority()
	return 10
end

--------------------------------------------------------------------------------

function modifier_nature_overgrowth:OnCreated( kv )
	if not IsServer() then
		return
	end

	if self:GetParent():IsHero() then
		local nFXIndexA = ParticleManager:CreateParticle( "particles/econ/items/treant_protector/treant_ti10_immortal_head/treant_ti10_immortal_overgrowth_root.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
		ParticleManager:SetParticleControlEnt( nFXIndexA, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
		self:AddParticle( nFXIndexA, false, false, -1, false, false )
	else
		local nFXIndexB = ParticleManager:CreateParticle( "particles/econ/items/treant_protector/treant_ti10_immortal_head/treant_ti10_immortal_overgrowth_root_small.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
		ParticleManager:SetParticleControlEnt( nFXIndexB, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
		self:AddParticle( nFXIndexB, false, false, -1, false, false )
	end
end

--------------------------------------------------------------------------------

function modifier_nature_overgrowth:CheckState()
	local state =
	{
		[ MODIFIER_STATE_ROOTED ] = true,

		[ MODIFIER_STATE_DISARMED ] = true,
		[ MODIFIER_STATE_INVISIBLE ] = false,
	}

	return state
end

--------------------------------------------------------------------------------

modifier_nature_overgrowth_thinker = class({})

-----------------------------------------------------------------------------

function modifier_nature_overgrowth_thinker:OnCreated( kv )
	if not IsServer() then
		return
	end
	local vPos = self:GetParent():GetAbsOrigin()	
	-- particles/creatures/treant_miniboss/entangle_vines.vpcf
	local nCastFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_treant/treant_overgrowth_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	--local nCastFX = ParticleManager:CreateParticle( "particles/econ/items/treant_protector/treant_ti10_immortal_head/treant_ti10_immortal_overgrowth_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	--local nCastFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_treant/treant_overgrowth_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt( nCastFX, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", vPos, true )
	ParticleManager:ReleaseParticleIndex( nCastFX )

	local radius = self:GetAbility():GetSpecialValueFor( "radius" )
	local damage = self:GetAbility():GetSpecialValueFor( "damage" )
	local unit_count = self:GetAbility():GetSpecialValueFor( "unit_count" )
	local root_duration = self:GetAbility():GetSpecialValueFor( "root_duration" )

	local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), vPos, self:GetCaster(), radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, 0, false )

	enemies=subrange(enemies,1,unit_count)

	for _, enemy in pairs( enemies ) do
		if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
			local DamageInfo =
			{
				victim = enemy,
				attacker = self:GetCaster(),
				ability = self,
				damage = damage,
				damage_type = self:GetAbility():GetAbilityDamageType(),
			}
			ApplyDamage( DamageInfo )

			root_duration = root_duration * (1 - CalUnitStatusResistance(enemy))

			enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_nature_overgrowth", { duration = root_duration } )

			-- EmitSoundOn( "TreantMiniboss.Overgrowth.Target", enemy )

			--[[
			local nTrailFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_treant/treant_overgrowth_trails.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
			ParticleManager:SetParticleControl( nTrailFX, 0, self:GetCaster():GetAbsOrigin() )
			--ParticleManager:SetParticleControl( nTrailFX, 0, enemy:GetAbsOrigin() )
			ParticleManager:SetParticleControl( nTrailFX, 1, enemy:GetAbsOrigin() )
			ParticleManager:ReleaseParticleIndex( nTrailFX )
			]]
		end
	end
end

-----------------------------------------------------------------------------
