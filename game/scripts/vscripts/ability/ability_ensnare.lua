LinkLuaModifier( "modifier_ability_ensnare", "ability/ability_ensnare.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ability_ensnare_tag", "ability/ability_ensnare.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
ability_ensnare = class({})

wave_12_champion_ensnare=ability_ensnare

function ability_ensnare:OnAbilityPhaseStart()
	local caster=self:GetCaster()
	local target=self:GetCursorTarget()

	if target:HasModifier("modifier_ability_ensnare_tag") then
		return false
	end
	target:AddNewModifier(caster, self, "modifier_ability_ensnare_tag", {duration=1})
	return true
end
function ability_ensnare:OnSpellStart()
	local caster=self:GetCaster()
	local target=self:GetCursorTarget()
	
	local eff="particles/units/heroes/hero_siren/siren_net_projectile.vpcf"
	local units=SimpleFindEnemy(caster:GetTeamNumber(), target:GetAbsOrigin(), 500,FIND_CLOSEST)
	self.count=self:GetSpecialValueFor("count")

	local count=self.count

	local c=count
	for i = 1,#units, 1 do
		local enemy=units[i]
		if not enemy:HasModifier("modifier_ability_ensnare_tag") and enemy~=self:GetCursorTarget() then
			SimpleTrackingProjectile(self, self:GetCaster(), enemy, eff, 1500)
			EmitSoundOn( "Hero_NagaSiren.Ensnare.Cast",enemy )
			c=c-1
			if c==0 then
				break
			end
		end
	end
	SimpleTrackingProjectile(self, self:GetCaster(), self:GetCursorTarget(), eff, 1500)
	EmitSoundOn( "Hero_NagaSiren.Ensnare.Cast", self:GetCaster() )
	
	return true
end
function ability_ensnare:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) and ( not hTarget:TriggerSpellAbsorb( self ) ) then
		EmitSoundOn( "Hero_NagaSiren.Ensnare.Target", hTarget )
		local caster=self:GetCaster()
		--
		if hTarget:HasFlyMovementCapability() then
			SimpleMoveUnit(hTarget,caster:GetAbsOrigin()+(caster:GetForwardVector():Normalized()*60))
		end
		local duration=self:GetSpecialValueFor("duration")
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_ability_ensnare", {duration=duration})
	end
	return true
end
---------------------------------------------------------------------
--Modifiers
modifier_ability_ensnare_tag = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
---------------------------------------------------------------------
--Modifiers
if modifier_ability_ensnare == nil then
	modifier_ability_ensnare = class({})
end
function modifier_ability_ensnare:OnCreated(params)
	if IsServer() then
	end
end
function modifier_ability_ensnare:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ability_ensnare:OnDestroy()
	if IsServer() then
	end
end
function modifier_ability_ensnare:DeclareFunctions()
	return {
	}
end
function modifier_ability_ensnare:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_FLYING] = false,
	}
end

function modifier_ability_ensnare:GetEffectName()
	return "particles/units/heroes/hero_siren/siren_net_main.vpcf"
end

function modifier_ability_ensnare:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
