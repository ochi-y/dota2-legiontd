LinkLuaModifier("modifier_goblin_side_gunner", "ability/goblin_side_gunner.lua", LUA_MODIFIER_MOTION_NONE)

if goblin_side_gunner == nil then
	goblin_side_gunner = class({})
end

function goblin_side_gunner:GetIntrinsicModifierName()
	return "modifier_goblin_side_gunner"
end

modifier_goblin_side_gunner = class({
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
function modifier_goblin_side_gunner:AllowIllusionDuplicate()
	return false
end

function modifier_goblin_side_gunner:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.fire_rate = ability:GetSpecialValueFor("fire_rate")
	self.scepter_radius = ability:GetSpecialValueFor("scepter_radius")
	if not IsServer() then return end
	self:StartIntervalThink(self.fire_rate)
end


function modifier_goblin_side_gunner:OnIntervalThink(params)
	if not IsServer() then
		return
	end



	local hParent = self:GetParent()
	local hAbility = self:GetAbility()

	if (not hParent) or hParent:IsNull() then
		return
	end

	if (not hAbility) or hAbility:IsNull() then
		return
	end

	local enemies = FindUnitsInRadius(
		hParent:GetTeamNumber(),
		hParent:GetAbsOrigin(),
		nil,
		self.scepter_radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		FIND_FARTHEST,
		false
	)
	-- attack the farthest enemy
	if #enemies > 0 then
		local hEnemy = enemies[1]
		if not hEnemy or hEnemy:IsNull() then return end
		if hEnemy:IsAttackImmune() or hEnemy:IsInvulnerable() then return end
		if not hEnemy:IsAlive() then return end
		hParent:PerformAttack(hEnemy, false, false, true, false, true, false, false)
	end
end

function modifier_goblin_side_gunner:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_goblin_side_gunner:DeclareFunctions()
	return {

	}
end
