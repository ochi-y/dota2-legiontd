LinkLuaModifier( "modifier_toggle_debuff_maker", "ability/toggle_debuff_maker.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if toggle_debuff_maker == nil then
	toggle_debuff_maker = class({})
end

function toggle_debuff_maker:OnToggle()
	local caster = self:GetCaster()
    local modifier = caster:FindModifierByName( "modifier_toggle_debuff_maker" )

    if self:GetToggleState() then
        if not modifier then
            caster:AddNewModifier(
                caster,
                self,
                "modifier_toggle_debuff_maker",
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
-------------------------------------------------------------------------------------------------------
modifier_toggle_debuff_maker = class({
	IsHidden = function(self)
		return true
	end,
	IsPurgable = function(self)
		return false
	end,
	IsDebuff = function(self)
		return false
	end,
	IsBuff = function(self)
		return true
	end,
	RemoveOnDeath = function(self)
		return true
	end,
	GetAttributes = function(self)
		return MODIFIER_ATTRIBUTE_NONE
	end
})
function modifier_toggle_debuff_maker:AllowIllusionDuplicate()
	return false
end
function modifier_toggle_debuff_maker:OnCreated(params)
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true) 
end
function modifier_toggle_debuff_maker:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_toggle_debuff_maker:DeclareFunctions()
	return {

	}
end
