LinkLuaModifier("modifier_ghost_reincarnation_aura", "ability/ghost_reincarnation_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ghost_reincarnation_aura_buff", "ability/ghost_reincarnation_aura.lua",
	LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_ghost_reincarnation_aura_zombie", "ability/ghost_reincarnation_aura.lua",
	LUA_MODIFIER_MOTION_NONE)


--Abilities
if ghost_reincarnation_aura == nil then
	ghost_reincarnation_aura = class({})
end
function ghost_reincarnation_aura:GetIntrinsicModifierName()
	if self:GetLevel() > 0 then
		return "modifier_ghost_reincarnation_aura"
	end
end

-------------------------------------------------------------------------------------------------------
modifier_ghost_reincarnation_aura = class({
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
function modifier_ghost_reincarnation_aura:AllowIllusionDuplicate()
	return false
end

function modifier_ghost_reincarnation_aura:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.aura_radius = ability:GetSpecialValueFor("aura_radius")
	if not IsServer() then return end
end

function modifier_ghost_reincarnation_aura:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_ghost_reincarnation_aura:DeclareFunctions()
	return {
	}
end

function modifier_ghost_reincarnation_aura:IsAura()
	return true
end

function modifier_ghost_reincarnation_aura:GetAuraRadius()
	return self.aura_radius
end

function modifier_ghost_reincarnation_aura:GetAuraEntityReject(unit)
	return unit:HasModifier("modifier_ghost_reincarnation_aura_zombie")
end

function modifier_ghost_reincarnation_aura:GetAuraDuration()
	return 0
end

function modifier_ghost_reincarnation_aura:GetAuraSearchTeam()
	return self:GetAbility():GetAbilityTargetTeam()
end

function modifier_ghost_reincarnation_aura:GetAuraSearchType()
	return self:GetAbility():GetAbilityTargetType()
end

function modifier_ghost_reincarnation_aura:GetAuraSearchFlags()
	return self:GetAbility():GetAbilityTargetFlags()
end

function modifier_ghost_reincarnation_aura:GetModifierAura()
	return "modifier_ghost_reincarnation_aura_buff"
end

-------------------------------------------------------------------------------------------------------
modifier_ghost_reincarnation_aura_buff = class({
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
function modifier_ghost_reincarnation_aura_buff:AllowIllusionDuplicate()
	return false
end

function modifier_ghost_reincarnation_aura_buff:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()

	self.duration = ability:GetSpecialValueFor("duration")

	if not IsServer() then return end
end

function modifier_ghost_reincarnation_aura_buff:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_ghost_reincarnation_aura_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
end

function modifier_ghost_reincarnation_aura_buff:GetModifierIncomingDamage_Percentage(data)
	if not IsServer() then
		return
	end
	local health = self:GetParent():GetHealth()
	if (health - data.damage <= 0) then
		local parent = self:GetParent()
		local caster = self:GetCaster()
		EmitSoundOn("Hero_SkeletonKing.Reincarnate.Ghost", parent)

		parent:Purge(false, true, false, true, true)

		parent:ModifyHealth(parent:GetMaxHealth(), self:GetAbility(), false,
		DOTA_DAMAGE_FLAG_NO_DIRECTOR_EVENT + DOTA_DAMAGE_FLAG_HPLOSS)

		--PrintTable(data)

		parent:AddNewModifier(caster, self:GetAbility(), "modifier_ghost_reincarnation_aura_zombie", {
			duration=self.duration,
			attackIndex=data.attacker:entindex()
		})
		return -100
	end
	return 0
end


modifier_ghost_reincarnation_aura_zombie = class({
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
function modifier_ghost_reincarnation_aura_zombie:AllowIllusionDuplicate()
	return false
end

function modifier_ghost_reincarnation_aura_zombie:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	if not IsServer() then return end
	self.attackIndex = params.attackIndex

	self.attacker = EntIndexToHScript(self.attackIndex)
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true)
end

function modifier_ghost_reincarnation_aura_zombie:OnRefresh(params)
end

function modifier_ghost_reincarnation_aura_zombie:OnDestroy(params)
	if not IsServer() then return end
	local parent=self:GetParent()
	if self.attacker and not self.attacker:IsNull() then
		parent:Kill(self:GetAbility(),nil)
	else
		parent:Kill(self:GetAbility(),parent)	
	end
	-- parent:ForceKill(false)
end

function modifier_ghost_reincarnation_aura_zombie:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		
	}
end
function modifier_ghost_reincarnation_aura_zombie:GetModifierIncomingDamage_Percentage()
	return -100
end


function modifier_ghost_reincarnation_aura_zombie:GetMinHealth()
	return 1
end

function modifier_ghost_reincarnation_aura_zombie:CheckState()
	local state = {
		[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
		[MODIFIER_STATE_SILENCED] = true
	}
	return state
end

function modifier_ghost_reincarnation_aura_zombie:GetEffectName()
	return "particles/units/heroes/hero_skeletonking/wraith_king_ghosts_ambient.vpcf"
end
function modifier_ghost_reincarnation_aura_zombie:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end
function modifier_ghost_reincarnation_aura_zombie:GetStatusEffectName()
	return "particles/status_fx/status_effect_wraithking_ghosts.vpcf"
end
function modifier_ghost_reincarnation_aura_zombie:StatusEffectPriority()
	return 1000
end

