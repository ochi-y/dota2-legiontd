
LinkLuaModifier( "modifier_element_mana_burst", "ability/element_mana_burst.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_orb_effect_lua", "lua_abilities/generic/modifier_generic_orb_effect_lua", LUA_MODIFIER_MOTION_NONE )    

if element_mana_burst == nil then
	element_mana_burst = class({})
end
function element_mana_burst:GetIntrinsicModifierName()
	return "modifier_generic_orb_effect_lua"
end
function element_mana_burst:GetProjectileName()
    return "particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_arcane_orb.vpcf"
end

function element_mana_burst:OnOrbFire( params )
    local sound_cast = "Hero_ObsidianDestroyer.ArcaneOrb"
     EmitSoundOn( sound_cast, self:GetCaster() )
end

function element_mana_burst:OnOrbImpact( params )
    if not IsServer() then return end
    local damage=self:GetSpecialValueFor("damage")
    local caster=self:GetCaster()
    local target=params.target

	EmitSoundOn( "Hero_ObsidianDestroyer.ArcaneOrb.Impact", self:GetCaster() )

    local damageTable = {
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_PURE,
        ability = self
    }
    ApplyDamage(damageTable)
end
