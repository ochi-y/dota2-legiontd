LinkLuaModifier( "modifier_holy_light", "ability/holy_light.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if holy_light == nil then
	holy_light = class({})
end

function holy_light:OnAbilityPhaseStart()
	if not IsServer() then return end
	local caster=self:GetCaster()
	local pdata=Player:GetPData(pid)
	local king=GamePlay:GetKing(caster:GetTeamNumber())
	
	local orderPlayerId=self.lastOrderPlayerId

	if king and king:GetHealthPercent()>=100 then
		SendErrorMessage(orderPlayerId,"error_holy_light_fail")
		return false
	end
	return true
end



function holy_light:OnSpellStart()
	if not IsServer() then return end
	local caster=self:GetCaster()
	local orderPlayerId=self.lastOrderPlayerId
	GamePlay:holyLight(caster,orderPlayerId,self)
end
