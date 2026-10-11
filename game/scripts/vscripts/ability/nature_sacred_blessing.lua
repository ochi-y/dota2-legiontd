LinkLuaModifier("modifier_nature_sacred_blessing", "ability/nature_sacred_blessing.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if nature_sacred_blessing == nil then
    nature_sacred_blessing = class({})
end
function nature_sacred_blessing:OnProjectileHit_ExtraData(target, location, params)
    if not target then
        return
    end
	local heal=self:GetSpecialValueFor("heal")

	-- if not IsActiveUnit(self:GetCaster()) then
	-- 	heal=150
	-- end
	--EmitSoundOn("Hero_Treant.LeechSeed.Target",target)
    -- target:Heal(heal, self)

    target:HealWithParams(heal, self, false, true,self:GetCaster() , false)

    PopupHealing(target, heal)
end

function nature_sacred_blessing:GetIntrinsicModifierName()
    return "modifier_nature_sacred_blessing"
end
---------------------------------------------------------------------
-- Modifiers
if modifier_nature_sacred_blessing == nil then
    modifier_nature_sacred_blessing = class({})
end
function modifier_nature_sacred_blessing:IsHidden()
    return true
end
function modifier_nature_sacred_blessing:OnCreated(params)
    if not self:GetAbility() then return end
    local ability=self:GetAbility()
    self.heal_count=ability:GetSpecialValueFor("heal_count")
    self.heal_cooldown=ability:GetSpecialValueFor("heal_cooldown")
    

    if IsServer() then
        self:StartIntervalThink(self.heal_cooldown)
    end
end
function modifier_nature_sacred_blessing:IsPurgable(params)
    return false
end
function modifier_nature_sacred_blessing:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_nature_sacred_blessing:OnDestroy()
    if IsServer() then
    end
end
function modifier_nature_sacred_blessing:DeclareFunctions()
    return {}
end
function modifier_nature_sacred_blessing:OnIntervalThink()
    if IsServer() then
        if IsCustomBuilding(self:GetParent()) then
            return
        end
        if not IsActiveUnit(self:GetParent()) then
            return
        end
        self:DoHeal(self.heal_count)
    end
end

function modifier_nature_sacred_blessing:DoHeal(count)
    if IsServer() then
        local caster = self:GetParent()
        local ability=self:GetAbility()
        EmitSoundOn("Hero_Treant.LeechSeed.Cast", caster)
		-- SimplePlayEffOnUnit(caster,"particles/units/heroes/hero_treant/treant_leech_seed.vpcf")


        -- local units = SimpleFindFriend(caster:GetTeamNumber(), caster:GetAbsOrigin(), 700)

        local units=FindAbilityTarget(ability,caster:GetAbsOrigin(),ability:GetSpecialValueFor("radius"),{})

        
        stableSort(units, function(a, b)
            return a:GetHealthPercent() < b:GetHealthPercent()
        end)

        -- table.sort(units,function (a, b)
		-- 	return a:GetHealthPercent()<b:GetHealthPercent()
		-- end)

		local c = 0
        for key, unit in pairs(units) do
			SimpleTrackingProjectile(self:GetAbility(), caster, unit,
				"particles/units/heroes/hero_treant/treant_leech_seed_projectile.vpcf", 400)
			c = c + 1
			if c >= count then
				break
			end
        end
    end
end


