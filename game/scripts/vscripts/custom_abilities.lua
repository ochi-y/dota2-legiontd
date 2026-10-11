if CustomAbilities == nil then
	CustomAbilities = class({})
end




function CDOTABaseAbility:GetCastPosition()
	if self.cast_position_override then
		local position = self.cast_position_override
		self.cast_position_override = nil
		return position
	else
		return self:GetCursorPosition()
	end
end

function CDOTABaseAbility:GetCastTarget()
	if self.cast_target_override then
		local target = self.cast_target_override
		self.cast_target_override = nil
		return target
	else
		return self:GetCursorTarget()
	end
end


function CDOTA_BaseNPC_Hero:ReduceAllCurrentCooldowns(time)
	local ability_slots = {DOTA_Q_SLOT, DOTA_W_SLOT, DOTA_E_SLOT, DOTA_R_SLOT}
	for i = 1, #ability_slots, 1 do
		local ability = self:GetAbilityByIndex(ability_slots[i])
		if ability then
			local remainingCD = ability:GetCooldownTimeRemaining()
			if remainingCD > 0 then
				local newCD = remainingCD - time
				if newCD > 0 then
					ability:EndCooldown()
					ability:StartCooldown(newCD)
				else
					ability:EndCooldown()
				end
			end
		end
	end
end

