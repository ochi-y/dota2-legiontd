LinkLuaModifier( "modifier_demi_human_hand_of_midas", "ability/demi_human_hand_of_midas.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if demi_human_hand_of_midas == nil then
	demi_human_hand_of_midas = class({})
end
function demi_human_hand_of_midas:OnSpellStart()
	local caster=self:GetCaster()
	local target=self:GetCursorTarget()

	EmitSoundOn("DOTA_Item.Hand_Of_Midas", target)

	PlayEffOnUnit("particles/econ/items/alchemist/alchemist_midas_knuckles/alch_hand_of_midas.vpcf",target,{
		cpUnit = {
            [1] = {caster, PATTACH_POINT_FOLLOW, "attach_attack1"}
        }
	})
	target:Kill(self,caster)
	
	local pid=caster:GetPlayerOwnerID()

	local bonus_gold=self:GetSpecialValueFor("bonus_gold")
	if pid then
		local pdata=Player:GetPData(pid)
		Player:ModifyGold(pid,bonus_gold)
		PopupGoldGain(target,bonus_gold,{
			-- team=PlayerResource:GetTeam(pid)
			pid=pid
		})
	end
end


