function collision_trigger( colliding_entity_id )
    local entered_text = GameTextGetTranslatedOrNot("$log_entered")
    local zone_text = GameTextGetTranslatedOrNot("$zone_blankstone_progress")
    entered_text = entered_text:gsub("$0",zone_text)
    GamePrintImportant(entered_text)
end