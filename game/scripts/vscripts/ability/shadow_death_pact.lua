LinkLuaModifier("modifier_shadow_death_pact", "ability/shadow_death_pact.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if shadow_death_pact == nil then
	shadow_death_pact = class({})
end

function shadow_death_pact:CastFilterResultTarget(hTarget)
	if IsKing(hTarget) then
		return UF_FAIL_CUSTOM
	end
	return UF_SUCCESS
end

function shadow_death_pact:GetCustomCastErrorTarget(hTarget)
	-- if self:GetCaster() == hTarget then
	-- 	return "#dota_hud_error_cant_cast_on_self"
	-- end
	return "#dota_hud_error_cant_cast_on_building"
end

function shadow_death_pact:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	EmitSoundOn("Hero_Clinkz.DeathPact", target)
	local health_gain = self:GetSpecialValueFor("health_gain")
	local damage_percent = self:GetSpecialValueFor("damage_percent")
	local duration = self:GetSpecialValueFor("duration")

	local hp = math.floor(target:GetHealth() * health_gain / 100)
	local damage = math.floor(target:GetHealth() * damage_percent / 100)

	local eff = "particles/units/heroes/hero_clinkz/clinkz_death_pact.vpcf"


	if IsCustomBuilding(caster) then
		GamePlay:FighterSetAbilityTarget(caster.fighterId,self:GetAbilityName(),target.fighterId)
	end

	PlayEffOnUnit(eff, target)

	local health = target:GetHealth()

	if not IsActiveBuilding(target) then
		target:Kill(self, caster)
	end

	local mod = caster:AddNewModifier(caster, self, "modifier_shadow_death_pact", {
		duration = duration,
		hp = hp,
		damage = damage,
	})
	mod:SetStackCount(math.floor(health))
	-- caster:Heal(hp,self)
	caster:CalculateGenericBonuses()
end

-------------------------------------------------------------------------------------------------------
modifier_shadow_death_pact = class({
	IsHidden = function(self)
		return false
	end,
	IsPurgable = function(self)
		return true
	end,
	IsPurgeException = function(self)
		return true
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
function modifier_shadow_death_pact:AllowIllusionDuplicate()
	return false
end

function modifier_shadow_death_pact:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()

	self.hp = params.hp
	self.damage = params.damage

	self.health_gain = ability:GetSpecialValueFor("health_gain")
	self.damage_percent = ability:GetSpecialValueFor("damage_percent")

	if not IsServer() then return end
	--	self:SetHasCustomTransmitterData(true)

	-- self:SetStackCount(params.hp)

	-- self:StartIntervalThink(1)
	-- self:SendBuffRefreshToClients()
end

function modifier_shadow_death_pact:OnIntervalThink()
	self:SendBuffRefreshToClients()

	self:GetCaster():CalculateGenericBonuses()
end

function modifier_shadow_death_pact:AddCustomTransmitterData()
	-- on server
	local data = {
		hp = self.hp,
		damage = self.damage,
	}
	return data
end

function modifier_shadow_death_pact:HandleCustomTransmitterData(data)
	-- on client
	self.hp = data.hp
	self.damage = data.damage
end

function modifier_shadow_death_pact:OnRefresh(params)
	-- self:OnCreated(params)
end

function modifier_shadow_death_pact:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		-- MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS
	}
end

function modifier_shadow_death_pact:GetModifierExtraHealthBonus()
	return math.floor(self:GetStackCount() * self.health_gain / 100)
end

function modifier_shadow_death_pact:GetModifierPreAttack_BonusDamage()
	return math.floor(self:GetStackCount() * self.damage_percent / 100)
end

-- function modifier_shadow_death_pact:GetModifierExtraHealthPercentage()
-- 	return self.hp
-- end
