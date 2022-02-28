dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/spell_performance/files/helpers.lua")

local entity_id = GetUpdatedEntityID()
local projcomp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )

if projcomp ~= nil then

    -- get the number of stacks to apply
    local num_stacks = get_num_stacks("data/entities/misc/homing_rotate.xml", projcomp)
    
    
    -- create a HitEffectComponent with the proper amount of crit on it

    count = math.min(num_stacks, 20)
    
    for i=1,count do
        comp = EntityAddComponent( entity_id, "HomingComponent")
        ComponentSetValue2( comp, "just_rotate_towards_target", true )
        ComponentSetValue2( comp, "max_turn_rate", 0.2)
    end
    
end