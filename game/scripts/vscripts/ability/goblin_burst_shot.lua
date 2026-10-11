
goblin_burst_shot = class({})
LinkLuaModifier( "modifier_goblin_burst_shot", "ability/goblin_burst_shot", LUA_MODIFIER_MOTION_NONE )
-- Passive Modifier
function goblin_burst_shot:GetIntrinsicModifierName()

	-- Default is using attack modifier for meme reasons with moon glaive
	return "modifier_goblin_burst_shot"
end

--------------------------------------------------------------------------------
-- Projectile
function goblin_burst_shot:OnProjectileHit( target, location )
	if not target then return end
	-- perform attack
	self.split_shot_attack = true
	
	handleAttackType(self:GetCaster(),target)
	self:GetCaster():PerformAttack(
		target, -- hTarget
		false, -- bUseCastAttackOrb
		false, -- bProcessProcs
		true, -- bSkipCooldown
		false, -- bIgnoreInvis
		false, -- bUseProjectile
		false, -- bFakeAttack
		false -- bNeverMiss
	)
	self.split_shot_attack = false
end

-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
modifier_goblin_burst_shot = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_goblin_burst_shot:IsHidden()
	return true
end

function modifier_goblin_burst_shot:IsPurgable()
	return false
end

function modifier_goblin_burst_shot:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end
--------------------------------------------------------------------------------
-- Initializations
function modifier_goblin_burst_shot:OnCreated( kv )
	if not IsServer() then return end
	-- references
	self.reduction = self:GetAbility():GetSpecialValueFor( "damage_modifier" )
	self.count = self:GetAbility():GetSpecialValueFor( "arrow_count" )

	self.parent = self:GetParent()

	-- will be changed dynamically for talents
	self.use_modifier = false
	--self.projectile_name = GetUnitKV(self.parent:GetUnitName(),"ProjectileModel",1) 
    
	self.projectile_name="particles/units/heroes/hero_tinker/tinker_base_attack.vpcf"
	--self.parent:GetRangedProjectileName()
	self.projectile_speed = self.parent:GetProjectileSpeed()
end

function modifier_goblin_burst_shot:OnRefresh( kv )
	-- references
	self.reduction = self:GetAbility():GetSpecialValueFor( "damage_modifier" )
	self.count = self:GetAbility():GetSpecialValueFor( "arrow_count" )
end

function modifier_goblin_burst_shot:OnRemoved()
end

function modifier_goblin_burst_shot:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_goblin_burst_shot:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK,

		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}

	return funcs
end

function modifier_goblin_burst_shot:OnAttack( params )
	if not IsServer() then return end


	if params.attacker~=self.parent then return end

	-- not proc for instant attacks
	if params.no_attack_cooldown then return end

	-- not proc for attacking allies
	if params.target:GetTeamNumber()==params.attacker:GetTeamNumber() then return end

	-- not proc if break
	if self.parent:PassivesDisabled() then return end
	-- not proc if attack can't use attack modifiers
	if not params.process_procs then return end

	-- not proc on split shot attacks, even if it can use attack modifier, to avoid endless recursive call and crash
	if self.split_shot then return end
	-- split shot
	self:SplitShotNoModifier( params.target )
end

function modifier_goblin_burst_shot:GetModifierDamageOutgoing_Percentage()
	if not IsServer() then return end
	
	-- if uses modifier
	if self.split_shot then
		return self.reduction
	end

	-- if not use modifier
	if self:GetAbility().split_shot_attack then
		
		
		return self.reduction
	end
end
--------------------------------------------------------------------------------
-- Helper
--[[
	NOTE:
	- PerformAttack will use projectile particle from items, even if it actually not using attack modifiers
	- Split shot without attack modifier uses regular tracking projectile, then perform instant attacks on projectile hit
	- Therefore, SplitShotModifier and SplitShotNoModifier are separated JUST BECAUSE of projectile effects.
]]

function modifier_goblin_burst_shot:SplitShotNoModifier( target )
	-- get radius
	local radius = 200

	-- find other target units
	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(),	-- int, your team number
		target:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_COURIER,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	-- get targets
	local count = 0
	for _,enemy in pairs(enemies) do
		-- not target itself
		if enemy~=target then
			-- launch projectile
			local info = {
				Target = enemy,
				Source = self.parent,
				Ability = self:GetAbility(),	
				
				EffectName = self.projectile_name,
				iMoveSpeed = self.projectile_speed,
				bDodgeable = true,                           -- Optional
				-- bIsAttack = true,                                -- Optional
			}
			ProjectileManager:CreateTrackingProjectile(info)

			count = count + 1
			if count>=self.count then break end
		end
	end

	-- play effects if splitshot
	if count>0 then
		local sound_cast = "Hero_Tinker.ProjectileImpact"
		EmitSoundOn( sound_cast, self.parent )
	end
end