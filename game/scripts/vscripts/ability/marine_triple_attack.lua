
marine_triple_attack = class({})
LinkLuaModifier( "modifier_marine_triple_attack", "ability/marine_triple_attack", LUA_MODIFIER_MOTION_NONE )
-- Passive Modifier
function marine_triple_attack:GetIntrinsicModifierName()

	-- Default is using attack modifier for meme reasons with moon glaive
	return "modifier_marine_triple_attack"
end

--------------------------------------------------------------------------------
-- Projectile
function marine_triple_attack:OnProjectileHit( target, location )
	if not target then return end
	-- perform attack
	self.split_shot_attack = true
	handleAttackType(self:GetCaster(),target)
	self:GetCaster():PerformAttack(
		target, -- hTarget
		false, -- bUseCastAttackOrb
		true, -- bProcessProcs
		true, -- bSkipCooldown
		false, -- bIgnoreInvis
		false, -- bUseProjectile
		false, -- bFakeAttack
		false -- bNeverMiss
	)
	self.split_shot_attack = false
	EmitSoundOn( "Hero_Venomancer.ProjectileImpact", self.parent )
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
modifier_marine_triple_attack = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_marine_triple_attack:IsHidden()
	return false
end

function modifier_marine_triple_attack:IsPurgable()
	return false
end

function modifier_marine_triple_attack:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end
--------------------------------------------------------------------------------
-- Initializations
function modifier_marine_triple_attack:OnCreated( kv )
	if not self:GetAbility() then return end
	-- references
	self.reduction = self:GetAbility():GetSpecialValueFor( "damage_modifier" )
	self.count = self:GetAbility():GetSpecialValueFor( "arrow_count" )
	self.attack_count = self:GetAbility():GetSpecialValueFor( "attack_count" )
	self.bonus_range = self:GetAbility():GetSpecialValueFor( "split_shot_bonus_range" )

	self.parent = self:GetParent()

	-- will be changed dynamically for talents
	self.use_modifier = false
	if not IsServer() then return end
	self.projectile_name = GetUnitKV(self.parent:GetUnitName(),"ProjectileModel",1) 
    --self.parent:GetRangedProjectileName()
	self.projectile_speed = self.parent:GetProjectileSpeed()

	self:SetStackCount(0)
end

function modifier_marine_triple_attack:OnRefresh( kv )
	if not self:GetAbility() then return end
	-- references
	self.reduction = self:GetAbility():GetSpecialValueFor( "damage_modifier" )
	self.count = self:GetAbility():GetSpecialValueFor( "arrow_count" )
	self.bonus_range = self:GetAbility():GetSpecialValueFor( "split_shot_bonus_range" )
	self.attack_count = self:GetAbility():GetSpecialValueFor( "attack_count" )

end

function modifier_marine_triple_attack:OnRemoved()
end

function modifier_marine_triple_attack:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_marine_triple_attack:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK,

		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}

	return funcs
end

function modifier_marine_triple_attack:OnAttack( params )
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end

	if not self:GetAbility().split_shot_attack then
		self:IncrementStackCount()
	end
	if (self:GetStackCount() % self.attack_count )== 0 then
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
		if self.use_modifier then
			self:SplitShotModifier( params.target )
		else
			self:SplitShotNoModifier( params.target )
		end
		self:SetStackCount(0)
	end
	
end

function modifier_marine_triple_attack:GetModifierDamageOutgoing_Percentage()
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
function modifier_marine_triple_attack:SplitShotModifier( target )
	-- get radius
	local radius = self.parent:Script_GetAttackRange() + self.bonus_range

	-- find other target units
	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(),	-- int, your team number
		self.parent:GetOrigin(),	-- point, center point
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

			-- perform attack
			self.split_shot = true
			self.parent:PerformAttack(
				enemy, -- hTarget
				false, -- bUseCastAttackOrb
				self.use_modifier, -- bProcessProcs
				true, -- bSkipCooldown
				false, -- bIgnoreInvis
				true, -- bUseProjectile
				false, -- bFakeAttack
				false -- bNeverMiss
			)
			self.split_shot = false

			count = count + 1
			if count>=self.count then break end
		end
	end

	-- play effects if splitshot
	if count>0 then
		local sound_cast = "Hero_Venomancer.Attack"
		EmitSoundOn( sound_cast, self.parent )
	end
end

function modifier_marine_triple_attack:SplitShotNoModifier( target )
	-- get radius
	local radius = self.parent:Script_GetAttackRange() + self.bonus_range

	-- find other target units
	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(),	-- int, your team number
		self.parent:GetOrigin(),	-- point, center point
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
		local sound_cast = "Hero_Venomancer.Attack"
		EmitSoundOn( sound_cast, self.parent )
	end
end