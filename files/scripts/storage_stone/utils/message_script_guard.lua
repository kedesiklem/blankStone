--- Noita's LuaComponent has two kinds of script hooks:
---   - script_source_file, which runs on execute_every_n_frame and DOES
---     respect the component's enabled state.
---   - every other message-driven hook (script_kick -> kick(),
---     script_damage_received -> damage_received(), script_item_picked_up ->
---     item_pickup(), script_interacting -> interacting(), ...), which fires
---     as soon as the matching engine message arrives REGARDLESS of whether
---     the owning component is enabled or disabled.
--- See: https://noita.wiki.gg/wiki/Documentation:_LuaComponent
---   "Scripts that call functions will go through _enabled, meaning if you
---    have a disabled script that uses any that isn't script_source_file,
---    then it will run in spite of the components deactivation [...]
---    If script_kick is used on an item then if you store the item in your
---    inventory the kick script will go off while you kick."
---
--- The wiki's own recommended workaround is to check the component's
--- enabled state INSIDE the hook function itself. Since we won't edit
--- vanilla files directly (and shouldn't, for compatibility), we detour
--- the global function the hook defines instead. This file must be loaded
--- once (dofile_once) before use.

--- Wraps a global hook function (as defined by a LuaComponent script_* file)
--- so it becomes a no-op whenever the LuaComponent that would have received
--- the message is currently disabled.
--- MUST be called via ModLuaFileAppend, appended to the END of the target
--- vanilla/mod script file, so the original global function already exists
--- by the time this code runs. Safe to call more than once (idempotent).
--- 
--- @param function_name string # e.g. "kick", "damage_received", "item_pickup"
--- @return boolean # true if the function was found and wrapped
function blankStone_guard_message_function(function_name)
    local marker = "__blankStone_guarded_" .. function_name
    if _G[marker] then
        return true -- already wrapped, nothing to do
    end
    local original = _G[function_name]
    if type(original) ~= "function" then
        print_error("BlankStone: message_script_guard could not find global function '" .. tostring(function_name) .. "' to wrap - nothing was patched.")
        return false
    end
    _G[marker] = true
    _G[function_name] = function(...)
        local comp = GetUpdatedComponentID()
        -- GetUpdatedComponentID() returns the id of the LuaComponent that is
        -- currently receiving the message. If it is disabled, bail out
        -- before running the original (potentially destructive) behavior.
        if comp and comp ~= 0 and ComponentGetIsEnabled(comp) == false then
            return
        end
        return original(...)
    end
    return true
end
