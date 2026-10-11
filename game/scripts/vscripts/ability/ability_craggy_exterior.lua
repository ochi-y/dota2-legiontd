LinkLuaModifier("modifier_ability_craggy_exterior", "ability/ability_craggy_exterior.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities

ability_craggy_exterior = class({})

wave_11_champion_craggy_exterior = ability_craggy_exterior


element_craggy_exterior=ability_craggy_exterior


function ability_craggy_exterior:GetIntrinsicModifierName()
	return "modifier_ability_craggy_exterior"
end

function ability_craggy_exterior:OnProjectileHit(hTarget, vLocation)

	if not hTarget then
		return
	end
	local caster=self:GetCaster()
	local stun_chance=self:GetSpecialValueFor("stun_chance")
	local stun_duration=self:GetSpecialValueFor("stun_duration")
	local damage=self:GetSpecialValueFor("damage")

    if not self:IsNull() and not self:GetCaster():IsNull() and hTarget ~= nil and (not hTarget:IsInvulnerable()) and
        (not hTarget:TriggerSpellAbsorb(self)) then
        EmitSoundOn("n_mud_golem.Boulder.Target", hTarget)
        SimpleStun(self,hTarget,stun_duration)
		SimpleApplyDamage(self, caster, hTarget, damage)
		EmitSoundOn("Hero_Tiny.CraggyExterior.Stun", caster)
    end
    return true
end

---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_ability_craggy_exterior = class({
	IsHidden = function(self)
		return true
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
function modifier_ability_craggy_exterior:AllowIllusionDuplicate()
	return false
end

function modifier_ability_craggy_exterior:OnCreated(params)
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true)

	local ability=self:GetAbility()
	self.stun_chance=ability:GetSpecialValueFor("stun_chance")
	self.stun_duration=ability:GetSpecialValueFor("stun_duration")
	self.damage=ability:GetSpecialValueFor("damage")
	self.radius=ability:GetSpecialValueFor("radius")

end

function modifier_ability_craggy_exterior:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_ability_craggy_exterior:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_ability_craggy_exterior:CheckState()
	local state = {
	}
	return state
end

function modifier_ability_craggy_exterior:OnAttackLanded(params)
	if not IsServer() then return end

	local attacker=params.attacker
	local caster=self:GetCaster()

	local target = params.target

	local ability=self:GetAbility()
	if target==caster then
		if not SimpleUnitFilter(ability, attacker) then
			return
		end
		if (attacker:GetAbsOrigin()-caster:GetAbsOrigin()):Length2D()>self.radius then
			return 
		end
		-- if attacker:GetAttackCapability()~=DOTA_UNIT_CAP_MELEE_ATTACK then
		-- 	return 
		-- end
		local ability=self:GetAbility()
		if RandomInt(1, 100)<=self.stun_chance then
			local info = {
                EffectName = "particles/neutral_fx/mud_golem_hurl_boulder.vpcf",
                Ability = ability,
                iMoveSpeed = 2000,
                Source = self:GetCaster(),
                Target = attacker,
                bDodgeable = true,
                bProvidesVision = true,
                iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
                iVisionRadius = 100,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
            }
            ProjectileManager:CreateTrackingProjectile(info)
			EmitSoundOn("Hero_Tiny.CraggyExterior", caster)
		end
	end
end
