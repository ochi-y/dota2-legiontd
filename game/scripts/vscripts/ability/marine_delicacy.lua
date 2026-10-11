LinkLuaModifier("modifier_marine_delicacy", "ability/marine_delicacy.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if marine_delicacy == nil then
	marine_delicacy = class({})
end

function marine_delicacy:GetIntrinsicModifierName()
	return "modifier_marine_delicacy"
end

function marine_delicacy:Spawn()
	if not IsServer() then
		return
	end
	if GamePlay:Mode("fs") then
		Timers:CreateTimer(FrameTime(), function()
			local caster = self:GetCaster()
			local meta = GamePlay:FighterGetMeta(caster.fighterId)
			if meta then
				local age = meta.age
				local mod = caster:FindModifierByName("modifier_marine_delicacy")
				mod:SetStackCount(age)
			end
		end)
	end
end

---------------------------------------------------------------------
--Modifiers
modifier_marine_delicacy = class({
	IsHidden      = function(self) return false end,
	IsPurgable    = function(self) return false end,
	IsDebuff      = function(self) return false end,
	IsBuff        = function(self) return true end,
	RemoveOnDeath = function(self) return true end,
	GetAttributes = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_marine_delicacy:OnCreated(params)
	if IsServer() then
	end
end

function modifier_marine_delicacy:IsPurgable(params)
	return false
end

function modifier_marine_delicacy:OnRefresh(params)
	if IsServer() then
	end
end

function modifier_marine_delicacy:OnDestroy()
	if IsServer() then
	end
end

function modifier_marine_delicacy:DeclareFunctions()
	return {
	}
end
