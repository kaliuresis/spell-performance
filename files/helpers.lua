function get_num_stacks(entity_filename, projcomp)
    local counts_str = ComponentObjectGetValue2( projcomp, "config", "action_id" )
    return extract_int(entity_filename, counts_str)
end

-- get int associated with name 
function extract_int(name, str)
    -- find where in the string the stack num is stored by searching for the name
    -- then use a RE to extract the next consecutive digits, which will be the count
    
    local start = 0
    _, start = string.find(str, name)
    local target_substr = string.sub(str, start)
    local res = tonumber(string.match(target_substr, "\-*[%d]+"))
    return res
end
