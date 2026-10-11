LinkLuaModifier( "modifier_switch_attack_target", "ability/switch_attack_target.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if switch_attack_target == nil then
	switch_attack_target = class({})
end

function switch_attack_target:OnToggle()
	local caster = self:GetCaster()
    local modifier = caster:FindModifierByName( "modifier_switch_attack_target" )

    if self:GetToggleState() then
        if not modifier then
            caster:AddNewModifier(
                caster,
                self,
                "modifier_switch_attack_target",
                {}
            )
        end
    else
        if modifier then
            modifier:Destroy()
        end
    end
end
---------------------------------------------------------------------
--Modifiers
if modifier_switch_attack_target == nil then
	modifier_switch_attack_target = class({})
end
function modifier_switch_attack_target:OnCreated(params)
	if IsServer() then
	end
end
function modifier_switch_attack_target:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_switch_attack_target:OnDestroy()
	if IsServer() then
	end
end
function modifier_switch_attack_target:DeclareFunctions()
	return {
	}
end