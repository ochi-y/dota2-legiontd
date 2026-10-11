LinkLuaModifier("modifier_radiant_storm_attack", "ability/radiant_storm_attack.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_radiant_storm_attack_debuff", "ability/radiant_storm_attack.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if radiant_storm_attack == nil then
	radiant_storm_attack = class({})
end
function radiant_storm_attack:GetIntrinsicModifierName()
	return "modifier_radiant_storm_attack"
end

modifier_radiant_storm_attack = class({
	IsHidden         = function(self) return true end,
	IsPurgable       = function(self) return false end,
	IsDebuff         = function(self) return false end,
	IsBuff           = function(self) return true end,
	DeclareFunctions = function()
		return {
			MODIFIER_EVENT_ON_ATTACK_LANDED
		}
	end
})

function modifier_radiant_storm_attack:OnCreated()
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.duration = ability:GetSpecialValueFor("duration")
	self.chance = ability:GetSpecialValueFor("chance")
end

function modifier_radiant_storm_attack:OnRefresh()
	self:OnCreated()
end

function modifier_radiant_storm_attack:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target

	local duration = self.duration
	if params.attacker:PassivesDisabled() == false and SimpleUnitFilter(self:GetAbility(), target) and RandomInt(1, 100) <= self.chance then
		duration = duration * (1 - CalUnitStatusResistance(target))
		target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_radiant_storm_attack_debuff",
			{ duration = self.duration })
		EmitSoundOn("Hero_Zuus.StaticField", target)
		target:Purge(true, false, false, false, false)
	end
end

-- function modifier_radiant_storm_attack:GetEffectName()
-- 	return "particles/units/heroes/hero_brewmaster/brewmaster_fire_ambient.vpcf"
-- end

-- function modifier_radiant_storm_attack:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end
modifier_radiant_storm_attack_debuff = class({
	IsHidden = function(self)
		return false
	end,
	IsPurgable = function(self)
		return true
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
function modifier_radiant_storm_attack_debuff:AllowIllusionDuplicate()
	return false
end

function modifier_radiant_storm_attack_debuff:OnCreated(params)
	if not self:GetAbility() then return end

	local ability = self:GetAbility()
	self.max_slow = ability:GetSpecialValueFor("max_slow")
	self.attack_slow = ability:GetSpecialValueFor("attack_slow")

	if not IsServer() then return end
	self:StartIntervalThink(0.8)
	-- self.slowTick = 0
end

function modifier_radiant_storm_attack_debuff:OnRefresh(params)
	--self.slowTick = 0
end

function modifier_radiant_storm_attack_debuff:OnIntervalThink(params)
	if not IsServer() then return end
	--self.slowTick=self.slowTick+1
end

function modifier_radiant_storm_attack_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
	}
end

function modifier_radiant_storm_attack_debuff:GetModifierMoveSpeedBonus_Percentage(params)
	local slow =math.floor( self.max_slow * (100 - 20 * math.floor(self:GetElapsedTime() / 0.8)) / 100)
	if slow < 0 then
		slow = 0
	end
	return -slow
end

function modifier_radiant_storm_attack_debuff:GetModifierAttackSpeedPercentage(params)
	local slow =math.floor( self.attack_slow * (100 - 20 * math.floor(self:GetElapsedTime() / 0.8)) / 100)
	if slow < 0 then
		slow = 0
	end
	return -slow
end

function modifier_radiant_storm_attack_debuff:GetEffectName()
	return "particles/units/heroes/hero_zuus/zuus_shard_slow.vpcf"
end

function modifier_radiant_storm_attack_debuff:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end
