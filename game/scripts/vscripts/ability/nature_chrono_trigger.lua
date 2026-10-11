LinkLuaModifier( "modifier_nature_chrono_trigger", "ability/nature_chrono_trigger.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_nature_chrono_trigger_buff", "ability/nature_chrono_trigger.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if nature_chrono_trigger == nil then
	nature_chrono_trigger = class({})
end
function nature_chrono_trigger:GetIntrinsicModifierName()
	return "modifier_nature_chrono_trigger"
end
---------------------------------------------------------------------
--Modifiers

modifier_nature_chrono_trigger = class({
	IsHidden                = function(self) return true end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})

function modifier_nature_chrono_trigger:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.radius=ability:GetSpecialValueFor("radius")

	if IsServer() then
	end
end
function modifier_nature_chrono_trigger:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_nature_chrono_trigger:OnDestroy()
	if IsServer() then
	end
end
function modifier_nature_chrono_trigger:DeclareFunctions()
	return {
	}
end
function modifier_nature_chrono_trigger:IsAura()
	return true
end
function modifier_nature_chrono_trigger:GetModifierAura()
	return "modifier_nature_chrono_trigger_buff"
end
function modifier_nature_chrono_trigger:GetAuraRadius()
	local radius=self.radius
	return radius
end

function modifier_nature_chrono_trigger:GetAuraDuration()
	return 0
end

function modifier_nature_chrono_trigger:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_nature_chrono_trigger:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_nature_chrono_trigger:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_nature_chrono_trigger:GetAuraEntityReject( hEntity )
	return false
end
--
modifier_nature_chrono_trigger_buff = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return true end,
IsBuff                  = function(self) return false end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})


function modifier_nature_chrono_trigger_buff:OnCreated()
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.move_slow=ability:GetSpecialValueFor("move_slow")
end
function modifier_nature_chrono_trigger_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_nature_chrono_trigger_buff:GetModifierMoveSpeedBonus_Percentage()
	return - self.move_slow
end





