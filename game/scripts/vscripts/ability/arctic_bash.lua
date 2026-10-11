
if arctic_bash == nil then
	arctic_bash = class({
	})
end

LinkLuaModifier("modifier_arctic_bash", "ability/arctic_bash", LUA_MODIFIER_MOTION_NONE)

arctic_bash = class({
	GetIntrinsicModifierName = function() return "modifier_arctic_bash" end
})

modifier_arctic_bash = class({
	IsHidden    = function(self) return true end,
	IsPurgable = function(self) return false end,
	IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	} end
})

function modifier_arctic_bash:OnCreated()
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.chance=ability:GetSpecialValueFor("chance")
	self.damage=ability:GetSpecialValueFor("damage")
	

end

function modifier_arctic_bash:OnRefresh()
	self:OnCreated()
end

function modifier_arctic_bash:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target
	if self.bashed  then
		if params.attacker:PassivesDisabled() == false and (target:IsHero() or target:IsCreep()) then
			local duration=1
			EmitSoundOn("DOTA_Item.SkullBasher", target)

			duration = duration * (1 - CalUnitStatusResistance(target))

			target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = duration})
		end
	end
end

function modifier_arctic_bash:GetModifierProcAttack_BonusDamage_Physical()
	--
	local chance=self.chance
	self.bashed=RandomInt(1,100) <= chance
	if self.bashed then
		return self.chance
	end
	return 0
end

