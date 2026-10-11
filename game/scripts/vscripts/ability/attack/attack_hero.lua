LinkLuaModifier("modifier_attack_hero", "ability/attack/attack_hero.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if attack_hero == nil then
    attack_hero = class({})
end
function attack_hero:GetIntrinsicModifierName()
    return "modifier_attack_hero"
end
---------------------------------------------------------------------
-- Modifiers
modifier_attack_hero = class({
	IsHidden                = function(self) return false end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})

	function modifier_attack_hero:GetTexture()
		return "attack/attack_hero"
	end	


function modifier_attack_hero:OnCreated(params)
    if IsServer() then
		local caster=self:GetParent()
		caster.attackType="hero"
    end
end
function modifier_attack_hero:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_attack_hero:OnDestroy()
    if IsServer() then
    end
end
function modifier_attack_hero:DeclareFunctions()
    return {
		MODIFIER_EVENT_ON_ATTACK_LANDED, 
	}
end

function modifier_attack_hero:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target

	handleAttackType(params.attacker,target)
	
end