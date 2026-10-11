

function teleportTouch( trigger )
	local hHero = trigger.activator
	local sGateTriggerName = thisEntity:GetName()
	--print( "Gate_OnStartTouch: " .. sGateTriggerName .. " activated by " .. hHero:GetUnitName() )
    local target = Entities:FindByName( nil, sGateTriggerName .. "_target" )
end


function centerZoneTrigger( trigger )
	local unit = trigger.activator
	--local sGateTriggerName = thisEntity:GetName()
	if unit.path then
		unit:AddNewModifier(unit, nil, "modifier_center_zone", {})
	end
end

function teleportDefense( trigger )
	local unit = trigger.activator
	local sGateTriggerName = thisEntity:GetName()
	--print( "trigger: " .. sGateTriggerName .. " activated by " .. unit:GetUnitName() )
    --local target = Entities:FindByName( nil, sGateTriggerName .. "_target" )
	GamePlay:teleportDefense(unit)
end

function teleportToLane( trigger )
	local unit = trigger.activator
	local sGateTriggerName = thisEntity:GetName()
	--print( "trigger: " .. sGateTriggerName .. " activated by " .. unit:GetUnitName() )
    --local target = Entities:FindByName( nil, sGateTriggerName .. "_target" )

	if not GamePlay.buildallEnabled then
		GamePlay:teleportToLane(unit,sGateTriggerName)
	end

end

function triggerZone1(trigger)
	local unit = trigger.activator
	local sGateTriggerName = thisEntity:GetName()
	if unit then
		unit.zoneIndex=2
	end
end

function teleportToHome( trigger )
	local unit = trigger.activator
	local sGateTriggerName = thisEntity:GetName()
	--print( "trigger: " .. sGateTriggerName .. " activated by " .. unit:GetUnitName() )
    --local target = Entities:FindByName( nil, sGateTriggerName .. "_target" )
	if not GamePlay.buildallEnabled then
		GamePlay:teleportToHome(unit,sGateTriggerName)
	end
	
end

function triggerNoGold( trigger )
	local unit = trigger.activator
	local sGateTriggerName = thisEntity:GetName()
	--print( "trigger: " .. sGateTriggerName .. " activated by " .. unit:GetUnitName() )
	if unit then
		GamePlay:triggerCenterLeak(unit,sGateTriggerName)
		unit.zoneIndex=3	
	end
end


