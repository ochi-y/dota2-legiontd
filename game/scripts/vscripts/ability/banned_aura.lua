LinkLuaModifier( "modifier_banned_aura", "ability/banned_aura" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_banned_aura_buff", "ability/banned_aura" ,LUA_MODIFIER_MOTION_NONE )

if banned_aura == nil then
    banned_aura = class({})
end

--------------------------------------------------------------------------------
function banned_aura:GetIntrinsicModifierName()
    return "modifier_banned_aura"
end
--------------------------------------------------------------------------------


modifier_banned_aura = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
})


--------------------------------------------------------------------------------

function modifier_banned_aura:IsAura()
    return true
end

function modifier_banned_aura:GetModifierAura()
    return "modifier_banned_aura_buff"
end

function modifier_banned_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("aura_radius")
end

function modifier_banned_aura:GetAuraDuration()
    return 0.5
end

function modifier_banned_aura:GetAuraSearchTeam()    
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_banned_aura:GetAuraEntityReject(hEntity)
	if not IsServer() then return end
	local parent=self:GetParent()
	if parent:GetPlayerOwnerID()~=hEntity:GetPlayerOwnerID() then
		return true
	end
	return false
end
function modifier_banned_aura:GetAuraSearchType()    
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_banned_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
end

--------------------------------------------------------------------------------


modifier_banned_aura_buff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self)
        return {
            MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
        }
    end,
})
function modifier_banned_aura_buff:OnCreated()
	local ability=self:GetAbility()
	self.damage_reduce=ability:GetSpecialValueFor("damage_reduce")
end
function modifier_banned_aura_buff:GetModifierDamageOutgoing_Percentage()
	return -self.damage_reduce
end