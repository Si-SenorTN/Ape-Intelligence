--[[
local Map = {
	["Sheathe"] = {
		Key = Enum.KeyCode.X, Priority = Enum.ContextActionPriority.Medium.Value, CreateMobileButton = false, Action = function() 
		-- perform specific action
	end};
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

function Keys.NewBindGroup(Map)
	assert(typeof(Map) == "table")

	return setmetatable({
		KeyChange = Signal.new();
		Map = Map;
	}, Keys)
end

function Keys:TrackNewKeyFromName(Name)
	local QuickInput
	self:UnbindAllKeys()
	QuickInput = UserInputService.InputEnded:Connect(function(Input)
		if Input.KeyCode == Enum.KeyCode.Escape then
			QuickInput:Disconnect()
			self.KeyChange:Fire(Name, "Cancelled")
		elseif Input.KeyCode ~= Enum.KeyCode.Unknown and not table.find(self.Map[Name], Input.KeyCode) then
			QuickInput:Disconnect()
			ChangeKeyInMap(self, Name, Input.KeyCode)

			self.KeyChange:Fire(Name, Input.KeyCode)
			self:BindAllKeys()
		end
	end)
end

function Keys:BindSpecificKey(Name)
	local Map = self.Map

	if Map[Name] then
		local Index = Map[Name]
		ContextActionService:BindActionAtPriority(Name, Index.Action, Index.CreateMobileButton, Index.Priority, Index.Key)
	end
end

function Keys:UnbindKey(Name)
	local Map = self.Map

	if Map[Name] then
		ContextActionService:UnbindAction(Name)
	end
end

function Keys:BindAllKeys()
	for Name, Table in pairs(self.Map) do
		ContextActionService:BindActionAtPriority(Name, Table.Action, Table.CreateMobileButton, Table.Priority, Table.Key)
	end
end

function Keys:UnbindAllKeys()
	for Name, Table in pairs(self.Map) do
		ContextActionService:UnbindAction(Name)
	end
end

function Keys:DisableKeyMap()
	self:UnbindAllKeys()
	self.KeyChange:Destroy()
end

return Keys