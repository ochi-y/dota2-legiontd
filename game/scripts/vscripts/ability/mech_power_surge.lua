LinkLuaModifier( "modifier_mech_power_surge", "ability/mech_power_surge.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if mech_power_surge == nil then
	mech_power_surge = class({})
end
function mech_power_surge:GetIntrinsicModifierName()
	return "modifier_mech_power_surge"
end
---------------------------------------------------------------------
--Modifiers
if modifier_mech_power_surge == nil then
	modifier_mech_power_surge = class({})
end
function modifier_mech_power_surge:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.damage=ability:GetSpecialValueFor("damage")
	self.mana_per_hit=ability:GetSpecialValueFor("mana_per_hit")
	self.mana_cost=ability:GetSpecialValueFor("mana_cost")
	if IsServer() then
	end
end
function modifier_mech_power_surge:IsPurgable(params)
	return false
end
function modifier_mech_power_surge:IsHidden(params)
	return true
end
function modifier_mech_power_surge:OnRefresh(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.damage=ability:GetSpecialValueFor("damage")
	self.mana_per_hit=ability:GetSpecialValueFor("mana_per_hit")
	self.mana_cost=ability:GetSpecialValueFor("mana_cost")
end
function modifier_mech_power_surge:OnDestroy()
	if IsServer() then
	end
end
function modifier_mech_power_surge:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_mech_power_surge:OnAttackStart(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if not (params.attacker:GetMaxMana()>0) then
		return
	end
    local caster=self:GetParent()
	local mana=self.mana_per_hit
	caster:GiveMana(mana)
	--SimpleOverheadMsg(caster,OVERHEAD_ALERT_MANA_ADD,mana)
end


function modifier_mech_power_surge:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end

	local target = params.target
	
	if target:IsMagicImmune() then
		return
	end
	local caster=self:GetParent()

	if caster:GetMana()>=self.mana_cost then
		SimpleApplyDamage(self:GetAbility(),caster,target,self.damage)
		EmitSoundOn("Hero_Zuus.ArcLightning.Target",target)
		SimplePlayLink("particles/items_fx/chain_lightning.vpcf",caster,target,PATTACH_POINT_FOLLOW,PATTACH_ROOTBONE_FOLLOW,"attach_attack1",nil)
		caster:SpendMana(self.mana_cost, self:GetAbility())
		SimplePlayEffOnUnit(target,"particles/units/heroes/hero_zuus/zuus_arc_lightning_impact.vpcf")

		local duration = 0.1
		local knockbackProperties =
		{
			center_x = caster:GetAbsOrigin().x,
			center_y = caster:GetAbsOrigin().y,
			center_z = caster:GetAbsOrigin().z,
			duration = duration,
			knockback_duration = duration,
			knockback_distance = 50,
			knockback_height = 0,
			should_stun = false
		}

		target:AddNewModifier(caster, self:GetAbility(), "modifier_knockback", knockbackProperties)

	end
end