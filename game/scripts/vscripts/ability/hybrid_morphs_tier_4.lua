LinkLuaModifier( "modifier_hybrid_morphs_tier_4", "ability/hybrid_morphs_tier_4.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hybrid_morphs_tier_4_morphs", "ability/hybrid_morphs_tier_4.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if hybrid_morphs_tier_4 == nil then
	hybrid_morphs_tier_4 = class({})
end
function hybrid_morphs_tier_4:GetIntrinsicModifierName()
	return "modifier_hybrid_morphs_tier_4"
end


-------------------------------------------------------------------------------------------------------
modifier_hybrid_morphs_tier_4 = class({
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
function modifier_hybrid_morphs_tier_4:AllowIllusionDuplicate()
	return false
end
function modifier_hybrid_morphs_tier_4:OnCreated(params)
	if not IsServer() then return end
	self:StartIntervalThink(0.2)
end

function modifier_hybrid_morphs_tier_4:OnIntervalThink()
	local parent=self:GetParent()
	local ability=self:GetAbility()
	if not parent:HasModifier("modifier_crafting") then
		parent:AddNewModifier(parent, ability, "modifier_hybrid_morphs_tier_4_morphs", {duration=0.2})
		self:Destroy()
	end
end

function modifier_hybrid_morphs_tier_4:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_hybrid_morphs_tier_4:DeclareFunctions()
	return {

	}
end
function modifier_hybrid_morphs_tier_4:CheckState()
	local state = {
	}
	return state
end

-------------------------------------------------------------------------------------------------------
modifier_hybrid_morphs_tier_4_morphs = class({
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
function modifier_hybrid_morphs_tier_4_morphs:AllowIllusionDuplicate()
	return false
end
function modifier_hybrid_morphs_tier_4_morphs:OnCreated(params)
	local parent=self:GetParent()
	local ability=self:GetAbility()
	if not IsServer() then return end
	EmitSoundOn("Hero_Morphling.Replicate", parent)
end

function modifier_hybrid_morphs_tier_4_morphs:OnDestroy(params)
	local parent=self:GetParent()
	local ability=self:GetAbility()
	if not IsServer() then return end
	local units=GamePlay:getAllBuildingsByTier()[4]
	local unitName=units[RandomInt(1, #units)]
	hybridUpgradeBuilding(parent,unitName)
end

function modifier_hybrid_morphs_tier_4_morphs:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_hybrid_morphs_tier_4_morphs:DeclareFunctions()
	return {

	}
end
function modifier_hybrid_morphs_tier_4_morphs:CheckState()
	local state = {
	}
	return state
end
function modifier_hybrid_morphs_tier_4_morphs:GetEffectName()
	return "particles/items2_fx/manta_phase.vpcf"
end
function modifier_hybrid_morphs_tier_4_morphs:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end
