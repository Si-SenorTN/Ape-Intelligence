local TweenService = game:GetService("TweenService")

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("ApeIntelligence"))
local DraggableBar = require("DraggableBar")
local BuildWindow = require("BuildWindow")

local DraggableWindow = {}
DraggableWindow.__index = DraggableWindow
DraggableWindow.ClassName = "DraggableWindow"
DraggableWindow.Info = TweenInfo.new(.4, Enum.EasingStyle.Quad)

local Properties = {
	["Frame"] = {
		BackgroundTransparency = 1;
	};
	["TextLabel"] = {
		BackgroundTransparency = 1; TextTransparency = 1;
		TextStrokeTransparency = 1;
	};
	["TextButton"] = {
		BackgroundTransparency = 1; TextTransparency = 1;
		TextStrokeTransparency = 1;
	};
	["ImageButton"] = {
		BackgroundTransparency = 1; ImageTransparency = 1;
	};
	["ImageLabel"] = {
		BackgroundTransparency = 1; ImageTransparency = 1;
	};
}

function DraggableWindow.SetupCanvas(Player)
	assert(Player:WaitForChild("PlayerGui", 5), string.format("%q is not present", "PlayerGui"))

	local ScreenGui = BuildWindow.CreateScreenGui(true)
	ScreenGui.Name = "MenuPanel"
	ScreenGui.Parent = Player.PlayerGui

	return ScreenGui
end

--- wrapper for draggable menus
-- use .new to create a new one from scratch
function DraggableWindow.new(Parent, Title)
	local Gui = BuildWindow:CreateFullPackage(Title)
	local Bar = Gui:FindFirstChild("Header")
	Gui.Parent = Parent

	return DraggableWindow.CreateExisting(Bar, Gui)
end

-- use .CreateExisting to create one off an existing menu
function DraggableWindow.CreateExisting(Bar, Gui)
	local CloseButton = Gui:FindFirstChild("CloseButton", true)
	assert(CloseButton, string.format("%q is not present", "CloseButton"))

	local self = setmetatable(DraggableBar.new(Bar, Gui), DraggableWindow)
	self.Enabled = false
	self.Animating = false

	self.Contents = {}

	local function HandleDescendant(GuiBase)
		if not typeof(GuiBase) == "Instance" or not GuiBase:IsA("GuiBase") or not Properties[GuiBase.ClassName] then return end

		local Tab = {}

		for PropName, _ in pairs(Properties[GuiBase.ClassName]) do
			if GuiBase[PropName] then
				Tab[PropName] = GuiBase[PropName]
			end
		end

		self.Contents[GuiBase] = {
			[true] = Tab;
			[false] = Properties[GuiBase.ClassName];
		}
	end

	self.Maid:GiveTask(Gui.DescendantAdded:Connect(function(GuiBase)
		HandleDescendant(GuiBase)
	end))

	self.Maid:GiveTask(Gui.DescendantRemoving:Connect(function(GuiBase)
		if typeof(GuiBase) ~= "Instance" or not GuiBase:IsA("GuiBase") or not self.Conents[GuiBase] then return end
		self.Conents[GuiBase] = nil
	end))

	self.Maid:GiveTask(CloseButton.Activated:Connect(function()
		self:Toggle(false)
	end))

	for _, GuiBase in pairs(Gui:GetDescendants()) do
		HandleDescendant(GuiBase)
	end

	self:Toggle(false)
	self.Gui.Visible = false

	return self
end

function DraggableWindow:Toggle(Bool)
	if self.Animating then return end
	self.Animating = true

	if Bool then
		self.Gui.Visible = true
	end

	local LastTween
	for GuiBase, Table in pairs(self.Contents) do
		LastTween = TweenService:Create(GuiBase, self.Info, Table[Bool])
		LastTween:Play()
	end

	LastTween.Completed:Wait()
	self.Enabled = Bool
	self.Gui.Visible = Bool
	self.Animating = false
end

function DraggableWindow:Destroy()
	self.Maid:DoCleaning()
	self.Gui:Destroy()
end

return DraggableWindow