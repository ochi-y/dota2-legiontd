LinkLuaModifier( "modifier_nature_reassurance", "ability/nature_reassurance.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_nature_reassurance_buff", "ability/nature_reassurance.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if nature_reassurance == nil then
	nature_reassurance = class({})
end
function nature_reassurance:GetIntrinsicModifierName()
	return "modifier_nature_reassurance"
end
---------------------------------------------------------------------
--Modifiers

modifier_nature_reassurance = class({
	IsHidden                = function(self) return true end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})

function modifier_nature_reassurance:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.armor=ability:GetSpecialValueFor("armor")
	self.radius=ability:GetSpecialValueFor("radius")

	if IsServer() then
	end
end
function modifier_nature_reassurance:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_nature_reassurance:OnDestroy()
	if IsServer() then
	end
end
function modifier_nature_reassurance:DeclareFunctions()
	return {
	}
end
function modifier_nature_reassurance:IsAura()
	return true
end
function modifier_nature_reassurance:GetModifierAura()
	return "modifier_nature_reassurance_buff"
end
function modifier_nature_reassurance:GetAuraRadius()
	local radius=self.radius
	return radius
end

function modifier_nature_reassurance:GetAuraDuration()
	return 0
end

function modifier_nature_reassurance:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_nature_reassurance:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_nature_reassurance:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_nature_reassurance:GetAuraEntityReject( hEntity )
	return false
end
--
modifier_nature_reassurance_buff = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_nature_reassurance_buff:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.armor=ability:GetSpecialValueFor("armor")
	if IsServer() then
	end
end
function modifier_nature_reassurance_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end
function modifier_nature_reassurance_buff:GetModifierPhysicalArmorBonus()
	return self.armor
end





