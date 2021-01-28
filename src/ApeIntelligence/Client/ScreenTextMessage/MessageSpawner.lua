-- like a full screen snackbar except u control customization
local TweenService = game:GetService("TweenService")

local MessageSpawner = {}
MessageSpawner.__index = MessageSpawner
MessageSpawner.ClassName = "MessageSpawner"
MessageSpawner.TweenInfo = TweenInfo.new(.2, Enum.EasingStyle.Linear)

local function CreateScreenGui()
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Enabled = false
	ScreenGui.Name = "MessageSpanwer"
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.DisplayOrder = 10
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.ResetOnSpawn = false
	return ScreenGui
end

local function SetProperties(Instance, Properties)
	for Property, Value in pairs(Properties) do
		if Instance[Property] then
			Instance[Property] = Value
		end
	end
end

function MessageSpawner.new(Gui, Properties)
	if Gui then
		assert(Gui:IsA("GuiBase"))
	else
		Gui = CreateScreenGui()
	end
	assert(type(Properties) == "table")

	local self = setmetatable({}, MessageSpawner)

	self.Gui = Gui
	self.TextLabel = Instance.new("TextLabel")
	SetProperties(self.TextLabel, Properties)

	self.TextLabel.Parent = self.Gui
	if Properties["TextScaled"] then
		self.TextLabel.TextScaled = true -- weird bug where text scale resets after reparenting
	end

	self.ShowText = TweenService:Create(self.TextLabel, self.TweenInfo, {TextTransparency = 0})
	self.HideText = TweenService:Create(self.TextLabel, self.TweenInfo, {TextTransparency = 1})

	self.TweenCompleted = self.HideText.Completed:Connect(function()
		self.TextLabel.Visible = false
	end)

	return self
end

function MessageSpawner:ChangeProperties(Properties)
	assert(type(Properties) == "table")
	SetProperties(self.TextLabel, Properties)
end

function MessageSpawner:SendMessage(Text)
	self.TextLabel.Text = Text
	self.TextLabel.Visible = true
	self.ShowText:Play()
end

function MessageSpawner:Hide()
	self.HideText:Play()
end

function MessageSpawner:Destroy()
	self.Gui:Destroy()
	self.TweenCompleted:Disconnect()
end

return MessageSpawner