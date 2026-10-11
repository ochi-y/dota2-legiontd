LinkLuaModifier("modifier_ghost_pierce_the_veil", "ability/ghost_pierce_the_veil.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if ghost_pierce_the_veil == nil then
    ghost_pierce_the_veil = class({})
end
-- function ghost_pierce_the_veil:GetIntrinsicModifierName()
--     if self:GetLevel() > 0 then
--         return "modifier_ghost_pierce_the_veil"
--     end
-- end

function ghost_pierce_the_veil:OnSpellStart()
    local caster=self:GetCaster()
    EmitSoundOn("Hero_Muerta.PierceTheVeil.Cast", caster)           

    local duration=self:GetSpecialValueFor("duration")              

    caster:AddNewModifier(caster, self, "modifier_ghost_pierce_the_veil", {
        duration=duration
    })

    caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
end

---------------------------------------------------------------------
-- Modifiers
-------------------------------------------------------------------------------------------------------
modifier_ghost_pierce_the_veil = class({
    IsHidden = function(self)
        return false
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
function modifier_ghost_pierce_the_veil:AllowIllusionDuplicate()
    return false
end
function modifier_ghost_pierce_the_veil:OnCreated(params)
    if not self:GetAbility() then return end
    local ability = self:GetAbility()
    if not ability then
        return
    end   

    self.base_damage_pct = ability:GetSpecialValueFor("base_damage_pct")
    
    
    if not IsServer() then return end
    self.parent=self:GetParent()
end
function modifier_ghost_pierce_the_veil:OnRefresh(params)
    self:OnCreated(params)
end

function modifier_ghost_pierce_the_veil:OnDestroy(params)
    if not IsServer() then return end

    PlayEffOnUnit("particles/units/heroes/hero_muerta/muerta_ultimate_form_finish.vpcf",self.parent)
    EmitSoundOn("Hero_Muerta.PierceTheVeil.End", self.parent)
end

function modifier_ghost_pierce_the_veil:CheckState()
	local state = {
		-- [MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
	return state
end

function modifier_ghost_pierce_the_veil:DeclareFunctions()
    return { 
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE ,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_PROJECTILE_NAME,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,

        -- MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        -- MODIFIER_PROPERTY_ALWAYS_ETHEREAL_ATTACK,
        MODIFIER_PROPERTY_OVERRIDE_ATTACK_MAGICAL
    }
end


function modifier_ghost_pierce_the_veil:GetOverrideAttackMagical()
	return 1
end
function modifier_ghost_pierce_the_veil:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_ghost_pierce_the_veil:GetModifierModelChange()
	return "models/heroes/muerta/muerta_ult.vmdl"
end

function modifier_ghost_pierce_the_veil:GetModifierProjectileName()
	return "particles/units/heroes/hero_muerta/muerta_ultimate_projectile.vpcf"
end

function modifier_ghost_pierce_the_veil:GetAttackSound()
	return "Hero_Muerta.PierceTheVeil.Attack"
end



function modifier_ghost_pierce_the_veil:GetModifierBaseDamageOutgoing_Percentage()
    return -100
end

function modifier_ghost_pierce_the_veil:OnAttackLanded(params)
	if not IsServer() then
		return
	end
	if params.attacker ~= self:GetParent() then
		return
	end
	local target = params.target
	local caster=self:GetCaster()
	SimpleApplyDamage(self:GetAbility(), self:GetCaster(), target, caster:GetAttackDamage())
end

function modifier_ghost_pierce_the_veil:GetEffectName()
    return "particles/units/heroes/hero_muerta/muerta_ultimate_form_ethereal.vpcf"
end
function modifier_ghost_pierce_the_veil:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end
