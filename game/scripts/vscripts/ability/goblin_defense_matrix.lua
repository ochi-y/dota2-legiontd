LinkLuaModifier("modifier_goblin_defense_matrix", "ability/goblin_defense_matrix.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if goblin_defense_matrix == nil then
	goblin_defense_matrix = class({})
end
function goblin_defense_matrix:OnSpellStart()
	local caster = self:GetCaster()
	local barrier_duration = self:GetSpecialValueFor("barrier_duration")
	caster:AddNewModifier(caster, self, "modifier_goblin_defense_matrix", {
		duration = barrier_duration
	})
	EmitSoundOn("Hero_Tinker.DefensiveMatrix.Cast", caster)
end

---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_goblin_defense_matrix = class({
	IsHidden = function(self)
		return false
	end,
	IsPurgable = function(self)
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
function modifier_goblin_defense_matrix:AllowIllusionDuplicate()
	return false
end

function modifier_goblin_defense_matrix:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.status_resistance = ability:GetSpecialValueFor("status_resistance")

	if not IsServer() then return end
	self.current_shield = ability:GetSpecialValueFor("damage_absorb")


	self:SetHasCustomTransmitterData(true)

	local caster = self:GetCaster()

	self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_defense_matrix.vpcf",
		PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent())
	local position = self:GetParent():GetAbsOrigin()
	ParticleManager:SetParticleControlEnt(self.particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc",
		position, true)
	self:AddParticle(self.particle, false, false, -1, false, false)
end

function modifier_goblin_defense_matrix:OnRefresh(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.status_resistance = ability:GetSpecialValueFor("status_resistance")

	if not IsServer() then return end
	self.current_shield = ability:GetSpecialValueFor("damage_absorb")

	self:SetHasCustomTransmitterData(true)

	local caster = self:GetCaster()
	if self.particle then
		ParticleManager:DestroyParticle(self.particle, false)
	end

	self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_defense_matrix.vpcf",
		PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent())
	local position = self:GetParent():GetAbsOrigin()
	ParticleManager:SetParticleControlEnt(self.particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc",
		position, true)
	self:AddParticle(self.particle, false, false, -1, false, false)
end

function modifier_goblin_defense_matrix:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_REDUCTION_PERCENTAGE, 
		MODIFIER_PROPERTY_MOVESPEED_REDUCTION_PERCENTAGE,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
	}
end

function modifier_goblin_defense_matrix:AddCustomTransmitterData()
	-- on server
	local data = {
		current_shield = self.current_shield
	}
	return data
end

function modifier_goblin_defense_matrix:HandleCustomTransmitterData(data)
	-- on client
	self.current_shield = data.current_shield
end
function modifier_goblin_defense_matrix:GetModifierStatusResistanceStacking()
    return self.status_resistance
end

function modifier_goblin_defense_matrix:GetModifierAttackSpeedReductionPercentage()
    return self.status_resistance
end

function modifier_goblin_defense_matrix:GetModifierMoveSpeedReductionPercentage()
    return self.status_resistance
end

function modifier_goblin_defense_matrix:GetModifierIncomingDamageConstant(params)
	if not IsServer() then
		return self.current_shield
	end
	-- block based on damage
	if params.damage > self.current_shield then
		self:Destroy()
		return -self.current_shield
	else
		self.current_shield = self.current_shield - params.damage
		-- refresh shield on client using transmitter data
		self:SendBuffRefreshToClients()
		return -params.damage
	end
end

-- function modifier_goblin_defense_matrix:GetEffectName()
-- 	return "particles/units/heroes/hero_tinker/tinker_defense_matrix.vpcf"
-- end

-- function modifier_goblin_defense_matrix:GetEffectAttachType()
-- 	return PATTACH_POINT_FOLLOW
-- end
