element_energy_shield = {}

LinkLuaModifier( "modifier_element_energy_shield", "ability/element_energy_shield", LUA_MODIFIER_MOTION_NONE )

function element_energy_shield:OnToggle()
    local caster = self:GetCaster()
    local modifier = caster:FindModifierByName( "modifier_element_energy_shield" )

    if self:GetToggleState() then
        if not modifier then
            caster:AddNewModifier(
                caster,
                self,
                "modifier_element_energy_shield",
                {}
            )
        end
    else
        if modifier then
            modifier:Destroy()
        end
    end
end
function element_energy_shield:Spawn()
    if not IsServer() then return end

    self:ToggleAbility()
end

function element_energy_shield:ProcsMagicStick()
    return false
end

function element_energy_shield:OnUpgrade()
    local modifier = self:GetCaster():FindModifierByName( "modifier_element_energy_shield" )

    if modifier then
        modifier:ForceRefresh()
    end
end

modifier_element_energy_shield = {}

function modifier_element_energy_shield:IsHidden()
    return false
end

function modifier_element_energy_shield:IsDebuff()
    return false
end
function modifier_element_energy_shield:IsPurgable(params)
    return false
end



function modifier_element_energy_shield:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_element_energy_shield:OnCreated( kv )


    local ability=self:GetAbility()
    if not ability then
        return
    end     


    self.damage_per_mana = self:GetAbility():GetSpecialValueFor( "damage_per_mana" )
    self.absorption_pct = self:GetAbility():GetSpecialValueFor( "absorption_pct" ) 
    if not IsServer() then return end
    EmitSoundOn( "Hero_Medusa.ManaShield.On", self:GetParent() )
end

function modifier_element_energy_shield:OnRefresh( kv )
    self.damage_per_mana = self:GetAbility():GetSpecialValueFor( "damage_per_mana" )
    self.absorption_pct = self:GetAbility():GetSpecialValueFor( "absorption_pct" )  
end

function modifier_element_energy_shield:OnDestroy()
    if not IsServer() then return end

    EmitSoundOn( "Hero_Medusa.ManaShield.Off", self:GetParent() )
end

function modifier_element_energy_shield:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
end

function modifier_element_energy_shield:GetModifierIncomingDamage_Percentage( params )
    local absorb =-self.absorption_pct
    local damage_absorbed = params.damage * (self.absorption_pct)/100
    local manacost = damage_absorbed/self.damage_per_mana
    local mana = self:GetParent():GetMana()
    if mana<manacost then
        damage_absorbed = mana * self.damage_per_mana
        absorb = -damage_absorbed/params.damage*100

        manacost = mana
    end

    self:GetParent():SpendMana( manacost, self:GetAbility() )

    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_medusa/medusa_mana_shield_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector( damage_absorbed, 0, 0 ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )

    EmitSoundOn( "Hero_Medusa.ManaShield.Proc", self:GetParent() )
    return absorb
end

function modifier_element_energy_shield:GetEffectName()
    return "particles/units/heroes/hero_medusa/medusa_mana_shield.vpcf"
end

function modifier_element_energy_shield:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end