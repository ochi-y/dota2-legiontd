marine_sphere = class({})

marine_sphere_1 = marine_sphere

-- LinkLuaModifier("modifier_marine_sphere", "ability/marine_sphere",
--     LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_marine_sphere_buff", "ability/marine_sphere", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_marine_sphere_debuff", "ability/marine_sphere", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_marine_sphere_tag", "ability/marine_sphere", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Passive Modifier
-- function marine_sphere:GetIntrinsicModifierName()
--     return "modifier_marine_sphere"
-- end

--------------------------------------------------------------------------------
-- Ability Start
function marine_sphere:OnSpellStart()
    -- unit identifier
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    -- load data
    local duration = self:GetSpecialValueFor("duration")


    if IsCustomBuilding(caster) then
		GamePlay:FighterSetAbilityTarget(caster.fighterId,self:GetAbilityName(),target.fighterId)
	end

    -- add modifier
    target:AddNewModifier(caster, -- player source
    self, -- ability source
    "modifier_marine_sphere_buff", -- modifier name
    {
        duration = duration
    } -- kv
    )

    -- effects
    local sound_cast = "n_creep_OgreMagi.FrostArmor"
    EmitSoundOn(sound_cast, self:GetCaster())
end
--------------------------------------------------------------------------------------------------
-- modifier_marine_sphere = class({})

-- --------------------------------------------------------------------------------
-- -- Classifications
-- function modifier_marine_sphere:IsHidden()
-- 	return true
-- end

-- function modifier_marine_sphere:IsDebuff()
-- 	return false
-- end

-- function modifier_marine_sphere:IsPurgable()
-- 	return false
-- end

-- --------------------------------------------------------------------------------
-- -- Initializations
-- function modifier_marine_sphere:OnCreated( kv )

-- end

-- function modifier_marine_sphere:OnRefresh( kv )

-- end

-- function modifier_marine_sphere:OnDestroy( kv )

-- end

-- --------------------------------------------------------------------------------
-- -- Modifier Effects
-- function modifier_marine_sphere:DeclareFunctions()
-- 	local funcs = {
-- 		MODIFIER_EVENT_ON_ATTACKED,
-- 	}

-- 	return funcs
-- end

-- function modifier_marine_sphere:OnAttacked( params )
-- 	if IsServer() then
-- 		-- dont autocast if...
-- 		if not self:GetAbility():GetAutoCastState() then return end
-- 		if self:GetParent():IsChanneling() then return end

-- 		-- filter
-- 		local filter = UnitFilter(
-- 			params.unit,
-- 			DOTA_UNIT_TARGET_TEAM_FRIENDLY,
-- 			DOTA_UNIT_TARGET_HERO,
-- 			DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
-- 			self:GetParent():GetTeamNumber()
-- 		)
-- 		if filter ~= UF_SUCCESS then return	end

-- 		-- check if castable
-- 		if not self:GetAbility():IsFullyCastable() then return end

-- 		-- cast ability
-- 		-- self:GetParent():SetCursorCastTarget( params.unit )
-- 		self:GetParent():CastAbilityOnTarget( params.unit, self:GetAbility(), self:GetParent():GetPlayerOwnerID() )
-- 	end
-- end
--------------------------------------------------------------------------------------------------
modifier_marine_sphere_buff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_marine_sphere_buff:IsHidden()
    return false
end

function modifier_marine_sphere_buff:IsDebuff()
    return false
end

function modifier_marine_sphere_buff:GetAttributes()
    return MODIFIER_ATTRIBUTE_INVULNERABLE
end

function modifier_marine_sphere_buff:IsPurgable()
    return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_marine_sphere_buff:OnCreated(kv)
    if not self:GetAbility() then return end
    -- references
    self.armor = self:GetAbility():GetSpecialValueFor("armor_bonus")
    self.duration = self:GetAbility():GetSpecialValueFor("slow_duration")
    self.as_slow = self:GetAbility():GetSpecialValueFor("attackspeed_slow")
    self.ms_slow = self:GetAbility():GetSpecialValueFor("movespeed_slow")
    
    if not IsServer() then return end

    -- PlayEffOnUnit("particles/units/heroes/hero_lich/lich_ice_age.vpcf",self:GetParent(),{
    --     mod=self,
    --     cpKv={
    --         [2]=Vector(0,0,0)
    --     },
    --     cps={0,1}
    -- })

    PlayEffOnUnit("particles/neutral_fx/ogre_magi_frost_armor.vpcf",self:GetParent(),{
        mod=self,
        bind = PATTACH_OVERHEAD_FOLLOW
    })

end

function modifier_marine_sphere_buff:GetStatusEffectName()
    return "particles/neutral_fx/ogre_magi_frost_armor.vpcf"
end
function modifier_marine_sphere_buff:StatusEffectPriority()
    return MODIFIER_PRIORITY_HIGH
end
function modifier_marine_sphere_buff:OnRefresh(kv)
    -- references
    self.armor = self:GetAbility():GetSpecialValueFor("armor_bonus")
    self.duration = self:GetAbility():GetSpecialValueFor("slow_duration")
    self.as_slow = self:GetAbility():GetSpecialValueFor("attackspeed_slow")
    self.ms_slow = self:GetAbility():GetSpecialValueFor("movespeed_slow")

end

function modifier_marine_sphere_buff:OnDestroy(kv)

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_marine_sphere_buff:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_EVENT_ON_ATTACKED}

    return funcs
end

function modifier_marine_sphere_buff:GetModifierPhysicalArmorBonus()
    return self.armor
end

function modifier_marine_sphere_buff:OnAttacked(params)
    if IsServer() then
        -- filter
        if params.target ~= self:GetParent() then
            return
        end
        local filter = UnitFilter(params.attacker, DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, self:GetParent():GetTeamNumber())
        if filter ~= UF_SUCCESS then
            return
        end

        local duration = self.duration
        duration = duration * (1 - CalUnitStatusResistance(params.attacker))
        -- add modifier
        params.attacker:AddNewModifier(self:GetCaster(), -- player source
        self:GetAbility(), -- ability source
        "modifier_marine_sphere_debuff", -- modifier name
        {
            duration = duration,
            as_slow = self.as_slow,
            ms_slow = self.ms_slow
        } -- kv
        )

        -- play effects
        -- local sound_cast = "Hero_Lich.FrostArmorDamage"
        -- EmitSoundOn(sound_cast, params.attacker)
    end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
-- function modifier_marine_sphere_buff:GetEffectName()
--     return "particles/units/heroes/hero_lich/lich_frost_armor.vpcf"
-- end

-- function modifier_marine_sphere_buff:GetEffectAttachType()
--     return PATTACH_OVERHEAD_FOLLOW
-- end

-- function modifier_marine_sphere_buff:PlayEffects()
-- 	-- Get Resources
-- 	local particle_cast = "string"
-- 	local sound_cast = "string"

-- 	-- Get Data

-- 	-- Create Particle
-- 	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_NAME, hOwner )
-- 	ParticleManager:SetParticleControl( effect_cast, iControlPoint, vControlVector )
-- 	ParticleManager:SetParticleControlEnt(
-- 		effect_cast,
-- 		iControlPoint,
-- 		hTarget,
-- 		PATTACH_NAME,
-- 		"attach_name",
-- 		vOrigin, -- unknown
-- 		bool -- unknown, true
-- 	)
-- 	ParticleManager:SetParticleControlForward( effect_cast, iControlPoint, vForward )
-- 	SetParticleControlOrientation( effect_cast, iControlPoint, vForward, vRight, vUp )
-- 	ParticleManager:ReleaseParticleIndex( effect_cast )

-- 	-- buff particle
-- 	self:AddParticle(
-- 		nFXIndex,
-- 		bDestroyImmediately,
-- 		bStatusEffect,
-- 		iPriority,
-- 		bHeroEffect,
-- 		bOverheadEffect
-- 	)

-- 	-- Create Sound
-- 	EmitSoundOnLocationWithCaster( vTargetPosition, sound_location, self:GetCaster() )
-- 	EmitSoundOn( sound_target, target )
-- end
--------------------------------------------------------------------------------------------------
modifier_marine_sphere_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_marine_sphere_debuff:IsHidden()
    return false
end

function modifier_marine_sphere_debuff:IsDebuff()
    return true
end

function modifier_marine_sphere_debuff:IsStunDebuff()
    return false
end

function modifier_marine_sphere_debuff:IsPurgable()
    return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_marine_sphere_debuff:OnCreated(kv)
    if not self:GetAbility() then return end
    self.armor = self:GetAbility():GetSpecialValueFor("armor_bonus")
    self.duration = self:GetAbility():GetSpecialValueFor("slow_duration")
    self.as_slow = self:GetAbility():GetSpecialValueFor("attackspeed_slow")
    self.ms_slow = self:GetAbility():GetSpecialValueFor("movespeed_slow")

end

function modifier_marine_sphere_debuff:OnRefresh(kv)
    if not self:GetAbility() then return end
    -- references
    self.armor = self:GetAbility():GetSpecialValueFor("armor_bonus")
    self.duration = self:GetAbility():GetSpecialValueFor("slow_duration")
    self.as_slow = self:GetAbility():GetSpecialValueFor("attackspeed_slow")
    self.ms_slow = self:GetAbility():GetSpecialValueFor("movespeed_slow")
end

function modifier_marine_sphere_debuff:OnDestroy(kv)

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_marine_sphere_debuff:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}

    return funcs
end

function modifier_marine_sphere_debuff:GetModifierAttackSpeedPercentage()
    if self:GetParent():IsAncient() then
        return self.as_slow * (100 - BOSS_ATTACK_SPEED_REDUCTION_RESISTANCE) / 100
    end
    return self.as_slow
end
function modifier_marine_sphere_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.ms_slow
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_marine_sphere_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost_lich.vpcf"
end
--------------------------------------------------------------------------------------------------

modifier_marine_sphere_tag = class({
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    IsDebuff = function(self)
        return false
    end,
    IsBuff = function(self)
        return true
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_NONE
    end
})
