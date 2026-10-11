LinkLuaModifier( "modifier_ability_spectre_dispersion", "ability/ability_spectre_dispersion" ,LUA_MODIFIER_MOTION_NONE )

ability_spectre_dispersion = class({})

wave_18_champion_spectre_dispersion=ability_spectre_dispersion
--------------------------------------------------------------------------------

function ability_spectre_dispersion:GetIntrinsicModifierName()
	return "modifier_ability_spectre_dispersion"
end

--------------------------------------------------------------------------------


modifier_ability_spectre_dispersion = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    AllowIllusionDuplicate  = function(self) return false end,
    DeclareFunctions        = function(self)
        return {
            MODIFIER_EVENT_ON_TAKEDAMAGE,
            MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
        }
    end,
})


--------------------------------------------------------------------------------

function modifier_ability_spectre_dispersion:OnTakeDamage(k)
    local target = k.unit
    local caster = self:GetParent()
    local original_damage = k.original_damage
    local damage_type = k.damage_type
    if target == caster and not caster:PassivesDisabled() then
	    local damage_reflection_pct = self:GetAbility():GetSpecialValueFor("damage_reflection_pct")
		local min_radius = self:GetAbility():GetSpecialValueFor("min_radius")
		local max_radius = self:GetAbility():GetSpecialValueFor("max_radius")

    	local all = FindUnitsInRadius(target:GetTeam(), 
        caster:GetOrigin(), 
        nil, 
        max_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY, 
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER, 
        false)

        for _, hero in ipairs(all) do
            local part = ParticleManager:CreateParticle("particles/units/heroes/hero_spectre/spectre_dispersion.vpcf", PATTACH_ABSORIGIN, hero)
            -- ParticleManager:SetParticleControl(part, 0, hero:GetAbsOrigin() + Vector(0,0,50))
            -- ParticleManager:SetParticleControl(part, 1, caster:GetAbsOrigin() + Vector(0,0,50))
            -- ParticleManager:SetParticleControl(part, 2, caster:GetAbsOrigin() + Vector(0,0,50))

            ParticleManager:SetParticleControlEnt(part, 0, hero, PATTACH_POINT_FOLLOW, "attach_hitloc", hero:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(part, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(part, 2, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)


            ParticleManager:ReleaseParticleIndex(part)

            local distance = (caster:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()
            
            local reflect=0
            if distance<min_radius then
                reflect=damage_reflection_pct
            elseif distance>max_radius then
                reflect=0
            else
                reflect=damage_reflection_pct*(max_radius-distance)/(max_radius-min_radius)
            end
            local damage = original_damage / 100 * reflect
            if damage >0 then
                ApplyDamage({
                    victim = hero,
                    attacker = caster,
                    damage = damage,
                    damage_type = damage_type,
                    damage_flags = DOTA_DAMAGE_FLAG_HPLOSS,
                    ability = self:GetAbility()
                })
            end
        end
    end
end

function modifier_ability_spectre_dispersion:GetModifierIncomingDamage_Percentage() return self:GetAbility():GetSpecialValueFor("damage_reflection_pct") * -1 end