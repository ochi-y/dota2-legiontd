LinkLuaModifier("modifier_foulfell_broodmother_spawn_spiderite", "ability/foulfell_broodmother_spawn_spiderite.lua",
	LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_foulfell_broodmother_spawn_spiderite_debuff",
	"ability/foulfell_broodmother_spawn_spiderite.lua",
	LUA_MODIFIER_MOTION_NONE)
--Abilities
if foulfell_broodmother_spawn_spiderite == nil then
	foulfell_broodmother_spawn_spiderite = class({})
end
function foulfell_broodmother_spawn_spiderite:GetIntrinsicModifierName()
	return "modifier_foulfell_broodmother_spawn_spiderite"
end

-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_foulfell_broodmother_spawn_spiderite = class({
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
function modifier_foulfell_broodmother_spawn_spiderite:AllowIllusionDuplicate()
	return false
end

function modifier_foulfell_broodmother_spawn_spiderite:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.spiderite_duration = ability:GetSpecialValueFor("spiderite_duration")
	self.buff_duration = ability:GetSpecialValueFor("buff_duration")
	if not IsServer() then return end
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true)
end

function modifier_foulfell_broodmother_spawn_spiderite:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_foulfell_broodmother_spawn_spiderite:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,

	}
end

function modifier_foulfell_broodmother_spawn_spiderite:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target
	local parent = self:GetParent()
	local ability = self:GetAbility()
	--
	if not IsActiveUnit(ability.spawnUnit) then
		target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_foulfell_broodmother_spawn_spiderite_debuff",
			{
				duration = self.buff_duration
			})
	end
end

function modifier_foulfell_broodmother_spawn_spiderite:CheckState()
	local state = {
	}

	return state
end

-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_foulfell_broodmother_spawn_spiderite_debuff = class({
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
function modifier_foulfell_broodmother_spawn_spiderite_debuff:AllowIllusionDuplicate()
	return false
end

function modifier_foulfell_broodmother_spawn_spiderite_debuff:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	if not IsServer() then return end
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true)
end

function modifier_foulfell_broodmother_spawn_spiderite_debuff:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_foulfell_broodmother_spawn_spiderite_debuff:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH
	}
end

function modifier_foulfell_broodmother_spawn_spiderite_debuff:CheckState()
	local state = {
	}
	return state
end

function modifier_foulfell_broodmother_spawn_spiderite_debuff:OnDeath(params)
	if not self:GetAbility() then return end
	if not IsServer() then return end
	if params.unit == self:GetParent() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local pid = caster:GetPlayerOwnerID()
		if IsActiveUnit(caster) and  not IsActiveUnit(ability.spawnUnit) then
			EmitSoundOn("Hero_Broodmother.SpawnSpiderlings", caster)
			local points = GenPointsForSummon(parent, 0, 30, 1)
			local newUnit = OnZhaoHuan("foulfell_spiderling_spawn", caster, points[1], caster:GetTeamNumber(), 40, 1,
				"particles/units/heroes/hero_lycan/lycan_summon_wolves_spawn.vpcf")
			local pdata = Player:GetPData(pid)
			ability.spawnUnit = newUnit
			if newUnit and pdata then
				table.insert(pdata.creeps, newUnit)
			end

			local effect=ParticleManager:CreateParticle("particles/units/heroes/hero_broodmother/broodmother_spiderlings_spawn.vpcf", PATTACH_ABSORIGIN, newUnit)
			-- ParticleManager:SetParticleControlEnt(effect, 0, caster, PATTACH_ABSORIGIN_FOLLOW, nil,
			-- caster:GetAbsOrigin(), true)
			-- ParticleManager:SetParticleControl(effect, 1, Vector(500,500,500))
			ParticleManager:ReleaseParticleIndex(effect)

		end
	end
end

function modifier_foulfell_broodmother_spawn_spiderite_debuff:GetEffectName()
	return "particles/units/heroes/hero_broodmother/broodmother_spiderlings_debuff.vpcf"
end

function modifier_foulfell_broodmother_spawn_spiderite_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
