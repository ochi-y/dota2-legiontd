mech_tree_grap = class({})
LinkLuaModifier("modifier_mech_tree_grap", "ability/mech_tree_grap.lua", LUA_MODIFIER_MOTION_NONE)

--function mech_tree_grap:GetBehaviorInt( ... )

--end
wave_11_champion_tree_grap=mech_tree_grap

function mech_tree_grap:Spawn()
    if not IsServer() then
        return
    end
    Timers:CreateTimer(FrameTime(),function ()
        local caster=self:GetCaster()
        local meta=GamePlay:FighterGetMeta(caster.fighterId)
        if meta then
            if meta.age==0 then
                if self:GetAutoCastState() then
                    self:ToggleAutoCast()    
                end    
            else
                if meta.abilityAutocastMap[self:GetAbilityName()]~=self:GetAutoCastState() then
                    self:ToggleAutoCast()
                end
            end
        end
    end)
end

function mech_tree_grap:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_mech_tree_grap") then
        SendErrorMessage(caster:GetPlayerOwnerID(), "mech_tree_grap_done")
        return false
    end
	if teckTree:UseResource(caster, self) then
		return true
	end
	return false
end

local treeIndex=1

function mech_tree_grap:OnSpellStart( ... )
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local mod = caster:AddNewModifier(caster, self, "modifier_mech_tree_grap", {})
	--caster:SwapAbilities("mech_tree_grap", "tiny_tree_throw_lua", false, true)

	-- if target.CutDown then
	-- 	target:CutDown(caster:GetTeamNumber())
	-- end
	
	local trees={
		"models/items/tiny/tiny_prestige/tiny_prestige_sword.vmdl",
		"models/items/tiny_01/tiny_haunted_tree.vmdl",
		"models/items/tiny/tiny_bad_to_the_bone_weapon/tiny_bad_to_the_bone_weapon.vmdl",
		"models/items/tiny/scarletquarry_weapon/scarletquarry_weapon.vmdl",
		"models/items/tiny/tiny_anthozoa_giant_weapon/tiny_anthozoa_giant_weapon.vmdl",
		"models/items/tiny/burning_stone_giant_club/burning_stone_giant_club.vmdl",
		"models/heroes/tiny/tiny_01/tiny_tree_proj.vmdl"
	}
	
	local banana = SpawnEntityFromTableSynchronous("prop_dynamic", {model = trees[treeIndex%(#trees)+1]})
	treeIndex=treeIndex+1
	banana:FollowEntity(self:GetCaster(), true)

	mod.treeWeapon=banana

	caster:EmitSound("Hero_Tiny.Tree.Grab")


end

modifier_mech_tree_grap = class({})

function modifier_mech_tree_grap:IsPurgable() return false end
function modifier_mech_tree_grap:RemoveOnDeath() return true end

function modifier_mech_tree_grap:OnCreated( ... )
	local ability = self:GetAbility()

	if not ability or ability:IsNull() then self:Destroy() return end

	self.attack_range_override = ability:GetSpecialValueFor("attack_range")
	self.speed_reduction = -ability:GetSpecialValueFor("speed_reduction")

	self.splash_pct 	= ability:GetSpecialValueFor("splash_pct") / 100.0
	self.splash_width 	= ability:GetSpecialValueFor("splash_width")
	self.splash_range 	= ability:GetSpecialValueFor("splash_range")
	self.bonus_damage 	= ability:GetSpecialValueFor("bonus_damage")

	self.attack_count 	= ability:GetSpecialValueFor("attack_count")


	if not IsServer() then return end

	if self.attack_count>0 then
		self:SetStackCount(self.attack_count)
	end

	self.ability = ability
	self.parent = self:GetParent()
end

function modifier_mech_tree_grap:OnRefresh( ... )
	self:OnCreated()
end

function modifier_mech_tree_grap:OnDestroy( ... )
	if self.treeWeapon and not self.treeWeapon:IsNull() then
		self.treeWeapon:RemoveSelf()
	end
end

function modifier_mech_tree_grap:DeclareFunctions( ... )
	return {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS, -- GetActivityTranslationModifiers
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND, -- GetAttackSound
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK, -- GetModifierProcAttack_Feedback
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, -- GetModifierMoveSpeedBonus_Constant
		MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE, -- GetModifierAttackRangeOverride,
		--MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, -- GetModifierPreAttack_BonusDamage
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL, --GetModifierProcAttack_BonusDamage_Physical
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE
	}
end


function modifier_mech_tree_grap:GetModifierBaseAttack_BonusDamage()
	return self.bonus_damage
end
function modifier_mech_tree_grap:GetActivityTranslationModifiers()
	return "tree"
end

function modifier_mech_tree_grap:GetAttackSound()
	return "Hero_Tiny_Tree.Attack"
end

function modifier_mech_tree_grap:GetModifierMoveSpeedBonus_Constant()
	return self.speed_reduction
end

function modifier_mech_tree_grap:GetModifierAttackRangeOverride()
	return self.attack_range_override
end

function modifier_mech_tree_grap:GetModifierProcAttack_BonusDamage_Physical(params)
	if not IsServer() then return 0 end
	local damage = self.parent:GetAverageTrueAttackDamage(self.parent)
	return 0
end

function modifier_mech_tree_grap:GetModifierProcAttack_Feedback( params )
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local parent = self.parent
	if not parent or parent:IsNull() then return end
	if not params.target or params.target:IsNull() then return end
	if parent:GetTeam() == params.target:GetTeam() then return end

	local ability = self:GetAbility()

	local damage = params.original_damage

	local splash_damage = damage * self.splash_pct

	local target_origin = params.target:GetAbsOrigin()
	local direction = (target_origin - parent:GetAbsOrigin()):Normalized()

	-- custom cleave implementation since original DoCleaveAttack is somehow bricked
	-- throws AttackRecord warnings and doesn't display particles in a right way

	local enemies = FindUnitsInLine(
		parent:GetTeamNumber(),
		target_origin,
		target_origin + direction * self.splash_range,
		nil,
		self.splash_width,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	)

	local damage_table = {
		attacker = parent,
		ability = self.ability,
		victim = nil,
		damage = splash_damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL
	}

	for i, unit in pairs(enemies) do
		if unit ~= params.target then
			damage_table.damage = splash_damage * SimpleGetAttackFactor(parent, unit)
			damage_table.victim = unit
			ApplyDamage(damage_table)
			local cleave_p = ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny_craggy_cleave.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
			ParticleManager:SetParticleControl(cleave_p, 0, unit:GetAbsOrigin())
			ParticleManager:SetParticleControl(cleave_p, 1, parent:GetAbsOrigin())
			ParticleManager:SetParticleControlForward(cleave_p, 2, direction)
			ParticleManager:ReleaseParticleIndex(cleave_p)
		end
	end
	
	if self.attack_count>0 then
		self:DecrementStackCount()
		-- self:SendBuffRefreshToClients()
		if self:GetStackCount()==0 then
			self:Destroy()
		end
	end
end
