LinkLuaModifier( "modifier_beast_chain_lightning", "ability/beast_chain_lightning", LUA_MODIFIER_MOTION_NONE )


local function playuArc(OldTarget,target)
	local fx = ParticleManager:CreateParticle("particles/neutral_fx/harpy_chain_lightning_head.vpcf", PATTACH_ABSORIGIN_FOLLOW, OldTarget)
    ParticleManager:SetParticleControlEnt(fx, 0, OldTarget, PATTACH_POINT_FOLLOW, "attach_attack1", OldTarget:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(fx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(fx)
end

--Abilities
if beast_chain_lightning == nil then
	beast_chain_lightning = class({})
end

function beast_chain_lightning:OnSpellStart()
	local caster = self:GetCaster()
    local targetPos = self:GetCursorPosition()
	local target=SimpleFindOneClosestEnemy(caster:GetTeamNumber(),targetPos,500)
	if target then
		EmitSoundOn("n_creep_HarpyStorm.ChainLighting", caster)
		caster:AddNewModifier(caster, self, "modifier_beast_chain_lightning", {
			startUnitEntIndex  = target:entindex(),duration=3
		})
	end
end
---------------------------------------------------------------------
--Modifiers


modifier_beast_chain_lightning = class({
	IsHidden                = function(self) return true end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return true end,
	IsBuff                  = function(self) return false end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
})

function modifier_beast_chain_lightning:OnCreated(params)
	if not self:GetAbility() then return end
	
	if not IsServer() then
		return
	end

	local ability=self:GetAbility()
	self.jump_count=ability:GetSpecialValueFor("max_targets")
	self.damage_reduction=ability:GetSpecialValueFor("damage_percent_loss")
	self.count=0
	self.delay = 0.1
    self.radius = 500
    self.damage = ability:GetSpecialValueFor("initial_damage")
	
	if params.startUnitEntIndex then
		self.actual_unit = EntIndexToHScript(params.startUnitEntIndex)
		if self.actual_unit then
			self.affected_units = {}
			self:CreateArcLightning(self.actual_unit)
			self:StartIntervalThink(0.1)
		end
	end
end
function modifier_beast_chain_lightning:OnRefresh(params)
self:OnCreated(params)
end
function modifier_beast_chain_lightning:OnDestroy()
	if IsServer() then
	end
end
function modifier_beast_chain_lightning:DeclareFunctions()
	return {
	}
end
function modifier_beast_chain_lightning:OnIntervalThink()
	if not IsServer() then
		return
	end
    local caster = self:GetCaster()
	local all=SimpleFindEnemy(caster:GetTeamNumber(),self.actual_unit:GetAbsOrigin(),self.radius,FIND_CLOSEST)
	local old_actual_unit = self.actual_unit
    for _, unit in ipairs(all) do
        if not TableContainsValue(self.affected_units, unit) then
            unit:EmitSound("n_creep_HarpyStorm.ChainLighting")
            self:CreateArcLightning(unit)
            break
        end
    end
    if old_actual_unit == self.actual_unit or self.count >= self.jump_count then
        self:Destroy()
    end
end



function modifier_beast_chain_lightning:CreateArcLightning(target)
	if not IsServer() then
		return
	end
	self.count = self.count + 1
    local caster = self:GetCaster()
    local OldTarget = self.actual_unit
    if self.count == 1 then
        OldTarget = caster
    end
	playuArc(OldTarget,target)
    local field = caster:FindAbilityByName("ability_zuus_static_field")
    if field then field:ApplyStaticField(target) end
    
	
    ApplyDamage({
        victim = target,
        attacker = caster,
        damage = self.damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility()
    })
    self.actual_unit = target
	self.damage=self.damage*(100-self.damage_reduction)/100
    table.insert(self.affected_units, target)
end