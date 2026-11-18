local files_path = "mods/blankStone/files/scripts/mod_compatibility/"

return {
    dofile_once(files_path .. "apotheosis/init.lua"),
    dofile_once(files_path .. "entangled_worlds/init.lua"),
}