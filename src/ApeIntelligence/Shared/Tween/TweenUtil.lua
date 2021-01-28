--!strict
local RunService = game:GetService("RunService")

local TweenUtil = {}
local PlayingTweens = {}

type InstanceWithTransparency = {
	Transparency: number
}

type NumberSequenceTrnasparency = {
	Transparency: NumberSequence
}

type InstanceWithColorSequence = {
	Color: ColorSequence
}

local function GetPropertyTween(Inst, Property): RBXScriptConnection?
	if PlayingTweens[Inst] then
		local Index = PlayingTweens[Inst]
		if Index[Property] then
			return Index[Property]
		end
	end
	return nil
end

function TweenUtil.NumberSequenceTransparency(Inst: NumberSequenceTrnasparency, Amount: number)
	local ExistingPropertyTween = GetPropertyTween(Inst, "Transparency")
	if ExistingPropertyTween then
		ExistingPropertyTween:Disconnect()
	end
	local LogicConnection: RBXScriptSignal = RunService:IsClient() and RunService.RenderStepped or RunService.Heartbeat

	local Time = 0
	local Start = Inst.Transparency.Keypoints[1].Value
	local Accumulated = Inst.Transparency.Keypoints[1].Value

	if Start == Amount then
		return
	end

	local PropertyTween
	PropertyTween = LogicConnection:Connect(function(Delta)
		if Time >= 1 then
			PropertyTween:Disconnect()
		end

		Time += Delta
		if Start > 0 then
			Accumulated -= Delta
		else
			Accumulated += Delta
		end
		Inst.Transparency = NumberSequence.new(Accumulated)
	end)

	PlayingTweens[Inst] = {
		["Transparency"] = PropertyTween;
	}
	
	return PropertyTween
end

return TweenUtil