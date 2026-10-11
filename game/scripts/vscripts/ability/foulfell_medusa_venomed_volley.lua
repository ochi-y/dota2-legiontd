LinkLuaModifier( "modifier_foulfell_medusa_venomed_volley", "ability/foulfell_medusa_venomed_volley.lua", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_foulfell_medusa_venomed_volley_buff", "ability/foulfell_medusa_venomed_volley.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_foulfell_medusa_venomed_volley_debuff", "ability/foulfell_medusa_venomed_volley.lua", LUA_MODIFIER_MOTION_NONE )

--Abilities
if foulfell_medusa_venomed_volley == nil then
	foulfell_medusa_venomed_volley = class({})
end
function foulfell_medusa_venomed_volley:GetIntrinsicModifierName()
	return "modifier_foulfell_medusa_venomed_volley"
end

-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_foulfell_medusa_venomed_volley = class({
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
function modifier_foulfell_medusa_venomed_volley:AllowIllusionDuplicate()
	return false
end
function modifier_foulfell_medusa_venomed_volley:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.attack_count=ability:GetSpecialValueFor("attack_count")
	self.duration=ability:GetSpecialValueFor("duration")
	if not IsServer() then return end
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true) 
	self.attackRecords={}
end
function modifier_foulfell_medusa_venomed_volley:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_foulfell_medusa_venomed_volley:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
		MODIFIER_PROPERTY_PROJECTILE_NAME ,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND ,
		MODIFIER_EVENT_ON_ATTACK_LANDED 
	}
end

function modifier_foulfell_medusa_venomed_volley:OnAttackLanded(params)

	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end

	if self.attackRecords[params.record] then
		local caster= self:GetCaster()
		params.target: AddNewModifier(caster, self:GetAbility(), "modifier_foulfell_medusa_venomed_volley_debuff", {
			duration = self.duration
		})
	end
end

function modifier_foulfell_medusa_venomed_volley:GetAttackSound(params)
	-- if self:GetStackCount()== self.attack_count then
	-- 	return 
	-- end
end
function modifier_foulfell_medusa_venomed_volley:GetModifierProjectileName(params)
	if self:GetStackCount()== self.attack_count-1 then
		return "particles/units/heroes/hero_medusa/medusa_venom_arrow.vpcf"
	end
end

function modifier_foulfell_medusa_venomed_volley:OnAttackRecordDestroy(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	
	self.attackRecords[params.record]= nil
end

function modifier_foulfell_medusa_venomed_volley:OnAttack(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local caster=self:GetParent()
	local mod=caster:FindModifierByName("modifier_foulfell_medusa_venomed_volley")
	-- PrintTable(params)

	if mod then
		local c=mod:GetStackCount()
		if c>= self.attack_count-1 then
			-- EmitSoundOn("Hero_Slardar.Bash", params.target)
			-- local duration=self.stun
			-- duration = duration * (1 - CalUnitStatusResistance(params.target))
			-- params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = duration})
			self.attackRecords[params.record] = true
			EmitSoundOn("Hero_Medusa.Attack.VenomousVolley", caster)
			mod:SetStackCount(0)
		else
			mod:SetStackCount(mod:GetStackCount()+1)
			-- if mod:GetStackCount() == (self.attack_count-1) then
			-- 	caster:AddNewModifier(caster, self:GetAbility(), "modifier_foulfell_medusa_venomed_volley_buff", hModifierTable)
			-- end
		end
	end
end

function modifier_foulfell_medusa_venomed_volley:CheckState()
	local state = {
	}
	return state
end


-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_foulfell_medusa_venomed_volley_debuff = class({
	IsHidden = function(self)
		return false
	end,
	IsPurgable = function(self)
		return false
	end,
	IsDebuff = function(self)
		return true
	end,
	IsBuff = function(self)
		return false
	end,
	RemoveOnDeath = function(self)
		return true
	end,
	GetAttributes = function(self)
		return MODIFIER_ATTRIBUTE_NONE
	end
})
function modifier_foulfell_medusa_venomed_volley_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_foulfell_medusa_venomed_volley_debuff:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.move_slow=ability:GetSpecialValueFor("move_slow")
	self.attack_slow=ability:GetSpecialValueFor("attack_slow")
	if not IsServer() then return end
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true) 
end
function modifier_foulfell_medusa_venomed_volley_debuff:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_foulfell_medusa_venomed_volley_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE 

	}
end

function modifier_foulfell_medusa_venomed_volley_debuff:GetModifierMoveSpeedBonus_Percentage()
	return - self.move_slow
end
function modifier_foulfell_medusa_venomed_volley_debuff:GetModifierAttackSpeedPercentage()
	return - self.attack_slow
end

function modifier_foulfell_medusa_venomed_volley_debuff:CheckState()
	local state = {
	}
	return state
end

function modifier_foulfell_medusa_venomed_volley_debuff:GetEffectName()
	return "particles/units/heroes/hero_venomancer/venomancer_gale_poison_debuff.vpcf"
end
function modifier_foulfell_medusa_venomed_volley_debuff:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end
