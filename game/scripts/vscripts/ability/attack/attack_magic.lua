LinkLuaModifier("modifier_attack_magic", "ability/attack/attack_magic.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if attack_magic == nil then
    attack_magic = class({})
end
function attack_magic:GetIntrinsicModifierName()
    return "modifier_attack_magic"
end
---------------------------------------------------------------------
-- Modifiers
modifier_attack_magic = class({
	IsHidden                = function(self) return false end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})

	function modifier_attack_magic:GetTexture()
		return "attack/attack_magic"
	end	


function modifier_attack_magic:OnCreated(params)
    if IsServer() then
		local caster=self:GetParent()
		caster.attackType="magic"
    end
end
function modifier_attack_magic:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_attack_magic:OnDestroy()
    if IsServer() then
    end
end
function modifier_attack_magic:DeclareFunctions()
    return {
		MODIFIER_EVENT_ON_ATTACK_LANDED, 
	}
end

function modifier_attack_magic:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target

	handleAttackType(params.attacker,target)
	
end