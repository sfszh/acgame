local skynet = require "skynet"
local socket = require "socket"
local string = require "string"
local websocket = require "websocket"
local httpd = require "http.httpd"
local urllib = require "http.url"
local sockethelper = require "http.sockethelper"
local questgen = require "questgen"

local handler = {}
local all_text = ""
function handler.on_open(ws)
    print(string.format("%d::open", ws.id))
end

local function generate_and_pack(is_win)
   local desc, action =  questgen.generate_one_step(is_win)
   print("one step ".. desc .. " " .. action)
   return questgen.motivation .. '\n'..desc..'\n'..action
end

function handler.on_message(ws, message)
    print(string.format("%d receive:%s", ws.id, message))
    -- if message == "map" or message == "finish" then
    local all_text
    if message == "map" then
        questgen.init_onestep();
        all_text = generate_and_pack(true);
    elseif message == "win" then
        all_text = generate_and_pack(true);
    else
        all_text = generate_and_pack(false);
    end
    -- end
    print("send" .. all_text);
    ws:send_text(all_text);
    -- ws:close()
end

function handler.on_close(ws, code, reason)
    print(string.format("%d close:%s  %s", ws.id, code, reason))
end

local function handle_socket(id)
    -- limit request body size to 8192 (you can pass nil to unlimit)
    local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(id), 8192)
    if code then
        
        if url == "/ws" then
            local ws = websocket.new(id, header, handler)
            ws:start()
        end
    end


end
local function file_exists(file)
    local f = io.open(file, "rb")
    if f then
        f:close()
    end
    return f ~= nil
end

local function lines_from(file) 
    if not file_exists(file) then
        return {}
    end
    lines = {}
    for line in io.lines(file) do 
        lines[#lines +1] = line
    end
    return lines
end
skynet.start(function()
    -- local maps = lines_from("etc/maps/map1.json")
    -- for k,v in pairs(maps) do
       -- all_text = all_text .. v
    -- end

    local address = "0.0.0.0:8001"
    skynet.error("Listening "..address)
    local id = assert(socket.listen(address))
    socket.start(id , function(id, addr)
       socket.start(id)
       pcall(handle_socket, id)
    end)
    -- questgen.init_onestep()
    -- questgen.generate_one_step()
    -- repeat
        -- local desc, action = questgen.generate_one_step()
        -- print(desc .. " " .. action)
    -- until(desc == "finished")
    -- output = os.execute('perl /home/vagrant/loc/acgame/server/lualib/gistfile1.pl')
    -- print(output)
end)
