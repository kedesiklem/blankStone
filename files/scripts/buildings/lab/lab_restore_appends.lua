-- based on Purgatory by Priskip

local lab_factory = dofile_once("mods/blankStone/files/scripts/lab/lab_factory.lua")

local root_id = GetUpdatedEntityID()
lab_factory.restoreLab(root_id)
