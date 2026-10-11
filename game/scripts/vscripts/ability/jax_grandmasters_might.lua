
jax_grandmasters_might = class({})
LinkLuaModifier( "modifier_grandmasters_might_passive", "ability/jax_grandmasters_might", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_grandmasters_might_stack", "ability/jax_grandmasters_might", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_jax_grandmasters_might", "ability/jax_grandmasters_might", LUA_MODIFIER_MOTION_NONE)

function jax_grandmasters_might:GetIntrinsicModifierName()
    return "modifier_grandmasters_might_passive"
end


modifier_grandmasters_might_passive = class({})
function modifier_grandmasters_might_passive:IsDebuff() return false end
function modifier_grandmasters_might_passive:IsHidden() return true end
function modifier_grandmasters_might_passive:IsPurgable() return false end
function modifier_grandmasters_might_passive:IsPurgeException() return false end
function modifier_grandmasters_might_passive:RemoveOnDeath() return false end
function modifier_grandmasters_might_passive:AllowIllusionDuplicate() return false end

function modifier_grandmasters_might_passive:DeclareFunctions()
    local decFuns =
    {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }
    return decFuns
end

function modifier_grandmasters_might_passive:GetModifierProcAttack_BonusDamage_Magical( params )
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local bonusdamage = 0
		local maxstacks = ability:GetSpecialValueFor("max_stacks")
		local duration = ability:GetSpecialValueFor("stack_duration")
		local stun = ability:GetSpecialValueFor("stun")
		if caster:HasModifier("modifier_grandmasters_might_stack") then
			local stacks = caster:GetModifierStackCount("modifier_grandmasters_might_stack", caster)
		else local stacks = 0 end
		local target = params.target if target==nil then target = params.unit end
		if target:GetTeamNumber()==self:GetParent():GetTeamNumber() then
			return 0
		end
		
		if not self:GetParent():PassivesDisabled() and params.attacker == caster and not target:IsBuilding() then
			local modifier = caster:AddNewModifier(caster, ability, "modifier_grandmasters_might_stack", {duration = duration})
			if caster:GetModifierStackCount("modifier_grandmasters_might_stack", caster) < maxstacks then
				modifier:IncrementStackCount()
			end
			if caster:GetModifierStackCount("modifier_grandmasters_might_stack", caster) == maxstacks then
				bonusdamage = ability:GetSpecialValueFor("bonus_damage")
				caster:RemoveModifierByName("modifier_grandmasters_might_stack")


				PlayEffOnUnit("particles/econ/items/spirit_breaker/spirit_breaker_weapon_ti8/spirit_breaker_bash_ti8.vpcf",target,{
					cpDir={[1]=self:GetCaster():GetForwardVector()}
				})
				
				EmitSoundOn("Hero_Spirit_Breaker.GreaterBash", target)

				
				local origin = caster:GetAbsOrigin()
				local knockbackProperties = {
					center_x = origin.x,
					center_y = origin.y,
					center_z = origin.z,
					duration = 0.3,
					knockback_duration = 0.3,
					knockback_distance = 200,
					knockback_height = 0,
					ShouldStun=false
				}
				target:RemoveModifierByName("modifier_knockback")

				if not target:IsAncient() then
					target:AddNewModifier(caster, self, "modifier_knockback", knockbackProperties)
				end
				local stunDuration=stun
				if not target:IsAncient() then
					target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = stunDuration})
				end
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, bonusdamage, nil)
			end
		end
		return bonusdamage
	end
end
function modifier_grandmasters_might_passive:GetActivityTranslationModifiers()
	if self:GetCaster():GetModifierStackCount("modifier_grandmasters_might_stack", self:GetCaster()) == 3 then
		return "champ"
	else
		return nil
	end
end

modifier_grandmasters_might_stack = class({})
function modifier_grandmasters_might_stack:IsHidden() return false end
function modifier_grandmasters_might_stack:IsDebuff() return false end
function modifier_grandmasters_might_stack:IsPurgable() return false end
function modifier_grandmasters_might_stack:IsPurgeException() return false end