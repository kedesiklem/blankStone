local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger

--- Registers blankStone's multiplayer module into Entangled Worlds.
---
--- EW loads every file appended to its extra_modules.lua as a module, during
--- its own OnModInit. This must therefore run before that: call it from
--- blankStone's OnModPreInit, and only when "quant.ew" is enabled.
--- See entangled_worlds/ew_module.lua and entangled_worlds/lab_storage_host.lua.
local function ApplyEntangledWorldsPatches()
    ModLuaFileAppend(
        "mods/quant.ew/files/api/extra_modules.lua",
        "mods/blankStone/files/scripts/mod_compatibility/entangled_worlds/ew_module.lua"
    )
    log.tmp_info("Patch [entangled_worlds] applied: lab storage module registered")
end

return { ApplyEntangledWorldsPatches = ApplyEntangledWorldsPatches }
