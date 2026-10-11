require("utils/notify")
require("utils/str")
require("utils/ability")
require("utils/math")
require("utils/kvtool")
require("utils/unit_editor")

function DebugPrint(...)
    if USE_DEBUG then
        print(...)
    end
end

if not UTIL then
    UTIL = {}
    UTIL.tagMap = {}
end



function PrintTable(t, indent, done)
    -- print ( string.format ('PrintTable type %s', type(keys)) )
    if type(t) ~= "table" then
        print(t)
        return
    end

    done = done or {}
    done[t] = true
    indent = indent or 0

    local l = {}
    for k, v in pairs(t) do
        table.insert(l, k)
    end

    table.sort(l)
    for k, v in ipairs(l) do
        -- Ignore FDesc
        if v ~= 'FDesc' then
            local value = t[v]

            if type(value) == "table" and not done[value] then
                done[value] = true
                print(string.rep("\t", indent) .. tostring(v) .. ":")
                PrintTable(value, indent + 2, done)
            elseif type(value) == "userdata" and not done[value] then
                done[value] = true
                print(string.rep("\t", indent) .. tostring(v) .. ": " .. tostring(value))
                PrintTable((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2,
                    done)
            else
                if t.FDesc and t.FDesc[v] then
                    print(string.rep("\t", indent) .. tostring(t.FDesc[v]))
                else
                    print(string.rep("\t", indent) .. tostring(v) .. ": " .. tostring(value))
                end
            end
        end
    end
end

p = print
-- Requires an element and a table, returns true if element is in the table.
function TableContains(t, element)
    if t == nil then
        return false
    end
    for k, v in pairs(t) do
        if k == element then
            return true
        end
    end
    return false
end

function TableCopy(t)
    if not t then
        return {}
    end

    local res = {}
    for key, value in pairs(t) do
        res[key] = value
    end
    return res
end

function TableContainsValue(t, element)
    if t == nil then
        return false
    end
    for k, v in pairs(t) do
        if v == element then
            return true
        end
    end
    return false
end

function TableRemoveByValue(t, element)
    if t == nil then
        return false
    end
    for k, v in pairs(t) do
        if v == element then
            table.remove(t, k)
            return
        end
    end
end

function ArrayRemoveValue(t, v)
    if t == nil then
        return
    end
    for index, value in ipairs(t) do
        if value == v then
            table.remove(t, index)
            return
        end
    end
end

function ArrayFilter(t, cond)
    if t == nil then
        return {}
    end
    local res = {}
    for index, value in ipairs(t) do
        if cond(value) then
            table.insert(res, value)
        end
    end
    return res
end

-- Return length of the table even if the table is nil or empty
function TableLength(t)
    if t == nil or t == {} then
        return 0
    end
    local length = 0
    for k, v in pairs(t) do
        length = length + 1
    end
    return length
end

function subrange(t, first, last)
    local sub = {}
    for i = first, last do
        sub[#sub + 1] = t[i]
    end
    return sub
end

function GetRandomTableElement(t)
    -- iterate over whole table to get all keys
    local keyset = {}
    for k in pairs(t) do
        table.insert(keyset, k)
    end
    -- now you can reliably return a random key
    return t[keyset[RandomInt(1, #keyset)]]
end

function bool_to_number(value)
    return value and 1 or 0
end

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'


-- Author: Noya
-- This function hides all dota item cosmetics (hats/wearables) from the hero/unit and store them into a handle variable
-- Works only for wearables added with code
function HideWearables(unit)
    unit.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
    local model = unit:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            model:AddEffects(EF_NODRAW) -- Set model hidden
            table.insert(unit.hiddenWearables, model)
        end
        model = model:NextMovePeer()
    end
end

-- Author: Noya
-- This function un-hides (shows) wearables that were hidden with HideWearables() function.
function ShowWearables(unit)
    for i, v in pairs(unit.hiddenWearables) do
        v:RemoveEffects(EF_NODRAW)
    end
end

-- Author: Noya
-- This function changes (swaps) dota item cosmetic models (hats/wearables)
-- Works only for wearables added with code
function SwapWearable(unit, target_model, new_model)
    local wearable = unit:FirstMoveChild()
    while wearable ~= nil do
        if wearable:GetClassname() == "dota_item_wearable" then
            if wearable:GetModelName() == target_model then
                wearable:SetModel(new_model)
                return
            end
        end
        wearable = wearable:NextMovePeer()
    end
end

if IsServer() then
    -- This function checks if a given unit is Roshan, returns boolean value;
    function CDOTA_BaseNPC:IsRoshan()
        if self:IsAncient() and self:GetUnitName() == "npc_dota_roshan" then
            return true
        end

        return false
    end

    -- This function checks if this entity is a fountain or not; returns boolean value;
    function CBaseEntity:IsFountain()
        if self:GetName() == "ent_dota_fountain_bad" or self:GetName() == "ent_dota_fountain_good" then
            return true
        end

        return false
    end
end

function Format(fmt, ...)
    assert(fmt ~= nil, "Format error:Invalid Format String")
    local parms = { ... }

    local function search(k)
        -- convert from C# array style to Lua
        k = k + 1
        assert(k <= #parms and k >= 0, "Format error:IndexOutOfRange")
        return tostring(parms[k])
    end

    return (string.gsub(fmt, "{(%d)}", search))
end

-- note: custom abilities return userdata from GetBehavior
-- native abilities return a number from GetBehavior
function BehaviorContainsValue(sum, nValue)
    if type(sum) == "userdata" then
        sum = tonumber(tostring(sum))
    end
    if bit:_and(sum, nValue) == nValue then
        return true
    else
        return false
    end
end

function GetAllUnitsInKv(file)
    local scriptPath = "scripts/npc/units/"
    local kvs = LoadKeyValues(scriptPath .. file)
    local res = {}
    for k, v in pairs(kvs) do
        table.insert(res, k)
    end
    return res
end

function IsEnemy(unit1, unit2)
    if unit1:GetTeamNumber() == unit2:GetTeamNumber() then
        return false
    else
        return true
    end
end

function Normalized2D(vec)
    local newVec = Vector(vec.x, vec.y, 0)
    return newVec:Normalized()
end

function startWith(text, prefix)
    return text:find(prefix, 1, true) == 1
end

function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

function RandomPointInRadius(point, radius)
    local r = radius * math.sqrt(RandomFloat(0, 1))
    local theta = RandomFloat(0, 1) * 2 * math.pi
    local x = point.x + r * math.cos(theta)
    local y = point.y + r * math.sin(theta)
    return Vector(x, y, point.z)
end

function mysplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function GetHeroOfUnit(unit)
    local owner = unit
    while (not owner:IsRealHero()) do
        if owner.GetOwner then
            owner = owner:GetOwner()
        else
            return nil
        end
    end
    return owner
end

function WayPointClear(unit)
    if IsActiveUnit(unit) then
        unit.wayStep = nil
        unit.waypoints = {}
    end
end

function WayPointAdd(unit, pos)
    if IsActiveUnit(unit) and pos then
        if not unit.wayStep then
            unit.wayStep = 1
            unit.waypoints = {}
        end
        table.insert(unit.waypoints, pos)
    end
    -- unit.wayStep = nil
    -- unit.waypoints = {}
end

function AddItemToUnit(unit, item_name)
    if IsActiveUnit(unit) then
        local item = CreateItem(item_name, nil, nil)
        if item then
            item:SetPurchaseTime(0)
            unit:AddItem(item)
        end
    end
end

function DeleteItemOfUnit(unit, item_name)
    if IsActiveUnit(unit) then
        local item = unit:FindItemInInventory(item_name)
        if item then
            unit:TakeItem(item)
        end
    end
end

function refreshUnit(unit)
    if IsActiveUnit(unit) then
        local abilityCount = unit:GetAbilityCount() or 0
        for i = 0, abilityCount - 1 do
            local ab = unit:GetAbilityByIndex(i)
            if ab then
                ab:RefreshCharges()
                ab:EndCooldown()
            end
        end
        unit:SetMana(unit:GetMaxMana())
    end
end

-- hCaster:SetContextThink(DoUniqueString("order"), function() ExecuteOrderFromTable(t_order) end, FrameTime())

function AddItemOnGround(unit, item_name)
    local item = CreateItem(item_name, nil, nil)
    item:SetPurchaseTime(0)
    local pos = unit:GetAbsOrigin()
    local drop = CreateItemOnPositionSync(pos, item)
    local pos_launch = pos + RandomVector(RandomFloat(50, 100))
    item:LaunchLoot(false, 200, 0.75, pos_launch)
end

function AddItemOnPoint(pos, item_name)
    local item = CreateItem(item_name, nil, nil)
    if item then
        item:SetPurchaseTime(0)
        local drop = CreateItemOnPositionSync(pos, item)
        local pos_launch = pos + RandomVector(RandomFloat(50, 50))
        item:LaunchLoot(false, 200, 0.75, pos_launch)
    end
end

function AddAbilityAndSetLevel(unit, abilityName, level)
    local ability = unit:FindAbilityByName(abilityName)
    if not ability then
        unit:AddAbility(abilityName)
        ability = unit:FindAbilityByName(abilityName)
    end
    if ability then
        if level then
            ability:SetLevel(level)
        else
            ability:SetLevel(1)
        end
        return ability
    end
end

function getPlayerName(pid)
    if PlayerResource:IsFakeClient(pid) then
        return tostring(pid)
    end
    local pname = PlayerResource:GetPlayerName(pid)
    if pname and pname ~= "" then
        return pname
    end
    return tostring(PlayerResource:GetSteamAccountID(pid))
end

function playerSay(pid, msg)
    print("playerSay ",pid,msg)
    Say(PlayerResource:GetSelectedHeroEntity(pid),  msg, false)
end
--
function SimpleMoveUnit(unit, point)
    if not IsActiveUnit(unit) then
        return
    end
    FindClearSpaceForUnit(unit, point, true)
    unit:AddNewModifier(unit, nil, "modifier_phased", {
        duration = 0.5
    })
end

function IsKing(unit)
    if not IsActiveUnit(unit) then
        return false
    end
    return unit:GetUnitName() == "king_good" or unit:GetUnitName() == "king_bad"
end

function tableToKv(prefix, tb)
    prefix = prefix or ""
    print(prefix .. "{")

    for key, value in pairs(tb) do
        if type(value) == "table" then
            print(prefix .. "    " .. '"' .. key .. '"')
            tableToKv(prefix .. "    ", value)
        else
            local str = ""
            --if type(value)=="table" then
            str = tostring(value)
            --end


            print(prefix .. "    " .. '"' .. key .. '"' .. ' ' .. '"' .. str .. '"')
        end
    end
    print(prefix .. "}")
end

function isTrue(v)
    if v == nil then
        return false
    end
    if type(v) == "number" then
        return v ~= 0
    end
    if type(v) == "string" then
        return v ~= ""
    end
    if type(v) == "boolean" then
        return v
    end
    return v ~= nil
end

function isFalse(v)
    return not isTrue(v)
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        -- setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function randomValueFromTable(myTable)
    -- iterate over whole table to get all keys
    local keyset = {}
    for k in pairs(myTable) do
        table.insert(keyset, k)
    end
    -- now you can reliably return a random key
    return myTable[keyset[math.random(#keyset)]]
end

function getRandomUnitVo(unit, type)
    if not ENABLE_CREEP_VO then
        return nil
    end
    local Model = GetUnitKV(unit:GetUnitName(), "Model")
    if not Model then
        return nil
    end

    local modelMapping = VO_LIST["modelMapping"]
    if modelMapping and modelMapping[Model] then
        Model = modelMapping[Model]
    end
    local voModel = VO_LIST[Model]

    if not voModel then
        return nil
    end

    local vo = voModel[type]
    if not vo then
        return nil
    end
    return randomValueFromTable(vo)
end

function emitVoiceSound(unit, type, pid)
    print("🎤 [Voice] trying to play a voice line - type:", type, "player:", pid)

    if not IsActiveUnit(unit) then
        print("⚠️ [Voice] unit is not active, skipping")
        return
    end

    local sound = getRandomUnitVo(unit, type)

    if not sound then
        print("⚠️ [Voice] no voice resource - unit:", unit:GetUnitName(), "type:", type)
        return
    end

    print("🎵 [Voice] selected voice line:", sound)

    if unit:HasModifier("modifier_card_drag_move") then
        print("⏸️ [Voice] unit is being dragged, skipping")
        return
    end

    local pdata = Player:GetPData(pid)

    if pdata then
        if pdata.voiceEntity then
            print("🔇 [Voice] stopping the previous line:", pdata.voiceName)
            StopSoundOn(pdata.voiceName, pdata.voiceEntity)
        end

        EmitSoundOnEntityForPlayer(sound, unit, pid)
        pdata.voiceEntity = unit
        pdata.voiceName = sound

        print("✅ [Voice] voice line played -", sound, "-> player", pid)
    else
        print("❌ [Voice] could not get the player data, playback failed")
    end
end

-- EmitSoundOn("necrolyte_necr_move_08", PlayerResource:GetSelectedHeroEntity(0))
function getRandomPosInTrigger(triggerName)
    local entity = Entities:FindByName(nil, triggerName)
    local origin = entity:GetAbsOrigin()
    local bounds = entity:GetBounds()
    local min = bounds.Mins
    local max = bounds.Maxs
    local minX = min.x + origin.x
    local minY = min.y + origin.y
    local maxX = max.x + origin.x
    local maxY = max.y + origin.y

    local x = RandomInt(minX, maxX)
    local y = RandomInt(minY, maxY)

    return Vector(x, y, origin.z)
end

function removeDeadUnit(unitList)
    if not unitList then
        return
    end
    ArrayRemove(unitList, function(unit)
        if unit and not unit:IsNull() and unit:IsAlive() then
            return false
        else
            return true
        end
    end)
end

function ArrayRemove(t, fnRm)
    local j, n = 1, #t;
    for i = 1, n do
        local elem = t[i]
        if (not fnRm(elem)) then
            -- Move i's kept value to j's position, if it's not already there.
            if (i ~= j) then
                t[j] = t[i];
                t[i] = nil;
            end
            j = j + 1; -- Increment position of where we'll place the next kept value.
        else
            t[i] = nil;
        end
    end
    return t;
end

function ArrayOrderByMapFunc(units, func)
    stableSort(units, function(a, b)
        local valueA = func(a)
        local valueB = func(b)
        return valueA < valueB
    end)
    return units
end

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function combSort(elements, comparerList)
    table.sort(elements, function(a, b)
        for _, cmp in ipairs(comparerList) do
            if cmp(a, b) then
                return true
            end
            if cmp(b, a) then
                return false
            end
        end
        return false
    end)
end

function arrayfilter(t, filterIter)
    local out = {}
    for k, v in ipairs(t) do
        if filterIter(v, k, t) then
            out[k] = v
        end
    end
    return out
end

function CalculateDistance(ent1, ent2, b3D)
    local pos1 = ent1
    local pos2 = ent2
    if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
    if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
    local vector = (pos1 - pos2)
    if b3D then
        return vector:Length()
    else
        return vector:Length2D()
    end
end

function CalculateDirection(ent1, ent2)
    local pos1 = ent1
    local pos2 = ent2
    if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
    if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
    local direction = (pos1 - pos2):Normalized()
    direction.z = 0
    return direction
end

function CDOTA_Modifier_Lua:StartMotionController()
    if not self:GetParent():IsNull() and not self:IsNull() and self.DoControlledMotion and self:GetParent():HasMovementCapability() then
        self:GetParent():StopMotionControllers()
        self:GetParent():InterruptMotionControllers(true)
        self.controlledMotionTimer = Timers:CreateTimer(function()
            if pcall(function() self:DoControlledMotion() end) then
                return 0.03
            elseif not self:IsNull() then
                self:Destroy()
            end
        end)
    else
    end
end

function CDOTA_Modifier_Lua:StopMotionController(bForceDestroy)
    FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
    if self.controlledMotionTimer then Timers:RemoveTimer(self.controlledMotionTimer) end
    if bForceDestroy then self:Destroy() end
end

function CDOTA_BaseNPC:StopMotionControllers(bForceDestroy)
    if self.InterruptMotionControllers then self:InterruptMotionControllers(true) end
    for _, modifier in ipairs(self:FindAllModifiers()) do
        if modifier.controlledMotionTimer then
            modifier:StopMotionController(bForceDestroy)
        end
    end
end

function hex2rgb(hex)
    hex = hex:gsub("#", "")
    return { tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6)) }
end

function SimpleAddHealth(unit, h)
    unit:SetBaseMaxHealth(unit:GetBaseMaxHealth() + h)
    unit:SetMaxHealth(unit:GetMaxHealth() + h)
    unit:SetHealth(unit:GetHealth() + h)
end

function SimpleReduceHealth(unit, h)
    unit:SetBaseMaxHealth(math.max(1, unit:GetBaseMaxHealth() - h))
    unit:SetMaxHealth(math.max(1, unit:GetBaseMaxHealth() - h))
end

function SimplePerformAttack(attacker, target, useOrb, useProcs, useProjectile)
    attacker:PerformAttack(target, useOrb, useProcs, true, false, useProjectile, false, false)
end

function FindUnitsInTrapezoid(teamNumber, vDirection, vPosition, startRadius, endRadius, flLength, hCacheUnit, targetTeam,
                              targetUnit, targetFlags, findOrder, bCache)
    local circle_r = math.sqrt(math.pow(endRadius / 2, 2) + math.pow(flLength, 2))
    local enemy = FindUnitsInRadius(teamNumber, vPosition, hCacheUnit, circle_r, targetTeam, targetUnit, targetFlags,
        findOrder, bCache)
    local ta = {}
    local vStartPoint = { RotatePosition(vPosition, QAngle(0, 90, 0), vPosition + vDirection * (startRadius / 2)),
        RotatePosition(vPosition, QAngle(0, -90, 0), vPosition + vDirection * (startRadius / 2)) }
    local vEndPoint = { RotatePosition(vPosition + vDirection * flLength, QAngle(0, 90, 0),
        (vPosition + vDirection * flLength) + vDirection * (endRadius / 2)), RotatePosition(
        vPosition + vDirection * flLength, QAngle(0, -90, 0),
        (vPosition + vDirection * flLength) + vDirection * (endRadius / 2)) }
    local A = vStartPoint[1]
    local B = vEndPoint[1]
    local C = vEndPoint[2]
    local D = vStartPoint[2]

  
    for i = 1, #enemy do
        local pos = enemy[i]:GetAbsOrigin()
        local a = (B.x - A.x) * (pos.y - A.y) - (B.y - A.y) * (pos.x - A.x)
        local b = (C.x - B.x) * (pos.y - B.y) - (C.y - B.y) * (pos.x - B.x)
        local c = (D.x - C.x) * (pos.y - C.y) - (D.y - C.y) * (pos.x - C.x)
        local d = (A.x - D.x) * (pos.y - D.y) - (A.y - D.y) * (pos.x - D.x)
        if (a >= 0 and b >= 0 and c >= 0 and d >= 0) or (a <= 0 and b <= 0 and c <= 0 and d <= 0) then
            table.insert(ta, enemy[i])
        end
    end
    return ta
end

function FilterUnitInSector(units, point, direction, angle)
    local res = {}
    for index, unit in ipairs(units) do
        if unit:GetAbsOrigin() == point then
            table.insert(res, unit)
        else
            local dir = (unit:GetAbsOrigin() - point):Normalized()
            local a1 = angleOf2Vector(dir, direction:Normalized())
            if math.abs(a1) <= angle / 2 then
                table.insert(res, unit)
            end
        end
    end
    return res
end

function GetDirection2D(vEndPoint, vStartPoint)
    vEndPoint.z = 0
    vStartPoint.z = 0
    local direction = (vEndPoint - vStartPoint):Normalized()
    direction.z = 0
    return direction
end

-- normal pierce siege magic chaos hero
-- light medium heavy fortified hero unarmored
-- https://www.gamersky.com/handbook/201811/1119643.shtml
local attackTable = {}
attackTable["normal"] = {
    light = 90,
    medium = 120,
    heavy = 90,
    fortified = 80,
    hero = 100,
    unarmored = 100
}
attackTable["pierce"] = {
    light = 130,
    medium = 90,
    heavy = 80,
    fortified = 70,
    hero = 100,
    unarmored = 100
}
attackTable["siege"] = {
    light = 90,
    medium = 90,
    heavy = 90,
    fortified = 125,
    hero = 100,
    unarmored = 100
}
attackTable["magic"] = {
    light = 110,
    medium = 80,
    heavy = 120,
    fortified = 70,
    hero = 100,
    unarmored = 100
}
attackTable["chaos"] = {
    light = 100,
    medium = 100,
    heavy = 100,
    fortified = 100,
    hero = 100,
    unarmored = 100
}
attackTable["hero"] = {
    light = 100,
    medium = 100,
    heavy = 100,
    fortified = 100,
    hero = 100,
    unarmored = 100
}

local armorTypeList = { "light", "medium", "heavy", "fortified", "hero", "unarmored" }

function SimpleGetAttackFactor(attacker, target)
    local attackType = attacker.attackType
    local armorType = target.armorType
    --
    if attackType and armorType and attackTable[attackType] and attackTable[attackType][armorType] then
        local v = attackTable[attackType][armorType]
        if attackType == "pierce" and target:HasModifier("modifier_paladin_defend") then
            v = v * 0.75
        end
        if attackType == "pierce" and target:HasModifier("modifier_nature_mark_target_debuff") then
            v = v * 1.30
        end
        return v / 100
    else
        return 1
    end
end

function handleAttackType(attacker, target)
    if not IsActiveUnit(attacker) then
        return
    end
    if not IsActiveUnit(target) then
        return
    end

    -- Is the attack/armor type system disabled?
    if HERO_DEMO_ATTACK_ARMOR_TYPE_DISABLED then
        return
    end

    local attackType = attacker.attackType
    local armorType = target.armorType

    local damageFactor = math.floor(100 * SimpleGetAttackFactor(attacker, target))

    if damageFactor ~= 100 then
        target:AddNewModifier(attacker, nil, "modifier_attack_type_debuff", {
            duration = FrameTime(),
            attackBonus = damageFactor - 100
        })
    end
end

function tableFirstElement(t)
    if t and #t >= 1 then
        return t[1]
    end
    return nil
end

function playTeleportEffect(unit)
    local eff = "particles/items2_fx/teleport_start.vpcf"
    SimplePlayEffAtlocation("particles/econ/events/fall_2021/blink_dagger_fall_2021_start_lvl2.vpcf",
        unit:GetAbsOrigin(), { 0, 1, 2, 3 })
    -- local particle = SimplePlayEffOnUnit(unit, eff)
    -- EmitSoundOn("Item.AbyssalBlade.Blink", unit)
    EmitSoundOnLocationWithCaster(unit:GetAbsOrigin(), "Item.AbyssalBlade.Blink", unit)
end

function playTeleportEndEffect(unit)
    SimplePlayEffAtlocation("particles/econ/events/fall_2021/blink_dagger_fall_2021_end.vpcf", unit:GetAbsOrigin(),
        { 0, 1, 2, 3 })
    -- local particle = SimplePlayEffOnUnit(unit, eff)
    -- EmitSoundOn("Item.AbyssalBlade.Blink", unit)
    EmitSoundOnLocationWithCaster(unit:GetAbsOrigin(), "Item.AbyssalBlade.Blink", unit)
end

function IsActiveUnit(unit)
    return unit and (not unit:IsNull()) and unit:IsAlive()
end

function get_keys(t)
    local keys = {}
    for key, _ in pairs(t) do
        table.insert(keys, key)
    end
    return keys
end

function get_values(t)
    local keys = {}
    for key, v in pairs(t) do
        table.insert(keys, v)
    end
    return keys
end

function EnableAllAutoCast(unit)
    local abc = unit:GetAbilityCount()
    if not abc then
        return
    end
    for i = 0, abc - 1 do
        local ab = unit:GetAbilityByIndex(i)
        if ab then
            local abn = ab:GetAbilityName()
            if BehaviorContainsValue(ab:GetBehavior(), DOTA_ABILITY_BEHAVIOR_AUTOCAST) and not ab:GetAutoCastState() then
                ab:ToggleAutoCast()
            end
            -- if BehaviorContainsValue(ab:GetBehavior(), DOTA_ABILITY_BEHAVIOR_TOGGLE) and not ab:GetToggleState() then
            --     ab:ToggleAbility()
            -- end
        end
    end
end

function stableSort(list, comp)
    if not list then
        return
    end
    if not comp then
        return
    end

    local sortList = {}
    for k, node in ipairs(list) do
        table.insert(sortList, {
            index = k,
            value = node
        })
    end
    table.sort(sortList, function(a, b)
        if comp(a.value, b.value) then
            return true
        end
        if comp(b.value, a.value) then
            return false
        end

        return a.index < b.index
    end)
    for i, v in ipairs(sortList) do
        list[i] = v.value
    end
end

function stableSortByNumber(list, toNumberFunc)
    stableSort(list, function(a, b)
        return toNumberFunc(a) < toNumberFunc(b)
    end)
end

function SafeCall(func, ...)
    local status, result = pcall(func, ...)
    if not status then
        -- Game.storage:LogError(result)
        print(result)
    end
    return status, result
end

function copyCreepStack(fromUnit, toUnit)
    local abA = fromUnit:FindAbilityByName("fighter_death_spawn")
    local abB = toUnit:FindAbilityByName("fighter_death_spawn")

    if abA then
        AddAbilityAndSetLevel(toUnit, "fighter_death_spawn", abA:GetLevel())
    end
end

function copyManaAndCD(fromUnit, toUnit)
    local unitName = fromUnit:GetUnitName()
    local blackList = {
        "element_seer_of_darkness",
        "element_fenix",
        "elf_crusader",
        "goblin_small_land_mine",
        "goblin_medium_land_mine",
        "goblin_ultra_land_mine",
        "goblin_goblin_alchemist",
        "goblin_goblin_blaster",
        "marine_egg_sack",
        "orc_blood_orc_warrior",
        "paladin_cavalier",


    }
    if TableContainsValue(blackList, unitName) then
        return
    end
    if unitName == "ghost_meridian" then
        toUnit:SetMana(math.max(toUnit:GetMana() - 120, 0))
    else
        toUnit:SetMana(fromUnit:GetMana())
    end

    local abilityCount = fromUnit:GetAbilityCount() or 0
    for i = 0, abilityCount - 1 do
        local ab = fromUnit:GetAbilityByIndex(i)
        local ab1 = nil
        if ab then
            ab1 = toUnit:FindAbilityByName(ab:GetAbilityName())
        end
        if ab1 and ab and not ab:IsCooldownReady() then
            local cd = ab:GetCooldownTimeRemaining()
            if cd > 0 then
                ab1:StartCooldown(cd)
            end
        end
    end
end

function PlayChaosBoltNum(target, stun, damage)
    local digit = 4
    if damage < 100 then digit = 3 end
    local digit1 = damage % 10
    local digit2 = math.floor((damage % 100) / 10)
    local digit3 = math.floor((damage % 1000) / 100)
    local number = digit3 * 100 + digit2 * 10 + digit1

    local nFXIndex = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_chaos_knight/chaos_knight_bolt_msg.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
    ParticleManager:SetParticleControl(nFXIndex, 0, target:GetOrigin())
    ParticleManager:SetParticleControl(nFXIndex, 1, Vector(0, number, 3))
    ParticleManager:SetParticleControl(nFXIndex, 2, Vector(2, digit, 0))
    ParticleManager:SetParticleControl(nFXIndex, 3, Vector(0, stun, 4))
    ParticleManager:SetParticleControl(nFXIndex, 4, Vector(2, 2, 0))
    ParticleManager:ReleaseParticleIndex(nFXIndex)
end

function UTIL:addUnitTag(unit, tagName, timeOut)
    if not unit then
        return
    end

    local index = unit:entindex()
    if not UTIL.tagMap[index] then
        UTIL.tagMap[index] = {}
    end
    local endTime = GameRules:GetGameTime() + timeOut
    if timeOut == -1 then
        endTime = -1
    end
    UTIL.tagMap[index][tagName] = {
        endTime = endTime
    }
end

function UTIL:addUnitTagAOE(ability, pos, radius, tagName, timeOut)
    local caster = ability:GetCaster()
    local unitsA = AiFindAbilityTarget(caster, ability, {
        pos = pos,
        radius = radius
    })
    for _, unit in ipairs(unitsA) do
        UTIL:addUnitTag(unit, tagName, timeOut)
    end
end

function UTIL:checkUnitTag(unit, tagName)
    if not unit then
        return false
    end
    local index = unit:entindex()
    if not UTIL.tagMap[index] then
        return false
    end
    local node = UTIL.tagMap[index][tagName]
    if not node then
        return false
    end
    if node.endTime >= GameRules:GetGameTime() then
        return true
    end
    return false
end

function UTIL:filterByUnitTag(units, tagName, isTagged)
    if not units then
        return {}
    end
    local res = {}
    for i, unit in ipairs(units) do
        local b = UTIL:checkUnitTag(unit, tagName)
        if isTagged and b then
            table.insert(res, unit)
        end
        if not isTagged and not b then
            table.insert(res, unit)
        end
    end
    return res
end

function UTIL:filterByFlying(units, flying)
    if not units then
        return {}
    end
    local res = {}
    for i, unit in ipairs(units) do
        local f = (flying and unit:HasFlyMovementCapability()) or (not flying and not unit:HasFlyMovementCapability())
        if f then
            table.insert(res, unit)
        end
    end
    return res
end

function UTIL:orderByUnitTag(units, tagName, asc)
    stableSort(units, function(a, b)
        local v1 = 0
        local v2 = 0
        if IsActiveUnit(a) and UTIL:checkUnitTag(a, tagName) then
            v1 = 1
        end
        if IsActiveUnit(b) and UTIL:checkUnitTag(b, tagName) then
            v2 = 1
        end
        if asc then
            return v1 < v2
        else
            return v1 > v2
        end
    end)
end

function UTIL:findDispellableBuffs(unit, isBuff, isBasicDispell)
    local res = {}
    for i = 0, unit:GetModifierCount() do
        local modName = unit:GetModifierNameByIndex(i)
        local mod = unit:FindModifierByName(modName)
        if modName and mod and mod.IsPurgable and mod:IsPurgable() then
            if isBasicDispell and mod.IsStunDebuff and mod:IsStunDebuff() then

            else
                if isBuff and mod.IsBuff and mod:IsBuff() then
                    table.insert(res, mod)
                end
                if not isBuff and mod.IsDebuff and mod:IsDebuff() then
                    table.insert(res, mod)
                end
            end
        end
    end
    return res
end

function UTIL:orderByModifier(units, modName, asc)
    stableSort(units, function(a, b)
        local v1 = 0
        local v2 = 0
        if IsActiveUnit(a) and a:HasModifier(modName) then
            v1 = 1
        end
        if IsActiveUnit(b) and b:HasModifier(modName) then
            v2 = 1
        end
        if asc then
            return v1 < v2
        else
            return v1 > v2
        end
    end)
end

function UTIL:unitDistance(unitA, unitB)
    return (unitA:GetAbsOrigin() - unitB:GetAbsOrigin()):Length2D()
end

function UTIL:SetXAngle(unit, angle)
    local angles = unit:GetAngles()
    unit:SetLocalAngles(angle, angles.y, angles.z)
end

function UTIL:SetForwardZ(unit, z)
    local v = unit:GetForwardVector()
    v.z = z
    unit:SetForwardVector(v)
end

function isEmptyTable(myTable)
    return type(myTable) == "table" and next(myTable) == nil
end

function getAbilityOvershootPoint(ability, params)
    if not params then
        params = {}
    end
    if not params.rangeBonus then
        params.rangeBonus = 0
    end
    if not params.alwaysMax then
        params.alwaysMax = false
    end
    if not params.minLength then
        params.minLength = 0
    end

    local caster = ability:GetCaster()
    local origin = caster:GetAbsOrigin()
    local point = ability:GetCursorPosition()
    local max_range = ability:GetEffectiveCastRange(caster:GetAbsOrigin(), nil) + params.rangeBonus
    -- determine target position
    local direction = (point - origin)
    if direction:Length2D() > max_range or params.alwaysMax then
        direction = direction:Normalized() * max_range
    end

    if direction:Length2D() < params.minLength then
        direction = direction:Normalized() * params.minLength
    end

    point = origin + direction
    return point
end

function SimpleKnockback(unit, ability, centerPos, time, distance, height, stun)
    if not distance then
        distance = -(newPos - unit:GetAbsOrigin()):Length2D()
    end

    local kv_knockback = {
        center_x = centerPos.x,
        center_y = centerPos.y,
        center_z = centerPos.z,
        should_stun = stun,
        duration = time,
        knockback_duration = time,
        knockback_distance = distance,
        knockback_height = height
    }
    local mod = unit:AddNewModifier(ability:GetCaster(), ability, "modifier_knockback", kv_knockback)
    return mod
end

function UTIL:IsKing(unit)
    if IsActiveUnit(unit) then
        if unit:GetUnitName() == "king_bad" or unit:GetUnitName() == "king_bad" then
            return true
        end
    end
    return false
end

function UTIL:HasScepter(unit)
    if not IsActiveUnit(unit) then
        return false
    end
    return unit:HasModifier("modifier_generic_agh_scepter")
end

function IsValid(h)
    return h ~= nil and not h:IsNull()
end

function StringToVector(sString)
    local temp = {}
    for str in string.gmatch(sString, "%S+") do
        if tonumber(str) then
            temp[#temp + 1] = tonumber(str)
        else
            return nil
        end
    end
    return Vector(temp[1], temp[2], temp[3])
end

function moveAttack(unit, pos)
    local t_order = {
        UnitIndex = unit:entindex(),
        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
        TargetIndex = nil,
        AbilityIndex = 0,
        Position = pos,
        Queue = false
    }
    ExecuteOrderFromTable(t_order)
end

function clearCreeps(creeps)
    for k, unit in pairs(creeps) do
        if IsActiveUnit(unit) then
            --unit:AddEffects(EF_NODRAW)
            unit:Kill(nil, nil)
        end
    end
end

-- function safeKillUnit(unit)
--     if IsActiveUnit(unit) then
--         unit:SetTeam(DOTA_TEAM_NEUTRALS)
--         unit:AddEffects(EF_NODRAW)
--         unit:Kill(nil, unit)
--         -- unit:ForceKill(false)
--     end
-- end

function findUnitByNpcName(npcName)
    local units = GamePlay.metaKv.units
    if units[npcName] then
        return npcName, units[npcName]
    end
    for key, value in pairs(units) do
        if string.find(key, npcName) and value.creepValue and value.creepValue > 0 then
            return key, value
        end
    end
end

if not UTIL_INITED then
    print("init util")
    VO_LIST = LoadKeyValues("scripts/npc/vo_list.txt")
    UTIL_INITED = true
end


if IsInToolsMode() then
    local CreateEffectFixProjectile = function(sEffectName)
        local hExplosion = {
            Ability           = nil,
            EffectName        = sEffectName,
            vSpawnOrigin      = Vector(0, 0, 0),
            fDistance         = 0,
            fStartRadius      = 0,
            fEndRadius        = 0,
            Source            = nil,
            bHasFrontalCone   = false,
            bReplaceExisting  = false,
            iUnitTargetTeam   = 0,
            iUnitTargetFlags  = 0,
            iUnitTargetType   = 0,
            fExpireTime       = GameRules:GetGameTime() + FrameTime(),
            --bDeleteOnHit        = false,
            vVelocity         = 0,
            bProvidesVision   = false,
            iVisionRadius     = 0,
            iVisionTeamNumber = 0,
            --ExtraData             = {}
        }
        return ProjectileManager:CreateLinearProjectile(hExplosion)
    end

    if not VALVE_ParticleManager_CreateParticle then
        VALVE_ParticleManager_CreateParticle = CScriptParticleManager.CreateParticle
        VALVE_ParticleManager_CreateParticleForPlayer = CScriptParticleManager.CreateParticleForPlayer
        VALVE_ParticleManager_CreateParticleForTeam = CScriptParticleManager.CreateParticleForTeam
    end

    CScriptParticleManager.CreateParticle = function(self, sParticleName, ...)
        local iProjectile = CreateEffectFixProjectile(sParticleName)
        if iProjectile and ProjectileManager:IsValidProjectile(iProjectile) then
            ProjectileManager:DestroyLinearProjectile(iProjectile)
            --print("HMMMMM")
        end
        -- print("Server: Overriding Gaben Particle Function...")
        return VALVE_ParticleManager_CreateParticle(self, sParticleName, ...)
    end
    CScriptParticleManager.CreateParticleForPlayer = function(self, sParticleName, ...)
        local iProjectile = CreateEffectFixProjectile(sParticleName)
        if iProjectile and ProjectileManager:IsValidProjectile(iProjectile) then
            ProjectileManager:DestroyLinearProjectile(iProjectile)
            --print("HMMMMM")
        end
        -- print("Server: Overriding Gaben Particle Function...")
        return VALVE_ParticleManager_CreateParticleForPlayer(self, sParticleName, ...)
    end
    CScriptParticleManager.CreateParticleForTeam = function(self, sParticleName, ...)
        local iProjectile = CreateEffectFixProjectile(sParticleName)
        if iProjectile and ProjectileManager:IsValidProjectile(iProjectile) then
            ProjectileManager:DestroyLinearProjectile(iProjectile)
            --print("HMMMMM")
        end
        -- print("Server: Overriding Gaben Particle Function...")
        return VALVE_ParticleManager_CreateParticleForTeam(self, sParticleName, ...)
    end
end
