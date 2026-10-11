master_yi_alpha_strike = class({})
LinkLuaModifier("modifier_master_yi_alpha_strike_caster", "ability/master_yi_alpha_strike.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_master_yi_alpha_strike_mark", "ability/master_yi_alpha_strike.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_master_yi_alpha_strike_thinker", "ability/master_yi_alpha_strike.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_master_yi_alpha_strike_passive", "ability/master_yi_alpha_strike.lua", LUA_MODIFIER_MOTION_NONE)

function master_yi_alpha_strike:GetIntrinsicModifierName()
    return "modifier_master_yi_alpha_strike_passive"
end
function master_yi_alpha_strike:GetAOERadius()
	return self:GetSpecialValueFor("search_radius")
end
function master_yi_alpha_strike:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local origin = caster:GetAbsOrigin()
	local target_origin = target:GetAbsOrigin()
	local original_direction = ( origin - target_origin ):Normalized()
	local search_radius = self:GetSpecialValueFor("search_radius")
	local interval = self:GetSpecialValueFor("search_delay")

	if  target:TriggerSpellAbsorb(self) then
        return
    end

	self.strike_targets = {}
	self.original_target = target
	self.original_point = target_origin
	self.direction = original_direction
	self.start_location = origin
	
	caster:RemoveModifierByName( "modifier_double_strike_haste" )
	
	caster:EmitSound("Hero_EmberSpirit.SleightOfFist.Cast")
	
	local thinker = target:AddNewModifier( caster, self, "modifier_master_yi_alpha_strike_thinker", { duration = interval } )
	thinker:SetStackCount( self:GetSpecialValueFor("targets") - 1 )
	caster:AddNewModifier( caster, self, "modifier_master_yi_alpha_strike_caster", {} )
	self:MarkTarget( caster,target )
end
function master_yi_alpha_strike:MarkTarget( prevTarget,hTarget )
	
	playTrail(prevTarget,hTarget)

	local caster = self:GetCaster()
	if not table.contains( self.strike_targets, hTarget ) then
		if self.strike_targets then
			table.insert( self.strike_targets, 1, hTarget )
		else
			self.strike_targets = { hTarget }
		end
	end
	caster:SetAbsOrigin(hTarget:GetAbsOrigin() + self.direction * 64)
	self:PlayEffects2( hTarget )

	if hTarget:HasModifier( "modifier_master_yi_alpha_strike_mark" ) then
		local damage_pct = self:GetSpecialValueFor( "sametarget_damage_pct" ) / 100
		local damage = caster:GetAverageTrueAttackDamage( caster )
		local damageTable = {
			victim = hTarget,
			attacker = caster,
			damage = damage * damage_pct,
			damage_type = self:GetAbilityDamageType(),
			ability = self, --Optional.
		}
		ApplyDamage(damageTable)
	end
	if hTarget:IsAlive() then
		hTarget:AddNewModifier( caster, self, "modifier_master_yi_alpha_strike_mark", {} )
	end
end
function master_yi_alpha_strike:PlayEffects2( target )
	-- local particle_cast = "particles/units/heroes/hero_terrorblade/terrorblade_mirror_image.vpcf"
	-- local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	-- ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn("Hero_Terrorblade.Reflection", target)
end

function master_yi_alpha_strike:Strike()
	local caster = self:GetCaster()
	if self.strike_targets == nil then return end
	for _, target in pairs( self.strike_targets ) do
		if target:IsAlive() and not target:IsInvulnerable() and target ~= nil then
			target:RemoveModifierByName( "modifier_master_yi_alpha_strike_mark" )
			caster:PerformAttack( target, false, true, true, true, false, false, true )
			if caster:HasModifier( "modifier_double_strike_stack" ) then
				caster:FindModifierByName( "modifier_double_strike_stack" ):DecrementStackCount()
			end
		end
	end
	local direction = RandomVector( 1 )
	if self.direction ~= nil then
		direction = self.direction
	end
	local blink_loc = self.start_location
	if self.original_target ~= nil and self.original_target:IsAlive() then
		blink_loc = self.original_target:GetAbsOrigin()

		-- ExecuteOrderFromTable({
		-- 	UnitIndex = caster:entindex(),
		-- 	OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		-- 	TargetIndex = self.original_target:entindex()
		-- })

	end
	--if ( self.original_target:GetAbsOrigin() - self.original_point ):Length2D() > self:GetSpecialValueFor( "max_blinkdistance" ) then
		--blink_loc = self.start_location
	--end
	--caster:SetAbsOrigin(blink_loc + direction * 64)
	playTrail(caster,self.original_target)
	
	FindClearSpaceForUnit( caster, blink_loc + direction * 64, false )

	caster:RemoveModifierByName( "modifier_master_yi_alpha_strike_caster" )
	self.original_target = nil
	self.strike_targets = {}
end

function  playTrail(unit,target)

	if IsActiveUnit(unit) and IsActiveUnit(target) then
		-- local trail_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf", PATTACH_ABSORIGIN, target)
		-- ParticleManager:SetParticleControl(trail_pfx, 0, unit:GetAbsOrigin())
		-- ParticleManager:SetParticleControl(trail_pfx, 1, target:GetAbsOrigin())
		-- ParticleManager:ReleaseParticleIndex(trail_pfx)

		local particle_cast = "particles/econ/items/riki/riki_immortal_ti6/riki_immortal_ti6_blinkstrike.vpcf"
		
		local oldPos=unit:GetAbsOrigin()
		-- play particle
		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, target )
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			1,
			target,
			PATTACH_ABSORIGIN_FOLLOW,
			"attach_hitloc",
			target:GetOrigin(),
			true
		)
		ParticleManager:SetParticleControl( effect_cast, 0, oldPos )
		ParticleManager:ReleaseParticleIndex( effect_cast )

	end

	
end

modifier_master_yi_alpha_strike_caster = class ({})
function modifier_master_yi_alpha_strike_caster:IsPurgable() return false end
function modifier_master_yi_alpha_strike_caster:OnCreated()
	if IsServer() then
		-- The particles will properly attach if PATTACH_CUSTOMORIGIN is used instead of PATTACH_WORLDORIGIN, but there is a whole other subset of issues concerning invisible particles if the caster goes invisible or out of sight so this may be the lesser of two evils for now...

		-- self.sleight_caster_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
		-- ParticleManager:SetParticleControl(self.sleight_caster_particle, 0, self:GetCaster():GetAbsOrigin())
		-- ParticleManager:SetParticleControlForward(self.sleight_caster_particle, 1, self:GetCaster():GetForwardVector())
		
		self:GetParent():AddNoDraw()
		
		if self:GetCaster():HasAbility( "master_yi_meditate" ) then
			self:GetCaster():FindAbilityByName( "master_yi_meditate" ):SetActivated( false )
		end
		self:GetAbility():SetActivated( false )
	end
end
function modifier_master_yi_alpha_strike_caster:OnDestroy()
	if IsServer() then


		-- ParticleManager:DestroyParticle(self.sleight_caster_particle, false)
		-- ParticleManager:ReleaseParticleIndex(self.sleight_caster_particle)
	
		self:GetParent():RemoveNoDraw()
		if self:GetCaster():HasAbility( "master_yi_meditate" ) then
			self:GetCaster():FindAbilityByName( "master_yi_meditate" ):SetActivated( true )
		end
		self:GetAbility():SetActivated(true)
	end
end
function modifier_master_yi_alpha_strike_caster:CheckState()
	if IsServer() then
		local state = {
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			--[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_DISARMED] = true
		}

		return state
	end
end
function modifier_master_yi_alpha_strike_caster:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE
	}
	return funcs
end
function modifier_master_yi_alpha_strike_caster:GetModifierPreAttack_BonusDamage(params)
	if not params.target then return 0 end
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end
function modifier_master_yi_alpha_strike_caster:GetModifierIgnoreCastAngle()
	return 1
end



modifier_master_yi_alpha_strike_mark = class ({
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
})
function modifier_master_yi_alpha_strike_mark:IsDebuff() return true end
function modifier_master_yi_alpha_strike_mark:IsHidden() return true end
function modifier_master_yi_alpha_strike_mark:IsPurgable() return false end
-- function modifier_master_yi_alpha_strike_mark:GetEffectName()
-- 	return "particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_targetted_marker.vpcf"
-- end
-- function modifier_master_yi_alpha_strike_mark:GetEffectAttachType()
-- 	return PATTACH_OVERHEAD_FOLLOW
-- end
function modifier_master_yi_alpha_strike_mark:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
	}
	return funcs
end
function modifier_master_yi_alpha_strike_mark:GetModifierProvidesFOWVision()
	return 1
end

modifier_master_yi_alpha_strike_thinker = class ({})
function modifier_master_yi_alpha_strike_thinker:IsDebuff() return true end
function modifier_master_yi_alpha_strike_thinker:IsHidden() return true end
function modifier_master_yi_alpha_strike_thinker:IsPurgable() return false end
function modifier_master_yi_alpha_strike_thinker:RemoveOnDeath() return false end
function modifier_master_yi_alpha_strike_thinker:OnRemoved()

	if not IsServer() then return end

	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local interval = ability:GetSpecialValueFor("search_delay")
	local radius = ability:GetSpecialValueFor("search_radius")
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), 
		parent:GetAbsOrigin(), 
		nil, 
		radius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, 
		FIND_CLOSEST, 
		false)
	local next_target = parent
	for _, enemy in pairs( enemies ) do
		if not enemy:HasModifier( "modifier_master_yi_alpha_strike_mark" ) and not enemy:HasModifier( "modifier_master_yi_alpha_strike_thinker" ) then
			next_target = enemy
			break
		end
	end

	if next_target==parent and #enemies>0  then
		next_target=enemies[RandomInt(1, #enemies)]
	end


	if not next_target:IsAlive() then ability:Strike() end
	if self:GetStackCount() > 0 then
		local thinker = next_target:AddNewModifier( caster, ability, "modifier_master_yi_alpha_strike_thinker", { duration = interval } )
		if thinker then
			thinker:SetStackCount( self:GetStackCount() - 1 )
		end
		ability:MarkTarget(parent, next_target )
		--
	else
		ability:Strike()
	end
end

modifier_master_yi_alpha_strike_passive = class({})
function modifier_master_yi_alpha_strike_passive:IsDebuff() return false end
function modifier_master_yi_alpha_strike_passive:IsHidden() return true end
function modifier_master_yi_alpha_strike_passive:IsPurgable() return false end
function modifier_master_yi_alpha_strike_passive:IsPurgeException() return false end
function modifier_master_yi_alpha_strike_passive:RemoveOnDeath() return false end
function modifier_master_yi_alpha_strike_passive:DeclareFunctions()
    local decFuns =
    {
		MODIFIER_EVENT_ON_ATTACK
	}
    return decFuns
end
function modifier_master_yi_alpha_strike_passive:OnAttack(keys)
	-- local ability = self:GetAbility()
	-- local parent = self:GetParent()
	-- local reduce = ability:GetSpecialValueFor("cooldown_reduce")
	-- if ability then
	-- 	if (keys.attacker == parent) and (parent:IsRealHero()) and keys.target:GetTeamNumber() ~= parent:GetTeamNumber() then
	-- 		if not ability:IsCooldownReady() and not parent:HasModifier("modifier_master_yi_alpha_strike_caster") then
	-- 			local cooldown = ability:GetCooldownTimeRemaining() - reduce
	-- 			ability:EndCooldown()
	-- 			ability:StartCooldown(cooldown)
	-- 		end
	-- 	end
	-- end
end