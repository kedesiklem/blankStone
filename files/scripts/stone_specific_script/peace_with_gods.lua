
local function charmShopKeepers()
    local steves = EntityGetWithTag( "necromancer_shop" )
    if( steves ~= nil ) then
        for _,entity_steve in ipairs(steves) do
            if GameGetGameEffectCount(entity_steve,"CHARM") < 1 then
                GetGameEffectLoadTo( entity_steve, "CHARM", true )
            end
        end
    end
end

charmShopKeepers()