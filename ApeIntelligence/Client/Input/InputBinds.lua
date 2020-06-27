-- Credit goes out to EgoMoose for this very convenient module
-- in the very slightest modified

local UIS = game:GetService("UserInputService");

local uisBinds = {}
uisBinds.__index = uisBinds

function uisBinds.new()
	local self = {}
	
	self.connections = {}
	
	return setmetatable(self, uisBinds)
end

function uisBinds:BindToInput(actionName, func, ...)
	local binds = {...}
	self.connections[actionName] = {}
	for i = 1, #binds do
		local keycode = binds[i]
		self.connections[actionName][keycode] = {
			UIS.InputBegan:Connect(function(input, process)
				if (input.KeyCode == keycode or input.UserInputType == keycode) then
					func(actionName, input.UserInputState, input)
				end
			end),
			
			UIS.InputChanged:Connect(function(input, process)
				if (input.KeyCode == keycode or input.UserInputType == keycode) then
					func(actionName, input.UserInputState, input)
				end
			end),
			
			UIS.InputEnded:Connect(function(input, process)
				if (input.KeyCode == keycode or input.UserInputType == keycode) then
					func(actionName, input.UserInputState, input)
				end
			end)
		}
	end
end

function uisBinds:UnbindAction(actionName)
	for keycode, array in pairs(self.connections[actionName]) do
		for i = 1, #array do
			array[i]:Disconnect()
		end
	end
	self.connections[actionName] = nil
end

return uisBinds.new()