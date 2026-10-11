
if beast_club_bash == nil then
	beast_club_bash = class({
	})
end

LinkLuaModifier("modifier_beast_club_bash", "ability/beast_club_bash", LUA_MODIFIER_MOTION_NONE)

beast_club_bash = class({
	GetIntrinsicModifierName = function() return "modifier_beast_club_bash" end
})

modifier_beast_club_bash = class({
	IsHidden    = function(self) return true end,
	IsPurgable = function(self) return false end,
	IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	} end
})

function modifier_beast_club_bash:OnCreated()
	
	local ability=self:GetAbility()

	if not ability then
        return
    end     
	
	self.bash_chance=ability:GetSpecialValueFor("bash_chance")
	self.bash_damage=ability:GetSpecialValueFor("bash_damage")
	self.stun=ability:GetSpecialValueFor("stun")

	if IsServer() then
	end
end

function modifier_beast_club_bash:OnRefresh()
	self:OnCreated()
end

function modifier_beast_club_bash:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target
	if self.bashed  then
		if params.attacker:PassivesDisabled() == false and (target:IsHero() or target:IsCreep()) then
			local duration=self.stun
			EmitSoundOn("DOTA_Item.SkullBasher", target)
			duration = duration * (1 - CalUnitStatusResistance(target))
			target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = duration})
		end
	end
end

function modifier_beast_club_bash:GetModifierProcAttack_BonusDamage_Physical()
	--
	self.bashed=RandomInt(1,100) <= self.bash_chance
	if self.bashed then
		return self.bash_damage
	end
	return 0
end

