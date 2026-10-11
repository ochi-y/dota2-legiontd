// ===== Dependencies =====
var kv3tojs = require('./lib/kv3parser');
var obj2kv = require('./lib/obj2kv');
var obj2kv1 = require('./lib/obj2kv1');
const fs = require('fs');
var glob = require("glob");
const util = require('util');
const { mainModule } = require('process');
const fsExtra = require('fs-extra')
const prompt = require("prompt-sync")({ sigint: true });
var path = require('path');


// ===== Globals =====
let vpcfMap = {}
let vpcfFileList = []
let rootVpcfList = []


const folders = [
    "C:/Program Files (x86)/Steam/steamapps/common/dota 2 beta/content/dota/particles/units/heroes/**/*.vpcf",
]

// Initialise: collect every particle file
for (const key in folders) {
    const files = glob.sync(folders[key], null)
    vpcfFileList = vpcfFileList.concat(files)
}


// ===== Helpers =====
function simpleCopy(obj) {
    return JSON.parse(JSON.stringify(obj));
}

function getRandomInt(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min) + min);
}

function componentToHex(c) {
    var hex = c.toString(16);
    return hex.length == 1 ? "0" + hex : hex;
}

function rgbToHex(r, g, b, a) {
    return componentToHex(r) + componentToHex(g) + componentToHex(b) + componentToHex(a);
}


// ===== Particle file parsing =====
function parseVpcf(file) {
    let content = fs.readFileSync(file, { encoding: 'utf8' });
    var firstLine = content.substring(0, content.indexOf('\n'));
    if (firstLine.indexOf("kv3 encoding") == -1) {
        firstLine = null
    }
    return { data: kv3tojs.parse(content), kv3Info: firstLine };
}

// Async version of parseVpcf
async function parseVpcfAsync(file) {
    const content = await fs.promises.readFile(file, { encoding: 'utf8' });
    let firstLine = content.substring(0, content.indexOf('\n'));
    if (firstLine.indexOf("kv3 encoding") == -1) {
        firstLine = null
    }
    return { data: kv3tojs.parse(content), kv3Info: firstLine };
}


// ===== Particle data accessors =====
function getm_Children(d) {
    const res = []
    if (!d.m_Children) {
        return res
    }
    for (const key in d.m_Children) {
        const v = d.m_Children[key]
        if (v && v.m_ChildRef) {
            res.push({ name: v.m_ChildRef.value, m_bEndCap: v.m_bEndCap })
        }
    }
    return res
}

function getOperator(d, op) {
    if (!d.m_Operators) {
        return null
    }
    for (const key in d.m_Operators) {
        const v = d.m_Operators[key]
        if (v._class == op) {
            return v
        }
    }
    return null
}

function getEmit(d, op) {
    if (!d.m_Emitters) {
        return null
    }
    for (const key in d.m_Emitters) {
        const v = d.m_Emitters[key]
        if (v._class == op) {
            return v
        }
    }
    return null
}

function getComponent(d, name, op) {
    if (!d[name]) {
        return null
    }
    for (const key in d[name]) {
        const v = d[name][key]
        if (v._class == op && !v.m_bDisableOperator) {
            return v
        }
    }
    return null
}

function getInitializer(d, op) {
    if (!d.m_Initializers) {
        return null
    }
    for (const key in d.m_Initializers) {
        const v = d.m_Initializers[key]
        if (v._class == op) {
            return v
        }
    }
    return null
}

function getForceGenerator(d, op) {
    if (!d.m_ForceGenerators) {
        return null
    }
    for (const key in d.m_ForceGenerators) {
        const v = d.m_ForceGenerators[key]
        if (v._class == op) {
            return v
        }
    }
    return null
}


// ===== Particle attribute checks =====
function hasEmits(d, ops) {
    for (const key in ops) {
        if (!getEmit(d, ops[key])) {
            return false
        }
    }
    return true
}

function hasInitializers(d, ops) {
    for (const key in ops) {
        if (!getInitializer(d, ops[key])) {
            return false
        }
    }
    return true
}

function hasOperators(d, ops) {
    for (const key in ops) {
        if (!getOperator(d, ops[key])) {
            return false
        }
    }
    return true
}

function hasForceGenerators(d, ops) {
    for (const key in ops) {
        if (!getForceGenerator(d, ops[key])) {
            return false
        }
    }
    return true
}


// ===== Particle tree traversal =====
function getAllSubs(vpcf) {
    if (!vpcf) {
        return []
    }
    const res = []
    res.push(vpcf)
    for (const key in vpcf.childs) {
        const sub = getAllSubs(vpcfMap[vpcf.childs[key].name])
        for (const k in sub) {
            res.push(sub[k])
        }
    }
    return res
}


// ===== Particle type checks (cache accelerated) =====
function isTracking(vpcf, cachedSubs) {
    const subs = cachedSubs || getAllSubs(vpcf)
    let res = false
    for (const key in subs) {
        const sub = subs[key]
        if (hasOperators(sub.data, ["C_OP_CPOffsetToPercentageBetweenCPs", "C_OP_MaxVelocity"])) {
            res = true
            break
        }
        if (hasForceGenerators(sub.data, ["C_OP_AttractToControlPoint"]) && hasOperators(sub.data, ["C_OP_MaxVelocity", ])) {
            res = true
            break
        }
    }
    if (res) {
        for (const key in subs) {
            const sub = subs[key]
            sub.isTrackingChild = true
        }
    }
    return res
}

function isLinear(vpcf, cachedSubs) {
    const subs = cachedSubs || getAllSubs(vpcf)
    let res = false
    for (const key in subs) {
        const sub = subs[key]
        if (hasInitializers(sub.data, ["C_INIT_VelocityFromCP"])) {
            res = true
            break
        }
    }
    if (res) {
        for (const key in subs) {
            const sub = subs[key]
            sub.isLinearChild = true
        }
    }
    return res
}

function isLink(vpcf, cachedSubs) {
    const subs = cachedSubs || getAllSubs(vpcf)
    for (const key in subs) {
        const sub = subs[key]
        if (getOperator(sub.data, "C_OP_PercentageBetweenCPs") && getInitializer(sub.data, "C_INIT_CreateSequentialPath")) {
            return true
        }
        var init = getInitializer(sub.data, "C_INIT_CreateAlongPath")
        if (init && init.m_PathParams && init.m_PathParams.m_nEndControlPointNumber == 1) {
            return true
        }
        var C_OP_ConstrainDistanceToPath = getOperator(sub.data, "C_OP_ConstrainDistanceToPath")
        if (C_OP_ConstrainDistanceToPath && C_OP_ConstrainDistanceToPath.m_PathParameters && C_OP_ConstrainDistanceToPath.m_PathParameters.m_nEndControlPointNumber == 1) {
            return true
        }
    }
    return false
}

function isWithHand(vpcf, cachedSubs) {
    const subs = cachedSubs || getAllSubs(vpcf)
    for (const key in subs) {
        const sub = subs[key]
        const lock = getOperator(sub.data, "C_OP_LockToBone")
        if (lock && lock.m_HitboxSetName == "hands") {
            return true
        }
    }
    return false
}

function isWithWeapon(vpcf, cachedSubs) {
    const subs = cachedSubs || getAllSubs(vpcf)
    for (const key in subs) {
        const sub = subs[key]
        const lock = getOperator(sub.data, "C_OP_LockToBone")
        if (lock && lock.m_HitboxSetName == "weapon") {
            return true
        }
    }
    return false
}

function isWithHead(vpcf, cachedSubs) {
    const subs = cachedSubs || getAllSubs(vpcf)
    for (const key in subs) {
        const sub = subs[key]
        const lock = getOperator(sub.data, "C_OP_LockToBone")
        if (lock && lock.m_HitboxSetName == "head") {
            return true
        }
    }
    return false
}

function isWithFeet(vpcf, cachedSubs) {
    const subs = cachedSubs || getAllSubs(vpcf)
    for (const key in subs) {
        const sub = subs[key]
        const lock = getOperator(sub.data, "C_OP_LockToBone")
        if (lock && lock.m_HitboxSetName == "feet") {
            return true
        }
    }
    return false
}

function isWithBody(vpcf, cachedSubs) {
    const subs = cachedSubs || getAllSubs(vpcf)
    for (const key in subs) {
        const sub = subs[key]
        const init = getInitializer(sub.data, "C_INIT_CreateOnModel")
        if (init) {
            return true
        }
    }
    return false
}

function isLockBody(vpcf, cachedSubs) {
    const subs = cachedSubs || getAllSubs(vpcf)
    for (const key in subs) {
        const sub = subs[key]
        const lock = getOperator(sub.data, "C_OP_LockToBone")
        if (lock && !lock.m_HitboxSetName) {
            return true
        }
    }
    return false
}

function isSphere(vpcf, cachedSubs) {
    const subs = cachedSubs || getAllSubs(vpcf)
    for (const key in subs) {
        const sub = subs[key]
        const lock = getInitializer(sub.data, "C_INIT_CreateWithinSphere")
        if (lock && lock.m_fRadiusMin && lock.m_fRadiusMax) {
            return true
        }
    }
    return false
}

function isScalabel(vpcf, cachedSubs) {
    const subs = cachedSubs || getAllSubs(vpcf)
    for (const key in subs) {
        const sub = subs[key]
        const init = getInitializer(sub.data, "C_INIT_RemapCPtoScalar")
        if (init) {
            return true
        }
    }
    return false
}

function isContinueOne(vpcf) {
    const emit = getEmit(vpcf.data, "C_OP_InstantaneousEmitter")
    if (emit) {
        return false
    }
    const ctn = getEmit(vpcf.data, "C_OP_ContinuousEmitter")
    if (ctn) {
        if (ctn.m_flEmissionDuration > 0) {
            return false
        } else {
            return true
        }
    }
    return false
}

function isContinue(vpcf, cachedSubs) {
    const subs = cachedSubs || getAllSubs(vpcf)
    for (const key in subs) {
        const sub = subs[key]
        if (isContinueOne(sub)) {
            return true
        }
    }
    return false
}

function isExplode(vpcf) {
    const emit = getEmit(vpcf.data, "C_OP_InstantaneousEmitter")
    if (emit && emit.m_nParticlesToEmit && emit.m_nParticlesToEmit.m_flLiteralValue > 1) {
        return true
    }
    return false
}

function isStatusEffect(vpcf) {
    const comp = getComponent(vpcf.data, "m_Renderers", "C_OP_RenderStatusEffect")
    if (comp) {
        return true
    }
    return false
}

function getColor(vpcf, cachedSubs) {
    const subs = cachedSubs || getAllSubs(vpcf)
    const colors = []

    for (const key in subs) {
        const sub = subs[key]
        const lock = getOperator(sub.data, "C_OP_LockToBone")
        const colorRandom = getComponent(sub.data, "m_Initializers", "C_INIT_RandomColor")
        if (colorRandom && colorRandom.m_ColorMin && colorRandom.m_ColorMax) {
            const m_ColorMin = colorRandom.m_ColorMin
            const m_ColorMax = colorRandom.m_ColorMax
            colors.push(m_ColorMin, m_ColorMax)
        }

        const m_ConstantColor = sub.data.m_ConstantColor
        if (m_ConstantColor) {
            if (m_ConstantColor[0] == 0 && m_ConstantColor[1] == 0 && m_ConstantColor[2] == 0) {
                // skip black
            } else {
                colors.push(m_ConstantColor)
            }
        }
    }

    const resColor = [0, 0, 0, 0]
    for (const key in colors) {
        const color = colors[key]
        resColor[0] += color[0] || 0
        resColor[1] += color[1] || 0
        resColor[2] += color[2] || 0
        resColor[3] += color[3] || 0
    }
    if (colors.length > 0) {
        resColor[0] = Math.floor(resColor[0] / colors.length)
        resColor[1] = Math.floor(resColor[1] / colors.length)
        resColor[2] = Math.floor(resColor[2] / colors.length)
        resColor[3] = Math.floor(resColor[3] / colors.length)
    }

    return resColor
}


// ===== Async parallel parsing (optimisations 1 and 2) =====
async function parseAllAndAnalyzeAsync() {
    console.log("=".repeat(60))
    console.log("🌟 Parsing the particle system... (async parallel mode)")
    console.log("=".repeat(60))

    const totalStartTime = Date.now()
    let phaseStartTime = Date.now()

    // First pass: parse every file in parallel
    const BATCH_SIZE = 50  // 50 files per parallel batch
    console.log(`\n📖 [phase 1/4] parsing files in parallel... ${vpcfFileList.length} particle files`)
    console.log(`   batch size: ${BATCH_SIZE} files per batch`)

    let parsedCount = 0
    const filesToParse = vpcfFileList.filter(file => file.indexOf("_loadout.vpcf") === -1)

    for (let i = 0; i < filesToParse.length; i += BATCH_SIZE) {
        const batch = filesToParse.slice(i, i + BATCH_SIZE)

        // Read and parse in parallel batches
        await Promise.all(batch.map(async (file) => {
            try {
                // Async read and parse
                const parseRes = await parseVpcfAsync(file)
                const name = file.substring(file.indexOf("particles"))
                vpcfMap[name] = {
                    data: parseRes.data,
                    isChild: false,
                    name: name,
                    kv3Info: parseRes.kv3Info
                }

                parsedCount++
                if (parsedCount % 100 === 0) {
                    console.log(`   progress: ${parsedCount}/${filesToParse.length} (${Math.floor(parsedCount/filesToParse.length*100)}%)`)
                }
            } catch (error) {
                console.error(`   ❌ parse failed: ${file} - ${error.message}`)
            }
        }))
    }

    const phase1Time = Date.now() - phaseStartTime
    console.log(`✅ phase 1 done - ${parsedCount} files (took ${phase1Time}ms, avg ${(phase1Time/parsedCount).toFixed(2)}ms/file)`)

    // Second pass: link particles and cache subtrees (caching getAllSubs results)
    phaseStartTime = Date.now()
    console.log(`\n🔗 [phase 2/4] linking particles and caching subtrees...`)
    let processedCount = 0
    const totalVpcf = Object.keys(vpcfMap).length
    for (const name in vpcfMap) {
        const vpcf = vpcfMap[name]
        vpcf.childs = getm_Children(vpcf.data)

        // Key optimisation: compute and cache every child particle up front
        vpcf._cachedAllSubs = getAllSubs(vpcf)

        if (vpcf.childs.length > 1) {
            for (const key in vpcf.childs) {
                const child = vpcf.childs[key]
                if (vpcfMap[child.name]) {
                    vpcfMap[child.name].isChild = true
                }
            }
        }
        for (const key in vpcf.childs) {
            if (vpcf.childs[key].m_bEndCap) {
                // Use the cached subtree
                const childVpcf = vpcfMap[vpcf.childs[key].name]
                if (childVpcf && childVpcf._cachedAllSubs) {
                    for (const sub of childVpcf._cachedAllSubs) {
                        sub.data.isEndCap = true
                    }
                }
            }
        }
        processedCount++
        if (processedCount % 500 === 0) {
            console.log(`   progress: ${processedCount}/${totalVpcf} (${Math.floor(processedCount/totalVpcf*100)}%)`)
        }
    }
    const phase2Time = Date.now() - phaseStartTime
    console.log(`✅ phase 2 done - ${processedCount} particles (took ${phase2Time}ms)`)

    // Third pass: classify
    phaseStartTime = Date.now()
    console.log(`\n📊 [phase 3/4] classifying particles...`)
    rootVpcfList = []
    for (const name in vpcfMap) {
        const vpcf = vpcfMap[name]
        if (!vpcf.isChild) {
            rootVpcfList.push(vpcf)
        }
    }
    rootVpcfList.sort(function(a, b) {
        return a < b
    })
    const phase3Time = Date.now() - phaseStartTime
    console.log(`✅ phase 3 done - root particles: ${rootVpcfList.length} (took ${phase3Time}ms)`)

    // Fourth pass: analyse attributes, reusing the cached subtrees
    phaseStartTime = Date.now()
    console.log(`\n🔍 [phase 4/4] analysing particle attributes... (cache accelerated)`)
    let analyzedCount = 0
    for (const key in vpcfMap) {
        const vpcf = vpcfMap[key]
        const cachedSubs = vpcf._cachedAllSubs

        vpcf.isTracking = isTracking(vpcf, cachedSubs)
        vpcf.isLinear = isLinear(vpcf, cachedSubs)
        vpcf.isLink = isLink(vpcf, cachedSubs)
        vpcf.isExplode = isExplode(vpcf)
        vpcf.isWithHand = isWithHand(vpcf, cachedSubs)
        vpcf.isWithBody = isWithBody(vpcf, cachedSubs)
        vpcf.isContinue = isContinue(vpcf, cachedSubs)
        vpcf.isWithHead = isWithHead(vpcf, cachedSubs)
        vpcf.isStatusEffect = isStatusEffect(vpcf)
        vpcf.isLockBody = isLockBody(vpcf, cachedSubs)
        vpcf.isWithFeet = isWithFeet(vpcf, cachedSubs)
        vpcf.isScalabel = isScalabel(vpcf, cachedSubs)
        vpcf.isSphere = isSphere(vpcf, cachedSubs)
        vpcf.isWithWeapon = isWithWeapon(vpcf, cachedSubs)
        vpcf.color = getColor(vpcf, cachedSubs)
        vpcf.colorHex = rgbToHex(vpcf.color[0], vpcf.color[1], vpcf.color[2], vpcf.color[3])

        analyzedCount++
        if (analyzedCount % 500 === 0) {
            console.log(`   progress: ${analyzedCount}/${totalVpcf} (${Math.floor(analyzedCount/totalVpcf*100)}%)`)
        }
    }
    const phase4Time = Date.now() - phaseStartTime
    console.log(`✅ phase 4 done - ${analyzedCount} particles (took ${phase4Time}ms, avg ${(phase4Time/analyzedCount).toFixed(2)}ms/particle)`)

    const totalTime = Date.now() - totalStartTime
    console.log("\n" + "=".repeat(60))
    console.log("🎉 Particle parsing complete! (async parallel mode)")
    console.log("=".repeat(60))
    console.log(`📈 Performance:`)
    console.log(`   total: ${totalTime}ms (${(totalTime/1000).toFixed(2)}s)`)
    console.log(`   phase 1 (async parse): ${phase1Time}ms (${(phase1Time/totalTime*100).toFixed(1)}%)`)
    console.log(`   phase 2 (linking): ${phase2Time}ms (${(phase2Time/totalTime*100).toFixed(1)}%)`)
    console.log(`   phase 3 (classifying): ${phase3Time}ms (${(phase3Time/totalTime*100).toFixed(1)}%)`)
    console.log(`   phase 4 (attributes): ${phase4Time}ms (${(phase4Time/totalTime*100).toFixed(1)}%)`)
    console.log(`   throughput: ${(totalVpcf/(totalTime/1000)).toFixed(0)} particles/s`)
    console.log("=".repeat(60))
}


// ===== Export functions =====
function dumpAll() {
    console.log("\n💾 Exporting the results...")
    const dumpStartTime = Date.now()

    console.log("   cleaning the data...")
    for (const key in vpcfMap) {
        const vpcf = vpcfMap[key]
        vpcf.data = null
        vpcf.childs = null
        // Drop the caches so no circular references remain
        vpcf._cachedAllSubs = null
    }
    for (const key in rootVpcfList) {
        rootVpcfList[key]["kv3Info"] = null
    }

    // Write to the target path
    const outputPath = "./content/panorama/layout/custom_game/hud_demo/hud_hero_demo_particle.js"

    console.log(`   writing ${outputPath}...`)

    // Emit valid JS: var particleList = [...]
    const fileContent = "var particleList = " + JSON.stringify(rootVpcfList, null, "    ")

    // Make sure the directory exists
    const outputDir = path.dirname(outputPath)
    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true })
        console.log(`   ✓ created directory: ${outputDir}`)
    }

    fs.writeFileSync(outputPath, fileContent)
    console.log(`   ✓ ${outputPath} saved (${rootVpcfList.length} root particles)`)

    const dumpTime = Date.now() - dumpStartTime
    console.log(`✅ Export complete! took ${dumpTime}ms`)
}

// ===== Export particle names to a KV file =====
function dumpParticleKV() {
    console.log("\n💾 Exporting the particle KV file...")
    const kvStartTime = Date.now()

    // Collect every particle whose isChild is false
    const particleObj = {}
    let index = 1
    for (const name in vpcfMap) {
        const vpcf = vpcfMap[name]
        if (!vpcf.isChild) {
            particleObj[index] = name
            index++
        }
    }

    console.log(`   collected ${index - 1} root particles...`)

    // Convert to KV format with obj2kv1
    const kvContent = obj2kv1.obj2kv1(particleObj)

    // Write the file
    const kvOutputPath = "./game/scripts/npc/npc_dev_particle.txt"
    console.log(`   writing ${kvOutputPath}...`)

    // Make sure the directory exists
    const kvOutputDir = path.dirname(kvOutputPath)
    if (!fs.existsSync(kvOutputDir)) {
        fs.mkdirSync(kvOutputDir, { recursive: true })
        console.log(`   ✓ created directory: ${kvOutputDir}`)
    }

    fs.writeFileSync(kvOutputPath, kvContent)
    console.log(`   ✓ ${kvOutputPath} saved (${index - 1} root particles)`)

    const kvTime = Date.now() - kvStartTime
    console.log(`✅ KV export complete! took ${kvTime}ms`)
}


// ===== Entry point: parse and save =====
async function parseAllAndSave() {
    await parseAllAndAnalyzeAsync()
    dumpAll()
    dumpParticleKV()
}

// Run
parseAllAndSave().catch(error => {
    console.error('❌ Parsing failed:', error)
    process.exit(1)
})
