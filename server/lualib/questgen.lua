local M= {}


M.actions = {
  ['goto'] ={ 
    {
      description = 'Just wander around and look',
      sequence = {'>explore'}
    }
  },
  ['learn'] ={
    {
      description = 'Go someplcae, get something, and read what is written on it',
      sequence = {'goto', 'get', '>read'}
    }
  },
  ['get'] = {
    {
      description = 'steal it from somebody',
      sequence = {'steal'}
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
      description = 'Go someplace and kill somebody',
      sequence = {'goto', '>kill'}
    }
  }
}

M.motivations = {
  ['knowledge'] = {
    description = 'Deliver item for study',
    sequence = {'get', 'goto', '>give'}
  }
}

M.actions_index = {'goto', 'learn', 'get', 'steal', 'spy', 'capture', 'kill'}

local function random_action()

  local index = math.random(1, #M.actions_index)
  return M.actions[M.actions_index[index]]
end

M.generated_steps = {}
M.depth = 0
function M.generatequest(depth)
  local motivation = M.random_from(M.motivations)
  print("Generating a Quest for "..motivation.description .. ":" .. M.sequence_to_str(motivation.sequence))
  M.generate_step(motivation.sequence)
  for _, step in pairs(M.generated_steps) do
    print(step)
  end
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
    if string.match(action, '>.-$') == nil then
      local step = M.random_from( M.actions[action])
      M.generated_steps[#M.generated_steps + 1] = M.padding_by(M.depth)..step.description .. ":" .. M.sequence_to_str(step.sequence)
      M.depth = M.depth + 1
      M.generate_step(step.sequence)
    else 
      M.depth = M.depth - 1
      M.generated_steps[#M.generated_steps + 1] = M.padding_by(M.depth).. action
      return
      -- print(action)
    end
  end
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
