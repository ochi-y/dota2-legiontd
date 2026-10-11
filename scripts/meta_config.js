const fs = require("fs");
const path = require("path");

const META_DIR = path.join(__dirname, "data", "metas");
const META_FILES = {
    races: "races.json",
    otherFighters: "otherFighters.json",
    summons: "summons.json",
    waves: "waves.json",
    king: "king.json"
};

function readMetaFile(key, fileName) {
    const filePath = path.join(META_DIR, fileName);

    try {
        return JSON.parse(fs.readFileSync(filePath, { encoding: "utf8" }));
    } catch (error) {
        throw new Error(`Failed to load meta config ${key} from ${filePath}: ${error.message}`);
    }
}

function loadMetaConfig() {
    const meta = {};

    for (const [key, fileName] of Object.entries(META_FILES)) {
        meta[key] = readMetaFile(key, fileName);
    }

    return meta;
}

module.exports = {
    loadMetaConfig
};
