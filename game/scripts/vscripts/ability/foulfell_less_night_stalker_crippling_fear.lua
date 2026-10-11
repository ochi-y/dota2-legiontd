LinkLuaModifier("modifier_foulfell_less_night_stalker_crippling_fear",
	"ability/foulfell_less_night_stalker_crippling_fear.lua",
	LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_foulfell_less_night_stalker_crippling_fear_buff",
	"ability/foulfell_less_night_stalker_crippling_fear.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if foulfell_less_night_stalker_crippling_fear == nil then
	foulfell_less_night_stalker_crippling_fear = class({})
end
function foulfell_less_night_stalker_crippling_fear:GetIntrinsicModifierName()
	return "modifier_foulfell_less_night_stalker_crippling_fear"
end

---------------------------------------------------------------------
--Modifiers
modifier_foulfell_less_night_stalker_crippling_fear = class({
	IsHidden      = function(self) return true end,
	IsPurgable    = function(self) return false end,
	IsDebuff      = function(self) return false end,
	IsBuff        = function(self) return true end,
	RemoveOnDeath = function(self) return true end,
	GetAttributes = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_foulfell_less_night_stalker_crippling_fear:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.radius = ability:GetSpecialValueFor("radius")
	self.miss = ability:GetSpecialValueFor("miss")

	if IsServer() then
		local caster = self:GetCaster()
		local effect = ParticleManager:CreateParticle(
			"particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW,
			caster)
		ParticleManager:SetParticleControlEnt(effect, 0, caster, PATTACH_ABSORIGIN_FOLLOW, nil,
			caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(effect, 2, Vector(self.radius, self.radius, self.radius))
		-- ParticleManager:ReleaseParticleIndex(effect)
		self:AddParticle(effect, false, false, -1, false, false)
	end
end

function modifier_foulfell_less_night_stalker_crippling_fear:OnRefresh(params)
	if IsServer() then
	end
end

function modifier_foulfell_less_night_stalker_crippling_fear:OnDestroy()
	if IsServer() then
	end
end

function modifier_foulfell_less_night_stalker_crippling_fear:DeclareFunctions()
	return {
	}
end

function modifier_foulfell_less_night_stalker_crippling_fear:IsAura()
	return true
end

function modifier_foulfell_less_night_stalker_crippling_fear:GetModifierAura()
	return "modifier_foulfell_less_night_stalker_crippling_fear_buff"
end

function modifier_foulfell_less_night_stalker_crippling_fear:GetAuraRadius()
	return self.radius
end

function modifier_foulfell_less_night_stalker_crippling_fear:GetAuraDuration()
	return 0
end

function modifier_foulfell_less_night_stalker_crippling_fear:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_foulfell_less_night_stalker_crippling_fear:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_foulfell_less_night_stalker_crippling_fear:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_foulfell_less_night_stalker_crippling_fear:GetAuraEntityReject(hEntity)
	return false
end

-- function modifier_foulfell_less_night_stalker_crippling_fear:GetEffectName()
-- 	return "particles/units/heroes/hero_pudge/pudge_rot.vpcf"
-- end

-- function modifier_foulfell_less_night_stalker_crippling_fear:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end

--
modifier_foulfell_less_night_stalker_crippling_fear_buff = class({
	IsHidden      = function(self) return false end,
	IsPurgable    = function(self) return false end,
	IsDebuff      = function(self) return true end,
	IsBuff        = function(self) return false end,
	RemoveOnDeath = function(self) return true end,
	GetAttributes = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_foulfell_less_night_stalker_crippling_fear_buff:OnCreated()
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.miss = ability:GetSpecialValueFor("miss")
	self.attack_slow = ability:GetSpecialValueFor("attack_slow")
end

function modifier_foulfell_less_night_stalker_crippling_fear_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MISS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
	}
end

function modifier_foulfell_less_night_stalker_crippling_fear_buff:GetModifierMiss_Percentage()
	return self.miss
end

function modifier_foulfell_less_night_stalker_crippling_fear_buff:GetModifierAttackSpeedPercentage(params)
	return -self.attack_slow
end
