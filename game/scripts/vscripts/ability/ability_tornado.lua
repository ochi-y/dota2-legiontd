LinkLuaModifier( "modifier_ability_tornado", "ability/ability_tornado", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ability_tornado_slow", "ability/ability_tornado", LUA_MODIFIER_MOTION_NONE )

--Abilities
ability_tornado = class({})

wave_23_champion_tornado=ability_tornado

function ability_tornado:OnSpellStart()
	local caster=self:GetCaster()
	local pos=self:GetCursorPosition()
	local duration=self:GetSpecialValueFor("duration")
	--
	-- local tUnit =SummonUnit("ability_tornado",caster,pos,{
	-- 	duration=duration
	-- })

	local tUnit = CreateUnitByName("wave_23_champion_tornado",pos, false, nil, nil, caster:GetTeamNumber())
	tUnit:SetControllableByPlayer(caster:GetMainControllingPlayer(),true)

	GamePlay:afterWaveCreepSummon(caster, tUnit)

	self.tornadoUnit=tUnit
	--
	tUnit:AddNewModifier(caster, self, "modifier_ability_tornado", {})
	EmitSoundOn("n_creep_Wildkin.SummonTornado", tUnit)


end
function ability_tornado:GetChannelTime()
    local duration = self:GetSpecialValueFor("duration")
    return duration
end
function ability_tornado:OnChannelFinish(interrupt)
	if self.tornadoUnit and not self.tornadoUnit:IsNull() then
		self.tornadoUnit:RemoveModifierByName("modifier_ability_tornado")
		self.tornadoUnit:ForceKill(false)
		self.tornadoUnit=0
	end
	--StopSoundOn("hero_Crystal.freezingField.wind", self:GetCaster())
end
---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_ability_tornado = class({
	IsHidden = function(self)
		return false
	end,
	IsPurgable = function(self)
		return false
	end,
	IsDebuff = function(self)
		return true
	end,
	IsBuff = function(self)
		return false
	end,
	RemoveOnDeath = function(self)
		return true
	end,
	GetAttributes = function(self)
		return MODIFIER_ATTRIBUTE_NONE
	end
})
function modifier_ability_tornado:AllowIllusionDuplicate()
	return false
end
function modifier_ability_tornado:OnCreated(params)
	local ability=self:GetAbility()
	self.duration=ability:GetSpecialValueFor("duration")
	self.radius=ability:GetSpecialValueFor("radius")
	self.damage=ability:GetSpecialValueFor("damage")
	if not IsServer() then return end
	EmitSoundOn("n_creep_Wildkin.Tornado", self:GetParent())
	local interval=0.25
	self.damage=self.damage*interval
    self:StartIntervalThink(interval)
end
function modifier_ability_tornado:OnIntervalThink()
	AoeDamage(self:GetAbility(),self:GetParent():GetAbsOrigin(),self.radius,self.damage)
end
function modifier_ability_tornado:OnDestroy(params)
	StopSoundOn("n_creep_Wildkin.Tornado", self:GetParent())
end
function modifier_ability_tornado:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_ability_tornado:DeclareFunctions()
	return {

	}
end
function modifier_ability_tornado:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR ]=true
	}
	return state
end

function modifier_ability_tornado:GetEffectName()
	return "particles/neutral_fx/tornado_ambient.vpcf"
end
function modifier_ability_tornado:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function modifier_ability_tornado:IsAura()
    return true
end

function modifier_ability_tornado:GetModifierAura()
    return "modifier_ability_tornado_slow"
end

function modifier_ability_tornado:GetAuraRadius()
    return self.radius
end

function modifier_ability_tornado:GetAuraSearchTeam()    
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_ability_tornado:GetAuraDuration()    
    return 0
end

function modifier_ability_tornado:GetAuraSearchType()    
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_ability_tornado:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end


modifier_ability_tornado_slow = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsPurgeException        = function(self) return false end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self)
        return {
            MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
        }
    end,
})


--------------------------------------------------------------------------------

function modifier_ability_tornado_slow:OnCreated()
    self.movement_slow = self:GetAbility():GetSpecialValueFor("movement_slow") * (-1)
end

function modifier_ability_tornado_slow:OnRefresh()
    self:OnCreated()
end

function modifier_ability_tornado_slow:GetModifierMoveSpeedBonus_Percentage() return self.movement_slow end