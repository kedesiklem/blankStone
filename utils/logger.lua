---@class logger
local logger = {}

logger.mod_name = "BlankStone"

ERROR = 0
WARN = 1
INFO = 2
DEBUG = 3

CURRENT_LOG_MODE = ERROR

-- Get current timestamp in HH:MM:SS format
local function get_timestamp()
    local year, month, day, hour, minute, second = GameGetDateAndTimeLocal()
    return string.format("%02d:%02d:%02d", hour, minute, second)
end

-- Log basique
function logger.log(text)
    print("[" .. get_timestamp() .. "] [" .. logger.mod_name .. "] " .. text)
end

-- Log for different levels
function logger.debug(text)
    if(CURRENT_LOG_MODE >= DEBUG) then
        logger.log("[DEBUG] " .. text)
    end
end

function logger.info(text)
    if(CURRENT_LOG_MODE >= INFO) then
        logger.log("[INFO] " .. text)
    end
end

function logger.warn(text)
    if(CURRENT_LOG_MODE >= WARN) then
        logger.log("[WARN] " .. text)
    end
end

function logger.error(text)
    if(CURRENT_LOG_MODE >= ERROR) then
        print_error("[" .. get_timestamp() .. "] [" .. logger.mod_name .. "] [ERROR] " .. text)
    end
end

return logger