
LinkLuaModifier( "modifier_marine_biotoxin", "ability/marine_biotoxin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_marine_biotoxin_debuff", "ability/marine_biotoxin.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_orb_effect_lua", "lua_abilities/generic/modifier_generic_orb_effect_lua", LUA_MODIFIER_MOTION_NONE )    

if marine_biotoxin == nil then
	marine_biotoxin = class({})
end
function marine_biotoxin:GetIntrinsicModifierName()
	return "modifier_generic_orb_effect_lua"
end
function marine_biotoxin:GetProjectileName()
end

function marine_biotoxin:OnOrbFire( params )
    local sound_cast = "Hero_DrowRanger.FrostArrows"
    --EmitSoundOn( sound_cast, self:GetCaster() )
end

function marine_biotoxin:OnOrbImpact( params )
    if not IsServer() then return end
    --
	local caster=self:GetCaster()
    local target=params.target

	local duration=self:GetSpecialValueFor("duration")
	duration = duration * (1 - CalUnitStatusResistance(target))
	addNewModiferWithStack(target,caster,self,"modifier_marine_biotoxin_debuff",{duration=duration})
	SimplePlayEffOnUnit(target,"particles/econ/items/viper/viper_ti7_immortal/viper_poison_crimson_attack_ti7_explosion_flash_goo.vpcf")
end


modifier_marine_biotoxin_debuff = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return true end,
IsDebuff                = function(self) return true end,
IsBuff                  = function(self) return false end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_marine_biotoxin_debuff:OnCreated( kv )
	local ability=self:GetAbility()
	self.attack_slow=ability:GetSpecialValueFor("attack_slow")
	self.move_slow=ability:GetSpecialValueFor("move_slow")
end

function modifier_marine_biotoxin_debuff:OnRefresh( kv )
	self:OnCreated( kv )
end
function modifier_marine_biotoxin_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
	}
	return funcs
end

function modifier_marine_biotoxin_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self.move_slow*self:GetStackCount()
end

function modifier_marine_biotoxin_debuff:GetModifierAttackSpeedPercentage()
	if self:GetParent():IsAncient() then
        return -self.attack_slow*(100-BOSS_ATTACK_SPEED_REDUCTION_RESISTANCE)/100
	end
	return -self.attack_slow
end
