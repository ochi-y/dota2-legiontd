ghost_ghost_essence = {}

LinkLuaModifier( "modifier_ghost_ghost_essence", "ability/ghost_ghost_essence", LUA_MODIFIER_MOTION_NONE )

function ghost_ghost_essence:OnToggle()
    local caster = self:GetCaster()
    local modifier = caster:FindModifierByName( "modifier_ghost_ghost_essence" )

    if self:GetToggleState() then
        if not modifier then
            caster:AddNewModifier(
                caster,
                self,
                "modifier_ghost_ghost_essence",
                {}
            )
        end
    else
        if modifier then
            modifier:Destroy()
        end
    end
end
function ghost_ghost_essence:ProcsMagicStick()
    return false
end
function ghost_ghost_essence:Spawn()
    if not IsServer() then return end
    self:ToggleAbility()
end

function ghost_ghost_essence:OnUpgrade()
    local modifier = self:GetCaster():FindModifierByName( "modifier_ghost_ghost_essence" )

    if modifier then
        modifier:ForceRefresh()
    end
end

modifier_ghost_ghost_essence = {}

function modifier_ghost_ghost_essence:IsHidden()
    return false
end

function modifier_ghost_ghost_essence:IsDebuff()
    return false
end

function modifier_ghost_ghost_essence:IsPurgable()
    return false
end

function modifier_ghost_ghost_essence:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_ghost_ghost_essence:OnCreated( kv )

    local ability=self:GetAbility()

	if not ability then
        return
    end   

    
    self.damage_per_mana = self:GetAbility():GetSpecialValueFor( "damage_per_mana" )
    self.absorption_pct = self:GetAbility():GetSpecialValueFor( "absorption_pct" ) 

    if not IsServer() then return end

    EmitSoundOn( "Hero_Medusa.ManaShield.On", self:GetParent() )
end

function modifier_ghost_ghost_essence:OnRefresh( kv )

    local ability=self:GetAbility()

	if not ability then
        return
    end   

    self.damage_per_mana = self:GetAbility():GetSpecialValueFor( "damage_per_mana" )
    self.absorption_pct = self:GetAbility():GetSpecialValueFor( "absorption_pct" )  
end

function modifier_ghost_ghost_essence:OnDestroy()
    if not IsServer() then return end

    EmitSoundOn( "Hero_Medusa.ManaShield.Off", self:GetParent() )
end

function modifier_ghost_ghost_essence:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
end

function modifier_ghost_ghost_essence:GetModifierIncomingDamage_Percentage( params )
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

function modifier_ghost_ghost_essence:GetEffectName()
    return "particles/units/heroes/hero_medusa/medusa_mana_shield.vpcf"
end

function modifier_ghost_ghost_essence:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end