local entity_id = GetUpdatedEntityID()
EntityRemoveFromParent(entity_id)

local who_shot = GameGetWorldStateEntity()
if(who_shot) then
    EntityAddChild(who_shot, entity_id)
end
