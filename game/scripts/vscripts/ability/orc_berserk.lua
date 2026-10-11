LinkLuaModifier("modifier_orc_berserk", "ability/orc_berserk.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if orc_berserk == nil then
	orc_berserk = class({})
end
function orc_berserk:GetIntrinsicModifierName()
	return "modifier_orc_berserk"
end

---------------------------------------------------------------------
--Modifiers
if modifier_orc_berserk == nil then
	modifier_orc_berserk = class({})
end
function modifier_orc_berserk:OnCreated(params)
	if not self:GetAbility() then return end

	local ability = self:GetAbility()
	self.max_attack_speed = ability:GetSpecialValueFor("max_attack_speed")
	self.max_move_speed = ability:GetSpecialValueFor("max_move_speed")
	if not IsServer() then return end
	-- self.attack_speed_1=ability:GetSpecialValueFor("attack_speed_1")
	-- self.attack_speed_2=ability:GetSpecialValueFor("attack_speed_2")
	-- self.attack_speed_3=ability:GetSpecialValueFor("attack_speed_3")

	-- self.move_speed_1=ability:GetSpecialValueFor("move_speed_1")
	-- self.move_speed_2=ability:GetSpecialValueFor("move_speed_2")
	-- self.move_speed_3=ability:GetSpecialValueFor("move_speed_3")
end

function modifier_orc_berserk:OnRefresh(params)

end

function modifier_orc_berserk:OnDestroy()
	if IsServer() then
	end
end

function modifier_orc_berserk:IsPurgable(params)
	return false
end

function modifier_orc_berserk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_orc_berserk:GetModifierAttackSpeedPercentage()
	-- interpolate missing health
	local pct = self:GetParent():GetHealthPercent()

	return math.ceil(self.max_attack_speed*(100 - pct) / 100)

	-- local res=0
	-- pct=pct/100
	-- if pct<=0.6 then
	-- 	res=self.attack_speed_1
	-- end
	-- if pct<=0.4 then
	-- 	res=self.attack_speed_2
	-- end
	-- if pct<=0.2 then
	-- 	res=self.attack_speed_3
	-- end
	-- return res
end

function modifier_orc_berserk:GetModifierMoveSpeedBonus_Percentage()
	local pct = self:GetParent():GetHealthPercent()

	return math.ceil(self.max_move_speed*(100 - pct) / 100)
	-- local res=0
	-- pct=pct/100
	-- if pct<=0.6 then
	-- 	res=self.move_speed_1
	-- end
	-- if pct<=0.4 then
	-- 	res=self.move_speed_2
	-- end
	-- if pct<=0.2 then
	-- 	res=self.move_speed_3
	-- end
	-- return res
end

function modifier_orc_berserk:GetModifierModelScale()
	local pct = self:GetParent():GetHealthPercent()
	return math.ceil(30*(100 - pct) / 100)
	-- local res = 0
	-- pct = pct / 100
	-- if pct <= 0.6 then
	-- 	res = 20
	-- end
	-- if pct <= 0.4 then
	-- 	res = 40
	-- end
	-- if pct <= 0.2 then
	-- 	res = 60
	-- end
	-- return res
end
