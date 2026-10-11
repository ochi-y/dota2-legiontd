LinkLuaModifier( "modifier_item_gameplay_remake_out_of_world", "item_ability/item_gameplay_remake", LUA_MODIFIER_MOTION_NONE )
--Abilities
if item_gameplay_remake == nil then
	item_gameplay_remake = class({})
end

function item_gameplay_remake:GetHealthCost(level)
	if IsServer() then
		return 0
	else
		return self:GetSpecialValueFor("gold")
	end
end

function item_gameplay_remake:OnAbilityPhaseStart()

	if not IsServer() then return end
	local caster=self:GetCaster()
	local pid=caster:GetPlayerOwnerID()
	local pdata=Player:GetPData(pid)
	if teckTree:UseResource(caster, self,nil,{dontRefundGold=true})  then
		return true
	else	
		-- SendErrorMessage(pid, "error_not_enough_lumber")
        return false
	end

end


function item_gameplay_remake:OnSpellStart()
	if not IsServer() then return end
	local caster=self:GetCaster()
	local pid=caster:GetPlayerOwnerID()
	local pdata=Player:GetPData(pid)

	fireLeftNotify(pid,false,"notify_change_builder",{})
	pdata.changeBuilderCharge=pdata.changeBuilderCharge-1
	GamePlay:newHeroChoose(pid,"random")
	caster:AddNewModifier(caster, nil, "modifier_item_gameplay_remake_out_of_world", {})
	EmitSoundOn("DOTA_Item.Refresher.Activate", caster)
	PlayEffOnUnit("particles/items2_fx/refresher.vpcf",caster)
	self:SetCurrentCharges(pdata.changeBuilderCharge)
end


modifier_item_gameplay_remake_out_of_world = class({})

function modifier_item_gameplay_remake_out_of_world:CheckState() 
	local state = {
		-- [MODIFIER_STATE_OUT_OF_GAME] = self.serverside,
		-- [MODIFIER_STATE_PASSIVES_DISABLED] = true,
		-- [MODIFIER_STATE_PROVIDES_VISION] = false,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		-- [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		-- [MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_TEAM_MOVE_TO] = true,
		[MODIFIER_STATE_NO_TEAM_SELECT] = true,
		[MODIFIER_STATE_STUNNED] = true,
		-- [MODIFIER_STATE_BLIND] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}
	return state
end


function modifier_item_gameplay_remake_out_of_world:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
	return funcs
end

function modifier_item_gameplay_remake_out_of_world:GetOverrideAnimation( params )
	return ACT_DOTA_FLAIL
end

function modifier_item_gameplay_remake_out_of_world:OnCreated( params )
	local unit = self:GetParent()
	self.serverside = params.clientside ~= 1
end

function modifier_item_gameplay_remake_out_of_world:IsPurgable()
	return false
end