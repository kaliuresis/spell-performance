dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/spell_performance/files/helpers.lua")

local entity_id = GetUpdatedEntityID()
local projcomp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )

if projcomp ~= nil then

    -- get the number of stacks to apply
    local num_stacks = get_num_stacks("data/entities/misc/area_damage.xml", projcomp)
    
    local areacomp = EntityGetFirstComponent( entity_id, "AreaDamageComponent" )
    
    ComponentSetValue2( areacomp, "damage_per_frame", 0.14 * num_stacks)
    --[[
    EntityAddComponent2(entity_id, "AreaDamageComponent", {
        ["aabb_min.x"]="-16",
		["aabb_min.y"]="-16",
		["aabb_max.x"]="16", 
		["aabb_max.y"]="16", 
		["damage_per_frame"] = tostring(num_stacks * 0.14),
		["update_every_n_frame"] ="1",
		["entities_with_tag"] ="homing_target",
		["death_cause"]="$damage_rock_curse",
		["damage_type"]="DAMAGE_PROJECTILE",
		["circle_radius"]="16",
    })
    ]]
end