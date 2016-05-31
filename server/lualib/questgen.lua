local M= {}


M.actions = {
    ['goto'] ={
        {
            description = 'Just wander around and look',
            sequence = {'>explore'},
            level = 1
        }
    },
    ['learn'] ={
        {
            description = 'Go someplace, get something, and read what is written on it',
            sequence = {'goto', 'get', '>read'}
        }
    },
    ['get'] = {
        {
            description = 'steal it from somebody',
            sequence = {'steal'}
        },
        {
            description = 'Go someplace and pick something up which lying around',
            sequence = {'goto', '>gather'}
        }
    },
    ['steal'] = {
        {
            description = 'Go someplcae, sneek up on somebody, and take something',
            sequence = {'goto', '>stealth', '>take'}
        }
    },
    ['spy'] = {
        {
            description = 'go someplcae, spy on somebody, return and report',
            sequence = {'goto', 'kill', '>take'}
        }
    },
    ['capture'] = {
        {
            description = 'Get something, go someplace and use it to capture somebody',
            sequence = { 'get', 'goto', '>capture'}
        }
    },
    ['kill'] = {
        {
            description = '[easy]Go someplace and kill all the monsters',
            sequence = { '>kill'},
            level = 1
        },
        {
            description = '[normal]Go someplace and kill all the monsters',
            sequence = { '>kill'},
            level = 2
        },
        {
            description = '[hard]Go someplace and kill all the monsters',
            sequence = {'>kill'},
            level = 3
        }
    },
}
---[[
    function M.actions.Has_Level(name_type, level)
        for _,action in pairs(M.actions[name_type]) do
            if action.level == level then
                return action
            end
        end
        return nil
    end
    --]]
M.motivations = {
   --[[
    ['knowledge'] = {
        {
            description = 'Deliver item for study',
            sequence = {'get', 'goto', '>give'}
        }
    },
    ['comfort'] = {
        {
            description = 'Obtain luxuries',
            sequence = {'get', 'goto', '>give'}
        },
        {
            description = 'Kill pests',
            sequence    = {'goto', '>damage', 'goto', '>report'}
        },
    },
    --]]
    ['reputation'] = {
       -- --[[
        {
            description ='Obtain rare items',
            sequence    = {'get', 'goto', '>give'}
        },
        --]]
        --[[
        {
            description = 'Kill enemies',
            sequence    = {'kill', 'kill', 'kill','kill','goto','>report'},
        },
        --[[
        {
            description = 'Visit a dangerous place',
            sequence    = {'goto', 'goto', '>report'}
        },
        --]]
    },
}

M.actions_index = {'goto', 'learn', 'get', 'steal', 'spy', 'capture', 'kill'}

local function random_action()

    local index = math.random(1, #M.actions_index)
    return M.actions[M.actions_index[index]]
end

M.generated_steps = {}
M.depth = 0
function M.generatequest(depth)
    local motivation = M.random_from(M.random_from(M.motivations))
    print("Generating a Quest for "..motivation.description .. ":" .. M.sequence_to_str(motivation.sequence))
    M.generate_step(motivation.sequence)
    local fullstep = ''
    fullstep = fullstep .. motivation.description .. '\n'
    for _, step in pairs(M.generated_steps) do
        --print(step)
        fullstep = fullstep .. step.. '\n'
    end
    return fullstep
end

function M.init_onestep()
    local motivation = M.random_from(M.random_from(M.motivations))
    step_stack.push(motivation)
    M.motivation = motivation.description
    M.hard_level = 1
    print("end of init_onestep " ..M.motivation) -- M.random_from(M.random_from(M.motivations)).description)
end

function M.random_from( t )
    local choice = "F"
    local n = 0
    for i, o in pairs(t) do
        n = n + 1
        if math.random() < (1/n) then
            choice = o
        end
    end
    return choice
end

function M.generate_step(sequence)
    for _,action in pairs(sequence) do
        -- print("action is "..action)
        if string.match(action, '>.-$') == nil then
            local step = M.random_from( M.actions[action])
            M.generated_steps[#M.generated_steps + 1] = M.padding_by(M.depth)..step.description .. ":" .. M.sequence_to_str(step.sequence)
            M.depth = M.depth + 1
            -- print("match")
            M.generate_step(step.sequence)
        else
            M.depth = M.depth - 1
            M.generated_steps[#M.generated_steps + 1] = M.padding_by(M.depth).. action
            return
            -- print(action)
        end
    end
end

step_stack = {}
function step_stack.push(item)
   step_stack[#step_stack+1]= item
end

function step_stack.pop()
    step_stack[#step_stack] = nil
end

function step_stack.peak()
    return step_stack[#step_stack]
end

function M.generate_one_step(is_win)
   -- print("step stack is " .. #step_stack.."is win "..is_win)
    if is_win then
    print("generate_one_step is win ") --.. is_win)
        M.hard_level = M.hard_level +1
        if M.hard_level > 3 then
            M.hard_level = 3
        end
    else
    print("generate_one_step is lose") --.. is_win)
        M.hard_level = M.hard_level -1
        if M.hard_level < 1 then
            M.hard_level = 1
        end
    end
    if #step_stack == 0 then
        return "finished", ""
    end
    local cur_step = step_stack.peak()
    local count = 0
    for _,action in pairs(cur_step.sequence) do
        count = count + 1
    end
    print("count " .. count)
    if count == 0 then
        step_stack.pop()
        if #step_stack == 0 then
            return "finished", ""
        end
        cur_step = step_stack.peak()
    end
    local next_action = nil
    for _,action in pairs(cur_step.sequence) do
        next_action = action
        break
    end
    if next_action == nil then
        return "finished", ""
    end
    table.remove(cur_step.sequence, 1)
    ---- expand
    if string.match(next_action, '>.-$') == nil then
        if M.actions.Has_Level(next_action, M.hard_level) ~= nil then
            step_stack.push(M.actions.Has_Level(next_action, M.hard_level))
            print("action " .. next_action .. " has level " .. M.hard_level)
        else 
            step_stack.push(M.random_from(M.actions[next_action]))
            print("action " ..next_action .. " does not have level ".. M.hard_level)
        end
    end
    --print("description " 
    return cur_step.description , next_action

end


function M.sequence_to_str(sequence)
    local str = ""
    for _,v in pairs(sequence) do
        str = str .. v ..' '
    end
    return '['..str..']'
end

function M.padding_by( numbers )
    padding = "  "
    for i = 1, numbers, 1 do
        padding = padding .. padding
    end
    return padding
end

return M
