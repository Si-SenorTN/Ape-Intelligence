local UserInputService = game:GetService("UserInputService")

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("ApeIntelligence"))
local BuildSlideable = require("BuildSlideableBar")
local Maid = require("Maid")

--/* Creates a sort of draggable progress bar, a slider */--

local SliderBar = {}
SliderBar.__index = SliderBar
SliderBar.ClassName = "SliderBar"

function SliderBar.new(Parent, BaseValue, Width, Height, Position)
	local self = setmetatable({}, SliderBar)
	
	self.Maid = Maid.new()

	self.SliderBarTemplate = BuildSlideable:CreateSlideableBarTemplate()

	self.SliderBar = self.SliderBarTemplate.SliderBar
	self.BarLabel = self.SliderBarTemplate.BarLabel
	self.MouseDown = false

	self.SliderBarTemplate.Size = UDim2.new(Width, 0, Height, 0)
	self.SliderBarTemplate.Position = Position
	self.SliderBarTemplate.Parent = Parent
	
	self.BarValue = Instance.new("IntValue")
	self.BarValue.Value = BaseValue

	return self
end

function SliderBar:Enable()
	local AbsoluteSize = Vector2.new(self.SliderBarTemplate.AbsoluteSize.X, self.SliderBarTemplate.AbsoluteSize.Y)
	local AbsolutePosition = Vector2.new(self.SliderBarTemplate.AbsolutePosition.X, self.SliderBarTemplate.AbsolutePosition.Y)

	self.Maid:GiveTask(self.SliderBarTemplate.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.MouseDown = true
		end
	end))

	self.Maid:GiveTask(self.SliderBarTemplate.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.MouseDown = false
		end
	end))

	self.Maid:GiveTask(self.SliderBarTemplate.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement and self.MouseDown then
			local MouseX = Input.Position.X
			local XVal = MouseX - AbsolutePosition.X

			self.SliderBar.Size = UDim2.new(0, XVal, 1, 0)
			self.BarValue.Value = 100 * self.SliderBar.Size.X.Offset/AbsoluteSize.X
		end
	end))

	local function OnUpdate()
		local Value = self.BarValue.Value
		self.BarLabel.Text = Value.."%"
	end

	self.Maid:GiveTask(self.BarValue:GetPropertyChangedSignal("Value"):Connect(OnUpdate))
	OnUpdate()

	-- ini
	local Value = self.BarValue.Value/10
	self.SliderBar.Size = UDim2.new(Value, 0, 1, 0)
	self.BarLabel.Text = math.max(10, Value).."%"
end

function SliderBar:Disable()
	self.Maid:DoCleaning()
end

function SliderBar:Destroy()
	self:Disable()
	self.SliderBarTemplate:Destroy()
end

return SliderBar