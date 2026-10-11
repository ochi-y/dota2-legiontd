LinkLuaModifier( "modifier_paladin_flagbearer_creep_aura_effect", "ability/paladin_flagbearer_creep_aura_effect" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_paladin_flagbearer_creep_aura_effect_buff", "ability/paladin_flagbearer_creep_aura_effect" ,LUA_MODIFIER_MOTION_NONE )

if paladin_flagbearer_creep_aura_effect == nil then
    paladin_flagbearer_creep_aura_effect = class({})
end

--------------------------------------------------------------------------------
function paladin_flagbearer_creep_aura_effect:GetIntrinsicModifierName()
    return "modifier_paladin_flagbearer_creep_aura_effect"
end
--------------------------------------------------------------------------------

modifier_paladin_flagbearer_creep_aura_effect = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
})

--------------------------------------------------------------------------------
function modifier_paladin_flagbearer_creep_aura_effect:OnCreated()
	if not self:GetAbility() then return end

	local ability=self:GetAbility()
	self.radius=ability:GetSpecialValueFor("radius")

	if not IsServer() then return end

	local caster=self:GetCaster()

	PlayEffOnUnit("particles/props/creep_banners/radiant_creep_banner.vpcf",caster,{
		mod=self,
		bind=PATTACH_ROOTBONE_FOLLOW
	})
	PlayEffOnUnit("particles/props/creep_banners/radiant_creep_banner_ring.vpcf",caster,{
		mod=self
	})
end
function modifier_paladin_flagbearer_creep_aura_effect:OnRefresh()
	if not self:GetAbility() then return end

	local ability=self:GetAbility()
	self.radius=ability:GetSpecialValueFor("radius")
end
function modifier_paladin_flagbearer_creep_aura_effect:IsAura()
    return true
end

function modifier_paladin_flagbearer_creep_aura_effect:GetModifierAura()
    return "modifier_paladin_flagbearer_creep_aura_effect_buff"
end

function modifier_paladin_flagbearer_creep_aura_effect:GetAuraRadius()
    return self.radius
end

function modifier_paladin_flagbearer_creep_aura_effect:GetAuraDuration()
    return 0.5
end

function modifier_paladin_flagbearer_creep_aura_effect:GetAuraSearchTeam()    
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_paladin_flagbearer_creep_aura_effect:GetAuraSearchType()    
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_paladin_flagbearer_creep_aura_effect:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
end

--------------------------------------------------------------------------------


modifier_paladin_flagbearer_creep_aura_effect_buff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self)
        return {
            MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
        }
    end,
})
function modifier_paladin_flagbearer_creep_aura_effect_buff:OnCreated()
    if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.bonus_health_regen=ability:GetSpecialValueFor("bonus_health_regen")
end

function modifier_paladin_flagbearer_creep_aura_effect_buff:OnRefresh()
    if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.bonus_health_regen=ability:GetSpecialValueFor("bonus_health_regen")
end

function modifier_paladin_flagbearer_creep_aura_effect_buff:GetModifierHealthRegenPercentage()
	return self.bonus_health_regen
end

