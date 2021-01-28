local ServerStorage = game:GetService("ServerStorage")
local RankOverheadTemplate = ServerStorage.ServerAssets.RankOverhead

local RoleInGroupString = "<%s>"

local RankOverhead = {}
RankOverhead.GroupId = nil
RankOverhead.MainGroupTeam = nil

local function ConvertColor3ToRGB(r, g, b)
	return Color3.fromRGB(r * 255, g * 255, b * 255)
end

function RankOverhead:OnCharacterAdded(Player, Character)
	if Character:FindFirstChild("RankOverhead") then
		return
	end

	local TeamColor, TeamName = Player.Team.TeamColor.Color, Player.Team.Name
	local IsInGroup, RoleInGroup = Player:IsInGroup(self.GroupId), Player:GetRoleInGroup(self.GroupId)

	local NewTeamColor = ConvertColor3ToRGB(TeamColor.r, TeamColor.g, TeamColor.b)
	local NewRankOverhead = RankOverheadTemplate:Clone()
	NewRankOverhead.PlayerName.Text = string.upper(Player.Name)
	NewRankOverhead.PlayerName.TextColor3 = NewTeamColor
	NewRankOverhead.PlayerRole.TextColor3 = NewTeamColor
	NewRankOverhead.PlayerRole.Text = IsInGroup and string.format(RoleInGroupString, string.upper(RoleInGroup))
		or string.format(RoleInGroupString, string.upper(TeamName))

	NewRankOverhead.Adornee = Character:WaitForChild("HumanoidRootPart")
	NewRankOverhead.Parent = Character
end

function RankOverhead:OnTeamChange(Player, Character)
	local RankOverhead = Character and Character:FindFirstChild("RankOverhead")
	if not RankOverhead then return end

	local IsAssociatedWithMainGroup = self.MainGroupTeam == Player.Team

	local TeamColor, TeamName = Player.Team.TeamColor.Color, Player.Team.Name
	local NewTeamColor = ConvertColor3ToRGB(TeamColor.r, TeamColor.g, TeamColor.b)
	local IsInGroup, RoleInGroup = false, TeamName

	if IsAssociatedWithMainGroup then
		IsInGroup, RoleInGroup = Player:IsInGroup(self.GroupId), Player:GetRoleInGroup(self.GroupId)
	end

	RankOverhead.PlayerName.Text = string.upper(Player.Name)
	RankOverhead.PlayerName.TextColor3 = NewTeamColor
	RankOverhead.PlayerRole.TextColor3 = NewTeamColor
	RankOverhead.PlayerRole.Text = string.format(RoleInGroupString, string.upper(RoleInGroup))
end

function RankOverhead:SetGroupId(GroupId)
	self.GroupId = GroupId
end

function RankOverhead:AssociateGroupWithTeam(Team)
	assert(Team:IsA("Team"))
	self.MainGroupTeam = Team
end

return RankOverhead