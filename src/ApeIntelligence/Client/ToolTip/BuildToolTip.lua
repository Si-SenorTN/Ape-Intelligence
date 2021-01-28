local function CreateTextLabel()
	local TextLabel = Instance.new("TextLabel")
	TextLabel.BackgroundTransparency = 1
	TextLabel.Font = Enum.Font.Oswald
	TextLabel.TextColor3 = Color3.new(1, 1, 1)
	TextLabel.TextStrokeTransparency = .5
	TextLabel.ZIndex = 101
	TextLabel.TextScaled = true

	return TextLabel
end

return function()
	local Frame = Instance.new("Frame")
	Frame.AnchorPoint = Vector2.new(.5, .5)
	Frame.BackgroundTransparency = .3
	Frame.Size = UDim2.new(.1, 0, .05, 0)
	Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	Frame.BorderSizePixel = 0
	Frame.ZIndex = 100
	Frame.Name = "ToolTip"
	
	local Body = CreateTextLabel()
	Body.AnchorPoint = Vector2.new(0, 1)
	Body.Position = UDim2.fromScale(0, 1)
	Body.Size = UDim2.new(1, 0, .6, 0)
	Body.Name = "Body"
	Body.Parent = Frame
	
	local Title = CreateTextLabel()
	Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	Title.BackgroundTransparency = 0
	Title.BorderSizePixel = 0
	Title.TextXAlignment = Enum.TextXAlignment.Center
	Title.Size = UDim2.new(1, 0, .4, 0)
	Title.Name = "Title"
	Title.Parent = Frame
	
	local UITextSizeConstraint1 = Instance.new("UITextSizeConstraint")
	UITextSizeConstraint1.MaxTextSize = 25
	UITextSizeConstraint1.Parent = Body
	
	return Frame
end