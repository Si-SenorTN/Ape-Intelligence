local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = require(ReplicatedStorage.ApeIntelligence)
local Snackbar = require("Snackbar")

local ClientSnackbarEvent = Instance.new("BindableEvent")
ClientSnackbarEvent.Name = "ClientSnackbarEvent"
ClientSnackbarEvent.Parent = ReplicatedStorage:WaitForChild("Events", 2) or ReplicatedStorage -- change this to fill needs

local ServerSnackbarEvent = ClientSnackbarEvent.Parent:FindFirstChild("ServerSnackbarEvent")

local function CreateSnackbar(Message, Theme, Timeout, TextStyle)
	assert(type(Message) == "string" and type(Theme) == "string")
	assert(type(Timeout) == "number")

	Snackbar:CreateSnackbar(Message, Theme, Timeout, TextStyle)
end

ClientSnackbarEvent.Event:Connect(CreateSnackbar)
if ServerSnackbarEvent then ServerSnackbarEvent.OnClientEvent:Connect(CreateSnackbar) end

return ClientSnackbarEvent