local require = require(game:GetService("ReplicatedStorage"):WaitForChild("ApeIntelligence"))
local BuildSlideable = require("BuildSlideableBar")
--local GradientUtility = require("GradientUtility")
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
	self.Maid:GiveTask(self.SliderBarTemplate.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			self.MouseDown = true
		end
	end))

	self.Maid:GiveTask(self.SliderBarTemplate.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			self.MouseDown = false
		end
	end))

	self.Maid:GiveTask(self.SliderBarTemplate.InputChanged:Connect(function(Input)
		if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
			and self.MouseDown then

			local AbsoluteSize = self.SliderBarTemplate.AbsoluteSize
			local AbsolutePosition = self.SliderBarTemplate.AbsolutePosition

			local MouseX = Input.Position.X
			local Difference = (MouseX - AbsolutePosition.X)
			local Percent = math.clamp(Difference/AbsoluteSize.X, 0, 1)

			self.SliderBar.Size = UDim2.new(Percent, 0, 1, 0)
			self.BarValue.Value = 100 * Percent
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