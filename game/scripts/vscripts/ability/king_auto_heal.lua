LinkLuaModifier("modifier_king_auto_heal", "ability/king_auto_heal.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if king_auto_heal == nil then
    king_auto_heal = class({})
end
function king_auto_heal:GetIntrinsicModifierName()
    return "modifier_king_auto_heal"
end
---------------------------------------------------------------------
-- Modifiers
if modifier_king_auto_heal == nil then
    modifier_king_auto_heal = class({})
end
function modifier_king_auto_heal:OnCreated(params)
    if IsServer() then
    end
end
function modifier_king_auto_heal:IsPurgable(params)
    return false
end
function modifier_king_auto_heal:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_king_auto_heal:OnDestroy()
    if IsServer() then
    end
end
function modifier_king_auto_heal:DeclareFunctions()
    return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_king_auto_heal:GetModifierIncomingDamage_Percentage(data)
    if not IsServer() then
        return
    end
    local health = self:GetParent():GetHealth()
    if (health - data.damage <= 100) then
        local king = self:GetParent()
		local healed=false
		local team=king:GetTeam()
        -- 
        for _, pid in ipairs(Player:Ids()) do
            if PlayerResource:GetTeam(pid) == team  then
                healed=GamePlay:autoHeal(pid)
                print(pid,healed)
                if healed then
                    break
                end
            end
        end
        -- Player:ForeanchPlayer(function(pid, pdata)
        --     if healed == false and PlayerResource:GetTeam(pid) == team  then
        --         local healed=GamePlay:autoHeal(pid)
        --         print(pid,healed)
        --         healed = true
        --     end
            
        -- end)
		if healed then
			return -100
		end
    end
    return 0
end

