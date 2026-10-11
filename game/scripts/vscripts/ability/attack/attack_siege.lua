LinkLuaModifier("modifier_attack_siege", "ability/attack/attack_siege.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if attack_siege == nil then
    attack_siege = class({})
end
function attack_siege:GetIntrinsicModifierName()
    return "modifier_attack_siege"
end
---------------------------------------------------------------------
-- Modifiers
modifier_attack_siege = class({
	IsHidden                = function(self) return false end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})

	function modifier_attack_siege:GetTexture()
		return "attack/attack_siege"
	end	


function modifier_attack_siege:OnCreated(params)
    if IsServer() then
		local caster=self:GetParent()
		caster.attackType="siege"
    end
end
function modifier_attack_siege:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_attack_siege:OnDestroy()
    if IsServer() then
    end
end
function modifier_attack_siege:DeclareFunctions()
    return {
		MODIFIER_EVENT_ON_ATTACK_LANDED, 
	}
end

function modifier_attack_siege:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target
	handleAttackType(params.attacker,target)
end