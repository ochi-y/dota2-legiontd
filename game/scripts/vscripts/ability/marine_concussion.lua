LinkLuaModifier( "modifier_marine_concussion", "ability/marine_concussion.lua", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_marine_concussion_buff", "ability/marine_concussion.lua", LUA_MODIFIER_MOTION_NONE )

--Abilities
if marine_concussion == nil then
	marine_concussion = class({})
end
function marine_concussion:GetIntrinsicModifierName()
	return "modifier_marine_concussion"
end
function marine_concussion:Spawn()
	if not IsServer() then return end
	
	
end
---------------------------------------------------------------------
--Modifiers
if modifier_marine_concussion == nil then
	modifier_marine_concussion = class({

	})
end
function modifier_marine_concussion:IsHidden()
	return true
end
function modifier_marine_concussion:IsPurgable(params)
	return false
end
function modifier_marine_concussion:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.stun=ability:GetSpecialValueFor("stun")
	self.attack_count=ability:GetSpecialValueFor("attack_count")
	self.crit=ability:GetSpecialValueFor("crit")

	if not IsServer() then return end

	local caster=self:GetCaster()
	self:GetCaster():AddNewModifier(self:GetCaster(),ability,"modifier_marine_concussion_buff",{})
	local mod=caster:FindModifierByName("modifier_marine_concussion_buff")
	mod:SetStackCount(self.attack_count)
end
function modifier_marine_concussion:OnRefresh(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.stun=ability:GetSpecialValueFor("stun")
	self.attack_count=ability:GetSpecialValueFor("attack_count")
	self.crit=ability:GetSpecialValueFor("crit")

end
function modifier_marine_concussion:OnDestroy()
	if IsServer() then
	end
end
function modifier_marine_concussion:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_marine_concussion:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local caster=self:GetParent()
	local mod=caster:FindModifierByName("modifier_marine_concussion_buff")

	if mod then
		local c=mod:GetStackCount()
		if c>= self.attack_count then
			EmitSoundOn("Hero_Slardar.Bash", params.target)
			local duration=self.stun
			duration = duration * (1 - CalUnitStatusResistance(params.target))
			params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = duration})
			mod:SetStackCount(0)
			self.critFlag=true
		else
			mod:SetStackCount(mod:GetStackCount()+1)
		end
	end
end

function modifier_marine_concussion:GetModifierPreAttack_CriticalStrike( params )
	if not IsServer() then return end
	local caster=self:GetParent()
	local mod=caster:FindModifierByName("modifier_marine_concussion_buff")
	if self.critFlag then
		local c=mod:GetStackCount()
		if c>= self.attack_count then
			return self.crit
		end
	end
end
---------------------------------------------------------------------
--Modifiers
modifier_marine_concussion_buff = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_marine_concussion_buff:OnCreated(params)
end




