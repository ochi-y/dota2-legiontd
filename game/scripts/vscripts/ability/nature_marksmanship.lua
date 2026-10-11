LinkLuaModifier( "modifier_nature_marksmanship", "ability/nature_marksmanship" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_nature_marksmanship_proj", "ability/nature_marksmanship" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_nature_marksmanship_reduction", "ability/nature_marksmanship" ,LUA_MODIFIER_MOTION_NONE )

if nature_marksmanship == nil then
    nature_marksmanship = class({})
end

--------------------------------------------------------------------------------

function nature_marksmanship:GetIntrinsicModifierName()
    return "modifier_nature_marksmanship"
end

--------------------------------------------------------------------------------


modifier_nature_marksmanship = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsPurgeException        = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    DeclareFunctions        = function(self)
        return {
            MODIFIER_EVENT_ON_ATTACK_START,
            MODIFIER_EVENT_ON_ATTACK_RECORD,
            MODIFIER_EVENT_ON_ATTACK_LANDED,
            MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
            MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL
        }
    end,
    CheckState              = function(self)
        return {
            [MODIFIER_STATE_CANNOT_MISS] = self:GetStackCount() == 1 and true or false
        }
    end,
})


--------------------------------------------------------------------------------

function modifier_nature_marksmanship:OnCreated()
    if not self:GetAbility() then return end
    self.disable = self:GetAbility():GetSpecialValueFor( "disable_range" )
    if not IsServer() then return end

    self:SetStackCount(0)
    self.active = true
    self.records = {}

    self:PlayEffects1()

    self:StartIntervalThink(0.3)
end

function modifier_nature_marksmanship:OnRefresh()
    if not self:GetAbility() then return end
    self.disable = self:GetAbility():GetSpecialValueFor( "disable_range" )
end

function modifier_nature_marksmanship:GetModifierProcAttack_BonusDamage_Physical(k)
    if self.records[k.record] then
       return self:GetAbility():GetSpecialValueFor("bonus_damage")
    end
end

function modifier_nature_marksmanship:OnAttackStart(k)
    local caster = self:GetParent()
    local target = k.target
    local attacker = k.attacker
    if caster == attacker and not caster:IsIllusion() then
        caster:RemoveModifierByName("modifier_nature_marksmanship_proj")

        self:SetStackCount(0)

        if not self.active then return end

        local chance = self:GetAbility():GetSpecialValueFor("chance")

        if RollPercentage(chance) then
            self:SetStackCount(1)
            local drow_proj = 3
            caster:AddNewModifier(caster, self:GetAbility(), "modifier_nature_marksmanship_proj", {drow_proj=drow_proj})
        else
            local drow_proj = 1
            caster:AddNewModifier(caster, self:GetAbility(), "modifier_nature_marksmanship_proj", {drow_proj=drow_proj})
        end
    end
end

function modifier_nature_marksmanship:OnAttackRecord(k)
    local caster = self:GetParent()
    local target = k.target
    local attacker = k.attacker
    if caster == attacker and not caster:IsIllusion() then
        caster:RemoveModifierByName("modifier_nature_marksmanship_proj")

        if self:GetStackCount() > 0 then
            self.records[k.record] = true
        end
    end
end

function modifier_nature_marksmanship:OnAttackLanded(k)
    local caster = self:GetParent()
    local target = k.target
    local attacker = k.attacker
    if caster == attacker and not caster:IsIllusion() then
        if self.records[k.record] then
            local modifier = target:AddNewModifier(caster, self:GetAbility(), "modifier_nature_marksmanship_reduction", {duration=FrameTime()})
            EmitSoundOn("Hero_DrowRanger.Marksmanship.Target", target)

            self.records[k.record] = modifier
        end
    end
end

function modifier_nature_marksmanship:OnAttackRecordDestroy( k )
    if not self.records[k.record] then return end

    local modifier = self.records[k.record]
    if type(modifier)=='table' and not modifier:IsNull() then modifier:Destroy() end
    self.records[k.record] = nil
end



function modifier_nature_marksmanship:PlayEffects1()
    local particle_cast = "particles/units/heroes/hero_drow/drow_marksmanship.vpcf"
 
    self.fx = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )

    ParticleManager:SetParticleControl( self.fx, 2, Vector(2,0,0) )

    self:AddParticle(self.fx, false, false, -1, false, false)

    self:PlayEffects2( true )
end

function modifier_nature_marksmanship:OnIntervalThink()
    if not IsServer() then return end

    local enemies = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(),
        self:GetParent():GetOrigin(),
        nil,
        self.disable,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
        DOTA_UNIT_TARGET_FLAG_NONE,
        0,
        false)

    local no_enemies = #enemies==0

    if no_enemies ~= self.active then
        self:PlayEffects2( no_enemies )
        self.active = no_enemies
    end
end
function modifier_nature_marksmanship:PlayEffects2( start )


    print("PlayEffects2",start)
    local state = 1
    if start then state = 2 end
    ParticleManager:SetParticleControl( self.fx, 2, Vector(state,0,0) )

    if not start then return end

    local particle_cast = "particles/units/heroes/hero_drow/drow_marksmanship_start.vpcf"

    local fx = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:ReleaseParticleIndex( fx )
end

--------------------------------------------------------------------------------


modifier_nature_marksmanship_proj = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsPurgeException        = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    DeclareFunctions        = function(self)
        return {
            MODIFIER_PROPERTY_PROJECTILE_NAME
        }
    end,
    GetPriority             = function(self) return MODIFIER_PRIORITY_HIGH end,
})


--------------------------------------------------------------------------------

function modifier_nature_marksmanship_proj:OnCreated(kv)
    if kv.drow_proj == 1 then
        self.proj = "particles/units/heroes/hero_drow/drow_base_attack.vpcf"
    elseif kv.drow_proj == 2 then
        self.proj = "particles/units/heroes/hero_drow/drow_frost_arrow.vpcf"
    elseif kv.drow_proj == 3 then
        self.proj = "particles/units/heroes/hero_drow/drow_marksmanship_attack.vpcf"
    elseif kv.drow_proj == 4 then
        self.proj = "particles/units/heroes/hero_drow/drow_marksmanship_frost_arrow.vpcf"
    end
end

function modifier_nature_marksmanship_proj:GetModifierProjectileName()
    return self.proj
end

--------------------------------------------------------------------------------


modifier_nature_marksmanship_reduction = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsPurgeException        = function(self) return false end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self)
        return {
            -- MODIFIER_PROPERTY_PHYSICAL_ARMOR_BASE_PERCENTAGE,
			MODIFIER_PROPERTY_IGNORE_PHYSICAL_ARMOR
        }
    end,
})

function modifier_nature_marksmanship_reduction:GetModifierIgnorePhysicalArmor() return 1 end


--------------------------------------------------------------------------------

function modifier_nature_marksmanship_reduction:GetModifierPhysicalArmorBase_Percentage() return 0 end

--------------------------------------------------------------------------------
