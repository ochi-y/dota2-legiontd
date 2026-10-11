LinkLuaModifier( "modifier_nature_entangle_debuff", "ability/nature_entangle.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_nature_entangle_debuff_tag", "ability/nature_entangle.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if nature_entangle == nil then
	nature_entangle = class({})
end
function nature_entangle:OnSpellStart()
	if not IsServer() then return end
	self.duration=self:GetSpecialValueFor("duration")
	local caster=self:GetCaster()
	local target=self:GetCursorTarget()
	local duration=self.duration
	duration = duration * (1 - CalUnitStatusResistance(target))
	-- 
	local units=SimpleFindEnemy(caster:GetTeamNumber(), target:GetAbsOrigin(), 500,FIND_CLOSEST)
	self.count=1
	local count=self.count
	local c=count-1
	-- 
	for i = 1,#units, 1 do
		local enemy=units[i]
		if c<=0 then
			break
		end
		if not enemy:HasModifier("modifier_nature_entangle_debuff_tag") and enemy~=self:GetCursorTarget() then
			enemy:AddNewModifier(caster,self,"modifier_nature_entangle_debuff",{duration=duration})
			c=c-1
		end
	end
	-- 
	target:AddNewModifier(caster,self,"modifier_nature_entangle_debuff",{duration=duration})

	-- PlayEffOnUnit("particles/units/heroes/hero_treant/treant_overgrowth_trails.vpcf",caster,{
	-- 	cpUnit = {
    --         [1] = {target, PATTACH_POINT_FOLLOW, ""}
    --     }
	-- })
	EmitSoundOn("Hero_Treant.NaturesGrasp.Spawn", target)
end

---------------------------------------------------------------------
--Modifiers
if modifier_nature_entangle_debuff == nil then
	modifier_nature_entangle_debuff = class({})
end
function modifier_nature_entangle_debuff:OnCreated(params)
	if not IsServer() then return end
	local ability=self:GetAbility()
	self.damage=ability:GetSpecialValueFor("damage")
	
	self:StartIntervalThink( 1 )
end

function modifier_nature_entangle_debuff:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_nature_entangle_debuff:OnIntervalThink()
	if not IsServer() then return end
	SimpleApplyDamage(self:GetAbility(),self:GetCaster(),self:GetParent(),self.damage)
end
function modifier_nature_entangle_debuff:OnDestroy()
	if IsServer() then
	end
end
function modifier_nature_entangle_debuff:DeclareFunctions()
	return {
	}
end
function modifier_nature_entangle_debuff:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		-- [MODIFIER_STATE_DISARMED]=true
	}
end

function modifier_nature_entangle_debuff:GetEffectName()
	return "particles/units/heroes/hero_treant/treant_overgrowth_vines.vpcf"
end

function modifier_nature_entangle_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

modifier_nature_entangle_debuff_tag = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
