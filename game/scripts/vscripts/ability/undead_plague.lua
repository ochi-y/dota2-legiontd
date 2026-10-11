LinkLuaModifier( "modifier_undead_plague", "ability/undead_plague.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_undead_plague_buff", "ability/undead_plague.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if undead_plague == nil then
	undead_plague = class({})
end
function undead_plague:GetIntrinsicModifierName()
	return "modifier_undead_plague"
end
---------------------------------------------------------------------
--Modifiers

modifier_undead_plague = class({
	IsHidden                = function(self) return true end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})

function modifier_undead_plague:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.radius=ability:GetSpecialValueFor("radius")
	self.damage_reduction=ability:GetSpecialValueFor("damage_reduction")

	if IsServer() then
	end
end
function modifier_undead_plague:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_undead_plague:OnDestroy()
	if IsServer() then
	end
end
function modifier_undead_plague:DeclareFunctions()
	return {
	}
end
function modifier_undead_plague:IsAura()
	return true
end
function modifier_undead_plague:GetModifierAura()
	return "modifier_undead_plague_buff"
end
function modifier_undead_plague:GetAuraRadius()
    return self.radius
end

function modifier_undead_plague:GetAuraDuration()
	return 0
end

function modifier_undead_plague:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_undead_plague:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_undead_plague:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_undead_plague:GetAuraEntityReject( hEntity )
	return false
end

function modifier_undead_plague:GetEffectName()
	return "particles/units/heroes/hero_pudge/pudge_rot.vpcf"
end

function modifier_undead_plague:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

--
modifier_undead_plague_buff = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return true end,
IsBuff                  = function(self) return false end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_undead_plague_buff:OnCreated()
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.damage_reduction=ability:GetSpecialValueFor("damage_reduction")

end
function modifier_undead_plague_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
	}
end
function modifier_undead_plague_buff:GetModifierDamageOutgoing_Percentage()
	return - self.damage_reduction
end



