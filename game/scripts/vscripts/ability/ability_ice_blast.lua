LinkLuaModifier( "modifier_ability_ice_blast", "ability/ability_ice_blast.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities

ability_ice_blast = class({})

wave_14_champion_ice_blast=ability_ice_blast
arctic_ice_blast=ability_ice_blast
function ability_ice_blast:OnSpellStart()
	local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    EmitSoundOn("n_creep_ice_shaman.IceBomb.Cast", caster)

	local count=self:GetSpecialValueFor("count") or 1
	
	local units=FindAbilityTarget(self,target:GetAbsOrigin(),600,{findOrder=FIND_ANY_ORDER}) 

	-- UTIL:orderByUnitTag(units,"ability_ice_blast",true)
	-- UTIL:orderByModifier(units,"modifier_ability_ice_blast",true)
	TableRemoveByValue(units,target)
	table.insert(units,1,target)

	for i = 1, count, 1 do
		local unit=units[i]
		if unit then
			local speed = 1200
			local vision_radius = 0
		
			local proj = "particles/neutral_fx/icefire_bomb.vpcf"
		
			local info = {
				Target = unit,
				Source = caster,
				Ability = self,
				EffectName = proj,
				bDodgeable = true,
				bIsAttack = false,
				bProvidesVision = false,
				iMoveSpeed = speed,
				vSpawnOrigin = caster:GetAbsOrigin(),
				iVisionRadius = vision_radius,
				iVisionTeamNumber = caster:GetTeamNumber(),
				iSourceAttachment     = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
			}
			ProjectileManager:CreateTrackingProjectile( info )
		end
	end
end

function ability_ice_blast:OnProjectileHit(Target, Location)
	if Target ~= nil and not Target:IsInvulnerable() then
        local duration = self:GetSpecialValueFor("duration")
        EmitSoundOn("n_creep_ice_shaman.IceBomb.Target", Target)
		local damage=self:GetSpecialValueFor("damage")
		ApplyDamage({
			victim = Target,
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self
		})

		duration = duration * (1 - CalUnitStatusResistance(Target))

		Target:AddNewModifier(self:GetCaster(), self, "modifier_ability_ice_blast", {duration=duration})
    end
    return false
end

-------------------------------------------------------------------------------------------------------
modifier_ability_ice_blast = class({
	IsHidden = function(self)
		return false
	end,
	IsPurgable = function(self)
		return false
	end,
	IsDebuff = function(self)
		return true
	end,
	IsBuff = function(self)
		return false
	end,
	RemoveOnDeath = function(self)
		return true
	end,
	GetAttributes = function(self)
		return MODIFIER_ATTRIBUTE_NONE
	end
})
function modifier_ability_ice_blast:AllowIllusionDuplicate()
	return false
end
function modifier_ability_ice_blast:OnCreated(params)
	local ability=self:GetAbility()
	self.crippling=ability:GetSpecialValueFor("crippling")
	self.slow=ability:GetSpecialValueFor("slow")
	self.damage=ability:GetSpecialValueFor("damage")
	if not IsServer() then return end
	self:StartIntervalThink(1)
end

function modifier_ability_ice_blast:OnIntervalThink(params)
	SimpleApplyDamage(self:GetAbility(), self:GetCaster(), self:GetParent(), self.damage)
end

function modifier_ability_ice_blast:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_ability_ice_blast:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE 
	}
end

function modifier_ability_ice_blast:GetModifierAttackSpeedBonus_Constant()
	if self:GetParent():IsAncient() then
        return -self.crippling*(100-BOSS_ATTACK_SPEED_REDUCTION_RESISTANCE)/100
    end
	return -self.crippling
end
function modifier_ability_ice_blast:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow
end
function modifier_ability_ice_blast:GetEffectName()
	return "particles/neutral_fx/icefire_bomb_debuff.vpcf"
end
function modifier_ability_ice_blast:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end
