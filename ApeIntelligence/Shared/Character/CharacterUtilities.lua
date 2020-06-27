local CharUtil = {}

function CharUtil:GetCharacter(Player)
	return Player.Character or Player.CharacterAdded:Wait()
end

function CharUtil:GetHumanoid(Player)
	local Char = self:GetCharacter(Player)
	return Char:WaitForChild("Humanoid", 10)
end

function CharUtil:GetRootPart(Player)
	local Hum = self:GetHumanoid(Player)
	return Hum.RootPart
end

return CharUtil