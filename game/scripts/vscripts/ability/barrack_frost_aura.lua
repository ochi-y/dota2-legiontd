LinkLuaModifier( "modifier_barrack_frost_aura", "ability/barrack_frost_aura.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_barrack_frost_aura_debuff", "ability/barrack_frost_aura.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if barrack_frost_aura == nil then
	barrack_frost_aura = class({})
end
function barrack_frost_aura:GetIntrinsicModifierName()
	return "modifier_barrack_frost_aura"
end
---------------------------------------------------------------------
--Modifiers
modifier_barrack_frost_aura = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return true end,
IsBuff                  = function(self) return false end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
})

function modifier_barrack_frost_aura:OnCreated()
	if not self:GetAbility() then return end
	if IsServer() then 
		-- SimpleAddEff(self,self:GetParent(),"particles/econ/items/omniknight/omniknight_fall20_immortal/omniknight_fall20_immortal_degen_aura_debuff_runes.vpcf",nil) 
		local ability=self:GetAbility()
		local radius=ability:GetSpecialValueFor("radius")
		local caster=self:GetCaster()

		PlayEffOnUnit("particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_snow_shard.vpcf",caster,{
			cps={0},
			mod=self,
			cpKv={
                [1]=Vector(radius,radius,radius)
            }
		})
	end
end

function modifier_barrack_frost_aura:IsAura()
	return true
end

function modifier_barrack_frost_aura:GetModifierAura()
	if not IsServer() then return end
	if self:GetParent():PassivesDisabled() then
		return nil
	else
		return "modifier_barrack_frost_aura_debuff"
	end
end

function modifier_barrack_frost_aura:GetAuraRadius()
	return 300
end

function modifier_barrack_frost_aura:GetAuraDuration()
	return 0.3
end

function modifier_barrack_frost_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_barrack_frost_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_barrack_frost_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

modifier_barrack_frost_aura_debuff = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return true end,
IsBuff                  = function(self) return false end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_barrack_frost_aura_debuff:OnCreated()
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.attack_slow=ability:GetSpecialValueFor("attack_slow")
	self.move_slow=ability:GetSpecialValueFor("move_slow")
end

function modifier_barrack_frost_aura_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
	}
	return funcs
end

function modifier_barrack_frost_aura_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self.move_slow
end


function modifier_barrack_frost_aura_debuff:GetEffectName()
	return "particles/units/heroes/hero_invoker/invoker_cold_snap_status.vpcf"
end

function modifier_barrack_frost_aura_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_barrack_frost_aura_debuff:GetModifierAttackSpeedPercentage( params )
	if self:GetParent():IsAncient() then
        return -self.attack_slow*(100-BOSS_ATTACK_SPEED_REDUCTION_RESISTANCE)/100
    end
	return -self.attack_slow
end 

