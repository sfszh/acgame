local Tree = require "tree"
local M= {}


M.actions = {
    ['goto'] ={
        {
            description = 'go to someplace',
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
            description = '[easy] you just need to kill an easier monster',
            sequence = { '>kill'},
            level = 1
        },
        {
            description = '[normal]you need to kill an monster',
            sequence = { '>kill'},
            level = 2
        },
        {
            description = '[hard] aha you need to kill a very challenging monster',
            sequence = {'>kill'},
            level = 3
        }
    },
    ['explore'] = {
        {
            description = '[easy] you only need to look around',
            level = 1
        },
        {
            description = '[normal] you need to around',
            level = 2
        },
        {
            description = '[hard] you really need to look hardly',
            level = 3
        }
    },
    ['report'] = {
        {
            description = 'return and report',
            level = 1
        }
    }
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
       --[[
        {
            description ='Obtain rare items',
            sequence    = {'get', 'goto', '>give'}
        },
        --]]
        ----[[
        {
            description = 'Kill enemies',
            sequence    = {'kill','goto','>report'},
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

function M.generate_tree_0()
    local tree = Tree:new()
    tree(2):set("2") 
    tree(1):set("1")
    tree(1)(2):set("12")
    tree(1)(1):set("11")
    tree(1)(3):set("13")
    tree(1)(1)(1):set("111")
    return tree
end

function M.generate_tree()
    local motivation = M.random_from(M.random_from(M.motivations))
    local tree = Tree:new()
    tree:set(motivation.description)
    print("Generating a Quest for "..motivation.description .. ":" .. M.sequence_to_str(motivation.sequence))
    tree:newChild(1,"")
    M.generate_tree_step(tree[1],motivation.sequence)
    return tree
end

function M.generate_tree_step(node, sequence)
    for _,action in pairs(sequence) do
        if string.match(action, '>.-$') == nil then
            local step = M.random_from( M.actions[action])
            --M.generated_steps[#M.generated_steps + 1] = M.padding_by(M.depth)..step.description .. ":" .. M.sequence_to_str(step.sequence)
            print("step" .. step.description)
            node:newChild(1,step.description)
            M.depth = M.depth + 1
            -- print("match")
            M.generate_tree_step(node[1], step.sequence)
        else
            M.depth = M.depth - 1
            print("action" .. action)
            --M.generated_steps[#M.generated_steps + 1] = M.padding_by(M.depth).. action
            node.parent:newChild(nil,action)
            return
            -- print(action)
        end
    end
end

function M.get_desc(action_name, level) 
    
    if string.match(action_name, '>.-$') ~= nil then
        action_name = string.sub(action_name,2)
        print("yo" ..action_name)
    end
    if M.actions[action_name] == nil then
        return "invalid"
    end
    for _, action in pairs(M.actions[action_name]) do
        if action.level == level then
            return action.description
        end
    end
    return M.random_from(M.actions[action_name]).description
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
