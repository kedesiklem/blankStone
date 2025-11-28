---@class logger
local logger = {}

logger.mod_name = "BlankStone"

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
    logger.log("[DEBUG] " .. text)
end

function logger.info(text)
    logger.log("[INFO] " .. text)
end

function logger.warn(text)
    logger.log("[WARN] " .. text)
end

function logger.error(text)
    print_error("[" .. get_timestamp() .. "] [" .. logger.mod_name .. "] [ERROR] " .. text)
end

return logger