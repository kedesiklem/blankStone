local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")
local files_path = "mods/blankStone/files/"
local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger


local registries = {
    infuse  = dofile_once(files_path .. "scripts/stone_factory/craft_registry/infuse_registry.lua"),
    fuse    = dofile_once(files_path .. "scripts/stone_factory/craft_registry/fuse_registry.lua"),
    forge   = dofile_once(files_path .. "scripts/stone_factory/craft_registry/forge_registry.lua"),
    purify  = dofile_once(files_path .. "scripts/stone_factory/craft_registry/purify_registry.lua"),
}

local C = dofile_once(files_path .. "scripts/stone_factory/compat/compat_utils.lua")
local COMPAT_MODULES =  dofile_once(files_path .. "scripts/stone_factory/compat/compat_loader.lua")

for _, compat in ipairs(COMPAT_MODULES) do
    if C.isAnyEnabled(compat.mod_ids) and compat.craft then
        log.info("Compat [Craft registry] : " .. compat.mod_ids[1])

        for name, patch in pairs(compat.craft) do
            if registries[name] then
                C.MergeTable(registries[name], patch)
            end
        end
    else
        log.info("NO Compat [Craft registry] : " .. compat.mod_ids[1])
    end
end


return {
    INFUSION_RECIPES = registries.infuse,
    FUSE_RECIPES = registries.fuse,
    FORGE_RECIPES = registries.forge,
    PURIFY_RECIPES = registries.purify,
}