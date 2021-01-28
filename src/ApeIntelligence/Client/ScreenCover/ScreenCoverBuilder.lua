local Builder = {}
Builder.DarkTheme = Color3.fromRGB(20, 20, 20)
Builder.LightTheme = Color3.fromRGB(250, 250, 250)
Builder.ClassName = "ScreenCoverBuilder"

function Builder:CreateFrame(Theme)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, 0, 1, 0)
	Frame.Position = UDim2.new(0, 0, 0, 0)
	Frame.Active = true
	Frame.BackgroundColor3 = Theme == "Light" and Builder.LightTheme or Builder.DarkTheme
	Frame.BorderSizePixel = 0
	Frame.ZIndex = 100
	Frame.Name = "ScreenCover"
	return Frame
end

function Builder:CreateScreenGui()
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "ScreenCover"
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.DisplayOrder = 10
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.ResetOnSpawn = false
	return ScreenGui
end

return Builder