--[[
local Map = {
	["Sheathe"] = {
		Key = Enum.KeyCode.X, Priority = Enum.ContextActionPriority.Medium.Value, CreateMobileButton = false, Action = function() 
		-- perform specific action
		-- to change an action, just simply write into the map, then bind all keys
	end};
}

local Ignore = { -- keys you dont want to be able to replace other keys with
	[Enum.KeyCode.M] = true; -- and so on
}

--]]

local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("ApeIntelligence"))
local Signal = require("Signal")

local Keys = {}
Keys.__index = Keys

local function ChangeKeyInMap(self, Name, New)
	if self.Map[Name] then
		self.Map[Name].Key = New
	else
		warn("Didnt change key ", Name, " to ", New)
	end
end

function Keys.new(Map, Ignore)
	assert(type(Map) == "table")

	return setmetatable({
		KeyChange = Signal.new();
		EnterKeyFocus = Signal.new();
		LeaveKeyFocus = Signal.new();
		IsKeyFocused = false;

		Map = Map;
		Forbidden = Ignore;
	}, Keys)
end

function Keys:TrackNewKeyFromName(Name)
	self.EnterKeyFocus:Fire(Name)
	self.IsKeyFocused = true

	local QuickInput
	self:UnbindAllKeys()
	QuickInput = UserInputService.InputEnded:Connect(function(Input)
		if Input.KeyCode == Enum.KeyCode.Escape then
			QuickInput:Disconnect()

			self.KeyChange:Fire(Name, "Cancelled")
			self.LeaveKeyFocus:Fire("Cancelled")
			self.IsKeyFocused = false

			self:BindAllKeys()
		elseif Input.KeyCode ~= Enum.KeyCode.Unknown and not self:ContainsKey(Input.KeyCode) and not self:IsForbidden(Input.KeyCode) then
			QuickInput:Disconnect()
			ChangeKeyInMap(self, Name, Input.KeyCode)

			self.KeyChange:Fire(Name, Input.KeyCode)
			self.LeaveKeyFocus:Fire("Success", Name, Input.KeyCode)
			self.IsKeyFocused = false

			self:BindAllKeys()
		end
	end)
end

function Keys:IsForbidden(Key)
	if self.Forbidden and self.Forbidden[Key] then
		return true
	end
	return false
end

function Keys:ContainsKey(Key)
	for _, Table in pairs(self.Map) do
		if Table.Key == Key then
			return true
		end
	end
	return false
end

function Keys:BindSpecificKey(Name)
	local Map = self.Map

	if Map[Name] then
		local Index = Map[Name]
		ContextActionService:BindActionAtPriority(Name, Index.Action, Index.CreateMobileButton, Index.Priority, Index.Key)
	end
end

function Keys:CreateIgnoreList()
	assert(getmetatable(self) == Keys, ("Cannont invoke method %q, it is an instance method. Please define an instance of Keybinds via .new"):format("CreateIgnoreList"))
	local IgnoreList = {
		[Enum.KeyCode.Escape] = true;
		[Enum.KeyCode.W] = true;
		[Enum.KeyCode.A] = true;
		[Enum.KeyCode.S] = true;
		[Enum.KeyCode.D] = true;
		[Enum.KeyCode.Space] = true;
		[Enum.KeyCode.I] = true;
		[Enum.KeyCode.O] = true;
	}

	for _, Value in pairs(self.Map) do
		IgnoreList[Value.Key] = true
	end

	return IgnoreList
end

function Keys:UnbindKey(Name)
	local Map = self.Map

	if Map[Name] then
		ContextActionService:UnbindAction(Name)
	end
end

function Keys:BindAllKeys()
	self:UnbindAllKeys()
	for Name, Table in pairs(self.Map) do
		ContextActionService:BindActionAtPriority(Name, Table.Action, Table.CreateMobileButton, Table.Priority, Table.Key)
	end
end

function Keys:UnbindAllKeys()
	for Name, _ in pairs(self.Map) do
		self:UnbindKey(Name)
	end
end

function Keys:DisableKeyMap()
	self:UnbindAllKeys()
	-- would use a maid but is not necessary for extra memory
	self.KeyChange:Destroy()
	self.EnterKeyFocus:Destroy()
	self.LeaveKeyFocus:Destroy()
end

-- alias method
Keys.Destroy = Keys.DisableKeyMap

return Keys