local entity_id    = GetUpdatedEntityID()
local pos_x, pos_y = EntityGetTransform( entity_id )


local reaction_distance_max = 70 -- maybe change to entity variable
local elemental_stone_path = "mods/blankStone/files/entities/"
local material_to_stone_tbl =
{
  ["radioactive_liquid"] = "stone_toxic",
}

local converted = false

print("Checking for nearby potions to infuse...")
for _,id in pairs(EntityGetInRadiusWithTag(pos_x, pos_y, 70, "item_pickup")) do
	-- make sure item is not carried in inventory or wand
	if EntityGetRootEntity(id) == id then
		local x,y = EntityGetTransform(entity_id)

        -- Find nearest flask entity
        local potions = EntityGetInRadiusWithTag(pos_x, pos_y, reaction_distance_max, "item_pickup")
        for key, value in pairs(potions) do
            print("Found potion [" .. key .. "] entity with ID: " .. value)
        end
        -- if(potions) then
        --     local potion = pairs(potions)[1]
        --     local _,material = GetMaterialInventoryMainMaterial(potion)
        --     if (material) then
        --         local material_name = CellFactory_GetName( material )
        --         print("Material name: " .. material_name )

        --         local stone_name = material_to_stone_tbl[material_name]
        --         if (stone_name) then
        --             EntityLoad(elemental_stone_path .. stone_name .. ".xml", x, y - 5)
        --             EntityLoad("data/entities/projectiles/explosion.xml", x, y - 10)
        --             EntityKill(id)
        --             converted = true

        --         end
        --     end
        -- end
    end
end
print("Infusion complete.")