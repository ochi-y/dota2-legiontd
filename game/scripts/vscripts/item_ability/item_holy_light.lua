LinkLuaModifier( "modifier_item_holy_light", "ability/item_holy_light.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if item_holy_light == nil then
	item_holy_light = class({})
end

function item_holy_light:OnAbilityPhaseStart()
	if not IsServer() then return end
	local caster=self:GetCaster()
	local pdata=Player:GetPData(pid)
	local king=GamePlay:GetKing(caster:GetTeamNumber())
	local orderPlayerId=self.lastOrderPlayerId
	if king and king:GetHealthPercent()>=100 then

		
		SendErrorMessage(orderPlayerId,"error_holy_light_fail")
		return false
	end
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)
	return true
end


function item_holy_light:OnSpellStart()
	if not IsServer() then return end
	local caster=self:GetCaster()
	local orderPlayerId=self.lastOrderPlayerId
	GamePlay:holyLight(caster,orderPlayerId,self)
end
