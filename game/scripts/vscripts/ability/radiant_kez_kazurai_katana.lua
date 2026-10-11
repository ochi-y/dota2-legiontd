LinkLuaModifier( "modifier_radiant_kez_kazurai_katana", "ability/radiant_kez_kazurai_katana.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_radiant_kez_kazurai_katana_damage_fix", "ability/radiant_kez_kazurai_katana.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if radiant_kez_kazurai_katana == nil then
	radiant_kez_kazurai_katana = class({})
end
function radiant_kez_kazurai_katana:OnSpellStart()
	local caster= self:GetCaster()
	-- local target = self:GetCursorTarget()

	local targetPos= self:GetCursorPosition()

	local dir = (targetPos-caster:GetAbsOrigin()):Normalized()

	EmitSoundOn("Hero_Kez.Katana.Impale.Start", caster)
	local effect=ParticleManager:CreateParticle("particles/units/heroes/hero_kez/kez_katana_impale.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(effect, 0, caster, PATTACH_POINT, "attach_weapon",
	caster:GetAbsOrigin(), true)
	-- ParticleManager:SetParticleControl(effect, 0, Vector(0,0,80)+caster:GetAbsOrigin()+ 150*caster:GetForwardVector() )

	-- ParticleManager:SetParticleControl(effect, 0, Vector(0,0,200) )
	ParticleManager:SetParticleControlForward( effect, 1, (-1)*dir )
	-- local dir= (caster:GetAbsOrigin()- caster:GetAbsOrigin()):Normalized()
	-- ParticleManager:SetParticleControlForward( effect, 1, -1*dir)
	ParticleManager:ReleaseParticleIndex(effect)
	
	local endPos = caster:GetAbsOrigin()+375*dir
	
	local units = FindUnitsInLine(caster:GetTeamNumber(), caster:GetAbsOrigin(), endPos, nil
	, 75, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_CREEP+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)


	for index, unit in ipairs(units) do
		if unit:HasFlyMovementCapability() then
			caster:AddNewModifier(caster, self, "modifier_radiant_kez_kazurai_katana_damage_fix", {})
			SimplePerformAttack(caster, unit, true, true, false)
			caster:RemoveModifierByName("modifier_radiant_kez_kazurai_katana_damage_fix")
		else
			SimplePerformAttack(caster, unit, true, true, false)
		end
		
	end
end

-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_radiant_kez_kazurai_katana_damage_fix = class({
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
function modifier_radiant_kez_kazurai_katana_damage_fix:AllowIllusionDuplicate()
	return false
end
function modifier_radiant_kez_kazurai_katana_damage_fix:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()

	local ability=self:GetAbility()
	self.air_pct=ability:GetSpecialValueFor("air_pct")
	
	if not IsServer() then return end
end
function modifier_radiant_kez_kazurai_katana_damage_fix:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_radiant_kez_kazurai_katana_damage_fix:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
	}	
end

function modifier_radiant_kez_kazurai_katana_damage_fix:GetModifierDamageOutgoing_Percentage()
	return -self.air_pct
end

function modifier_radiant_kez_kazurai_katana_damage_fix:CheckState()
	local state = {
	}
	return state
end

