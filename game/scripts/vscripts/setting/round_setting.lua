-- Load the split metadata KV files
local META_KEYS = {
    "items",
    "abilities",
    "units",
    "heroes",
    "builders",
    "otherFighters",
    "summons",
    "king",
    "waves",
}

local function LoadMetaKvs()
    local meta = {}

    for _, key in ipairs(META_KEYS) do
        local filePath = "scripts/npc/metas/" .. key .. ".kv"
        local kv = LoadKeyValues(filePath)
        if kv and kv[key] then
            meta[key] = kv[key]
        else
            print("[Meta] failed to load " .. filePath)
            meta[key] = {}
        end
    end

    return meta
end

gMetaKv = LoadMetaKvs()

-- Load the active fighter list
gActiveFighters = LoadKeyValues("scripts/npc/meta/active_fighter.kv")


if not roundInfo then
    roundInfo = {}
end

LANE_META = {
    [0] = {
        forwardVector = Vector(0, 1, 0),
        zoneDirections = {
            Vector(0, 1, 0),
            Vector(-1, 0, 0),
            Vector(0, 1, 0),
        }
    },
    [1] = {
        forwardVector = Vector(0, -1, 0),
        zoneDirections = {
            Vector(0, -1, 0),
            Vector(-1, 0, 0),
            Vector(0, 1, 0),
        }
    },
    [2] = {
        forwardVector = Vector(0, 1, 0),
        zoneDirections = {
            Vector(0, 1, 0),
            Vector(1, 0, 0),
            Vector(0, 1, 0),
        }
    },
    [3] = {
        forwardVector = Vector(0, -1, 0),
        zoneDirections = {
            Vector(0, -1, 0),
            Vector(1, 0, 0),
            Vector(0, 1, 0),
        }
    },
    [4] = {
        forwardVector = Vector(0, 1, 0),
        zoneDirections = {
            Vector(0, 1, 0),
            Vector(-1, 0, 0),
            Vector(0, 1, 0),
        }
    },
    [5] = {
        forwardVector = Vector(0, -1, 0),
        zoneDirections = {
            Vector(0, -1, 0),
            Vector(-1, 0, 0),
            Vector(0, 1, 0),
        }
    },
    [6] = {
        forwardVector = Vector(0, 1, 0),
        zoneDirections = {
            Vector(0, 1, 0),
            Vector(1, 0, 0),
            Vector(0, 1, 0),
        }
    },
    [7] = {
        forwardVector = Vector(0, -1, 0),
        zoneDirections = {
            Vector(0, -1, 0),
            Vector(1, 0, 0),
            Vector(0, 1, 0),
        }
    },
}
