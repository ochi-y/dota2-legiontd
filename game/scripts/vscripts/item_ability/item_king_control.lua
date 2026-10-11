LinkLuaModifier("modifier_item_king_control", "item_ability/item_king_control.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if item_king_control == nil then
    item_king_control = class({})
end
function item_king_control:OnSpellStart()

    local caster = self:GetCaster()

    local pid = caster:GetPlayerOwnerID()

    local unit = GamePlay:GetTData(PlayerResource:GetTeam(pid)).king
    if not IsActiveUnit(unit) then
        return
    end
    EmitSoundOn("DOTA_Item.Buckler.Activate", caster)
    EmitSoundOn("DOTA_Item.Buckler.Activate", unit)

    unit:SetControllableByPlayer(pid, true)
    fireLeftNotify(pid, true, "notify_king_control", {})

    PlayEffOnUnit("particles/units/heroes/hero_chen/chen_cast_4.vpcf",unit)

    -- PlayEffOnUnit("particles/units/heroes/hero_chen/chen_cast_4.vpcf",caster)
end

