var kv3tojs = require('./lib/kv3parser');
const fs = require('fs');
var glob = require("glob");
const util = require('util');
var obj2kv = require('./lib/obj2kv'); // used for particle files
let path = require('path');
var obj2kv1 = require('./lib/obj2kv1'); // used for npc files

const { mainModule, exit } = require('process');
const { spawn } = require('child_process');
const { loadMetaConfig } = require('./meta_config');

const gUnits = {}
const gAbilities = {}

let gEnglishKv = {}

// Whether AllGoldCost and AllFoodCost are written back into the unit files
const WRITE_ALL_COSTS_TO_KV = false


let meta = {
    items: {},
    abilities: {},
    units: {},
    heroes: {},
    builders: []
}

function toFiniteNumber(value, defaultValue = 0) {
    const numberValue = Number(value)
    return Number.isFinite(numberValue) ? numberValue : defaultValue
}

function finiteString(value, defaultValue = 0) {
    return String(toFiniteNumber(value, defaultValue))
}

function average(values) {
    if (values.length === 0) {
        return 0
    }

    return values.reduce((sum, value) => sum + value, 0) / values.length
}

function percentile(sortedValues, percent) {
    if (sortedValues.length === 0) {
        return 0
    }

    const index = (sortedValues.length - 1) * percent
    const lowerIndex = Math.floor(index)
    const upperIndex = Math.ceil(index)

    if (lowerIndex === upperIndex) {
        return sortedValues[lowerIndex]
    }

    const weight = index - lowerIndex
    return sortedValues[lowerIndex] * (1 - weight) + sortedValues[upperIndex] * weight
}

function createStatSummary(values) {
    const sortedValues = values.slice().sort((a, b) => a - b)
    const total = values.reduce((sum, value) => sum + value, 0)
    const q1 = percentile(sortedValues, 0.25)
    const q3 = percentile(sortedValues, 0.75)
    const iqr = q3 - q1

    return {
        count: values.length,
        total: total,
        average: average(values),
        min: sortedValues.length > 0 ? sortedValues[0] : 0,
        max: sortedValues.length > 0 ? sortedValues[sortedValues.length - 1] : 0,
        q1: q1,
        q3: q3,
        lowerBound: q1 - iqr * 1.5,
        upperBound: q3 + iqr * 1.5
    }
}

function formatStatNumber(value) {
    return toFiniteNumber(value).toFixed(6)
}

function printUnitValueOutliers(title, units, fieldName, summary) {
    const outliers = units
        .filter(unit => unit[fieldName] < summary.lowerBound || unit[fieldName] > summary.upperBound)
        .sort((a, b) => b[fieldName] - a[fieldName])

    console.log(`  ${title} outliers: ${outliers.length}`)

    if (outliers.length === 0) {
        return
    }

    console.log(`    bounds: < ${formatStatNumber(summary.lowerBound)} or > ${formatStatNumber(summary.upperBound)}`)

    for (const unit of outliers) {
        console.log(`    - ${unit.name} [${unit.race}] ${fieldName}=${formatStatNumber(unit[fieldName])}, gold=${unit.gold}`)
    }
}

function printUnitValueStats(unitValueStats) {
    console.log("\nUnit value stats:")

    if (unitValueStats.length === 0) {
        console.log("  No unit data to summarize")
        return
    }

    const dpsValues = unitValueStats.map(unit => unit.dpsPerGold)
    const hpValues = unitValueStats.map(unit => unit.hpPerGold)
    const dpsSummary = createStatSummary(dpsValues)
    const hpSummary = createStatSummary(hpValues)

    console.log(`  usable units: ${unitValueStats.length}`)
    console.log(`  DpsPerGold total: ${formatStatNumber(dpsSummary.total)}, average: ${formatStatNumber(dpsSummary.average)}, min: ${formatStatNumber(dpsSummary.min)}, max: ${formatStatNumber(dpsSummary.max)}`)
    console.log(`  HealthPerGold total: ${formatStatNumber(hpSummary.total)}, average: ${formatStatNumber(hpSummary.average)}, min: ${formatStatNumber(hpSummary.min)}, max: ${formatStatNumber(hpSummary.max)}`)

    printUnitValueOutliers("DpsPerGold", unitValueStats, "dpsPerGold", dpsSummary)
    printUnitValueOutliers("HealthPerGold", unitValueStats, "hpPerGold", hpSummary)
}

function getUnitValueOutliers(units, fieldName, summary) {
    return units
        .filter(unit => unit[fieldName] < summary.lowerBound || unit[fieldName] > summary.upperBound)
        .sort((a, b) => b[fieldName] - a[fieldName])
}

function isEnabled(value) {
    return value === true || value === 1 || value === "1" || value === "true"
}

function filterEnabledOtherFighters(otherFighters) {
    const result = Object.assign({}, otherFighters || {})
    const building = Array.isArray(result.building) ? result.building : []

    result.building = building.filter(fighter => isEnabled(fighter && fighter.enabled))

    return result
}

if (!String.prototype.format) {
    String.prototype.format = function() {
        var args = arguments;
        return this.replace(/{(\d+)}/g, function(match, number) {
            return typeof args[number] != 'undefined' ?
                args[number] :
                match;
        });
    };
}

function parseKv3(file) {
    let content = fs.readFileSync(file, { encoding: 'utf8' });
    // if (content[0] == '"') {
    //     console.log(120)
    // }
    // content = "{" + content + "}"
    return kv3tojs.parse(content);
}

// const allUnitFolderList = [
//     "./game/scripts/npc/units/*.txt",
// ]

const unitFolder = "./game/scripts/npc/units/**/npc_units_+(beast|element|paladin|goblin|nature|ghost|undead|mech|shadow|arctic|marine|orc|elf|demi_human|wave|barrack|foulfell|radiant|other_fighter).txt"

const allAbilitiesFiles = "./game/scripts/npc/abilities/**.txt"

const allItemsFiles = "./game/scripts/npc/npc_items_custom.txt"

const metaAbilityFolder = [
    "./game/scripts/npc/abilities/**/npc_ability_*_building.txt",
    "./game/scripts/npc/abilities/npc_ability_barrack_buy.txt",
    "./game/scripts/npc/abilities/npc_ability_gameplay.txt",
    "./game/scripts/npc/npc_items_custom.txt",
]





function saveKv(data, filePath) {
    var fileStr = obj2kv1.obj2kv1(data)
    fs.mkdirSync(path.dirname(filePath), { recursive: true })
    fs.writeFileSync(filePath, fileStr);
}

const META_KEYS = [
    "items",
    "abilities",
    "units",
    "heroes",
    "builders",
    "otherFighters",
    "summons",
    "king",
    "waves",
]

function saveMetaKvs(data, folderPath) {
    fs.mkdirSync(folderPath, { recursive: true })

    for (const key of META_KEYS) {
        const filePath = path.join(folderPath, key + ".kv")
        saveKv({ [key]: data[key] || {} }, filePath)
        console.log(`✓ KV file saved: ${filePath}`)
    }

    const legacyFilePath = "./game/scripts/npc/npc_meta.kv"
    if (fs.existsSync(legacyFilePath)) {
        fs.unlinkSync(legacyFilePath)
        console.log(`✓ Removed the legacy KV file: ${legacyFilePath}`)
    }
}

function saveJson(data, filePath) {
    var fileStr = JSON.stringify(data,null,4)
    fs.mkdirSync(path.dirname(filePath), { recursive: true })
    fs.writeFileSync(filePath, fileStr);
}
function isObject(item) {
    return (item && typeof item === 'object' && !Array.isArray(item));
}

function parseUnitToMeta(name, unitKv) {

    let res = {}

    let attrs = [
        "AttackRate",
        "BaseAttackSpeed",
        "AttackRange",
        "StatusHealth",
        "StatusHealthRegen",
        "StatusMana",
        "StatusManaRegen",
        "AttackDamageMin",
        "AttackDamageMax",
        "MovementSpeed",
        "AttackType",
        "ArmorType",
        "ArmorPhysical",
        "BountyGoldMin",
        "BountyGoldMax",
        "AttackCapabilities",
        "MovementCapabilities",
        "scepterAbility",
        "race",
        "UnitCountLimit"
    ]


    res["abilities"] = []
    res["upgrades"] = []

    for (let index = 1; index < 10; index++) {
        let ab = unitKv["Ability" + index]

        if (ab) {
            let abilityKv = gAbilities[ab]
            let flag = true
            let blackList = ["sell_building","toggle_debuff_maker","ai_clear_target","upgrade_fighter_level","learn_fighter_ultimate_ability"]

            if (blackList.indexOf(ab) != -1) {
                flag = false
                continue
            }
            if (ab.indexOf("ability_empty") != -1) {
                flag = false
                continue
            }
            
            if (ab.startsWith("upgrade_")) {
                res["upgrades"].push(ab.substring(8))
                flag = false
            }
            if (abilityKv && abilityKv.IsOnCastBar == 0) {
                flag = false
            }
            if (abilityKv && abilityKv.isUltimateAbility == 1) {
                flag = false
            }
            if (abilityKv && abilityKv.AbilityBehavior && abilityKv.AbilityBehavior.indexOf("DOTA_ABILITY_BEHAVIOR_HIDDEN") != -1) {
                flag = false
            }
            if (flag) {
                res["abilities"].push(ab)
            }
        }
    }
    // 
    for (const attr of attrs) {
        if (unitKv[attr]) {
            res[attr] = unitKv[attr]
        }
    }
    // 
    return res
}

function parseAbilityToMeta(name, unitKv) {
    let res = {}

    let attrs = [
        "AbilityCooldown",
        "AbilityCharges",
        "AbilityChargeRestoreTime",
        "AbilityManaCost",
        "IsSummonAbility",
        "LegionUiType"
    ]

 //   res["IsSummonAbility"] = "1"

    for (const attr of attrs) {
        if (unitKv[attr]) {
            res[attr] = unitKv[attr]
        }
    }

    res["Summon"] = {}

    res["Summon"].SummonUnit = name.substring(name.indexOf("_") + 1)

    if (unitKv.AbilityValues) {
        for (const key in unitKv.AbilityValues) {
            res["Summon"][key] = unitKv.AbilityValues[key]
        }
    }

    if (unitKv.AbilitySpecial) {
        for (const key in unitKv.AbilitySpecial) {
            for (const k1 in unitKv.AbilitySpecial[key]) {
                if (k1 != "var_type") {
                    res["Summon"][k1] = unitKv.AbilitySpecial[key][k1]
                }
            }
        }
    }

    return res

}

function getAllSubFighters(unitName) {
    let res = []
    res.push(unitName)
    if(unitName=="fighter_level"){
        return res
    }
    let upgrades = meta.units[unitName].upgrades

    for (const name of upgrades) {
        let subs = getAllSubFighters(name)
        res = res.concat(subs)
    }
    return res
}

function parseBuilderToMeta(name, raceName, raceData) {
    //
    let builder = {
        buildings: [],
        fighters: [],
        name: name,
        race: raceName
    }

    // Use the building field from metas/races.json
    if (name != "npc_dota_hero_morphling" && raceData && raceData.building) {
        for (const unitName of raceData.building) {
            // the building field stores unit names directly
            builder.buildings.push(unitName)
            builder.fighters = builder.fighters.concat(getAllSubFighters(unitName))
        }
    }


    //
    return builder
}

function calUnitFood(unitName) {
    let unit = meta.units[unitName]
    if (!unit) {
        return 0
    }
    let ab = meta.abilities["build_" + unitName]
    if (!ab) {
        ab = meta.abilities["upgrade_" + unitName]
    }

    if (!ab) {
        return 0
    }
    let selfValue = Number(ab.Summon.food || 0)

    for (const key in meta.units) {
        let unitKv = meta.units[key]
        if (unitKv.upgrades) {
            for (const upgrade of unitKv.upgrades) {
                if (upgrade == unitName) {
                    selfValue += calUnitFood(key)
                }
            }
        }
    }
    return selfValue

}
function calUnitValue(unitName) {
    let unit = meta.units[unitName]
    if (!unit) {
        return 0
    }
    let ab = meta.abilities["build_" + unitName]
    if (!ab) {
        ab = meta.abilities["upgrade_" + unitName]
    }

    if (!ab) {
        return 0
    }
    let selfValue = Number(ab.Summon.gold || 0)
   

    for (const key in meta.units) {
        let unitKv = meta.units[key]
        if (unitKv.upgrades) {
            for (const upgrade of unitKv.upgrades) {
                if (upgrade == unitName) {
                    selfValue += calUnitValue(key)
                }
            }
        }
    }
    return selfValue

}
String.prototype.ucfirst = function() {
    // Split the string into words if string contains multiple words.
    var x = this.split(/\s+/g);
    for (var i = 0; i < x.length; i++) {
        // Splits the word into two parts. One part being the first letter,
        // second being the rest of the word.
        var parts = x[i].match(/(\w)(\w*)/);

        // Put it back together but uppercase the first letter and lowercase the 
        // rest of the word.
        x[i] = parts[1].toUpperCase() + parts[2].toLowerCase();
    } /* www. java  2  s. co m*/

    // Rejoin the string and return.
    return x.join(' ');
};

function dumpBuilding() {
    let unitMap = {}
    for (let index = 1; index <= 6; index++) {
        unitMap[index] = []
    }
    for (const index in meta.builders) {
        let kv = meta.builders[index]
        let buildings = kv.buildings
        for (const key in buildings) {
            unitMap[Number(key) + 1].push(buildings[key])
        }
    }


    for (const key in unitMap) {
        let units = unitMap[key]
        let totalValue = 0
        for (const unitName of units) {
            let creepValue = Number(meta.units[unitName].creepValue)
           // let creepValue = Number(meta.units[unitName].creepValue)
            totalValue += creepValue
        }
    }

}

function localize(key) {
    return gEnglishKv[key] || key
}

function writeAllCostsToKv(files) {
    // Walk every unit file
    for (const filePath of files) {
        // Skip the barrack and wave unit files
        if (filePath.includes('npc_units_barrack.txt') || filePath.includes('npc_units_wave.txt')) {
            continue
        }

        // Parse the KV file
        let kvData = parseKv3(filePath)
        let hasChanges = false

        // Walk every unit in the file
        for (const unitName in kvData["DOTAUnits"]) {
            // Skip base units
            if (unitName.includes('_base')) {
                continue
            }

            let unitKv = kvData["DOTAUnits"][unitName]

            // Work out AllGoldCost and AllFoodCost
            let allGoldCost = calUnitValue(unitName)
            let allFoodCost = calUnitFood(unitName)

            // Only write them into the KV when they are positive
            if (allGoldCost > 0) {
                unitKv.AllGoldCost = String(allGoldCost)
                hasChanges = true
            }
            if (allFoodCost > 0) {
                unitKv.AllFoodCost = String(allFoodCost)
                hasChanges = true
            }
        }

        // Save the file when anything changed
        if (hasChanges) {
            let fileStr = obj2kv1.objToNpcKv(kvData)
            fs.mkdirSync(path.dirname(filePath), { recursive: true })
            fs.writeFileSync(filePath, fileStr)
            console.log(`  ✓ Updated: ${filePath}`)
        }
    }
}

// Recursively collect every unit name from a unit tree
function getAllUnitsFromTree(tree) {
    let units = []
    if (tree.name) {
        units.push(tree.name)
    }
    if (tree.upgrades && Array.isArray(tree.upgrades)) {
        for (const upgrade of tree.upgrades) {
            units = units.concat(getAllUnitsFromTree(upgrade))
        }
    }
    return units
}

// Generate the active fighter list
function generateActiveFighters() {
    console.log("\nGenerating the active fighter list...")

    // Read the unit tree config
    let unitTreeData = JSON.parse(fs.readFileSync("./scripts/data/metas/unit_tree.json", { encoding: 'utf8' }))

    let activeFighters = {}

    // Walk every race
    for (const raceName in unitTreeData) {
        const race = unitTreeData[raceName]
        if (race.trees && Array.isArray(race.trees)) {
            // Walk every unit tree
            for (const tree of race.trees) {
                let units = getAllUnitsFromTree(tree)
                // Add every unit to the active fighter list
                for (const unitName of units) {
                    activeFighters[unitName] = {}
                }
            }
        }
    }

    // Save as KV
    saveKv({ units: activeFighters }, "./game/scripts/npc/meta/active_fighter.kv")
    console.log(`✓ Active fighter list saved: ./game/scripts/npc/meta/active_fighter.kv`)
    console.log(`  ${Object.keys(activeFighters).length} fighter units in total`)
}

// Analyze the stats of every unit
function analyzeUnitStats() {
    console.log("\n\n======================================")
    console.log("Analyzing unit stats...")
    console.log("======================================")

    // Read the unit tree config
    console.log("\n[1/4] Reading the unit tree config...")
    let unitTreeData = JSON.parse(fs.readFileSync("./scripts/data/metas/unit_tree.json", { encoding: 'utf8' }))

    // Collect every unit name
    let allUnitNames = []
    for (const raceName in unitTreeData) {
        const race = unitTreeData[raceName]
        if (race.trees && Array.isArray(race.trees)) {
            for (const tree of race.trees) {
                let units = getAllUnitsFromTree(tree)
                for (const unitName of units) {
                    allUnitNames.push({
                        name: unitName,
                        race: raceName
                    })
                }
            }
        }
    }

    console.log(`  ✓ ${allUnitNames.length} units found in the unit tree`)

    // Read the unit KV data of every race
    console.log("\n[2/4] Reading unit KV data...")
    let unitsDataMap = {}

    const allRaces = ["beast", "element", "paladin", "goblin", "nature", "ghost", "undead", "mech", "shadow", "arctic", "marine", "orc", "elf", "demi_human", "prophet", "hybrid"]

    for (const race of allRaces) {
        const unitFilePath = `./game/scripts/npc/units/npc_units_${race}.txt`

        try {
            let unitsKvData = parseKv3(unitFilePath)
            let unitsKv = unitsKvData.DOTAUnits

            for (const unitName in unitsKv) {
                unitsDataMap[unitName] = {
                    unitKv: unitsKv[unitName],
                    race: race
                }
            }

            console.log(`  ✓ ${race} data loaded`)
        } catch (err) {
            console.log(`  ⚠ no unit file for ${race}, skipping`)
        }
    }

    console.log(`  ✓ KV data loaded for ${Object.keys(unitsDataMap).length} units`)

    // DPS, health, DPS per gold and health per gold for every unit
    console.log("\n[3/4] Calculating unit stats...")
    let validUnits = []

    for (const unitInfo of allUnitNames) {
        const unitName = unitInfo.name
        const unitData = unitsDataMap[unitName]

        if (!unitData) {
            console.log(`  ⚠ Warning: unit ${unitName} was not found in the KV files`)
            continue
        }

        const unitKv = unitData.unitKv

        // Required fields
        if (!unitKv.BaseAttackSpeed || !unitKv.AttackRate || !unitKv.AttackDamageMin || !unitKv.AttackDamageMax || !unitKv.StatusHealth || !unitKv.AllGoldCost) {
            continue
        }

        const baseAttackSpeed = toFiniteNumber(unitKv.BaseAttackSpeed)
        const attackRate = toFiniteNumber(unitKv.AttackRate)
        const attackDamageMin = toFiniteNumber(unitKv.AttackDamageMin)
        const attackDamageMax = toFiniteNumber(unitKv.AttackDamageMax)
        const statusHealth = toFiniteNumber(unitKv.StatusHealth)
        const allGoldCost = toFiniteNumber(unitKv.AllGoldCost)

        // Skip units with a price of 0
        if (allGoldCost <= 0) {
            continue
        }

        // DPS = average damage / attack interval
        // attack interval = AttackRate / (BaseAttackSpeed / 100)
        const attackInterval = baseAttackSpeed === 0 ? 0 : attackRate / (baseAttackSpeed / 100)
        const avgDamage = (attackDamageMin + attackDamageMax) / 2
        const dps = attackInterval === 0 ? 0 : avgDamage / attackInterval

        // DPS per gold
        const dpsPerGold = allGoldCost === 0 ? 0 : dps / allGoldCost

        // HP per gold
        const hpPerGold = allGoldCost === 0 ? 0 : statusHealth / allGoldCost

        validUnits.push({
            name: unitName,
            race: unitInfo.race,
            dps: dps,
            hp: statusHealth,
            gold: allGoldCost,
            dpsPerGold: dpsPerGold,
            hpPerGold: hpPerGold,
            baseAttackSpeed: baseAttackSpeed,
            attackRate: attackRate,
            attackDamageMin: attackDamageMin,
            attackDamageMax: attackDamageMax
        })
    }

    console.log(`  ✓ ${validUnits.length} units with usable data`)

    // Nothing more to do without usable units
    if (validUnits.length === 0) {
        console.log("\n⚠ No usable unit data found")
        return
    }

    // Averages
    console.log("\n[4/4] Calculating averages and percentages...")
    let totalDpsPerGold = 0
    let totalHpPerGold = 0

    for (const unit of validUnits) {
        totalDpsPerGold += unit.dpsPerGold
        totalHpPerGold += unit.hpPerGold
    }

    const avgDpsPerGold = totalDpsPerGold / validUnits.length
    const avgHpPerGold = totalHpPerGold / validUnits.length
    const dpsSummary = createStatSummary(validUnits.map(unit => unit.dpsPerGold))
    const hpSummary = createStatSummary(validUnits.map(unit => unit.hpPerGold))
    const dpsOutliers = getUnitValueOutliers(validUnits, "dpsPerGold", dpsSummary)
    const hpOutliers = getUnitValueOutliers(validUnits, "hpPerGold", hpSummary)

    console.log(`  ✓ average DPS per gold: ${avgDpsPerGold.toFixed(6)}`)
    console.log(`  ✓ average HP per gold: ${avgHpPerGold.toFixed(6)}`)

    // Percentage against the average, for every unit
    for (const unit of validUnits) {
        unit.dpsPerGoldPercent = (unit.dpsPerGold / avgDpsPerGold * 100)
        unit.hpPerGoldPercent = (unit.hpPerGold / avgHpPerGold * 100)
    }

    console.log(`  ✓ percentages calculated`)

    // Write the report
    console.log("\nGenerating the stats report...")

    let output = []
    output.push("=" .repeat(120))
    output.push("Unit Stats Analysis Report")
    output.push("=" .repeat(120))
    output.push("")
    output.push(`Generated at: ${new Date().toLocaleString('en-US')}`)
    output.push(`Units analyzed: ${validUnits.length}`)
    output.push(`Data source: scripts/data/metas/unit_tree.json`)
    output.push("")
    output.push("=" .repeat(120))
    output.push("Summary")
    output.push("=" .repeat(120))
    output.push("")
    output.push(`Average DPS per gold:   ${avgDpsPerGold.toFixed(6)}`)
    output.push(`Average HP per gold:    ${avgHpPerGold.toFixed(6)}`)
    output.push(`DPS per gold total:     ${formatStatNumber(dpsSummary.total)}`)
    output.push(`HP per gold total:      ${formatStatNumber(hpSummary.total)}`)
    output.push("")
    output.push("IQR outlier bounds:")
    output.push(`DPS per gold: Q1=${formatStatNumber(dpsSummary.q1)}, Q3=${formatStatNumber(dpsSummary.q3)}, IQR=${formatStatNumber(dpsSummary.q3 - dpsSummary.q1)}, lower=${formatStatNumber(dpsSummary.lowerBound)}, upper=${formatStatNumber(dpsSummary.upperBound)}, outliers=${dpsOutliers.length}`)
    output.push(`HP per gold:  Q1=${formatStatNumber(hpSummary.q1)}, Q3=${formatStatNumber(hpSummary.q3)}, IQR=${formatStatNumber(hpSummary.q3 - hpSummary.q1)}, lower=${formatStatNumber(hpSummary.lowerBound)}, upper=${formatStatNumber(hpSummary.upperBound)}, outliers=${hpOutliers.length}`)
    output.push("")
    output.push("=" .repeat(120))
    output.push("Per-unit details")
    output.push("=" .repeat(120))
    output.push("")

    // Header row
    const header = [
        "Unit".padEnd(40, ' '),
        "Race".padEnd(12, ' '),
        "Gold".padStart(8, ' '),
        "DPS".padStart(10, ' '),
        "Health".padStart(10, ' '),
        "DPS/Gold".padStart(12, ' '),
        "HP/Gold".padStart(12, ' '),
        "DPS%".padStart(10, ' '),
        "HP%".padStart(10, ' ')
    ].join(" | ")

    output.push(header)
    output.push("-".repeat(120))

    // Sort by DPS per gold
    validUnits.sort((a, b) => b.dpsPerGold - a.dpsPerGold)

    // One row per unit
    for (const unit of validUnits) {
        const row = [
            unit.name.padEnd(40, ' '),
            unit.race.padEnd(12, ' '),
            unit.gold.toFixed(0).padStart(8, ' '),
            unit.dps.toFixed(2).padStart(10, ' '),
            unit.hp.toFixed(0).padStart(10, ' '),
            unit.dpsPerGold.toFixed(6).padStart(12, ' '),
            unit.hpPerGold.toFixed(6).padStart(12, ' '),
            unit.dpsPerGoldPercent.toFixed(2).padStart(10, ' ') + "%",
            unit.hpPerGoldPercent.toFixed(2).padStart(10, ' ') + "%"
        ].join(" | ")
        output.push(row)
    }

    output.push("")
    output.push("=" .repeat(120))
    output.push("Additional info")
    output.push("=" .repeat(120))
    output.push("")
    output.push("Legend:")
    output.push("- Data source: every unit recorded in metas/unit_tree.json")
    output.push("- DPS: average damage / attack interval, where attack interval = AttackRate / (BaseAttackSpeed / 100)")
    output.push("- DPS per gold: DPS provided by each point of gold")
    output.push("- HP per gold: health provided by each point of gold")
    output.push("- DPS%: percentage of the average DPS per gold (100% = average)")
    output.push("- HP%: percentage of the average HP per gold (100% = average)")
    output.push("- IQR: interquartile range, IQR = Q3 - Q1")
    output.push("- Outlier: below Q1 - 1.5 * IQR or above Q3 + 1.5 * IQR")
    output.push("")
    output.push("=" .repeat(120))
    output.push("DPS per gold outliers")
    output.push("=" .repeat(120))
    if (dpsOutliers.length === 0) {
        output.push("none")
    } else {
        for (const unit of dpsOutliers) {
            output.push(`${unit.name.padEnd(40, ' ')} | ${unit.race.padEnd(12, ' ')} | gold ${unit.gold.toFixed(0).padStart(8, ' ')} | DPS/Gold ${formatStatNumber(unit.dpsPerGold)}`)
        }
    }
    output.push("")
    output.push("=" .repeat(120))
    output.push("HP per gold outliers")
    output.push("=" .repeat(120))
    if (hpOutliers.length === 0) {
        output.push("none")
    } else {
        for (const unit of hpOutliers) {
            output.push(`${unit.name.padEnd(40, ' ')} | ${unit.race.padEnd(12, ' ')} | gold ${unit.gold.toFixed(0).padStart(8, ' ')} | HP/Gold ${formatStatNumber(unit.hpPerGold)}`)
        }
    }
    output.push("")
    output.push("=" .repeat(120))

    // Save the report
    const outputPath = "./tmp/unit_stats.txt"
    const outputContent = output.join("\n")

    fs.mkdirSync(path.dirname(outputPath), { recursive: true })
    fs.writeFileSync(outputPath, outputContent, { encoding: 'utf8' })

    console.log(`  ✓ Report saved: ${outputPath}`)
    console.log("")
    console.log("=" .repeat(120))
    console.log("Unit stats analysis complete! May the winds bless you~")
    console.log("=" .repeat(120))
}

function main(params) {
    console.log("======================================")
    console.log("Generating metadata files...")
    console.log("======================================")

    console.log("\n[1/7] Scanning unit files...")
    var files = glob.sync(unitFolder, null)
    console.log(`${files.length} unit files found`)

    console.log("\n[2/7] Loading the base metadata...")
    let meta_pre = loadMetaConfig()
    console.log("Base metadata loaded")

    console.log("\n[3/7] Loading localized text...")
    gEnglishKv = parseKv3("./game/resource/addon_russian.txt").lang.Tokens
    console.log("Localized text loaded")

    // Parse every unit
    console.log("\nParsing unit data...")
    for (const key in files) {
        var units = parseKv3(files[key])
        let found = files[key].match(/npc_units_(.*)\.txt/);
        let race=found[1]
        for (const name in units["DOTAUnits"]) {
            var unit = units["DOTAUnits"][name]
            unit.race=race
            gUnits[name] = unit
        }
    }
    console.log(`Parsed ${Object.keys(gUnits).length} units`)

    // Parse every ability
    console.log("\nParsing ability data...")
    var abilityFiles = glob.sync(allAbilitiesFiles, null)
    for (const key in abilityFiles) {
        var abilities = parseKv3(abilityFiles[key])
        for (const name in abilities["DOTAAbilities"]) {
            var ability = abilities["DOTAAbilities"][name]
            gAbilities[name] = ability

        }
    }
    // Parse items
    abilityFiles = glob.sync(allItemsFiles, null)
    for (const key in abilityFiles) {
        var abilities = parseKv3(abilityFiles[key])
        for (const name in abilities["DOTAAbilities"]) {
            var ability = abilities["DOTAAbilities"][name]
            gAbilities[name] = ability
        }
    }
    console.log(`Parsed ${Object.keys(gAbilities).length} abilities/items`)

    // Build the unit metadata
    console.log("\n[5/7] Generating unit metadata...")
    for (const key in files) {
        var units = parseKv3(files[key])
        let found = files[key].match(/npc_units_(.*)\.txt/);
        let race=found[1]

        for (const name in units["DOTAUnits"]) {
            var unit = units["DOTAUnits"][name]
            unit.race=race
            meta.units[name] = parseUnitToMeta(name, unit)
        }
    }
    console.log(`Generated metadata for ${Object.keys(meta.units).length} units`)

    // Build the ability metadata
    console.log("\nGenerating ability metadata...")
    var abilityFiles = []
    for (const folder of metaAbilityFolder) {
        abilityFiles = abilityFiles.concat(glob.sync(folder, null))
    }
    for (const key in abilityFiles) {
        var abilities = parseKv3(abilityFiles[key])
        for (const name in abilities["DOTAAbilities"]) {
            var ability = abilities["DOTAAbilities"][name]
            meta.abilities[name] = parseAbilityToMeta(name, ability)

        }
    }
    console.log(`Generated metadata for ${Object.keys(meta.abilities).length} abilities`)

    // Build the builder metadata
    console.log("\nGenerating builder metadata...")
    for (const raceName in meta_pre.races) {
        const race = meta_pre.races[raceName]
        const heroName = race.hero
        meta.builders.push(parseBuilderToMeta(heroName, raceName, race))
    }
    console.log(`Generated metadata for ${meta.builders.length} builders`)
    // Calculate unit value
    console.log("\n[6/7] Calculating unit value...")
    let unitValueStats = []

    for (const unitName in meta.units) {

        let unit = meta.units[unitName]
        let unitKv = gUnits[unitName]

        // Read AllGoldCost and AllFoodCost straight from the unit KV
        if (unitKv && unitKv.AllGoldCost) {
            unit.creepValue = unitKv.AllGoldCost
        } else {
            unit.creepValue = "0"
        }

        if (unitKv && unitKv.AllFoodCost) {
            unit.creepFood = unitKv.AllFoodCost
        } else {
            unit.creepFood = "0"
        }

        // Only units with a creepValue above 0 get a value ratio
        const creepValue = toFiniteNumber(unit.creepValue)
        if (creepValue > 0) {
            const baseAttackSpeed = toFiniteNumber(unit.BaseAttackSpeed)
            const attackRate = toFiniteNumber(unit.AttackRate)
            const attackDamageMin = toFiniteNumber(unit.AttackDamageMin)
            const attackDamageMax = toFiniteNumber(unit.AttackDamageMax)
            const attackInterval = baseAttackSpeed === 0 ? 0 : attackRate / (baseAttackSpeed / 100)
            const avgDamage = (attackDamageMin + attackDamageMax) / 2
            const dps = attackInterval === 0 ? 0 : avgDamage / attackInterval

            unit.dpsPerGold = finiteString(dps / creepValue)
            unit.hpPerGold = finiteString(toFiniteNumber(unit.StatusHealth) / creepValue)
            unit.fightValuePerGold = finiteString(toFiniteNumber(unit.dpsPerGold) * toFiniteNumber(unit.hpPerGold))

            unitValueStats.push({
                name: unitName,
                race: unit.race || "",
                gold: creepValue,
                dpsPerGold: toFiniteNumber(unit.dpsPerGold),
                hpPerGold: toFiniteNumber(unit.hpPerGold)
            })
        } else {
            unit.dpsPerGold = "0"
            unit.hpPerGold = "0"
            unit.fightValuePerGold = "0"
        }

    }
    printUnitValueStats(unitValueStats)
    dumpBuilding()
    console.log("Unit value calculated")

    // Write AllGoldCost and AllFoodCost back into the unit files
    if (WRITE_ALL_COSTS_TO_KV) {
        console.log("\nWriting AllGoldCost and AllFoodCost into the unit files...")
        writeAllCostsToKv(files)
        console.log("AllGoldCost and AllFoodCost written")
    }

    // Copy the fields from scripts/data/metas/*.json
    console.log("\nCopying metadata fields...")
    meta.otherFighters = filterEnabledOtherFighters(meta_pre.otherFighters)
    meta.summons = meta_pre.summons
    meta.king = meta_pre.king
    meta.waves = meta_pre.waves
    console.log("Metadata fields copied")

    // Calculate the total gold of every wave
    console.log("\nCalculating wave gold totals...")
    let sumGold = 300;
    let x2SumGold = 400;
    for (const i in meta.waves) {
        let wave = meta.waves[i]

        let unit = meta.units[wave.unit]
        let creepBounty = (Number(unit["BountyGoldMin"]) + Number(unit["BountyGoldMax"])) / 2
        let totalCreepBounty = Number(wave.count) * creepBounty

        let bounty = Number(wave.waveGold) + totalCreepBounty

        sumGold += bounty
        x2SumGold += totalCreepBounty * 2 + Number(wave.waveGold)
        wave.sumGold = String(sumGold)
        wave.x2SumGold = String(x2SumGold)

        wave.x2Value = String(Number(wave.value) * 2)

        wave.AttackType=unit.AttackType
        wave.ArmorType=unit.ArmorType
        wave.MovementCapabilities=unit.MovementCapabilities
        wave.AttackCapabilities=unit.AttackCapabilities

    }
    console.log(`Processed ${Object.keys(meta.waves || {}).length} waves`)

    // Write the output files
    console.log("\n[7/7] Writing output files...")

    // Write the split KV files into the game directory
    saveMetaKvs(meta, "./game/scripts/npc/metas")

    // Write the JSON for the Panorama scripts (prefixed with var GAME_META=)
    let metaJsContent = "var GAME_META=" + JSON.stringify(meta, null, 4)
    fs.mkdirSync(path.dirname("./content/panorama/scripts/custom_game/meta.js"), { recursive: true })
    fs.writeFileSync("./content/panorama/scripts/custom_game/meta.js", metaJsContent)
    console.log("✓ JS file saved: ./content/panorama/scripts/custom_game/meta.js")

    // Generate the active fighter list
    generateActiveFighters()

    // Analyze unit stats
    analyzeUnitStats()

    console.log("\n======================================")
    console.log("Metadata generated! Good luck, traveler~")
    console.log("======================================")
}

// Run when invoked directly
if (require.main === module) {
    main();
}

// Exports for other modules
module.exports = {
    main,
    generateActiveFighters,
    analyzeUnitStats
};
