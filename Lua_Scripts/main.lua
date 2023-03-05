-- Getting Graphics from Screen
BoxRadius = 6
InputSize = (BoxRadius * 2 + 1) * (BoxRadius * 2 + 1)
Inputs = InputSize + 1

ButtonNames = {"A", "B", "Up", "Down", "Left", "Right"}
controller = {}
saveStateFile = "Level1.State" 

client.pause()

local g_client = nil

g_client = require("gameClient")


console.clear()

function initialize()
    savestate.load(saveStateFile)
    lastFit = 27
    rightmost = 0
    currentFrame = 0
    TimeoutConstant=20
    timeout = TimeoutConstant
    reward = 0
    frame_gap = 5
end

--Input Functions
function getPosition()
    marioScreenX = memory.readbyte(0x0086)
    screenEdgeX = memory.readbyte(0x071C)
    marioX = memory.readbyte(0x006D) * 0x100 + memory.readbyte(0x0086)
    marioY = memory.readbyte(0x03B8) + 16
end
function getSprites()
    local sprites = {}
    for slot = 0, 4 do
        local enemy = memory.readbyte(0xF + slot)
        if enemy ~= 0 then
            local ex = memory.readbyte(0x6E + slot) * 0x100 + memory.readbyte(0x87 + slot)
            local ey = memory.readbyte(0xCF + slot) + 24
            sprites[#sprites + 1] = {
                ["x"] = ex,
                ["y"] = ey
            }
        end
    end

    return sprites
end
function getTile(dx, dy)
    local x = marioX + dx + 8
    local y = marioY + dy - 16
    local page = math.floor(x / 256) % 2

    local subx = math.floor((x % 256) / 16)
    local suby = math.floor((y - 32) / 16)
    local addr = 0x500 + page * 13 * 16 + suby * 16 + subx

    if suby >= 13 or suby < 0 then
        return 0
    end

    if memory.readbyte(addr) >= 0x0010 and memory.readbyte(addr) <= 0x0021 then
        return 0.6 --Pipe Tile
    end

    if memory.readbyte(addr) >= 0x00C0 and memory.readbyte(addr) <= 0x00C1 then
        return 0.4 --Lucky Block
    end

    if memory.readbyte(addr) == 0x00C2 then
        return 0.2 --Coin
    end

    if memory.readbyte(addr) >= 0x0024 and memory.readbyte(addr) <= 0x0025 then
        return 0.8 --Flag Tile
    end

    if memory.readbyte(addr) ~= 0 then
        return 1 --Other Collision
    else
        return 0
    end
end
function getInputs()
    local inputs = {}
    
    getPosition()
    sprites = getSprites()

    for dy = -BoxRadius*16, BoxRadius*16, 16 do
        for dx = -BoxRadius*16, BoxRadius*16, 16 do
            inputs[#inputs + 1] = 0

            tile = getTile(dx, dy)

            if tile == 1 and marioY + dy < 0x1B0 then
                inputs[#inputs] = 1
            else 
                inputs[#inputs] = tile
            end
            
            for i = 1, #sprites do
                distx = math.abs(sprites[i]["x"] - (marioX + dx))
                disty = math.abs(sprites[i]["y"] - (marioY + dy))
                if distx <= 8 and disty <= 8 then
                    inputs[#inputs] = -1
                end
            end

            

        end
    end
    return inputs
end

function getScore()
 
end



--Joypad Functions
function getController()
	local buttons = {}
	local state = joypad.get(1)
	
	for b=1,#ButtonNames do
		button = ButtonNames[b] 
		if state[button] then
			buttons[b] = 1
		else
			buttons[b] = 0
		end
	end	
	
	return buttons
end

function clearJoypad()
    controller = {}
    for b = 1, #ButtonNames do
        controller["P1 " .. ButtonNames[b]] = false
    end
    joypad.set(controller)
end

function setController(controls)
    controller = {}
    for b = 1, #ButtonNames do
        controller["P1 " .. ButtonNames[b]] = math.floor((controls[b]+0.5))==1
    end
    for input = 1,#controls do
    end
    joypad.set(controller)

end


--Connection Functions
function connect()
    -- local hostnameFile, err = io.open('hostname.txt', 'w')
	-- hostnameFile:write(forms.gettext(hostnameBox))
	-- hostnameFile:close()

	if g_client.isConnected() then
		forms.settext(connectButton, "Connect Start")
		g_client.close()
	else
		
		g_client.connect(forms.gettext(hostnameBox))

		if g_client.isConnected() then
			print("Connected.")
            forms.settext(connectButton, "Disconnect")
		else
			print("Unable to connect.")
		end

        controls = g_client.receiveController()
	end
end


initialize()
clearJoypad()


--Forms
form = forms.newform(295, 335, "Settings")
hostnameBox = forms.textbox(form, "LAPTOP-F79I9PRS", 100, 20, "TEXT", 60, 70)
forms.label(form, "Hostname:", 3, 73)
connectButton = forms.button(form, "Connect", connect, 3, 100, 70, 20)



while(true) do
    
   
        if(g_client.isConnected()) then

            --Send
            screen = getInputs()
            g_client.sendList(screen)

            --Receive
            controls = g_client.receiveController()
            

            ----Do Stuff
            --Check Death
            
            if marioX > rightmost then
                rightmost = marioX
                timeout = TimeoutConstant
            end
            timeout = timeout-1
            local timeoutBonus = currentFrame / 4
            if currentFrame%frame_gap == 0 then
                local fitness = math.floor(rightmost - (currentFrame) / 2 - (timeout + timeoutBonus) * 2 / 3)
                reward = fitness - lastFit
                lastFit = fitness
            end
            if timeout + timeoutBonus <=0 then
                initialize()
            end
            

            setController(controls)

        end
    
    emu.frameadvance()
    currentFrame = currentFrame+1

end