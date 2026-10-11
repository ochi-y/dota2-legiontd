function MapWearables()
    GameRules.items = LoadKeyValues("scripts/items/items_game.txt")['items']
    GameRules.modelmap = {}
    for k, v in pairs(GameRules.items) do
        if v.name and v.prefab ~= "loading_screen" then
            GameRules.modelmap[v.name] = k
        end
    end
end
function GenerateDefaultBlock(heroName)
    print("    \"Creature\"")
    print("    {")
    print("        \"AttachWearables\" " .. "// Default " .. heroName)
    print("        {")
    local defCount = 1
    for code, values in pairs(GameRules.items) do
        if values.name and values.prefab == "default_item" and values.used_by_heroes then
            for k, v in pairs(values.used_by_heroes) do
                if k == heroName then
                    local itemID = GameRules.modelmap[values.name]
                    GenerateItemDefLine(defCount, itemID, values.name)
                    defCount = defCount + 1
                end
            end
        end
    end
    print("        }")
    print("    }")
end

function GenerateBundleBlock(setname)
    local bundle = {}
    for code, values in pairs(GameRules.items) do
        if values.name and values.name == setname and values.prefab and values.prefab == "bundle" then
            bundle = values.bundle
        end
    end

    print("    \"Creature\"")
    print("    {")
    print("        \"AttachWearables\" " .. "// " .. setname)
    print("        {")
    local wearableCount = 1
    for k, v in pairs(bundle) do
        local itemID = GameRules.modelmap[k]
        if itemID then
            GenerateItemDefLine(wearableCount, itemID, k)
            wearableCount = wearableCount + 1
        end
    end
    print("        }")
    print("    }")
end

function GenerateAllPart(heroName)
    local items={}
    for code, values in pairs(GameRules.items) do
        if values.name and values.used_by_heroes and type(values.used_by_heroes)=="table" and  values.used_by_heroes[heroName] and values.prefab == "wearable" then
            if not GameRules.budleItemMap[values.name] then
                table.insert(items,{values.name,values.item_rarity or "common",values.creation_date or "2000-00-00",code,values.item_type_name})
            end
       end
    end
    
    local item_rarityMap={
        ["common"]=1,
        ["uncommon"]=2,
        ["rare"]=3,
        ["mythical"]=4,
        ["legendary"]=5,
        ["immortal"]=6,
        ["arcana"]=7,
        ["ancient"]=8,
    }

    table.sort(items,function (a,b)
        local v1=item_rarityMap[a[2]] or 0
        local v2=item_rarityMap[b[2]] or 0
        if v1==v2 then
            return b[3]<a[3]
        else
            return v2<v1
        end
    end)

    for i, v in ipairs(items) do
        print(v[1],v[2],v[3],v[5])
        GenerateItemDefLine(1, v[4], v[1])

    end
end

function GenerateItemDefLine(i, itemID, comment)
    print("            \"" .. tostring(i) .. "\" { " .. "\"ItemDef\" \"" .. itemID .. "\" } // " .. comment)
end

function GenerateAllBundleBlock(heroName)
    

    if not GameRules.MapWearables then
        MapWearables()
    end
    GameRules.MapWearables = true
    
    local bundleList = {}


    local item_rarityMap = {
        ["common"] = 1,
        ["uncommon"] = 2,
        ["rare"] = 3,
        ["mythical"] = 4,
        ["legendary"] = 5,
        ["immortal"] = 6,
        ["arcana"] = 7,
        ["ancient"] = 8
    }


    for code, values in pairs(GameRules.items) do
        if values.name and values.used_by_heroes and type(values.used_by_heroes) == "table" and
            values.used_by_heroes[heroName] and values.prefab and values.prefab == "bundle" then
            table.insert(bundleList, {values.name, values.item_rarity or "common", values.creation_date or "2000-00-00"})
        end
    end

    table.sort(bundleList, function(a, b)
        -- local v1=item_rarityMap[a[2]] or 0
        -- local v2=item_rarityMap[b[2]] or 0
        -- if v1==v2 then
        return b[3] < a[3]
        -- else
        --     return v2<v1
        -- end
    end)

    for i, v in ipairs(bundleList) do
        print("----------------------------------------------------")
        print(v[1], v[2], v[3])
        GenerateBundleBlock(v[1])
    end

    GameRules.budleItemMap={}

    for code, values in pairs(GameRules.items) do
        if values.name and values.prefab=="bundle" and type(values.bundle)=="table" then
            for k, v in pairs(values.bundle) do
                GameRules.budleItemMap[k]=1
            end
        end
    end

end

function GenerateAllImmortal(heroName)
    local itemList = {}

    local item_rarityMap = {
        ["common"] = 1,
        ["uncommon"] = 2,
        ["rare"] = 3,
        ["mythical"] = 4,
        ["legendary"] = 5,
        ["immortal"] = 6,
        ["arcana"] = 7,
        ["ancient"] = 8
    }

    for code, values in pairs(GameRules.items) do
        if values.name and values.used_by_heroes and type(values.used_by_heroes) == "table" and
            values.used_by_heroes[heroName] and values.prefab and values.prefab == "wearable" and
            item_rarityMap[values.item_rarity] and item_rarityMap[values.item_rarity] >= 6 then
            table.insert(itemList,
                {code, values.name, values.item_rarity or "common", values.creation_date or "2000-00-00"})
        end
    end

    for i, v in ipairs(itemList) do
        print("----------------------------------------------------")
        print(v[1], v[2], v[3], v[4])
        GenerateItemDefLine(1, v[1], v[2])
    end
end

function GenRoundTxt()
    for i = 1, 10 do
        print(Format('"round_{0}" "Round {1}"', i, i))
    end
    for i = 12, 21 do
        print(Format('"round_{0}" "Round {1}"', i, i - 1))
    end
    for i = 23, 33 do
        print(Format('"round_{0}" "Round {1}"', i, i - 2))
    end
end

-- Timers:CreateTimer(0,function ()
--     GenRoundTxt()
-- end)

function GenerateLocalizeFile(filePath, type)
    local kvs = LoadKeyValues(filePath)
    local strs = {}
    for k, v in pairs(kvs) do
        if type == "unit" then
            table.insert(strs, Format("\"{0}\" \"\"", k))
        end
        if type == "item" then
            table.insert(strs, Format("\"DOTA_Tooltip_ability_{0}\"								\"\"", k))
            table.insert(strs, Format("\"DOTA_Tooltip_ability_{0}_Description\"								\"\"", k))
        end
        if type == "ability" then
            table.insert(strs, Format("\"DOTA_Tooltip_ability_{0}\" \"\"", k))
            table.insert(strs, Format("\"DOTA_Tooltip_ability_{0}_Description\" \"\"", k))
            local spKv = v["AbilitySpecial"]
            if spKv then
                for _, v1 in pairs(spKv) do
                    for k2, _ in pairs(v1) do
                        if k2 ~= "var_type" then
                            local tokens = mysplit(k2, "_")
                            local k2s = ""
                            for _, s in ipairs(tokens) do
                                if k2s ~= "" then
                                    k2s = k2s .. " "
                                end
                                k2s = k2s .. string.upper(s)
                            end
                            table.insert(strs, Format("\"DOTA_Tooltip_ability_{0}_{1}\" \"{2}\"", k, k2, k2s))
                        end
                    end
                end
            end
        end
        if type == "abilityCost" then
            table.insert(strs, Format("\"DOTA_Tooltip_ability_{0}_gold\" \"Gold\"", k))
            table.insert(strs, Format("\"DOTA_Tooltip_ability_{0}_wood\" \"Wood\"", k))
            table.insert(strs, Format("\"DOTA_Tooltip_ability_{0}_food\" \"Food\"", k))
        end
        if type == "building" then
            table.insert(strs, Format('"DOTA_Tooltip_ability_{0}"								"Deploy XX"', k))
            table.insert(strs, Format(
                '"DOTA_Tooltip_ability_{0}_Description"								"XX Attack<br>XX Armor<br>Ability: <font color=\'#03fceb\'>XX</font>"',
                k))
            table.insert(strs, Format('"DOTA_Tooltip_ability_{0}_gold" "<font color=\'#E6DB74\'>GOLD COST</font>"', k))
            table.insert(strs, Format('"DOTA_Tooltip_ability_{0}_food" "<font color=\'#9b41bf\'>FOOD COST</font>"', k))
            table.insert(strs, Format('"DOTA_Tooltip_ability_{0}_damage" "Damage"', k))
            table.insert(strs, Format('"DOTA_Tooltip_ability_{0}_speed" "Attack Speed"', k))
            table.insert(strs, Format('"DOTA_Tooltip_ability_{0}_range" "Range"', k))
            table.insert(strs, Format('"DOTA_Tooltip_ability_{0}_hit_points" "Hit Points"', k))
        end
        if type == "barrack" then
            table.insert(strs, Format('"DOTA_Tooltip_ability_{0}"								"Deploy XX"', k))
            table.insert(strs, Format(
                '"DOTA_Tooltip_ability_{0}_Description"								"XX Attack<br>XX Armor<br>Ability: <font color=\'#03fceb\'>XX</font>"',
                k))
            table.insert(strs, Format('"DOTA_Tooltip_ability_{0}_wood" "<font color=\'#00c3ff\'>Wood Cost</font>"', k))
            table.insert(strs, Format('"DOTA_Tooltip_ability_{0}_damage" "Damage"', k))
            table.insert(strs, Format('"DOTA_Tooltip_ability_{0}_speed" "Attack Speed"', k))
            table.insert(strs, Format('"DOTA_Tooltip_ability_{0}_range" "Range"', k))
            table.insert(strs, Format('"DOTA_Tooltip_ability_{0}_hit_points" "Hit Points"', k))
            table.insert(strs, Format(
                '"DOTA_Tooltip_ability_{0}_need_round" "<font color=\'#f6fa05\'>Require Round</font>"', k))
            table.insert(strs,
                Format('"DOTA_Tooltip_ability_{0}_income" "<font color=\'#00ff11\'>Add Income</font>"', k))
        end
        table.insert(strs, "\n")
    end
    -- table.sort(strs,function (a, b)
    --     return a<b
    -- end)
    for i = 1, #strs do
        print(strs[i])
    end
end




function GenerateAbilityLocalizeFile(abilityName)
    print("")
    local strs = {}
    local abilityKv = KeyValues.All[abilityName]
    table.insert(strs, Format("\"DOTA_Tooltip_ability_{0}\" \"{1}\"", abilityName, abilityName))
    table.insert(strs, Format("\"DOTA_Tooltip_ability_{0}_Description\" \"{1}\"", abilityName, abilityName))

    local AbilityValues = abilityKv["AbilityValues"]
    if AbilityValues then
        for k1, v1 in pairs(AbilityValues) do
            local tokens = mysplit(k1, "_")
            local k2s = ""
            for _, s in ipairs(tokens) do
                if k2s ~= "" then
                    k2s = k2s .. " "
                end
                k2s = k2s .. string.upper(s)
            end
            table.insert(strs, Format("\"DOTA_Tooltip_ability_{0}_{1}\" \"{2}\"", abilityName, k1, k2s))
        end
    end
    for i = 1, #strs do
        print(strs[i])
    end
    print("")
end

if IsInToolsMode() and LOAD_WEARABLE then
    if not GameRules.MapWearables then
        MapWearables()
    end
    GameRules.MapWearables = true
end

function genWearable(cloth)
    if cloth then

        if startWith(cloth, "npc_") then
            GenerateDefaultBlock(cloth)
        else
            GenerateBundleBlock(cloth)
        end
    end
end


function dumpTableAsKv_h(t, indent, done)
    -- print ( string.format ('PrintTable type %s', type(keys)) )
    if type(t) ~= "table" then
        return
    end

    done = done or {}
    done[t] = true
    indent = indent or 0

    local l = {}
    for k, v in pairs(t) do
        table.insert(l, k)
    end

    print(string.rep("    ", indent)  .. "{")

    table.sort(l)
    for k, v in ipairs(l) do
        -- Ignore FDesc
        if v ~= 'FDesc' then
            local value = t[v]

            if type(value) == "table" and not done[value] then
                done[value] = true
                print(string.rep("    ", indent+1) .. "\""..tostring(v).. "\"" .. "")
                dumpTableAsKv_h(value, indent + 1, done)
            elseif type(value) == "userdata" and not done[value] then
                done[value] = true
                print(string.rep("    ", indent) .. tostring(v) .. ": " .. tostring(value))
                dumpTableAsKv_h((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2,
                    done)
            else
                if t.FDesc and t.FDesc[v] then
                    print(string.rep("    ", indent) .. tostring(t.FDesc[v]))
                else
                    print(string.rep("    ", indent+1) .. "\""..tostring(v).. "\"" .. " " .. "\""..tostring(value).."\"")
                end
            end
        end
    end
    print(string.rep("    ", indent)  .. "}")

end
function dumpTableAsKv(data)
    dumpTableAsKv_h(data,0,false)
end
function dumpWaves()
    local waves={}
    for index, round in ipairs(roundInfo) do
        if isFalse(round.duel) and not round.test then
            table.insert(waves,round)
            print(Format('background-image: url("file://{images}/custom_game/waves/{0}.png");',round.unit))
        end
    end
    -- dumpTableAsKv(waves)
end

-- Timers:CreateTimer(0.1,function ()
--     dumpWaves()
-- end)


if IsInToolsMode() then
    --GenerateAbilityLocalizeFile("war3_aerial_shackles")
end

-- genWearable("npc_dota_hero_sand_king")

-- scripts/npc/npc_items_custom.txt
-- scripts/npc/units/npc_yemanren.txt
-- scripts/npc/abilities/npc_abilities_yemanren.txt
-- GenerateLocalizeFile("scripts/npc/npc_items_custom.txt","abilityCost")
-- generate unit wearable

-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_beast_building.txt","building")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_beast.txt","ability")
-- GenerateLocalizeFile("scripts/npc/units/npc_units_beast.txt","unit")

-- GenerateLocalizeFile("scripts/npc/units/npc_units_building.txt","unit")

-- GenerateLocalizeFile("scripts/npc/units/npc_units_barrack.txt","unit")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_barrack_building.txt","barrack")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_barrack.txt","ability")
-- GenerateLocalizeFile("scripts/npc/units/npc_units_wave.txt","unit")
-- GenerateLocalizeFile("scripts/npc/units/npc_units_wave_champion.txt","unit")
-- GenerateLocalizeFile("scripts/npc/units/npc_units_demi_human.txt","unit")

-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_demi_human_building.txt","building")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_demi_human.txt","ability")

-- GenerateLocalizeFile("scripts/npc/units/npc_units_undead.txt","unit")

-- GenerateLocalizeFile("scripts/npc/units/npc_units_undead.txt","unit")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_undead_building.txt","building")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_undead.txt","ability")

-- GenerateLocalizeFile("scripts/npc/units/npc_units_orc.txt","unit")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_orc_building.txt","building")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_orc.txt","ability")

-- GenerateLocalizeFile("scripts/npc/units/npc_units_elf.txt","unit")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_elf_building.txt","building")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_elf.txt","ability")

-- GenerateLocalizeFile("scripts/npc/units/npc_units_element.txt","unit")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_element_building.txt","building")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_element.txt","ability")

-- GenerateLocalizeFile("scripts/npc/units/npc_units_goblin.txt","unit")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_goblin_building.txt","building")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_goblin.txt","ability")

-- GenerateLocalizeFile("scripts/npc/units/npc_units_ghost.txt","unit")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_ghost_building.txt","building")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_ghost.txt","ability")

-- GenerateLocalizeFile("scripts/npc/units/npc_units_mech.txt","unit")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_mech_building.txt","building")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_ghost.txt","ability")

-- GenerateLocalizeFile("scripts/npc/units/npc_units_marine.txt","unit")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_marine_building.txt","building")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_marine.txt","ability")

-- GenerateLocalizeFile("scripts/npc/units/npc_units_arctic.txt","unit")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_arctic_building.txt","building")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_arctic.txt","ability")

-- GenerateLocalizeFile("scripts/npc/units/npc_units_shadow.txt","unit")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_shadow_building.txt","building")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_shadow.txt","ability")

-- GenerateLocalizeFile("scripts/npc/units/npc_units_paladin.txt","unit")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_paladin_building.txt","building")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_shadow.txt","ability")

-- GenerateLocalizeFile("scripts/npc/units/npc_units_nature.txt","unit")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_nature_building.txt","building")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_nature.txt","ability")

-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_paladin.txt","ability")
-- GenerateLocalizeFile("scripts/npc/abilities/npc_ability_mech.txt","ability")
