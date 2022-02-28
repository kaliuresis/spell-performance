dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/spell_performance/files/helpers.lua")

local entity_id = GetUpdatedEntityID()
local projcomp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )

if projcomp ~= nil then

    -- get the number of stacks to apply
    local num_stacks = get_num_stacks("data/entities/misc/hitfx_burning_critical_hit.xml", projcomp)
    
    
    -- create a HitEffectComponent with the proper amount of crit on it

    comp = EntityAddComponent( entity_id, "HitEffectComponent")
    ComponentSetValue2( comp, "condition_effect", "ON_FIRE" )
    ComponentSetValue2( comp, "effect_hit", "CRITICAL_HIT_BOOST" )
    ComponentSetValue2( comp, "value", num_stacks * 100 )
    
end