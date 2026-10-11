-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]] --------------------------------------------------------------------------------
elf_mirage = class({})
LinkLuaModifier("modifier_elf_mirage", "ability/elf_mirage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_elf_mirage_ambient", "ability/elf_mirage", LUA_MODIFIER_MOTION_NONE)


--------------------------------------------------------------------------------
-- Ability Start
elf_mirage.illusions = {}
function elf_mirage:OnSpellStart()
    -- unit identifier
    local caster = self:GetCaster()

    -- load data
    local delay = self:GetSpecialValueFor("invuln_duration")

    -- stop, dodge & dispel
    -- caster:Stop()
    ProjectileManager:ProjectileDodge(caster)
    caster:Purge(false, true, false, false, false)

    -- add delay modifier
    caster:AddNewModifier(caster, -- player source
    self, -- ability source
    "modifier_elf_mirage", -- modifier name
    {
        duration = delay
    } -- kv
    )

    -- play effects
    local sound_cast = "Hero_NagaSiren.MirrorImage"
    EmitSoundOn(sound_cast, caster)
end

function elf_mirage:GetIntrinsicModifierName()
	return "modifier_elf_mirage_ambient"
end


-------------------------------------------------------------------------------------------------------
modifier_elf_mirage_ambient = class({
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
function modifier_elf_mirage_ambient:AllowIllusionDuplicate()
    return true
end
function modifier_elf_mirage_ambient:OnCreated(params)
    -- self.damage = params.damage
    -- self:SetHasCustomTransmitterData(true) 
end
function modifier_elf_mirage_ambient:OnRefresh(params)
    self:OnCreated(params)
end

function modifier_elf_mirage_ambient:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
	}
end
function modifier_elf_mirage_ambient:GetActivityTranslationModifiers( params )
	return "torment"
end

-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
modifier_elf_mirage = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_elf_mirage:IsHidden()
    return true
end

function modifier_elf_mirage:IsDebuff()
    return false
end

function modifier_elf_mirage:IsStunDebuff()
    return false
end

function modifier_elf_mirage:IsPurgable()
    return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_elf_mirage:OnCreated(kv)
    if not self:GetAbility() then return end
    -- load data
    self.count = self:GetAbility():GetSpecialValueFor("images_count")
    self.duration = self:GetAbility():GetSpecialValueFor("illusion_duration")
    self.outgoing = self:GetAbility():GetSpecialValueFor("outgoing_damage")
    self.incoming = self:GetAbility():GetSpecialValueFor("incoming_damage")
    self.distance = 72

    -- references
    if not IsServer() then
        return
    end
end

function modifier_elf_mirage:OnRefresh(kv)

end

function modifier_elf_mirage:OnRemoved()
end

function modifier_elf_mirage:OnDestroy()
    if not IsServer() then return end

    --[[
		NOTE: Rather than kill previous illu and summon new,
		the original have set can_respawn = true and just respawn the illu.
		but then the illusion is outdated in level, items, and abilities.
		And set its respawn position manually.
		So, no thanks.
	]]

    for illusion, _ in pairs(self:GetAbility().illusions) do
        if not illusion:IsNull() then
            -- kill previous illusion
            illusion:ForceKill(false)
        end

        -- unregister
        self:GetAbility().illusions[illusion] = nil
    end

    -- create illusions
    -- this function seems unoptimizedly slow, but whatever. doing manually is bothersome
    -- for manual illusion, see CK's Phantasm

	local pid = self:GetParent():GetPlayerOwnerID()
	local hero=PlayerResource:GetSelectedHeroEntity(pid)
	local caster=self:GetParent()

    local illusion=caster:CreateIllusion(self:GetParent(), self:GetAbility(), self.duration, caster:GetAbsOrigin()+Vector(100,0,0), self.outgoing, self.incoming, false, 1)
        
	
	if illusion then
		-- illusion:RemoveAbility(self:GetAbility():GetAbilityName())
		GamePlay:removeBuildingAbility(illusion)
        illusion:AddNewModifier(hero, nil, "modifier_phased", {
            duration = 0.1
        })
        illusion:SetForwardVector(caster:GetForwardVector())
        if caster:GetLevel()-illusion:GetLevel()>0 then
            illusion:CreatureLevelUp(caster:GetLevel()-illusion:GetLevel())    
        end
	end

	local pdata=Player:GetPData(pid)
	if illusion and pdata then
		table.insert(pdata.creeps,illusion)
	end
    
    local newUnit=illusion
    if newUnit then
        newUnit.wayStep=caster.wayStep
        newUnit.waypoints=caster.waypoints
    end

    -- local illusions = CreateIllusions(hero, -- hOwner
    -- self:GetParent(), -- hHeroToCopy
    -- {
    --     outgoing_damage = self.outgoing,
    --     incoming_damage = self.incoming,
    --     duration = self.duration
    -- }, -- hModiiferKeys
    -- self.count, -- nNumIllusions
    -- self.distance, -- nPadding
    -- true, -- bScramblePosition
    -- true -- bFindClearSpace
    -- )

	-- -- register illusions
    -- for _, illusion in pairs(illusions) do
    --     self:GetAbility().illusions[illusion] = true
    -- end
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_elf_mirage:CheckState()
    local state = {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_STUNNED] = true
    }

    return state
end

--------------------------------------------------------------------------------
-- Helper
function modifier_elf_mirage:CreateIllusion()
    self:GetAbility().illusions = {}

end

function modifier_elf_mirage:SummonIllusion()

end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_elf_mirage:GetEffectName()
    return "particles/units/heroes/hero_siren/naga_siren_mirror_image.vpcf"
end
function modifier_elf_mirage:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
