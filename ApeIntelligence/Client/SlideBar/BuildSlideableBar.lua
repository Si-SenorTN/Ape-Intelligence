local BuildSlideableBar = {}
BuildSlideableBar.ClassName = "SlideableBarBuilder"

function BuildSlideableBar:CreateBar()
	local Frame = Instance.new("Frame")
	Frame.AnchorPoint = Vector2.new(0, 0)
	Frame.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
	Frame.BorderSizePixel = 0
	Frame.Size = UDim2.new(.5, 0, 1, 0)
	Frame.Position = UDim2.new(0, 0, 0, 0)
	Frame.Name = "SliderBar"
	
	return Frame
end

function BuildSlideableBar:CreateSlideableBarTemplate()
	local Frame = Instance.new("Frame")
	Frame.AnchorPoint = Vector2.new(0, .5)
	Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	Frame.BorderSizePixel = 0
	Frame.Name = "Background"

	local Bar = self:CreateBar()
	Bar.Parent = Frame
	
	local TextLabel = Instance.new("TextLabel")
	TextLabel.AnchorPoint = Vector2.new(0, 0)
	TextLabel.BackgroundTransparency = 1
	TextLabel.Size = UDim2.new(1, 0, 1, 0)
	TextLabel.TextScaled = true
	TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel.Font = Enum.Font.SourceSansBold
	TextLabel.Text = "0%"
	TextLabel.Name = "BarLabel"
	TextLabel.Parent = Frame
	
	local TextSizeConstraint = Instance.new("UITextSizeConstraint")
	TextSizeConstraint.MaxTextSize = 30
	TextSizeConstraint.Parent = TextLabel

	return Frame
end

return BuildSlideableBar