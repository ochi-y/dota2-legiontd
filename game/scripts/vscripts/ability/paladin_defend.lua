LinkLuaModifier( "modifier_paladin_defend", "ability/paladin_defend.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if paladin_defend == nil then
	paladin_defend = class({})
end
function paladin_defend:OnToggle()
	-- local caster=self:GetCaster()

	

	-- if caster:HasModifier("modifier_paladin_defend") then
	-- 	EmitSoundOn("Hero_DragonKnight.ElderDragonForm.Revert", caster)
	-- 	SimplePlayEffOnUnit(caster,"particles/econ/items/dragon_knight/dk_immortal_dragon/dragon_knight_dragon_tail_dragonform_iron_dragon.vpcf")
	-- 	caster:RemoveModifierByName("modifier_paladin_defend")
		
	-- else
	-- 	EmitSoundOn("Hero_DragonKnight.DragonTail.DragonFormCast", caster)
	-- 	SimplePlayEffOnUnit(caster,"particles/econ/items/dragon_knight/dk_immortal_dragon/dragon_knight_dragon_tail_iron_dragon.vpcf")

	-- 	caster:AddNewModifier(caster, self, "modifier_paladin_defend", {})
	-- end



	local caster = self:GetCaster()
    local modifier = caster:FindModifierByName( "modifier_paladin_defend" )

    if self:GetToggleState() then

        if not modifier then
			EmitSoundOn("Hero_DragonKnight.DragonTail.DragonFormCast", caster)
			SimplePlayEffOnUnit(caster,"particles/econ/items/dragon_knight/dk_immortal_dragon/dragon_knight_dragon_tail_iron_dragon.vpcf")
            caster:AddNewModifier(
                caster,
                self,
                "modifier_paladin_defend",
                {}
            )
        end
    else
		EmitSoundOn("Hero_DragonKnight.ElderDragonForm.Revert", caster)
		SimplePlayEffOnUnit(caster,"particles/econ/items/dragon_knight/dk_immortal_dragon/dragon_knight_dragon_tail_dragonform_iron_dragon.vpcf")
		
        if modifier then
            modifier:Destroy()
        end
    end

end
---------------------------------------------------------------------
--Modifiers
if modifier_paladin_defend == nil then
	modifier_paladin_defend = class({})
end
function modifier_paladin_defend:IsPurgable()
	return false
end
function modifier_paladin_defend:IsHidden(params)
	return false
end
function modifier_paladin_defend:OnCreated(params)

	local ability=self:GetAbility()
	self.slow=ability:GetSpecialValueFor("slow")



	if IsServer() then
	end
end
function modifier_paladin_defend:OnRefresh(params)

	local ability=self:GetAbility()
	self.slow=ability:GetSpecialValueFor("slow")


	
	if IsServer() then
	end
end
function modifier_paladin_defend:OnDestroy()
	if IsServer() then
	end
end

function modifier_paladin_defend:GetTexture()
	return "dragon_knight_dragon_tail"
end

function modifier_paladin_defend:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end
function modifier_paladin_defend:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow
end
