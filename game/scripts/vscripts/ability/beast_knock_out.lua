
if beast_knock_out == nil then
	beast_knock_out = class({
	})
end

LinkLuaModifier("modifier_beast_knock_out", "ability/beast_knock_out", LUA_MODIFIER_MOTION_NONE)

beast_knock_out = class({
	GetIntrinsicModifierName = function() return "modifier_beast_knock_out" end
})

modifier_beast_knock_out = class({
	IsHidden    = function(self) return true end,
	IsPurgable = function(self) return false end,
	IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	} end
})

function modifier_beast_knock_out:OnCreated()
	local ability=self:GetAbility()
	if not ability then
        return
    end   
	if IsServer() then
	end
end

function modifier_beast_knock_out:OnRefresh()
	self:OnCreated()
end

function modifier_beast_knock_out:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target
	if self.bashed  then
		if params.attacker:PassivesDisabled() == false and (target:IsHero() or target:IsCreep()) then
			local duration=2
			EmitSoundOn("DOTA_Item.SkullBasher", target)
			duration = duration * (1 - CalUnitStatusResistance(target))
			target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = duration})
		end
	end
end

function modifier_beast_knock_out:GetModifierProcAttack_BonusDamage_Physical()
	--
	self.bashed=RandomInt(1,100) <= 35
	if self.bashed then
		return 45
	end
	return 0
end

