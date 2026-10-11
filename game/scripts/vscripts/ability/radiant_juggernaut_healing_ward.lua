LinkLuaModifier("modifier_radiant_juggernaut_healing_ward", "ability/radiant_juggernaut_healing_ward",
	LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_radiant_juggernaut_healing_ward_aura", "ability/radiant_juggernaut_healing_ward",
	LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_radiant_juggernaut_healing_ward_aura_buff", "ability/radiant_juggernaut_healing_ward",
	LUA_MODIFIER_MOTION_NONE)
--Abilities
if radiant_juggernaut_healing_ward == nil then
	radiant_juggernaut_healing_ward = class({})
end
function radiant_juggernaut_healing_ward:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_Juggernaut.HealingWard.Cast", caster)
	local pos = caster:GetCursorPosition()

	local pid = caster:GetPlayerOwnerID()
	local hero = PlayerResource:GetSelectedHeroEntity(pid)
	local tUnit = CreateUnitByName("radiant_healing_ward", pos, false, hero, hero, caster:GetTeamNumber())
	-- tUnit:SetControllableByPlayer(pid, true)
	local angle_now = caster:GetAnglesAsVector()
	tUnit:SetAngles(angle_now.x, angle_now.y, angle_now.z)
	-- local ab = tUnit:FindAbilityByName("war3_healing_aura")
	-- ab:SetLevel(1)
	SimpleMoveUnit(tUnit, pos)

	tUnit:AddNewModifier(caster, self, "modifier_radiant_juggernaut_healing_ward_aura",
		{})

	tUnit:AddNewModifier(caster, self, "modifier_kill",
		{ duration = self:GetSpecialValueFor("healing_ward_duration_tooltip") })
end

function radiant_juggernaut_healing_ward:GetAOERadius()
	return self:GetSpecialValueFor("healing_ward_aura_radius")
end

---------------------------------------------------------------------
-- Modifiers
modifier_radiant_juggernaut_healing_ward_aura = class({
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
function modifier_radiant_juggernaut_healing_ward_aura:OnCreated(params)
	local ability = self:GetAbility()
	self.radius = ability:GetSpecialValueFor("healing_ward_aura_radius")
	self.heal_hp_pct = ability:GetSpecialValueFor("healing_ward_heal_amount")

	if not IsServer() then return end
	local eff = "particles/units/heroes/hero_juggernaut/juggernaut_healing_ward.vpcf"
	local parent = self:GetParent()
	local effect_cast = ParticleManager:CreateParticle(eff, PATTACH_ABSORIGIN_FOLLOW, parent)
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(self.radius, 0, -400))
	self:AddParticle(effect_cast, false, false, -1, false, false)
end

function modifier_radiant_juggernaut_healing_ward_aura:OnRefresh(params)
	local ability = self:GetAbility()
	self.radius = ability:GetSpecialValueFor("healing_ward_aura_radius")
	self.heal_hp_pct = ability:GetSpecialValueFor("healing_ward_heal_amount")
end

function modifier_radiant_juggernaut_healing_ward_aura:OnDestroy()
	if IsServer() then
	end
end

function modifier_radiant_juggernaut_healing_ward_aura:DeclareFunctions()
	return {}
end

function modifier_radiant_juggernaut_healing_ward_aura:IsAura()
	return true
end

function modifier_radiant_juggernaut_healing_ward_aura:GetModifierAura()
	return "modifier_radiant_juggernaut_healing_ward_aura_buff"
end

function modifier_radiant_juggernaut_healing_ward_aura:GetAuraRadius()
	return self.radius
end

function modifier_radiant_juggernaut_healing_ward_aura:GetAuraDuration()
	return 0
end

function modifier_radiant_juggernaut_healing_ward_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_radiant_juggernaut_healing_ward_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_radiant_juggernaut_healing_ward_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_radiant_juggernaut_healing_ward_aura:GetAuraEntityReject(hEntity)
	return false
end

function modifier_radiant_juggernaut_healing_ward_aura:CheckState()
	local state = {
		[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
	}
	return state
end

--
modifier_radiant_juggernaut_healing_ward_aura_buff = class({
	IsHidden = function(self)
		return false
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

function modifier_radiant_juggernaut_healing_ward_aura_buff:OnCreated()
	local ability = self:GetAbility()
	self.heal_hp_pct = ability:GetSpecialValueFor("healing_ward_heal_amount")
end

function modifier_radiant_juggernaut_healing_ward_aura_buff:DeclareFunctions()
	return { MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE }
end

function modifier_radiant_juggernaut_healing_ward_aura_buff:GetModifierHealthRegenPercentage()
	return self.heal_hp_pct
end
