local log = dofile_once("mods/blankStone/utils/logger.lua") ---@type logger
local STONE_REGISTRY = dofile_once("mods/blankStone/files/scripts/stone_factory/stone_registry.lua")

local function ApplyComponentExplorerPatches()
    local filepath = "mods/component-explorer/spawn_data/items.lua"
    local new_entries = ""

    for stone_key, stone_data in pairs(STONE_REGISTRY) do
        if stone_data.category ~= "vanilla" then
            new_entries = new_entries .. string.format(
                '  {\n    file="%s",\n    item_name="%s",\n    origin="blankStone",\n    tags="teleportable_NOT,item_physics,blankstone"\n  },\n',
                stone_data.path, stone_key
            )
        end
    end

    local content = ModTextFileGetContent(filepath)
    local result, count = content:gsub("(\n})%s*$", ",\n" .. new_entries .. "\n}")

    if count == 0 then
        log.tmp_warn("Patch [component_explorer_items] échoué sur " .. filepath)
        return false
    end

    ModTextFileSetContent(filepath, result)
    log.tmp_info("Patch [component_explorer_items] appliqué : " .. filepath)
    return true
end

return { ApplyComponentExplorerPatches = ApplyComponentExplorerPatches }