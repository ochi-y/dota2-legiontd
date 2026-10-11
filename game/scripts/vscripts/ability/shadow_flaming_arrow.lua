
LinkLuaModifier( "modifier_shadow_flaming_arrow", "ability/shadow_flaming_arrow.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_orb_effect_lua", "lua_abilities/generic/modifier_generic_orb_effect_lua", LUA_MODIFIER_MOTION_NONE )    

if shadow_flaming_arrow == nil then
	shadow_flaming_arrow = class({})
end
function shadow_flaming_arrow:GetIntrinsicModifierName()
	return "modifier_generic_orb_effect_lua"
end
function shadow_flaming_arrow:GetProjectileName()
    return "particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf"
end

function shadow_flaming_arrow:OnOrbFire( params )
    local sound_cast = "Hero_Clinkz.SearingArrows"
    EmitSoundOn( sound_cast, self:GetCaster() )
end

function shadow_flaming_arrow:OnOrbImpact( params )
    if not IsServer() then return end
    local damage=self:GetSpecialValueFor("damage")

    local caster=self:GetCaster()
    local target=params.target
    local damageTable = {
        victim = target,
        attacker = caster,
        damage = damage*SimpleGetAttackFactor(caster,target),
        damage_type = DAMAGE_TYPE_PHYSICAL,
        ability = self
    }
    ApplyDamage(damageTable)
end
