local BuildMenu = {}

local function CreateFrame()
	local Frame = Instance.new("Frame")
	Frame.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
	Frame.BackgroundTransparency = .6
	Frame.BorderSizePixel = 0

	return Frame
end

function BuildMenu.CreateScreenGui(Enabled)
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Enabled = Enabled
	ScreenGui.ResetOnSpawn = false

	return ScreenGui
end

function BuildMenu.CreateBody()
	local Frame = CreateFrame()
	Frame.AnchorPoint = Vector2.new(0, 1)
	Frame.Name = "Body"
	Frame.Position = UDim2.new(0, 0, 1, 0)
	Frame.Size = UDim2.new(1, 0, .9, 0)

	local UIGridLayout = Instance.new("UIGridLayout")
	UIGridLayout.CellPadding = UDim2.new(0, 0, 0, 10)
	UIGridLayout.CellSize = UDim2.new(1, 0, .13, 0)
	UIGridLayout.FillDirection = Enum.FillDirection.Horizontal
	UIGridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	UIGridLayout.Parent = Frame

	local UIPadding = Instance.new("UIPadding")
	UIPadding.PaddingTop = UDim.new(0, 10)
	UIPadding.Parent = Frame

	return Frame
end

function BuildMenu.CreateTopBar(Title)
	local Frame = CreateFrame()
	Frame.Name = "Header"
	Frame.Size = UDim2.new(1, 0, .07, 0)

	local Label = Instance.new("TextLabel")
	Label.BackgroundTransparency = 1
	Label.Size = UDim2.new(1, 0, 1, 0)
	Label.Font = Enum.Font.SourceSansBold
	Label.Text = string.upper(Title)
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.TextScaled = true
	Label.Parent = Frame

	local CloseButton = Instance.new("TextButton")
	CloseButton.AnchorPoint = Vector2.new(.5, .5)
	CloseButton.BackgroundTransparency = 1
	CloseButton.Name = "CloseButton"
	CloseButton.Position = UDim2.new(.95, 0, .5, 0)
	CloseButton.Size = UDim2.new(.1, 0, .8, 0)
	CloseButton.Font = Enum.Font.SourceSansBold
	CloseButton.Text = "X"
	CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	CloseButton.TextScaled = true
	CloseButton.Parent = Frame

	local TextSizeConstraint = Instance.new("UITextSizeConstraint")
	TextSizeConstraint.MaxTextSize = 30
	TextSizeConstraint.Parent = Label

	return Frame
end

function BuildMenu:CreateFullPackage(Title)
	local MenuContainer = CreateFrame()
	MenuContainer.AnchorPoint = Vector2.new(.5, .5)
	MenuContainer.BackgroundTransparency = 1
	MenuContainer.Name = "DraggableMenu"
	MenuContainer.Position = UDim2.new(.5, 0, .5, 0)
	MenuContainer.Size = UDim2.new(.2, 0, .4, 0)

	local Body = self.CreateBody()
	Body.Parent = MenuContainer

	local Header = self.CreateTopBar(Title)
	Header.Parent = MenuContainer

	return MenuContainer
end

return BuildMenu