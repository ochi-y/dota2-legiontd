LinkLuaModifier( "modifier_gameplay_defense_mode", "ability/gameplay_defense_mode.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if gameplay_defense_mode == nil then
	gameplay_defense_mode = class({})
end


function gameplay_defense_mode:OnToggle()
	
	if not IsServer() then return end

    local caster = self:GetCaster()
    local modifier = caster:FindModifierByName( "modifier_element_energy_shield" )

	local pdata=Player:GetPData(caster:GetPlayerOwnerID())

	if not pdata then
		return
	end
    if self:GetToggleState() then
        pdata.defenseMode="global"
		fireLeftNotify(caster:GetPlayerOwnerID(), true, "notify_defense_mode_global", {
		})
    else
        pdata.defenseMode="local"
		fireLeftNotify(caster:GetPlayerOwnerID(), true, "notify_defense_mode_local", {
		})
    end
end