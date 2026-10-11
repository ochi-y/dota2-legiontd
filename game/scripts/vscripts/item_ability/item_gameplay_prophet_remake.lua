LinkLuaModifier("modifier_item_gameplay_prophet_remake", "item_ability/item_gameplay_prophet_remake",
	LUA_MODIFIER_MOTION_NONE)
--Abilities
if item_gameplay_prophet_remake == nil then
	item_gameplay_prophet_remake = class({})
end


function item_gameplay_prophet_remake:GetHealthCost(level)
	if IsServer() then
		return 0
	else
		return self:GetSpecialValueFor("gold")
	end
end

function item_gameplay_prophet_remake:OnAbilityPhaseStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local pid = caster:GetPlayerOwnerID()
	local pdata = Player:GetPData(pid)
	if teckTree:UseResource(caster, self, nil, { }) then
		return true
	else
		-- SendErrorMessage(pid, "error_not_enough_lumber")
		return false
	end
end

function item_gameplay_prophet_remake:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local pid = caster:GetPlayerOwnerID()
	local pdata = Player:GetPData(pid)

	fireLeftNotify(pid, false, "notify_prophet_rerandom", {})
	PlayRefreshEff(caster)
	pdata.prophetRandomCharge = pdata.prophetRandomCharge - 1
	--Timers:CreateTimer(FrameTime(),function ()
	GamePlay:refreshProphet(pid)
	local ab = caster:FindItemInInventory("item_gameplay_prophet_remake")
	if ab then
		if pdata.prophetRandomCharge <= 0 then
			DeleteItemOfUnit(caster, "item_gameplay_prophet_remake")
		else
			ab:SetCurrentCharges(pdata.prophetRandomCharge)
			ab:SetLevel(6 - pdata.prophetRandomCharge)
		end
	end
	--end)
	-- if pdata.prophetRandomCharge==0 then
	-- 	caster:RemoveAbility(self:GetAbilityName())
	-- end
end
