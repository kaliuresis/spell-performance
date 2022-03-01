local entity_id = GetUpdatedEntityID()
EntityRemoveFromParent(entity_id)

local who_shot
local projectile_component = EntityGetFirstComponent(entity_id, "ProjectileComponent")
if(projectile_component) then
    who_shot = ComponentGetValue2(projectile_component, "mWhoShot")
end
if(who_shot) then
    EntityAddChild(who_shot, entity_id)
end
