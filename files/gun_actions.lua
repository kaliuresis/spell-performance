for _, spell in ipairs(actions) do

    if spell.id == "DIVIDE_10" then
        local _action = spell.action
        spell.action 		= function( recursion_level, iteration )
            -- empty entity list here because evaluation trees with d10 
            -- are the most likely to need intermittent processing
            process_entity_list()
            return _action(recursion_level, iteration)
            
		end
    end
end
