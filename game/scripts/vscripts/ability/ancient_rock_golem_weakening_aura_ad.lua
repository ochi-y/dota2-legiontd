LinkLuaModifier( "modifier_ancient_rock_golem_weakening_aura_ad", "ability/ancient_rock_golem_weakening_aura_ad.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ancient_rock_golem_weakening_aura_ad_buff", "ability/ancient_rock_golem_weakening_aura_ad.lua", LUA_MODIFIER_MOTION_NONE )


--Abilities
ancient_rock_golem_weakening_aura_ad = class({})

wave_6_champion_weakening_aura=ancient_rock_golem_weakening_aura_ad

function ancient_rock_golem_weakening_aura_ad:GetIntrinsicModifierName()
	return "modifier_ancient_rock_golem_weakening_aura_ad"
end

---------------------------------------------------------------------
--Modifiers

modifier_ancient_rock_golem_weakening_aura_ad = class({
	IsHidden                = function(self) return true end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})

function modifier_ancient_rock_golem_weakening_aura_ad:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.radius=ability:GetSpecialValueFor("radius")
	
	if IsServer() then
	end
end
function modifier_ancient_rock_golem_weakening_aura_ad:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ancient_rock_golem_weakening_aura_ad:OnDestroy()
	if IsServer() then
	end
end
function modifier_ancient_rock_golem_weakening_aura_ad:DeclareFunctions()
	return {
	}
end
function modifier_ancient_rock_golem_weakening_aura_ad:IsAura()
	return true
end
function modifier_ancient_rock_golem_weakening_aura_ad:GetModifierAura()
	return "modifier_ancient_rock_golem_weakening_aura_ad_buff"
end
function modifier_ancient_rock_golem_weakening_aura_ad:GetAuraRadius()
	local radius=self.radius
	return radius
end

function modifier_ancient_rock_golem_weakening_aura_ad:GetAuraDuration()
	return 0
end

function modifier_ancient_rock_golem_weakening_aura_ad:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_ancient_rock_golem_weakening_aura_ad:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_ancient_rock_golem_weakening_aura_ad:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_ancient_rock_golem_weakening_aura_ad:GetAuraEntityReject( hEntity )
	return false
end
--
modifier_ancient_rock_golem_weakening_aura_ad_buff = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return true end,
IsBuff                  = function(self) return false end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_ancient_rock_golem_weakening_aura_ad_buff:OnCreated(params)
	if self:GetAbility() then
		self.armor_reduction=self:GetAbility():GetSpecialValueFor("armor_reduction")
	end
end
function modifier_ancient_rock_golem_weakening_aura_ad_buff:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_ancient_rock_golem_weakening_aura_ad_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end

function modifier_ancient_rock_golem_weakening_aura_ad_buff:GetModifierPhysicalArmorBonus()
    return -self.armor_reduction
end

