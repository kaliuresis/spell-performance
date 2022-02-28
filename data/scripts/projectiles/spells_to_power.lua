dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/spell_performance/files/helpers.lua")

local entity_id = GetUpdatedEntityID()
local root_id = EntityGetRootEntity( entity_id )
local x, y = EntityGetTransform( entity_id )
local radius = 160

local projectiles = EntityGetInRadiusWithTag( x, y, radius, "projectile" )
local count = 0
local expcount = 0
local who_shot

local num_stacks = 1
local comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
if ( comp ~= nil ) then
	who_shot = ComponentGetValue2( comp, "mWhoShot" )
    -- get number of stp stacks
    num_stacks = get_num_stacks("data/entities/misc/spells_to_power.xml", comp)
end

if ( who_shot ~= nil ) and ( comp ~= nil ) then
    --first, retrieve cached values for stp if they exist
    
    local stp_cache_comp = "continue"
    local i = 0
    while stp_cache_comp == "continue" do
        i = i + 1
        if i > 50 then GamePrint("loop"); break end
        --find first stp_cache_comp, may be an old value
        stp_cache_comp = EntityGetFirstComponent( who_shot, "VariableStorageComponent", "stp_cache" )
        
        if stp_cache_comp ~= nil then
            --check if the cached value is stale
            frame_num = GameGetFrameNum()
            cache_frame_num = ComponentGetValue2( stp_cache_comp, "value_int" )
            if cache_frame_num ~= frame_num then
                --delete the stale value
                EntityRemoveComponent(who_shot, stp_cache_comp)
                stp_cache_comp = "continue" -- try again for a fresh value
            end
        end
    end
    
    if stp_cache_comp ~= nil then
        --retrieve cached values
        values_str = ComponentGetValue2( stp_cache_comp, "value_string" )
        count = extract_int("count", values_str)
        expcount = extract_int("expcount", values_str)
    else
        --otherwise, we must compute values

        for i,projectile_id in ipairs(projectiles) do
            if ( projectile_id ~= root_id ) and ( projectile_id ~= entity_id ) and ( EntityHasTag( projectile_id, "spells_to_power_target" ) == false ) and ( EntityHasTag( projectile_id, "projectile_not" ) == false ) then
                local comp2 = EntityGetFirstComponent( projectile_id, "ProjectileComponent" )
                local delete = false
                
                if ( comp2 ~= nil ) then
                    local who_shot2 = ComponentGetValue2( comp2, "mWhoShot" )
                    
                    if ( who_shot == who_shot2 ) and ( who_shot ~= NULL_ENTITY ) then
                        delete = true
                        ComponentSetValue2( comp2, "on_death_explode", false )
                        ComponentSetValue2( comp2, "on_lifetime_out_explode", false )
                        ComponentSetValue2( comp2, "collide_with_entities", false )
                        ComponentSetValue2( comp2, "collide_with_world", false )
                        ComponentSetValue2( comp2, "lifetime", 999 )
                    end
                end
                
                if delete then
                    local amount = ComponentGetValue2( comp2, "damage" ) or 0.1
                    local amount2 = tonumber( ComponentObjectGetValue2( comp2, "config_explosion", "damage" ) ) or 0.1
                    amount = amount * 10
                    amount2 = amount2 * 10
                    
                    count = count + amount
                    expcount = expcount + amount2
                    
                    if delete then
                        EntityAddComponent( projectile_id, "LifetimeComponent", 
                        {
                            lifetime = "1",
                        } )
                    end
                end
            end
        end
        
        --now, cache the values for future stps
        --GamePrint(tostring(who_shot))
        cache_comp = EntityAddComponent( who_shot, "VariableStorageComponent")
        --GamePrint("cache_comp id: " .. tostring(cache_comp))
        ComponentSetValue2( cache_comp, "value_int", GameGetFrameNum() )
        ComponentSetValue2( cache_comp, "value_string", "count: " .. tostring(math.floor(count)) .. " expcount: " .. tostring(math.floor(expcount)))
        ComponentAddTag( cache_comp, "stp_cache" )
    end
    
    -- count and expcount are now found, whether through computing them or retrieving a past cache
    -- just proceed and finish and do normal stp things, scaled by number of stp stacks
	
	local totalcount = (count + expcount)
	
	local damage = ComponentGetValue2( comp, "damage" )
	local expdamage = ComponentObjectGetValue( comp, "config_explosion", "damage" )
	local exprad = ComponentObjectGetValue( comp, "config_explosion", "explosion_radius" )
	
	damage = damage + count * 0.1 * num_stacks
	expdamage = expdamage + expcount * 0.1 * num_stacks
	exprad = math.min( 120, math.floor( exprad + math.log( totalcount * 10.5 ) ) )
	
	ComponentSetValue2( comp, "damage", damage )
	ComponentObjectSetValue( comp, "config_explosion", "damage", expdamage )
	ComponentObjectSetValue( comp, "config_explosion", "explosion_radius", exprad )
	
    setting = tonumber(ModSettingGet("spell_performance.cosmetics_setting"))
    if setting > 0 then 
        for i = 1, math.min(setting, num_stacks) do
            local effect_id = EntityLoad("data/entities/particles/tinyspark_red_large.xml", x, y)
            EntityAddChild( root_id, effect_id )
            
            edit_component( effect_id, "ParticleEmitterComponent", function(comp3,vars)
                local part_min = math.min( math.floor( totalcount * 0.5 ), 100 )
                local part_max = math.min( totalcount + 1, 120 )
                
                ComponentSetValue2( comp3, "count_min", part_min )
                ComponentSetValue2( comp3, "count_max", part_max )
            end)
        end 
    end
    
	
end