-- all functions below are optional and can be left out

--[[

function OnModPreInit()
	print("Mod - OnModPreInit()") -- First this is called for all mods
end

function OnModInit()
	print("Mod - OnModInit()") -- After that this is called for all mods
end

function OnModPostInit()
	print("Mod - OnModPostInit()") -- Then this is called for all mods
end

function OnPlayerSpawned( player_entity ) -- This runs when player entity has been created
	GamePrint( "OnPlayerSpawned() - Player entity id: " .. tostring(player_entity) )
end

function OnWorldInitialized() -- This is called once the game world is initialized. Doesn't ensure any world chunks actually exist. Use OnPlayerSpawned to ensure the chunks around player have been loaded or created.
	GamePrint( "OnWorldInitialized() " .. tostring(GameGetFrameNum()) )
end

function OnWorldPreUpdate() -- This is called every time the game is about to start updating the world
	GamePrint( "Pre-update hook " .. tostring(GameGetFrameNum()) )
end

]]

function OnMagicNumbersAndWorldSeedInitialized() -- this is the last point where the Mod* API is available. after this materials.xml will be loaded.
	local x = ProceduralRandom(0,0)
	print( "===================================== random " .. tostring(x) )
end

-- This code runs when all mods' filesystems are registered
ModLuaFileAppend( "data/scripts/gun/gun_actions.lua", "mods/spell_performance/files/gun_actions.lua" ) -- Basically dofile("mods/example/files/actions.lua") will appear at the end of gun_actions.lua
ModLuaFileAppend( "data/scripts/gun/gun_extra_modifiers.lua", "mods/spell_performance/files/gun_extra_modifiers.lua" )
ModLuaFileAppend( "data/scripts/gun/gun.lua", "mods/spell_performance/files/gun.lua" )

function uncram(entity, max_slots)
    local items = EntityGetAllChildren(entity)
    if(not items) then return end
    local n_slots_filled = {0,0}
    if(type(max_slots) ~= "table") then
        max_slots = {max_slots, max_slots}
    end
    for i,item in ipairs(items) do
        local slot_type = 1
        local item_comp = EntityGetFirstComponentIncludingDisabled(item, "ItemComponent")
        local item_capacity = EntityGetWandCapacity(item)
        if(item_comp
           and not EntityHasTag(item, "this_is_sampo")
           and not ComponentGetValue2(item_comp, "permanently_attached"))
        then
            local item_slot_x, item_slot_y = ComponentGetValue2(item_comp, "inventory_slot")
            local ability_comp = EntityGetFirstComponentIncludingDisabled(item, "AbilityComponent")
            local item_slot = item_slot_x+1000*item_slot_y
            if(ability_comp and ComponentGetValue2(ability_comp, "use_gun_script")) then
                slot_type = 2
            end
            if(max_slots[slot_type] and n_slots_filled[slot_type] >= max_slots[slot_type]) then
                -- GamePrint("Nice try "..item_slot_x..", "..item_slot_y)
                EntityRemoveFromParent(item)
                local components = EntityGetAllComponents(item)
                for m,comp in ipairs(components) do
                    if(ComponentHasTag(comp, "enabled_in_world") and not ComponentHasTag(comp, "item_unidentified")) then
                        EntitySetComponentIsEnabled(item, comp, true)
                    end
                end
            else
                n_slots_filled[slot_type] = n_slots_filled[slot_type]+1
            end
        end
        uncram(item, item_capacity)
    end
end

function OnWorldPostUpdate() -- This is called every time the game has finished updating the world
    local player = EntityGetWithTag("player_unit")[1]
    if(player) then
        local inventory = EntityGetFirstComponent(player, "Inventory2Component")
        local inventory_capacity = {}
        inventory_capacity["inventory_full"] = (ComponentGetValue2(inventory, "full_inventory_slots_x")
                                                *ComponentGetValue2(inventory, "full_inventory_slots_y"))
        inventory_capacity["inventory_quick"] = {4,4}
        local children = EntityGetAllChildren(player)
        for c,child in ipairs(children) do
            local name = EntityGetName(child)
            if(inventory_capacity[name]) then
                uncram(child, inventory_capacity[name])
            end
        end
    end
end

--print("Example mod init done")
