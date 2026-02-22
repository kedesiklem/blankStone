local log = dofile_once("mods/blankStone/utils/logger.lua")

local MOD_PRFX     = "blankStone."
local SETTING_KEY  = "storage_pickup_key"
local SETTING_TYPE = "storage_pickup_key_type"
local DEFAULT_KEY  = "10"   -- G
local DEFAULT_TYPE = "kb"

local function _read_key()
    return tostring(ModSettingGet(MOD_PRFX .. SETTING_KEY) or DEFAULT_KEY)
end

local function _read_type()
    local t = ModSettingGet(MOD_PRFX .. SETTING_TYPE)
    if t == "kb" or t == "mouse" then return t end
    return DEFAULT_TYPE
end

local function is_pickup_just_pressed()
    local code  = tonumber(_read_key())
    local itype = _read_type()
    if not code then return false end
    if itype == "mouse" then
        return InputIsMouseButtonJustDown(code)
    else
        return InputIsKeyJustDown(code)
    end
end

return {
    is_pickup_just_pressed = is_pickup_just_pressed,
}