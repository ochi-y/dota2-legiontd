
LinkLuaModifier( "modifier_nature_aftershock", "ability/nature_aftershock.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_nature_aftershock_debuff", "ability/nature_aftershock.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if nature_aftershock == nil then
	nature_aftershock = class({})
end
function nature_aftershock:GetIntrinsicModifierName()
	return "modifier_nature_aftershock"
end
---------------------------------------------------------------------
--Modifiers
if modifier_nature_aftershock == nil then
	modifier_nature_aftershock = class({

	})
end
function modifier_nature_aftershock:IsPurgable(params)
	return false
end
function modifier_nature_aftershock:IsHidden()
	return true
end
function modifier_nature_aftershock:OnCreated(params)
	if not self:GetAbility() then return end
	if IsServer() then
	end
	local ability=self:GetAbility()
	self.damage=ability:GetSpecialValueFor("damage")
end
function modifier_nature_aftershock:OnRefresh(params)
	if IsServer() then
	end
	self:OnCreated()
end

function modifier_nature_aftershock:OnDestroy()
	if IsServer() then
	end
end

function modifier_nature_aftershock:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK
	}
end

function modifier_nature_aftershock:OnAttack(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target
	local attacker =params.attacker
	local caster=attacker
	local ability=self:GetAbility()

	local units=SimpleFindEnemy(caster:GetTeamNumber(), target:GetAbsOrigin(), 400,FIND_CLOSEST)


	TableRemoveByValue(units,target)

	local count=1

	for i = 1, count, 1 do
		local unit=units[i]
		if unit and unit~=target then
			EmitSoundOn("Hero_Zuus.ArcLightning.Target", unit)
			SimplePlayLink("particles/econ/events/ti7/maelstorm_ti7.vpcf",attacker,unit,nil,nil,"attach_attack1")
			SimplePlayEffOnUnit(unit,"particles/units/heroes/hero_zuus/zuus_arc_lightning_impact_b.vpcf")
			SimpleApplyDamage(self:GetAbility(),attacker,unit,self.damage)
		end
	end

end
