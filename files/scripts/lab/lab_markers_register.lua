-- based on Purgatory by Priskip
--

do
    local lab_markers = dofile_once("mods/blankStone/files/scripts/lab/lab_markers.lua")
    for _, marker in pairs(lab_markers.MARKERS) do
        RegisterSpawnFunction(marker.color, marker.fn_name)
    end
end
