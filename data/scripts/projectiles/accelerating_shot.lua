dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/spell_performance/files/helpers.lua")

local entity_id    = GetUpdatedEntityID()

-- get number of accel stacks

local projcomp = EntityGetFirstComponent( entity_id, "ProjectileComponent" )
local num_stacks = 1
if projcomp ~= nil then 
    num_stacks = get_num_stacks("data/entities/misc/accelerating_shot.xml", projcomp)
end

-- continue game code

local x, y = EntityGetTransform( entity_id )

local parent_id = EntityGetParent( entity_id )

local target_id = 0

if ( parent_id ~= NULL_ENTITY ) then
	target_id = parent_id
else
	target_id = entity_id
end

if ( target_id ~= NULL_ENTITY ) then
	local projectile_components = EntityGetComponent( target_id, "ProjectileComponent" )
	
	if( projectile_components == nil ) then return end
		
	if ( #projectile_components > 0 ) then
		edit_component( target_id, "VelocityComponent", function(comp,vars)
			local air_friction = ComponentGetValue( comp, "air_friction" )
			air_friction = air_friction - 3 * num_stacks
			vars.air_friction = air_friction
		end)
	end
end
