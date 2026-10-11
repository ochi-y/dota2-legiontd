
paladin_multishot = class({})
LinkLuaModifier( "modifier_paladin_multishot", "ability/paladin_multishot", LUA_MODIFIER_MOTION_NONE )
-- Passive Modifier
function paladin_multishot:GetIntrinsicModifierName()
	-- Default is using attack modifier for meme reasons with moon glaive
	return "modifier_paladin_multishot"
end

--------------------------------------------------------------------------------
-- Projectile
function paladin_multishot:OnProjectileHit( target, location )
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
	--EmitSoundOn( "Hero_Venomancer.ProjectileImpact", self.parent )
end
--------------------------------------------------------------------------------
modifier_paladin_multishot = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_paladin_multishot:IsHidden()
	return true
end

function modifier_paladin_multishot:IsPurgable()
	return false
end

function modifier_paladin_multishot:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end
--------------------------------------------------------------------------------
-- Initializations
function modifier_paladin_multishot:OnCreated( kv )
	if not self:GetAbility() then return end
	-- references
	self.reduction = self:GetAbility():GetSpecialValueFor( "damage_modifier" )
	self.count = self:GetAbility():GetSpecialValueFor( "arrow_count" )
	self.bonus_range = self:GetAbility():GetSpecialValueFor( "split_shot_bonus_range" )

	self.parent = self:GetParent()

	-- will be changed dynamically for talents
	self.use_modifier = false
	if not IsServer() then return end
	self.projectile_name = GetUnitKV(self.parent:GetUnitName(),"ProjectileModel",1) 
    --self.parent:GetRangedProjectileName()
	self.projectile_speed = self.parent:GetProjectileSpeed()
end

function modifier_paladin_multishot:OnRefresh( kv )
	-- references
	self.reduction = self:GetAbility():GetSpecialValueFor( "damage_modifier" )
	self.count = self:GetAbility():GetSpecialValueFor( "arrow_count" )
	self.bonus_range = self:GetAbility():GetSpecialValueFor( "split_shot_bonus_range" )
end

function modifier_paladin_multishot:OnRemoved()
end

function modifier_paladin_multishot:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_paladin_multishot:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK,

		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}

	return funcs
end

function modifier_paladin_multishot:OnAttack( params )
	if not IsServer() then return end
	
	if params.attacker~=self.parent then return end
	-- not proc for instant attacks
	if params.no_attack_cooldown then return end


	if self.parent:HasModifier("modifier_paladin_focus_fire") then
		return
	end

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
	
end

function modifier_paladin_multishot:GetModifierDamageOutgoing_Percentage()
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
function modifier_paladin_multishot:SplitShotModifier( target )
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
		-- local sound_cast = "Hero_Venomancer.Attack"
		-- EmitSoundOn( sound_cast, self.parent )
	end
end

function modifier_paladin_multishot:SplitShotNoModifier( target )
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

			if IsActiveUnit(info.Source) then
				ProjectileManager:CreateTrackingProjectile(info)
				count = count + 1
				if count>=self.count then break end
			end
		end
	end

	-- play effects if splitshot
	if count>0 then
		-- local sound_cast = "Hero_Venomancer.Attack"
		-- EmitSoundOn( sound_cast, self.parent )
	end
end