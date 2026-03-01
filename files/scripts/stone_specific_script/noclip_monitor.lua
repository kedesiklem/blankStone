dofile_once( "mods/blankStone/files/scripts/no_clip.lua" )


local item_id = GetUpdatedEntityID()

if not NoClip.is_active( item_id ) then return end

local hand_comp = EntityGetFirstComponentIncludingDisabled( item_id, "LuaComponent" )
if not hand_comp then return end

if GameGetFrameNum() <= ComponentGetValue2( hand_comp, "mLastExecutionFrame" ) then return end

NoClip.disable( item_id )

function throw_item( from_x, from_y, to_x, to_y )
    local item_id = GetUpdatedEntityID()
    if not NoClip.is_active( item_id ) then return end
    local hand_comp = EntityGetFirstComponentIncludingDisabled( item_id, "LuaComponent" )
    if not hand_comp then return end
    if GameGetFrameNum() <= ComponentGetValue2( hand_comp, "mLastExecutionFrame" ) then return end
    NoClip.disable( item_id )
end