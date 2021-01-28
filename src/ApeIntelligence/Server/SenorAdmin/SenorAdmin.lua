local Players = game:GetService("Players")
local GroupService = game:GetService("GroupService")
local Teams = game:GetService("Teams")

local DataStoreService = game:GetService("DataStoreService")
local BannedStore = DataStoreService:GetDataStore("BannedUserId's")
local Admins = {}
Admins.AcceptedPlayers = {} -- table will contain player instances, do not attempt to pre-write into it
Admins.GroupIds = {}
Admins.UserIds = {[689279674] = true; [90026158] = true; [100785208] = true}

Admins.Unbannable = {[689279674] = true; [19887239] = true; [90026158] = true; [100785208] = true}
Admins.Banned = {}

Admins.Prefix = ":"
Admins.Commands = {
	["team"] = function(_, PlayerToTeam, Team)
		if tonumber(PlayerToTeam) or tonumber(Team) then return end
		if not PlayerToTeam or not Team then return end

		local NewPlayer = FindFromAbb(PlayerToTeam, Players:GetPlayers())
		local NewTeam = FindFromAbb(Team, Teams:GetTeams())
		if not NewTeam or not NewPlayer then return end

		NewPlayer.Team = NewTeam
	end;

	["bring"] = function(Player, Bring)
		if tonumber(Bring) or not Bring then return end
		local AdminChar = Player.Character
		local AdminHum = AdminChar and AdminChar:FindFirstChildOfClass("Humanoid")

		if AdminHum and Bring:lower() == "all" then
			for _, Player in pairs(Players:GetPlayers()) do
				if Player.Character then
					local RootPart = Player.Character:FindFirstChild("HumanoidRootPart")
					if not RootPart then continue end

					RootPart.CFrame = AdminHum.RootPart.CFrame * CFrame.new(math.random(-2, 2), 2, math.random(-2, 2))
				end
			end
		elseif AdminHum then
			local PlayerToBring = FindFromAbb(Bring, Players:GetPlayers())

			if PlayerToBring and PlayerToBring.Character then
				local Char = PlayerToBring.Character
				local Hum = Char:FindFirstChildOfClass("Humanoid")

				if Hum then
					Hum.RootPart.CFrame = AdminHum.RootPart.CFrame
				end
			end
		end
	end;

	["re"] = function(Player, OptionalPlayer)
		if not OptionalPlayer then
			Player:LoadCharacter()
		elseif OptionalPlayer then
			local NewPlayer = FindFromAbb(OptionalPlayer, Players:GetPlayers())
			if NewPlayer then NewPlayer:LoadCharacter() end
		end
	end;

	["heal"] = function(Player, Arg1, Arg2)
		local PlayerToHeal, Amount
		if tonumber(Arg2) then
			PlayerToHeal = FindFromAbb(Arg1, Players:GetPlayers())
			Amount = Arg2
		elseif tonumber(Arg1) then
			PlayerToHeal = Player
			Amount = Arg1
		end

		if not PlayerToHeal then return end
		local Character = PlayerToHeal.Character
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			Humanoid.Health += Amount
		end
	end;

	["damage"] = function(Player, Arg1, Arg2)
		local PlayerToDamage, Amount
		if tonumber(Arg2) then
			PlayerToDamage = FindFromAbb(Arg1, Players:GetPlayers())
			Amount = Arg2
		elseif tonumber(Arg1) then
			PlayerToDamage = Player
			Amount = Arg1
		end

		if not PlayerToDamage then return end
		local Character = PlayerToDamage.Character
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			Humanoid:TakeDamage(Amount)
		end
	end;

	["kick"] = function(Player, PlayerTokick, Reason)
		local Kick = FindFromAbb(PlayerTokick, Players:GetDescendants())

		if Kick then
			Kick:Kick(Reason)
		end
	end;

	["ban"] = function(Player, PlayerToBan, Reason)
		local Kick = FindFromAbb(PlayerToBan, Players:GetDescendants())

		if Kick and not Admins.Unbannable[Kick.UserId] then
			table.insert(Admins.Banned, Kick.UserId)
			Kick:Kick(Reason)
		end
	end;

	["unban"] = function(Player, UserId)
		local Find = table.find(Admins.Banned, UserId)
		if Find then
			table.remove(Admins.Banned, Find)
		elseif Admins.Banned[UserId] then
			Admins.Banned[UserId] = nil
		end
	end;

	["mod"] = function(Player, PlayerToMod)
		local Mod = FindFromAbb(PlayerToMod, Players:GetDescendants())

		if Mod then
			Admins.UserIds[Mod.UserId] = true
			ProcessPlayer(Mod)
			TrackPlayer(Mod)
		end
	end

--[[
	["supersmite"] = function(Player, Smite)
		if tonumber(Smite) then return end

		local PlayerToSmite = FindFromAbb(Smite, Players:GetPlayers()
	end;
]]
}

function FindFromAbb(Arg, Dir)
	if type(Arg) ~= "string" then return end

	local LowerString = string.lower(Arg)
	local len = string.len(Arg)

	for _, Object in pairs(Dir) do
		local LowerName = string.lower(Object.Name)
		local Find = string.sub(LowerName, 1, len) == LowerString

		if Find then
			return Object
		end
	end

	return nil
end

local function ProcessMessage(Player, Message)
	local Index = string.find(Message, Admins.Prefix)
	local Args
	if Index then
		Args = string.split(string.lower(Message), " ")
	end

	if Args and #Args > 0 then
		local Split = string.split(Args[1], Admins.Prefix)
		local Command = Split[2]
		-- a stupid temporary fix bc string.split now wants to add a space at the end of a string
		--[[for Name in pairs(Admins.Commands) do
			if string.match(Command, Name) then
				Admins.Commands[Name](Player, table.unpack(Args, 2))
				return
			end
		end]]

		if Admins.Commands[Command] then
			Admins.Commands[Command](Player, table.unpack(Args, 2))
		end
	end
end

function AssertPlayerCommand(Player)
	if Admins.AcceptedPlayers[Player] then
		return true
	end
	return false
end

function ProcessPlayer(Player)
	local UserId = Player.UserId

	if table.find(Admins.Banned, UserId) or Admins.Banned[UserId] then
		Player:Kick("Banned")
	end

	if Admins.UserIds[UserId] then
		Admins.AcceptedPlayers[Player] = true
		return
	end

	for GroupId, Rank in pairs(Admins.GroupIds) do
		local Success1, IsInGroup = pcall(Player.IsInGroup, Player, GroupId)

		if Success1 and IsInGroup then
			local Success2, RankInGroup = pcall(Player.GetRankInGroup, Player, Rank)

			if Success2 and RankInGroup and RankInGroup >= Rank then
				Admins.AcceptedPlayers[Player] = true
				break
			end
		end
	end
end

function TrackPlayer(Player)
	Player.Chatted:Connect(function(Message)
		if AssertPlayerCommand(Player) then
			ProcessMessage(Player, Message)
		end
	end)
	-- add more events idk
end

function Admins:OnPlayerAdded(Player)
	ProcessPlayer(Player)

	if AssertPlayerCommand(Player) then
		TrackPlayer(Player)
	end
end

function Admins:OnPlayerRemoving(Player)
	if Admins.AcceptedPlayers[Player.UserId] then
		Admins.AcceptedPlayers[Player.UserId] = nil
	end
end

function Admins:AddGroupIdWithRankLock(GroupId, Rank)
	assert(type(GroupId) == "number" and type(Rank) == "number")

	local Success, GroupInfo = pcall(GroupService.GetGroupInfoAsync, GroupService, GroupId)

	if not Success or not GroupInfo then
		warn("Invalid group passed, will not proceed")
		return
	end

	self.GroupIds[GroupId] = Rank
end

function Admins:LoadBannedPlayers()
	local Success, BannedUsers = pcall(BannedStore.GetAsync, BannedStore, "BannedUsers")

	if Success and BannedUsers then
		Admins.Banned = BannedUsers
	elseif not Success then
		warn("Could not load banned user id's: ", BannedUsers)
	end
end

game:BindToClose(function()
	local Success, Error = pcall(BannedStore.SetAsync, BannedStore, "BannedUsers", Admins.Banned)
	if not Success then
		warn(Error)
	end
end)

return Admins