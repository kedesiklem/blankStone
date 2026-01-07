local blankStone_spellappends = {
        {
        id          = "blankStone_STONE_FUSER",
        name 		= "$spell_blankstone_stone_fuser_name",
        description = "$spell_blankstone_stone_fuser_desc",
        sprite 		= "mods/blankStone/files/ui_gfx/gun_actions/stone_fuser.png",
        sprite_unidentified = "data/ui_gfx/gun_actions/explosive_projectile_unidentified.png",
        related_extra_entities = { "mods/blankStone/files/entities/misc/stone_fuser.xml" },
        type 		= ACTION_TYPE_STATIC_PROJECTILE,
        spawn_level                       = "2,3,6,7,10", -- LAVA_TO_BLOOD
        spawn_probability                 = "0.1,0.1,0.3,0.5,0.05", -- LAVA_TO_BLOOD
        price = 250,
        mana = 200,
        max_uses = 5,
        action 		= function()
            add_projectile("mods/blankStone/files/entities/misc/stone_fuser.xml")
            c.fire_rate_wait = c.fire_rate_wait + 60
            current_reload_time = current_reload_time + 30
            c.screenshake = c.screenshake + 10
        end,
    },
}

-- Credit to Conga Lyne (almost exact copy-past for mod insertion (without the organized icon part))
local function append_blankStone_spells()
    for k=1,#blankStone_spellappends
    do local v = blankStone_spellappends[k]
        v.author    = v.author  or "Kedesiklem"
        v.mod       = v.mod     or "BlankStone"
        table.insert(actions,v)
    end
end

if actions ~= nil then
    append_blankStone_spells()
end
