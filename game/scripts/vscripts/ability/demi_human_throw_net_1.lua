LinkLuaModifier( "modifier_demi_human_throw_net_1", "ability/demi_human_throw_net_1.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_demi_human_throw_net_1_tag", "ability/demi_human_throw_net_1.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if demi_human_throw_net_1 == nil then
	demi_human_throw_net_1 = class({})
end

function demi_human_throw_net_1:OnAbilityPhaseStart()
	local caster=self:GetCaster()
	local target=self:GetCursorTarget()

	if target:HasModifier("modifier_demi_human_throw_net_1_tag") then
		return false
	end
	target:AddNewModifier(caster, self, "modifier_demi_human_throw_net_1_tag", {duration=1})
	return true
end
function demi_human_throw_net_1:OnSpellStart()
	local caster=self:GetCaster()
	local target=self:GetCursorTarget()
	
	local eff="particles/neutral_fx/dark_troll_ensnare_proj.vpcf"
	local units=SimpleFindEnemy(caster:GetTeamNumber(), target:GetAbsOrigin(), 500,FIND_CLOSEST)
	self.count=self:GetSpecialValueFor("count")

	local count=self.count

	local c=count
	for i = 1,#units, 1 do
		local enemy=units[i]
		if not enemy:HasModifier("modifier_demi_human_throw_net_1_tag") and enemy~=self:GetCursorTarget() then
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
function demi_human_throw_net_1:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) and ( not hTarget:TriggerSpellAbsorb( self ) ) then
		EmitSoundOn( "Hero_NagaSiren.Ensnare.Target", hTarget )
		local caster=self:GetCaster()
		--
		if hTarget:HasFlyMovementCapability() then
			SimpleMoveUnit(hTarget,caster:GetAbsOrigin()+(caster:GetForwardVector():Normalized()*60))
		end
		local duration=self:GetSpecialValueFor("duration")
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_demi_human_throw_net_1", {duration=duration})
	end
	return true
end
---------------------------------------------------------------------
--Modifiers
modifier_demi_human_throw_net_1_tag = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
---------------------------------------------------------------------
--Modifiers
if modifier_demi_human_throw_net_1 == nil then
	modifier_demi_human_throw_net_1 = class({})
end
function modifier_demi_human_throw_net_1:OnCreated(params)
	if IsServer() then
	end
end
function modifier_demi_human_throw_net_1:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_demi_human_throw_net_1:OnDestroy()
	if IsServer() then
	end
end
function modifier_demi_human_throw_net_1:DeclareFunctions()
	return {
	}
end
function modifier_demi_human_throw_net_1:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_FLYING] = false,
	}
end

function modifier_demi_human_throw_net_1:GetEffectName()
	return "particles/neutral_fx/dark_troll_ensnare.vpcf"
end

function modifier_demi_human_throw_net_1:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
