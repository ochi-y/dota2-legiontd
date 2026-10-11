LinkLuaModifier("modifier_kobold_disarm_ad", "ability/kobold_disarm_ad.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kobold_disarm_ad_debuff", "ability/kobold_disarm_ad.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if kobold_disarm_ad == nil then
    kobold_disarm_ad = class({})
end
function kobold_disarm_ad:GetIntrinsicModifierName()
    return "modifier_kobold_disarm_ad"
end
---------------------------------------------------------------------
-- Modifiers
if modifier_kobold_disarm_ad == nil then
    modifier_kobold_disarm_ad = class({})
end
function modifier_kobold_disarm_ad:OnCreated(params)

	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.attack_count=ability:GetSpecialValueFor("attack_count")
	self.duration=self:GetAbility():GetSpecialValueFor("duration")

	
	if IsServer() then 
		self:SetStackCount(0)
	end
    
end
function modifier_kobold_disarm_ad:IsPurgable(params)
	return false
end
function modifier_kobold_disarm_ad:OnRefresh(params)
    self:OnCreated(params)
end
function modifier_kobold_disarm_ad:OnDestroy()
    if IsServer() then
    end
end
function modifier_kobold_disarm_ad:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_kobold_disarm_ad:OnAttackLanded(params)
	if not IsServer() then return end

	if params.attacker ~= self:GetParent() then
        return
    end
	if params.attacker:PassivesDisabled() then return end
	local target = params.target
	
	if target:IsMagicImmune() then
		return
	end

	if not SimpleUnitFilter(self:GetAbility(),target) then
		return
	end

	if params.attacker:PassivesDisabled() == false and (target:IsHero() or target:IsCreep()) then
		if self:GetAbility():IsCooldownReady()   then
			local attacker = params.attacker
			local target = params.target
			self:SetStackCount(self:GetStackCount()+1)
			if self:GetStackCount()==self.attack_count then
				target:AddNewModifier(attacker, self:GetAbility(), "modifier_kobold_disarm_ad_debuff", {duration=self.duration})
				self:SetStackCount(0)
				self:GetAbility():StartCooldown(self:GetAbility():GetEffectiveCooldown(self:GetAbility():GetLevel()))
				EmitSoundOn("DOTA_Item.HeavensHalberd.Activate", target)
			end
		end
	end
end
---------------------------------------------------------------------
-- Modifiers

modifier_kobold_disarm_ad_debuff = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return true end,
IsDebuff                = function(self) return true end,
IsBuff                  = function(self) return false end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_kobold_disarm_ad_debuff:OnCreated(params)
    if IsServer() then
    end
end
function modifier_kobold_disarm_ad_debuff:CheckState() 
    return {
            [MODIFIER_STATE_DISARMED] =true,
         }
end
function modifier_kobold_disarm_ad_debuff:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_kobold_disarm_ad_debuff:OnDestroy()
    if IsServer() then
    end
end
function modifier_kobold_disarm_ad_debuff:DeclareFunctions()
    return {}
end


function modifier_kobold_disarm_ad_debuff:GetEffectName()
	return "particles/generic_gameplay/generic_disarm.vpcf"
end

function modifier_kobold_disarm_ad_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end