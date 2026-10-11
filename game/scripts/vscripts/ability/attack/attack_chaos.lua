LinkLuaModifier("modifier_attack_chaos", "ability/attack/attack_chaos.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if attack_chaos == nil then
    attack_chaos = class({})
end
function attack_chaos:GetIntrinsicModifierName()
    return "modifier_attack_chaos"
end
---------------------------------------------------------------------
-- Modifiers
modifier_attack_chaos = class({
	IsHidden                = function(self) return false end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})

	function modifier_attack_chaos:GetTexture()
		return "attack/attack_chaos"
	end	


function modifier_attack_chaos:OnCreated(params)
    if IsServer() then
		local caster=self:GetParent()
		caster.attackType="chaos"
    end
end
function modifier_attack_chaos:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_attack_chaos:OnDestroy()
    if IsServer() then
    end
end
function modifier_attack_chaos:DeclareFunctions()
    return {
		MODIFIER_EVENT_ON_ATTACK_LANDED, 
	}
end

function modifier_attack_chaos:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target

	handleAttackType(params.attacker,target)
	
end