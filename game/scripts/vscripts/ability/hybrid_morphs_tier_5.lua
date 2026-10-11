LinkLuaModifier( "modifier_hybrid_morphs_tier_5", "ability/hybrid_morphs_tier_5.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hybrid_morphs_tier_5_morphs", "ability/hybrid_morphs_tier_5.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if hybrid_morphs_tier_5 == nil then
	hybrid_morphs_tier_5 = class({})
end
function hybrid_morphs_tier_5:GetIntrinsicModifierName()
	return "modifier_hybrid_morphs_tier_5"
end


-------------------------------------------------------------------------------------------------------
modifier_hybrid_morphs_tier_5 = class({
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
function modifier_hybrid_morphs_tier_5:AllowIllusionDuplicate()
	return false
end
function modifier_hybrid_morphs_tier_5:OnCreated(params)
	if not IsServer() then return end
	self:StartIntervalThink(0.2)
end

function modifier_hybrid_morphs_tier_5:OnIntervalThink()
	local parent=self:GetParent()
	local ability=self:GetAbility()
	if not parent:HasModifier("modifier_crafting") then
		parent:AddNewModifier(parent, ability, "modifier_hybrid_morphs_tier_5_morphs", {duration=0.2})
		self:Destroy()
	end
end

function modifier_hybrid_morphs_tier_5:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_hybrid_morphs_tier_5:DeclareFunctions()
	return {

	}
end
function modifier_hybrid_morphs_tier_5:CheckState()
	local state = {
	}
	return state
end

-------------------------------------------------------------------------------------------------------
modifier_hybrid_morphs_tier_5_morphs = class({
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
function modifier_hybrid_morphs_tier_5_morphs:AllowIllusionDuplicate()
	return false
end
function modifier_hybrid_morphs_tier_5_morphs:OnCreated(params)
	local parent=self:GetParent()
	local ability=self:GetAbility()
	if not IsServer() then return end
	EmitSoundOn("Hero_Morphling.Replicate", parent)
end

function modifier_hybrid_morphs_tier_5_morphs:OnDestroy(params)
	local parent=self:GetParent()
	local ability=self:GetAbility()
	if not IsServer() then return end
	local units=GamePlay:getAllBuildingsByTier()[5]
	local unitName=units[RandomInt(1, #units)]
	hybridUpgradeBuilding(parent,unitName)
end

function modifier_hybrid_morphs_tier_5_morphs:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_hybrid_morphs_tier_5_morphs:DeclareFunctions()
	return {

	}
end
function modifier_hybrid_morphs_tier_5_morphs:CheckState()
	local state = {
	}
	return state
end
function modifier_hybrid_morphs_tier_5_morphs:GetEffectName()
	return "particles/items2_fx/manta_phase.vpcf"
end
function modifier_hybrid_morphs_tier_5_morphs:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end
