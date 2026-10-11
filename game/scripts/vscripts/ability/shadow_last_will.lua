LinkLuaModifier( "modifier_shadow_last_will", "ability/shadow_last_will", LUA_MODIFIER_MOTION_NONE )
--Abilities
if shadow_last_will == nil then
	shadow_last_will = class({})
end
function shadow_last_will:GetIntrinsicModifierName()
	return "modifier_shadow_last_will"
end
---------------------------------------------------------------------
--Modifiers
if modifier_shadow_last_will == nil then
	modifier_shadow_last_will = class({})
end

function modifier_shadow_last_will:IsHidden(params)
	return true
end

function modifier_shadow_last_will:OnCreated(params)
	if IsServer() then
	end
end
function modifier_shadow_last_will:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_shadow_last_will:OnDestroy()
	if IsServer() then
	end
end
function modifier_shadow_last_will:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH
	}
end

function modifier_shadow_last_will:OnDeath( params )
	if IsServer() then
		if params.unit == self:GetCaster() then
			local attacker=params.attacker
			if attacker then
				PlayEffOnUnit("particles/items_fx/necronomicon_warrior_last_will.vpcf",attacker,{
					cpUnit = {
						[0] = { attacker, PATTACH_POINT, "attach_hitloc" },
						[1] = { self:GetCaster(), PATTACH_POINT, "attach_hitloc" }
					}
				})
				local damage=self:GetAbility():GetSpecialValueFor("explosion")
				SimpleApplyDamage(self:GetAbility(), params.unit, attacker, damage)
			end
		end
	end
end
