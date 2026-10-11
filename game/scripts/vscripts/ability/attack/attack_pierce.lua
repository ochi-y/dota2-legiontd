LinkLuaModifier("modifier_attack_pierce", "ability/attack/attack_pierce.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if attack_pierce == nil then
    attack_pierce = class({})
end
function attack_pierce:GetIntrinsicModifierName()
    return "modifier_attack_pierce"
end
---------------------------------------------------------------------
-- Modifiers
modifier_attack_pierce = class({
	IsHidden                = function(self) return false end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})

	function modifier_attack_pierce:GetTexture()
		return "attack/attack_pierce"
	end	


function modifier_attack_pierce:OnCreated(params)
    if IsServer() then
		local caster=self:GetParent()
		caster.attackType="pierce"
    end
end
function modifier_attack_pierce:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_attack_pierce:OnDestroy()
    if IsServer() then
    end
end
function modifier_attack_pierce:DeclareFunctions()
    return {
		MODIFIER_EVENT_ON_ATTACK_LANDED, 
	}
end

function modifier_attack_pierce:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target

	handleAttackType(params.attacker,target)
	
end