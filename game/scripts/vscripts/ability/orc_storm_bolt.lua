LinkLuaModifier( "modifier_orc_storm_bolt_tag", "ability/orc_storm_bolt.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if orc_storm_bolt == nil then
	orc_storm_bolt = class({})
end

function orc_storm_bolt:OnSpellStart()
	-- 
	local ability=self
	self.damage=ability:GetSpecialValueFor("damage")
	self.duration=ability:GetSpecialValueFor("duration")
	-- 
	local eff="particles/units/heroes/hero_sven/sven_spell_storm_bolt.vpcf"

	local caster=self:GetCaster()

	local target=self:GetCursorTarget()


	local units=FindAbilityTarget(self,target:GetAbsOrigin(),500,{})

	local count=1
	
	TableRemoveByValue(units,target)
	
	AiOrderByNoModifier(units,"modifier_orc_storm_bolt_tag", false)

	for i = 1, count-1, 1 do
		if units[i] then
			SimpleTrackingProjectile(self, self:GetCaster(), units[i], eff, 1000)
		end
	end


	SimpleTrackingProjectile(self, self:GetCaster(), target, eff, 1000)
	EmitSoundOn( "Hero_Sven.StormBolt", self:GetCaster() )
end

function orc_storm_bolt:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) and ( not hTarget:TriggerSpellAbsorb( self ) ) then
		EmitSoundOn( "Hero_Sven.StormBoltImpact", hTarget )
		SimpleApplyDamage(self,self:GetCaster(),hTarget,self.damage)
		local duration=self.duration

		duration = duration * (1 - CalUnitStatusResistance(hTarget))
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration=duration})
	end
	return true
end

-------------------------------------------------------------------------------------------------------
modifier_orc_storm_bolt_tag = class({
	IsHidden = function(self)
		return true
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
function modifier_orc_storm_bolt_tag:AllowIllusionDuplicate()
	return false
end
function modifier_orc_storm_bolt_tag:OnCreated(params)
end
function modifier_orc_storm_bolt_tag:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_orc_storm_bolt_tag:DeclareFunctions()
	return {

	}
end
