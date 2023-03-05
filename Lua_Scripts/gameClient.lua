getmetatable('').__index = function(str,i) return string.sub(str,i,i) end

local gameClient = {}

gameClient.client = nil

function gameClient.connect(host)
	local socket = require("socket")
	local port = 2222
	print("Connecting to " .. host  .. ":" .. port .. "...")
	gameClient.client = socket.connect(host, port)

	if client == nil then
		print('Error connecting to server at ' .. host .. ':' .. port .. '.')
	end

	gameClient.client:settimeout(-1)
	gameClient.client:setoption("tcp-nodelay", true)
end

function gameClient.close()
	if gameClient.client ~= nil then
		gameClient.client:send("lua close\n")
		gameClient.client:close()
	end
	gameClient.client = nil
end

function gameClient.isConnected()
	return gameClient.client ~= nil
end

function gameClient.sendList(list)
	local send = ""
	local first = true
	for i=1,#list do
		if first then
			first = false
		else
			send = send .. " "
		end
		send = send .. list[i]
	end

	send = send .. "\n"

	gameClient.client:send(send)
end



function receiveLine()
	local line = ""
	local data = nil
	local err = nil
	while data ~= "\n" do
		data,err = gameClient.client:receive(1)
		
		if err ~= nil then
			print("Socket Error: " .. err)
			
			gameClient.close()
			return nil
		end
		
		if data ~= nil and data ~= "\n" then
			line = line .. data
		end
	end
	
	return line
end

function gameClient.receiveController()
	local gC_Controls = {}
	local line = receiveLine()
	for i= 1,#line do
		gC_Controls[i] = tonumber(line[i])
	end
	return gC_Controls
end

return gameClient