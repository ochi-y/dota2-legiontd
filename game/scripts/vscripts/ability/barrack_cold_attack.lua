
LinkLuaModifier( "modifier_barrack_cold_attack", "ability/barrack_cold_attack.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_barrack_cold_attack_debuff", "ability/barrack_cold_attack.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_orb_effect_lua", "lua_abilities/generic/modifier_generic_orb_effect_lua", LUA_MODIFIER_MOTION_NONE )    

if barrack_cold_attack == nil then
	barrack_cold_attack = class({})
end
function barrack_cold_attack:GetIntrinsicModifierName()
	return "modifier_generic_orb_effect_lua"
end
function barrack_cold_attack:GetProjectileName()
    return ""
end

function barrack_cold_attack:OnOrbFire( params )
    -- local sound_cast = "Hero_DrowRanger.FrostArrows"
    -- EmitSoundOn( sound_cast, self:GetCaster() )
end

function barrack_cold_attack:OnOrbImpact( params )
    if not IsServer() then return end
    --
    -- print("impact")

    self.duration=self:GetSpecialValueFor("duration")
    local damage=self:GetAbilityDamage()
	local caster=self:GetCaster()
    local target=params.target
    target:AddNewModifier(caster,self,"modifier_barrack_cold_attack_debuff",{duration=self.duration})
    SimpleApplyDamage(self,caster,target,damage,DAMAGE_TYPE_PHYSICAL)
end


modifier_barrack_cold_attack_debuff = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return true end,
IsBuff                  = function(self) return false end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_barrack_cold_attack_debuff:OnCreated( kv )
    if not self:GetAbility() then return end
    local ability=self:GetAbility()
    self.move_slow=ability:GetSpecialValueFor("move_slow")
    self.attack_slow=ability:GetSpecialValueFor("attack_slow")

end

function modifier_barrack_cold_attack_debuff:OnRefresh( kv )
	self:OnCreated( kv )
end
function modifier_barrack_cold_attack_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
	}
	return funcs
end

function modifier_barrack_cold_attack_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self.move_slow
end
function modifier_barrack_cold_attack_debuff:GetModifierAttackSpeedPercentage( params )
    if self:GetParent():IsAncient() then
        return -self.attack_slow*(100-BOSS_ATTACK_SPEED_REDUCTION_RESISTANCE)/100
    end
    return -self.attack_slow
end 
function modifier_barrack_cold_attack_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_frost_lich.vpcf"
end
function modifier_barrack_cold_attack_debuff:StatusEffectPriority()
    return 100
end