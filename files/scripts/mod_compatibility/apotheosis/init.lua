local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local modName = "apotheosis"

local files_path = "mods/blankStone/files/scripts/mod_compatibility/"..modName.."/"

local function tryLoad(path)
    if ModDoesFileExist(path) then
        return dofile_once(path)
    end
    log.warn("File not found : ".. path)
    return {}
end

return {
    mod_ids = { "apotheosis", "Apotheosis" },

    stones = tryLoad(files_path .. "stone_registry.lua"),

    craft = {
        infuse = tryLoad(files_path .. "infuse_registry.lua"),
        fuse   = tryLoad(files_path .. "fuse_registry.lua"),
        forge  = tryLoad(files_path .. "forge_registry.lua"),
    },
}