
LinkLuaModifier( "modifier_elf_magic_missile", "ability/elf_magic_missile", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_orb_effect_lua", "lua_abilities/generic/modifier_generic_orb_effect_lua", LUA_MODIFIER_MOTION_NONE )    

if elf_magic_missile == nil then
	elf_magic_missile = class({})
end
function elf_magic_missile:GetIntrinsicModifierName()
	return "modifier_generic_orb_effect_lua"
end
function elf_magic_missile:GetProjectileName()
    return "particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf"
end

function elf_magic_missile:OnOrbFire( params )
    -- local sound_cast = "Hero_Clinkz.SearingArrows"
    -- EmitSoundOn( sound_cast, self:GetCaster() )
end

function elf_magic_missile:OnOrbImpact( params )
    if not IsServer() then return end
	self.damage=self:GetSpecialValueFor("damage")
    local caster=self:GetCaster()
    local target=params.target

    local damage=self.damage


    local damageTable = {
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self
    }
    ApplyDamage(damageTable)
end
