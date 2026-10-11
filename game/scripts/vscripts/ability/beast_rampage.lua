LinkLuaModifier("modifier_beast_rampage", "ability/beast_rampage.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if beast_rampage == nil then
	beast_rampage = class({})
end
function beast_rampage:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_TrollWarlord.Rampage.Cast", caster)
	PlayEffOnUnit("particles/units/heroes/hero_troll_warlord/troll_warlord_rampage.vpcf", caster)


	local duration = self:GetSpecialValueFor("duration")

	local units = FindAbilityTarget(self, caster:GetAbsOrigin(), self:GetSpecialValueFor("radius"), {})

	for index, unit in ipairs(units) do
		unit:AddNewModifier(caster, self, "modifier_beast_rampage", {
			duration = duration
		})
	end
end

---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_beast_rampage = class({
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
function modifier_beast_rampage:AllowIllusionDuplicate()
	return false
end

function modifier_beast_rampage:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.attack_speed = ability:GetSpecialValueFor("attack_speed")
	self.attackspeed_reduction_percentage = ability:GetSpecialValueFor("attackspeed_reduction_percentage")
	self.movespeed_reduction_percentage = ability:GetSpecialValueFor("movespeed_reduction_percentage")
	if not IsServer() then return end
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true)
end

function modifier_beast_rampage:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_beast_rampage:DeclareFunctions()
	return {
		-- MODIFIER_PROPERTY_ATTACKSPEED_REDUCTION_PERCENTAGE,
		-- MODIFIER_PROPERTY_MOVESPEED_REDUCTION_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
	}
end

function modifier_beast_rampage:CheckState()
	local state = {
	}
	return state
end

function modifier_beast_rampage:GetEffectName()
	return "particles/units/heroes/hero_troll_warlord/troll_warlord_rampage_attack_speed_buff.vpcf"
end

function modifier_beast_rampage:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_beast_rampage:GetModifierAttackSpeedReductionPercentage()
	return self.attackspeed_reduction_percentage
end

function modifier_beast_rampage:GetModifierMoveSpeedReductionPercentage()
	return self.movespeed_reduction_percentage
end

function modifier_beast_rampage:GetModifierAttackSpeedPercentage()
	return self.attack_speed
end
