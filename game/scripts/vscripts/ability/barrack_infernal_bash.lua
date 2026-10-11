
if barrack_infernal_bash == nil then
	barrack_infernal_bash = class({
	})
end

LinkLuaModifier("modifier_barrack_infernal_bash", "ability/barrack_infernal_bash", LUA_MODIFIER_MOTION_NONE)

barrack_infernal_bash = class({
	GetIntrinsicModifierName = function() return "modifier_barrack_infernal_bash" end
})

modifier_barrack_infernal_bash = class({
	IsHidden    = function(self) return true end,
	IsPurgable = function(self) return false end,
	IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	} end
})

function modifier_barrack_infernal_bash:OnCreated()
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.bash_chance=ability:GetSpecialValueFor("bash_chance")
	self.bash_damage=ability:GetSpecialValueFor("bash_damage")
	self.stun_duration=ability:GetSpecialValueFor("stun_duration")
	if IsServer() then
	end
end
function modifier_barrack_infernal_bash:IsPurgable(params)
	return false
end
function modifier_barrack_infernal_bash:OnRefresh()
	self:OnCreated()
end

function modifier_barrack_infernal_bash:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target
	if self.bashed  then
		if params.attacker:PassivesDisabled() == false and (target:IsHero() or target:IsCreep()) then
			local duration=self.stun_duration
			--
			EmitSoundOn("DOTA_Item.SkullBasher", target)
			duration = duration * (1 - CalUnitStatusResistance(target))
			target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = duration})
		end
	end
end

function modifier_barrack_infernal_bash:GetModifierProcAttack_BonusDamage_Physical()
	--
	self.bashed=RandomInt(1,100) <= self.bash_chance
	if self.bashed then
		return self.bash_damage
	end
	return 0
end

