assert(game:GetService("RunService"):IsClient(), "Only Client should access Local PlayerGui")

local PlayerGuiUtil = {}

local Player = game:GetService("Players").LocalPlayer

function PlayerGuiUtil.GetPlayerGui()
	local PlayerGui = Player:WaitForChild("PlayerGui") -- it should return at some point

	return PlayerGui
end

return PlayerGuiUtil