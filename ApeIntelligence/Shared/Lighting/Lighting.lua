local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

if RunService:IsClient() then
	local ClientLighting = {}
	ClientLighting.__index = ClientLighting
	ClientLighting.ClassName = "ClientLighting"

	local function TryOrCreate(Class)
		local Object = Lighting:FindFirstChildOfClass(Class)
		if not Object then
			Object = Instance.new(Class)
			Object.Parent = Lighting
		end
		return Object
	end

	local TweenService = game:GetService("TweenService")

	ClientLighting.BlurEffect = TryOrCreate("BlurEffect")
	ClientLighting.BlurEffect.Size = 2

	ClientLighting.DepthOfFieldEffect = TryOrCreate("DepthOfFieldEffect")
	ClientLighting.DepthOfFieldEffect.Enabled = false

	function ClientLighting:BlurScreen(Amount, Info, Yield)
		assert(typeof(Amount) == "number" and Amount >= 0, "Amount must a number greater than or equal to 0")
		assert(typeof(Info) == "TweenInfo", "Info parameter must be a TweenInfo", 2)

		local BlurTween = TweenService:Create(self.BlurEffect, Info, {Size = Amount})
		BlurTween:Play()
		if Yield == true then
			BlurTween.Completed:Wait()
		end
	end

	function ClientLighting:TweenDepthOfField(Far, FocusDist, InFocusRad, NearInt, Yield)
		self:ToggleDepthOfField(true)

		local Properties = {FarIntensity = Far or 1, FocusDistance = FocusDist or 10, InFocusRadius = InFocusRad or 10, NearIntensity = NearInt or 1}
		local TweenBase = TweenService:Create(self.DepthOfFieldEffect, TweenInfo.new(.3, Enum.EasingStyle.Quad), Properties)
		TweenBase:Play()
		if Yield then
			TweenBase.Completed:Wait()
		end
	end

	function ClientLighting:ToggleDepthOfField(Boolean)
		self.DepthOfFieldEffect.Enabled = Boolean
	end

	return ClientLighting
elseif RunService:IsServer() then
	local ServerLighting = {}
	ServerLighting.__index = ServerLighting
	ServerLighting.ClassName = "ServerLighting"
	warn("Server lighting is currently empty")

	return ServerLighting
else
	error("[Lighting] unkown run state", 2)
end
