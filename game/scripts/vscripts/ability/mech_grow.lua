if mech_grow == nil then mech_grow = class({}) end

LinkLuaModifier("modifier_mech_grow", "ability/mech_grow", LUA_MODIFIER_MOTION_NONE) --- PATH WERY IMPORTANT

local banana

function mech_grow:GetIntrinsicModifierName()
	if self:GetLevel()>0 then
		return "modifier_mech_grow"
	end
	
end

function mech_grow:GetBehavior()
	local behav = DOTA_ABILITY_BEHAVIOR_PASSIVE
	return behav
end

function mech_grow:OnUpgrade()
	if IsServer() then

		print("OnUpgrade")
		local level_1 = "models/heroes/tiny_02/tiny_02.vmdl"
		local level_2 = "models/heroes/tiny_03/tiny_03.vmdl"
		local level_3 = "models/items/tiny/tiny_prestige/tiny_prestige_lvl_04.vmdl"

		-- UTIL_Remove(self.torso)
		-- UTIL_Remove(self.head)
		-- UTIL_Remove(self.left_arm)
		-- UTIL_Remove(self.rigt_arm)

		-- self:GetCaster():SetOriginalModel(level_3)

		-- self.torso = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_04/tiny_04_body.vmdl"})
		-- self.torso:FollowEntity(self:GetCaster(), true)
		-- self.head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_04/tiny_04_head.vmdl"})
		-- self.head:FollowEntity(self:GetCaster(), true)
		-- self.left_arm = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_04/tiny_04_left_arm.vmdl"})
		-- self.left_arm:FollowEntity(self:GetCaster(), true)
		-- self.rigt_arm = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_04/tiny_04_right_arm.vmdl"})
		-- self.rigt_arm:FollowEntity(self:GetCaster(), true)
	end
end

if modifier_mech_grow == nil then modifier_mech_grow = class({}) end

function modifier_mech_grow:IsHidden()
	return true
end

function modifier_mech_grow:IsPurgable()
	return false
end

function modifier_mech_grow:OnCreated()
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.bonus_armor = ability:GetSpecialValueFor("bonus_armor")
	self.bonus_damage = ability:GetSpecialValueFor("bonus_damage")
	self.attack_speed_reduction = ability:GetSpecialValueFor("attack_speed_reduction")
	
	if not IsServer() then return end
	PlayEffOnUnit("particles/units/heroes/hero_tiny/tiny_transform_lvl4.vpcf",self:GetCaster())
end

function modifier_mech_grow:OnIntervalThink()
	-- if self:GetCaster():GetUnitName() == "npc_dota_hero_tiny" then
	-- 	if self:GetParent():HasScepter() then
	-- 		if banana == nil then
	-- 			banana = SpawnEntityFromTableSynchronous("prop_dynamic",
	-- 				{ model = "models/heroes/tiny_01/tiny_01_tree.vmdl" })
	-- 			banana:FollowEntity(self:GetParent(), true)
	-- 		end
	-- 	else
	-- 		if banana ~= nil then
	-- 			if type(banana) == "table" then
	-- 				UTIL_Remove(banana)
	-- 			end
	-- 		end
	-- 	end
	-- end
end

function modifier_mech_grow:OnDestroy()
	-- if banana ~= nil then
	-- 	if type(banana) == "table" then
	-- 		UTIL_Remove(banana)
	-- 	end
	-- end
end

function modifier_mech_grow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MODEL_CHANGE ,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS 
	}
	return funcs
end

function modifier_mech_grow:GetModifierPhysicalArmorBonus(params)
	return self.bonus_armor
end
function modifier_mech_grow:GetModifierModelChange(params)
	return "models/items/tiny/tiny_prestige/tiny_prestige_lvl_04.vmdl"
end
function modifier_mech_grow:GetModifierPreAttack_BonusDamage(params)
	return self.bonus_damage
end

function modifier_mech_grow:GetModifierAttackSpeedPercentage(params)
	return self.attack_speed_reduction
end
