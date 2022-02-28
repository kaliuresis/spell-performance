dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/spell_performance/files/helpers.lua")

local entity_id = GetUpdatedEntityID()
local projcomp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )

if projcomp ~= nil then

    -- get the number of stacks to apply
    local num_stacks = get_num_stacks("data/entities/misc/hitfx_curse.xml", projcomp)
    
    available_scripts = {8192, 4096, 2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1}
    
    while num_stacks > 0 do
        --find largest script that represents less stacks than we have left to apply,
        for i = 1,#available_scripts do
            if available_scripts[i] <= num_stacks then
                --apply it and reduce remaining stacks by that amount
                comp = EntityAddComponent( entity_id, "HitEffectComponent")
                ComponentSetValue2( comp, "effect_hit", "LOAD_CHILD_ENTITY" )
                ComponentSetValue2( comp, "value_string", "mods/spell_performance/files/curse_init_" .. 
                        tostring(available_scripts[i]) .. ".xml" )
                num_stacks = num_stacks - available_scripts[i]
            end
        end
    end
end