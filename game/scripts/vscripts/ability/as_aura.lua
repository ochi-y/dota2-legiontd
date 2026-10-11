LinkLuaModifier( "modifier_as_aura", "ability/as_aura" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_as_aura_buff", "ability/as_aura" ,LUA_MODIFIER_MOTION_NONE )

if as_aura == nil then
    as_aura = class({})
end

--------------------------------------------------------------------------------
function as_aura:GetIntrinsicModifierName()
    return "modifier_as_aura"
end
--------------------------------------------------------------------------------

modifier_as_aura = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
})


--------------------------------------------------------------------------------

function modifier_as_aura:IsAura()
    return true
end

function modifier_as_aura:GetModifierAura()
    return "modifier_as_aura_buff"
end

function modifier_as_aura:GetAuraRadius()
    return 3000
end

function modifier_as_aura:GetAuraDuration()
    return 0.5
end

function modifier_as_aura:GetAuraSearchTeam()    
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_as_aura:GetAuraSearchType()    
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_as_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
end

--------------------------------------------------------------------------------


modifier_as_aura_buff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self)
        return {
            MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
        }
    end,
})
function modifier_as_aura_buff:OnCreated()
    if not self:GetAbility() then return end
	local ability=self:GetAbility()

	if not IsServer() then return end

	local caster=self:GetCaster()
	local s= caster:FindModifierByName("modifier_as_aura"):GetStackCount()

	self:SetStackCount(s)

	self:StartIntervalThink(1)
end

function modifier_as_aura_buff:OnIntervalThink()
	local ability=self:GetAbility()
	local caster=self:GetCaster()
	local s= caster:FindModifierByName("modifier_as_aura"):GetStackCount()
	self:SetStackCount(s)
end
function modifier_as_aura_buff:GetModifierAttackSpeedPercentage()
	return self:GetStackCount()-100
end
