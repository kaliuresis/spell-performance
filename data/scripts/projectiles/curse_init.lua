dofile_once("data/scripts/lib/utilities.lua")

local entity_id = GetUpdatedEntityID()
local root_id = EntityGetRootEntity( entity_id )

local x,y = EntityGetTransform( root_id )
local curseflag = EntityHasTag( root_id, "effect_CURSE" )

--get num stacks, component of this entity which is a child of the target
local varcomps = EntityGetComponent( entity_id, "VariableStorageComponent" )
local num_stacks = 1
for i, varcomp in ipairs(varcomps) do
    local name = ComponentGetValue2( varcomp, "name" )
    if (name == "curse_stack_storage") then
        num_stacks = ComponentGetValue2( varcomp, "value_int" )
    end
end

if ( EntityHasTag( root_id, "curse_NOT" ) == false ) then
    local curse_entity = nil
    
	if ( curseflag == false ) then
		local eid = EntityLoad( "data/entities/misc/curse.xml", x, y )
		EntityAddChild( root_id, eid )
		EntityAddTag( root_id, "effect_CURSE" )
		
		local comps = EntityGetComponent( entity_id, "VariableStorageComponent" )
		if ( comps ~= nil ) then
			for i,comp in ipairs( comps ) do
				local name = ComponentGetValue2( comp, "name" )
				
				if ( name == "projectile_who_shot" ) then
					local who_shot = ComponentGetValue2( comp, "value_int" )
					
					EntityAddComponent( eid, "VariableStorageComponent",
					{
						name="projectile_who_shot",
						value_int=who_shot,
					} )
					break
				end
			end
		end
        --default entity already has 1 stack, don't add that one later
        num_stacks = num_stacks - 1
        curse_entity = eid
	else
		local c = EntityGetAllChildren( root_id )
		if ( c ~= nil ) then
			for i,v in ipairs( c ) do
				if EntityHasTag( v, "effect_CURSE" ) then
                    curse_entity = v -- save the entity to add damage stacks to it later, somewhat inelegant to not do it here
					local comp = EntityGetFirstComponent( v, "LifetimeComponent", "effect_curse_lifetime" )
					
					if ( comp ~= nil ) then
						ComponentSetValue2( comp, "creation_frame", GameGetFrameNum() )
						ComponentSetValue2( comp, "kill_frame", GameGetFrameNum() + 300 )
						
						comp = EntityGetFirstComponent( v, "VariableStorageComponent", "effect_curse_damage" )
						
						if ( comp ~= nil ) then
							local damage = ComponentGetValue2( comp, "value_float" )
							damage = damage + 0.08
							ComponentSetValue2( comp, "value_float", damage )
						end
					end
					
					break
				end
			end
		end
	end
    
    -- when the curse stack storage component is found,
    -- increase the curse entity's damage by that many stacks
    local curse_comps = EntityGetComponent( curse_entity, "VariableStorageComponent" )
    for i,curse_comp in ipairs( curse_comps ) do
        
        local name = ComponentGetValue2( curse_comp, "name" )
        if name == "effect_curse_damage" then
            -- GamePrint("adding damage, stacks = " .. tostring(num_stacks))
            old_damage = ComponentGetValue2(curse_comp, "value_float")
            ComponentSetValue2(curse_comp, "value_float", old_damage + num_stacks * 0.08)
        end
    end
end

EntityKill( entity_id )