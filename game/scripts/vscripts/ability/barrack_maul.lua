
if barrack_maul == nil then
	barrack_maul = class({
	})
end

LinkLuaModifier("modifier_barrack_maul", "ability/barrack_maul", LUA_MODIFIER_MOTION_NONE)

barrack_maul = class({
	GetIntrinsicModifierName = function() return "modifier_barrack_maul" end
})

modifier_barrack_maul = class({
	IsHidden    = function(self) return true end,
	IsPurgable = function(self) return false end,
	IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	} end
})

function modifier_barrack_maul:OnCreated()
	if not self:GetAbility() then return end
	
	local ability=self:GetAbility()
	self.bash_chance=ability:GetSpecialValueFor("bash_chance")
	self.bonus_damage=ability:GetSpecialValueFor("bonus_damage")
	self.stun_duration=ability:GetSpecialValueFor("stun_duration")
end

function modifier_barrack_maul:OnRefresh()
	self:OnCreated()
end

function modifier_barrack_maul:OnAttackLanded(params)
	if params.attacker ~= self:GetParent() then return end
	local target = params.target
	if self.bashed  then
		if params.attacker:PassivesDisabled() == false and (target:IsHero() or target:IsCreep()) then
			local duration=self.stun_duration
			duration = duration * (1 - CalUnitStatusResistance(target))
			EmitSoundOn("Hero_Slardar.Bash", target)
			target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = duration})
		end
	end
end

function modifier_barrack_maul:GetModifierProcAttack_BonusDamage_Physical()
	self.bashed=RandomInt(1,100) <= self.bash_chance
	if self.bashed then
		return self.bonus_damage
	end
	return 0
end

