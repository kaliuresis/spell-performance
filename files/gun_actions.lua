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
    if(spell.id == "RESET") then
		spell.action = function()
			current_reload_time = current_reload_time - 25

			for i,v in ipairs( hand ) do
				-- print( "removed " .. v.id .. " from hand" )
                if v.permanently_attached == nil then
                    table.insert( discarded, v )
                end
			end

			for i,v in ipairs( deck ) do
				-- print( "removed " .. v.id .. " from deck" )
				table.insert( discarded, v )
			end

			hand = {}
			deck = {}

			if ( force_stop_draws == false ) then
				force_stop_draws = true
				move_discarded_to_deck()
				order_deck()
			end
		end
    end
end
