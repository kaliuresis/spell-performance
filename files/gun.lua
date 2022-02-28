function string_split(inputstr, delim)
    result = {}

    for str in string.gmatch(inputstr, "([^"..delim.."]+)") do
        table.insert(result, str)
    end
    return result;
end

-- clear c.extra_entites, increment the respective count by 1 for each entity
function process_entity_list()
    entities = string_split(c.extra_entities, ",")
    if entity_counts == nil then entity_counts = {} end
    
    for _, entity in ipairs(entities) do
        count = entity_counts[entity] or 0
        entity_counts[entity] = count + 1
    end
    c.extra_entities = ""
    --GamePrint("process_entity_list(), crit wet count: " .. tostring(entity_counts["data/entities/misc/hitfx_critical_water.xml"]))
end


-- -1 : no stack limit, but stacks are handled by passing the number of stacks to a script
-- positive int : separate entity for every stack up to a maximum of that number
-- "cosmetic" : do what the user's setting tells us to do
entities_to_collapse = {
    ["data/entities/misc/hitfx_critical_water.xml"] = -1,
    ["data/entities/misc/hitfx_critical_blood.xml"] = -1,
    ["data/entities/misc/hitfx_critical_oil.xml"] = -1,
    ["data/entities/misc/hitfx_burning_critical_hit.xml"] = -1,
    
    ["data/entities/misc/accelerating_shot.xml"] = -1,
    ["data/entities/misc/decelerating_shot.xml"] = -1,
    ["data/entities/misc/spells_to_power.xml"] = -1,
    ["data/entities/misc/area_damage.xml"] = -1,
    ["data/entities/misc/phasing_arc.xml"] = -1,
    
    ["data/entities/misc/hitfx_curse.xml"] = -1,
    
    
    ["data/entities/misc/piercing_shot.xml"] = 1,
    ["data/entities/misc/effect_apply_wet.xml"] = 1,
    ["data/entities/misc/effect_apply_oiled.xml"] = 1,
    ["data/entities/misc/effect_apply_bloody.xml"] = 1,
    ["data/entities/misc/effect_apply_on_fire.xml"] = 1,
    ["data/entities/misc/hitfx_curse_wither_projectile.xml"] = 1,
    ["data/entities/misc/hitfx_curse_wither_explosion.xml"] = 1,
    ["data/entities/misc/hitfx_curse_wither_melee.xml"] = 1,
    ["data/entities/misc/hitfx_curse_wither_electricity.xml"] = 1,
    ["data/entities/misc/explosion_tiny.xml"] = 1,
    
    --transmutations
    ["data/entities/misc/water_to_poison.xml"] = 1,
    ["data/entities/misc/liquid_to_explosion.xml"] = 1,
    ["data/entities/misc/toxic_to_acid.xml"] = 1,
    ["data/entities/misc/transmutation.xml"] = 1,
    ["data/entities/misc/static_to_sand.xml"] = 1,
    ["data/entities/misc/lava_to_blood.xml"] = 1,
    
    
    
    
    ["data/entities/misc/homing_rotate.xml"] = 20,
    ["data/entities/misc/homing.xml"] = 20,
    ["data/entities/misc/homing_short.xml"] = 20,
    ["data/entities/misc/homing_shooter.xml"] = 20,
    ["data/entities/misc/autoaim.xml"] = 20,
    ["data/entities/misc/homing_accelerating.xml"] = 20,
    ["data/entities/misc/homing_cursor.xml"] = 20,
    ["data/entities/misc/homing_area.xml"] = 1,
    ["data/entities/misc/homing_shooter.xml" ] = 20,
    
    
    ["data/entities/misc/line_arc.xml"] = 20,
    ["data/entities/misc/horizontal_arc.xml"] = 20,
    
    
    
    
    
    
    
    ["data/entities/misc/effect_frozen.xml"] = 1,
    ["data/entities/particles/freeze_charge.xml"] = 1,
    ["data/entities/particles/electricity.xml"] = 1,
    
    
    
    
    ["data/entities/particles/gold_sparks.xml"] = "cosmetic",
    ["data/entities/particles/blood_sparks.xml"] = "cosmetic",
    ["data/entities/particles/tinyspark_white.xml"] = "cosmetic",
    ["data/entities/particles/tinyspark_white_weak.xml"] = "cosmetic",
    ["data/entities/particles/tinyspark_white_small.xml"] = "cosmetic",
    ["data/entities/particles/tinyspark_red.xml"] = "cosmetic",
    ["data/entities/particles/tinyspark_yellow.xml"] = "cosmetic",
    ["data/entities/particles/tinyspark_green.xml"] = "cosmetic",
    ["data/entities/particles/tinyspark_purple.xml"] = "cosmetic",
    ["data/entities/particles/tinyspark_purple_bright.xml"] = "cosmetic",
    ["data/entities/particles/tinyspark_orange.xml"] = "cosmetic",
    ["data/entities/particles/heavy_shot.xml"] = "cosmetic",
    ["data/entities/particles/light_shot.xml"] = "cosmetic",
    ["data/entities/misc/colour_red.xml"] = "cosmetic",
    ["data/entities/misc/colour_orange.xml"] = "cosmetic",
    ["data/entities/misc/colour_green.xml"] = "cosmetic",
    ["data/entities/misc/colour_yellow.xml"] = "cosmetic",
    ["data/entities/misc/colour_purple.xml"] = "cosmetic",
    ["data/entities/misc/colour_blue.xml"] = "cosmetic",
    ["data/entities/misc/colour_rainbow.xml"] = "cosmetic",
    ["data/entities/misc/colour_invis.xml"] = "cosmetic",
    
    
    
    
    
}

--[[ Currently affected spells:
Crit on wet, bloody, and oiled
Material water, blood, and oil
GtP and BtP
Spells to Power
Piercing
Proj weakening
Rotate toward foes
Accelerating shot
Heavy and Light Shot
Damage Plus
]]

function add_entities(filename, count)
    if count == 0 then return end
    for i = 1, count do
        c.extra_entities = c.extra_entities .. filename .. ","
    end
end


function draw_shot( shot, instant_reload_if_empty )
	local c_old = c
    local entity_counts_old = entity_counts
    
	c = shot.state
    entity_counts = nil
	
	shot_structure = {}
	draw_actions( shot.num_of_cards_to_draw, instant_reload_if_empty )
    
    --- this is the end of spell evaluation; do cleanup logic here
    
    process_entity_list()
    
    --- store the one copy of each extra entity in the list, and their counts in action_id
    --- the engine uses the c.extra_entities to add one copy of each script,
    --- then the individual scripts look at c.action_id to determine how many
    --- copies of themselves they should act as.
    
    -- GamePrint("Finished Cast")
    
    if entity_counts ~= nil then
        for filename, count in pairs(entity_counts) do
            if entities_to_collapse[filename] == nil then
                add_entities(filename, count)
        
            elseif entities_to_collapse[filename] == "cosmetic" then
                local setting = tonumber(ModSettingGet("spell_performance.cosmetics_setting"))
                -- GamePrint("setting = " .. tostring(setting))
                add_entities(filename, math.min(setting, count))
        
            elseif entities_to_collapse[filename] >= 0 then
                add_entities(filename, math.min(count, entities_to_collapse[filename])) 

            elseif entities_to_collapse[filename] == -1 then
                -- GamePrint(filename .. ": " .. tostring(count))
                add_entities(filename, 1)
                c.action_id = c.action_id .. filename .. ": " .. tostring(count) .. " "
                
            end
        end
        entity_counts = nil
    end
    
    -- continue with game's code
    
	register_action( shot.state )
	SetProjectileConfigs()

	c = c_old
    entity_counts = entity_counts_old
end
