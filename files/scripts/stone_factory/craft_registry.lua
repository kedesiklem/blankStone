local utils = dofile_once("mods/blankStone/files/scripts/utils.lua")

STONE_TO_MATERIAL_TO_STONE =    dofile_once("mods/blankStone/files/scripts/stone_factory/craft_registry/infuse_registry.lua")
FUSE_RECIPES =                  dofile_once("mods/blankStone/files/scripts/stone_factory/craft_registry/fuse_registry.lua")
FORGE_RECIPES =                 dofile_once("mods/blankStone/files/scripts/stone_factory/craft_registry/forge_registry.lua")

return {
    STONE_TO_MATERIAL_TO_STONE = STONE_TO_MATERIAL_TO_STONE,
    FUSE_RECIPES = FUSE_RECIPES,
    FORGE_RECIPES = FORGE_RECIPES,
}