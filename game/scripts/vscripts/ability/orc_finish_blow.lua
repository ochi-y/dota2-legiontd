LinkLuaModifier("modifier_orc_finish_blow", "ability/orc_finish_blow.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
orc_finish_blow = class({})

orc_finish_blow_hc = orc_finish_blow

function orc_finish_blow:GetIntrinsicModifierName()
	return "modifier_orc_finish_blow"
end

---------------------------------------------------------------------
--Modifiers
modifier_orc_finish_blow = class({
	IsHidden      = function(self) return true end,
	IsPurgable    = function(self) return false end,
	IsDebuff      = function(self) return false end,
	IsBuff        = function(self) return true end,
	RemoveOnDeath = function(self) return true end,
	GetAttributes = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_orc_finish_blow:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.chance = ability:GetSpecialValueFor("chance")
	if IsServer() then
	end
end

function modifier_orc_finish_blow:IsPurgable(params)
	return false
end

function modifier_orc_finish_blow:OnRefresh(params)
	if IsServer() then
	end
end

function modifier_orc_finish_blow:OnDestroy()
	if IsServer() then
	end
end

function modifier_orc_finish_blow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
	}
end

function modifier_orc_finish_blow:GetModifierPreAttack_CriticalStrike(params)
	if not IsServer() then return end
	if RandomInt(1, 100) <= self.chance then
		EmitSoundOn("Hero_Axe.Culling_Blade_Success", self:GetParent())
		PlayEffOnUnit("particles/econ/items/axe/ti9_jungle_axe/ti9_jungle_axe_culling_blade_kill_b.vpcf",
			params.target,
			{
				cps={4}
			}
		)
		local caster = self:GetParent()
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
		return 100 * 50
	end
end
