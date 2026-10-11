LinkLuaModifier( "modifier_nature_helping_hand", "ability/nature_helping_hand.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_nature_helping_hand_buff", "ability/nature_helping_hand.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if nature_helping_hand == nil then
	nature_helping_hand = class({})
end
function nature_helping_hand:GetIntrinsicModifierName()
	return "modifier_nature_helping_hand"
end
---------------------------------------------------------------------
--Modifiers

modifier_nature_helping_hand = class({
	IsHidden                = function(self) return true end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})

function modifier_nature_helping_hand:OnCreated(params)

	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.radius=ability:GetSpecialValueFor("radius")

	if IsServer() then
	end
end
function modifier_nature_helping_hand:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_nature_helping_hand:OnDestroy()
	if IsServer() then
	end
end
function modifier_nature_helping_hand:DeclareFunctions()
	return {
	}
end


function modifier_nature_helping_hand:IsAura()
	return true
end
function modifier_nature_helping_hand:GetModifierAura()
	return "modifier_nature_helping_hand_buff"
end
function modifier_nature_helping_hand:GetAuraRadius()
	local radius=self.radius
	return radius

end

function modifier_nature_helping_hand:GetAuraDuration()
	return 0
end

function modifier_nature_helping_hand:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_nature_helping_hand:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_nature_helping_hand:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_nature_helping_hand:GetAuraEntityReject( hEntity )
	return false
end
--
modifier_nature_helping_hand_buff = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_nature_helping_hand_buff:OnCreated()
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.bonus_move_speed=ability:GetSpecialValueFor("bonus_move_speed")
end
function modifier_nature_helping_hand_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_nature_helping_hand_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_move_speed
end






