LinkLuaModifier( "modifier_beast_adrenaline_rush", "ability/beast_adrenaline_rush.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_beast_adrenaline_rush_buff", "ability/beast_adrenaline_rush.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if beast_adrenaline_rush == nil then
	beast_adrenaline_rush = class({})
end
function beast_adrenaline_rush:GetIntrinsicModifierName()
	return "modifier_beast_adrenaline_rush"
end
---------------------------------------------------------------------
--Modifiers

modifier_beast_adrenaline_rush = class({
	IsHidden                = function(self) return true end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})

function modifier_beast_adrenaline_rush:OnCreated(params)

	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.radius=ability:GetSpecialValueFor("radius")
end
function modifier_beast_adrenaline_rush:OnRefresh(params)

	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.radius=ability:GetSpecialValueFor("radius")
	
end
function modifier_beast_adrenaline_rush:OnDestroy()
	if IsServer() then
	end
end
function modifier_beast_adrenaline_rush:DeclareFunctions()
	return {
	}
end
function modifier_beast_adrenaline_rush:IsAura()
	return true
end
function modifier_beast_adrenaline_rush:GetModifierAura()
	return "modifier_beast_adrenaline_rush_buff"
end
function modifier_beast_adrenaline_rush:GetAuraRadius()
	return self.radius
end

function modifier_beast_adrenaline_rush:GetAuraDuration()
	return 1
end

function modifier_beast_adrenaline_rush:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_beast_adrenaline_rush:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_beast_adrenaline_rush:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_beast_adrenaline_rush:GetAuraEntityReject( hEntity )
	return false
end
--
modifier_beast_adrenaline_rush_buff = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_beast_adrenaline_rush_buff:OnCreated()
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.attack_speed_pct_bonus=ability:GetSpecialValueFor("attack_speed_pct_bonus")
	self.move_speed_bonus=ability:GetSpecialValueFor("move_speed_bonus")
end


function modifier_beast_adrenaline_rush_buff:OnRefresh()
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.attack_speed_pct_bonus=ability:GetSpecialValueFor("attack_speed_pct_bonus")
	self.move_speed_bonus=ability:GetSpecialValueFor("move_speed_bonus")
end

function modifier_beast_adrenaline_rush_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
	}
end

function modifier_beast_adrenaline_rush_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.move_speed_bonus
end
function modifier_beast_adrenaline_rush_buff:GetModifierAttackSpeedPercentage( params )
	return self.attack_speed_pct_bonus
end





