LinkLuaModifier( "modifier_gameplay_prophet_remake", "ability/gameplay_prophet_remake.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if gameplay_prophet_remake == nil then
	gameplay_prophet_remake = class({})
end
function gameplay_prophet_remake:OnSpellStart()
	if not IsServer() then return end
	local caster=self:GetCaster()
	local pid=caster:GetPlayerOwnerID()
	local pdata=Player:GetPData(pid)

	if teckTree:UseResource(caster, self)  then
		fireLeftNotify(pid,false,"notify_prophet_rerandom",{})
		PlayRefreshEff(caster)
		pdata.prophetRandomCharge=pdata.prophetRandomCharge-1
		--Timers:CreateTimer(FrameTime(),function ()
			GamePlay:refreshProphet(pid)
			local ab=caster:FindAbilityByName("gameplay_prophet_remake") 
			if ab then
				if pdata.prophetRandomCharge<=0 then
					caster:RemoveAbility(ab:GetAbilityName())
				else
					ab:SetCurrentAbilityCharges(pdata.prophetRandomCharge)
					ab:SetLevel(6-pdata.prophetRandomCharge)
				end
			end
		--end)
		-- if pdata.prophetRandomCharge==0 then
		-- 	caster:RemoveAbility(self:GetAbilityName())
		-- end
	else	
        self:SetCurrentAbilityCharges(self:GetCurrentAbilityCharges()+1)
	end
end
