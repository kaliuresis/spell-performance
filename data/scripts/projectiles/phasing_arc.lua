dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once("mods/spell_performance/files/helpers.lua")

local entity_id    = GetUpdatedEntityID()
local x, y = EntityGetTransform( entity_id )

local num_stacks = 1
local comp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
if ( comp ~= nil ) then
    num_stacks = get_num_stacks("data/entities/misc/phasing_arc.xml", comp)
end

local distance = 28 * num_stacks

local velocity_comp = EntityGetFirstComponent( entity_id, "VelocityComponent")
if velocity_comp == nil then return end
local vel_x,vel_y = ComponentGetValueVector2( velocity_comp, "mVelocity")

local dir = 0 - math.atan2( vel_y, vel_x )

local ox = math.cos( dir ) * distance
local oy = 0 - math.sin( dir ) * distance

EntitySetTransform( entity_id, x + ox, y + oy )