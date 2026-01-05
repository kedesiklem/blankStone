local blankStone_status_list = {
    {
        id="blankStone_DOUBLE_VISION",
        ui_name="$status_blankStone_doublevision",
        ui_description="$statusdesc_blankStone_doublevision",
        ui_icon="data/ui_gfx/status_indicators/alcoholic.png",
		effect_entity="mods/blankStone/files/entities/misc/effect_double_vision.xml",
		is_harmful=true,
    },
    {
        id="blankStone_PROTECTION_POISON",
        ui_name="$status_blankStone_protection_poison",
        ui_description="$statusdesc_blankStone_protection_poison",
        ui_icon="mods/blankStone/files/ui_gfx/status_indicators/protection_poison_status.png",
		effect_entity="mods/blankStone/files/entities/misc/effect_protection_poison.xml",
		is_harmful=true,
    },
}
local len = #status_effects
for i=1, #blankStone_status_list do
    status_effects[len+i]=blankStone_status_list[i]
end