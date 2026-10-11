LinkLuaModifier("modifier_radiant_krama", "ability/radiant_krama.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_radiant_krama_debuff", "ability/radiant_krama.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if radiant_krama == nil then
	radiant_krama = class({})
end
function radiant_krama:GetIntrinsicModifierName()
	return "modifier_radiant_krama"
end

radiant_blade_dance = radiant_krama
---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_radiant_krama = class({
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

function modifier_radiant_krama:OnCreated(params)
	local ability = self:GetAbility()
	self.crit_chance = ability:GetSpecialValueFor("crit_chance")
	self.crit_mult = ability:GetSpecialValueFor("crit_mult")
	self.heal_chance = ability:GetSpecialValueFor("heal_chance")
	self.heal = ability:GetSpecialValueFor("heal")

	if not IsServer() then return end
	self.records = {}
end

function modifier_radiant_krama:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_radiant_krama:OnDestroy()
	if IsServer() then
	end
end

function modifier_radiant_krama:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_EVENT_ON_ATTACK_RECORD,
		MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK_START  
	}
end
function modifier_radiant_krama:OnAttackStart(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() then
		return
	end
	-- print(kv.record)

	self.critFlag=(RandomInt(1, 100) <= self.crit_chance)
	if not self.critFlag then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_radiant_krama_debuff", {
			duration = FrameTime()
		})
	end
end
function modifier_radiant_krama:OnAttackRecord(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() then
		return
	end

	self.records[kv.record] = self.critFlag
end

function modifier_radiant_krama:OnAttackRecordDestroy(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() then
		return
	end
	self.records[kv.record] = nil
end

function modifier_radiant_krama:OnAttackLanded(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() then
		return
	end
	if not self.records[kv.record] then
		-- PrintTable(kv)
		local d=self:GetParent():GetAverageTrueAttackDamage(self:GetParent())
		print(d)
		local heal = math.ceil(d * self.heal / 100)
		kv.target:HealWithParams(heal, self:GetAbility(), false, true, self:GetParent(), false)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, kv.target, heal, nil)
		self:PlayEffects(kv.target)

		-- self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_radiant_krama_debuff", {
		-- 	duration = 1
		-- })
		
	end
end

function modifier_radiant_krama:PlayEffects(unit)
	-- Get Resources
	local particle_cast = "particles/generic_gameplay/generic_lifesteal.vpcf"
	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, unit)
	-- ParticleManager:SetParticleControl( effect_cast, iControlPoint, vControlVector )
	-- ParticleManager:SetParticleControlEnt(
	-- 	effect_cast,
	-- 	iControlPoint,
	-- 	hTarget,
	-- 	PATTACH_NAME,
	-- 	"attach_name",
	-- 	vOrigin, -- unknown
	-- 	bool -- unknown, true
	-- )
	ParticleManager:ReleaseParticleIndex(effect_cast)
end

function modifier_radiant_krama:GetModifierPreAttack_CriticalStrike(kv)
	if self.records[kv.record] then
		EmitSoundOn("Hero_Juggernaut.BladeDance", self:GetCaster())
		return self.crit_mult
	end

	-- if RandomInt(1, 100) <= self.crit_chance then
	-- 	if self:GetAbility():GetAbilityName() == "radiant_blade_dance" then
	-- 		EmitSoundOn("Hero_Juggernaut.BladeDance", self:GetCaster())
	-- 	end
	-- 	return self.crit_mult
	-- end
end

-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_radiant_krama_debuff = class({
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
function modifier_radiant_krama_debuff:AllowIllusionDuplicate()
	return false
end

function modifier_radiant_krama_debuff:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	if not IsServer() then return end
end

function modifier_radiant_krama_debuff:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_radiant_krama_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
	}
end

function modifier_radiant_krama_debuff:GetModifierDamageOutgoing_Percentage()
	return -100
end
