local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("ApeIntelligence"))

local Keybinds = require("Keybinds")
local Snackbar = require("Snackbar")
local SenorMenu = require("CreateSenorMenu")
local PlayerGui = require("PlayerGui").GetPlayerGui()

local CharacterUtil = require("CharacterUtilities")
local Platform = require("PlatformService")
local TSOLib = require("TSOLibrary")
local MusicPlayer = require("MusicPlayer")

local CharacterHandler = {}
CharacterHandler.__index = CharacterHandler

function CharacterHandler.new(Player)
	local self = setmetatable({}, CharacterHandler)

	self.MusicPlayer = MusicPlayer.new(TSOLib.SoundLib)
	self.MusicPlayer:PlayRandomMusic("Music")

	self.DefaultActionKeys = Keybinds.NewBindGroup(TSOLib.DefaultActionKeys)
	self.DefaultActionKeys:BindAllKeys()

	self.GuiKeys = Keybinds.NewBindGroup(TSOLib.GuiKeys)
	self.SenorMenuOpen = false

	self.Player = Player
	self.Character = CharacterUtil:GetCharacter(Player)
	self.Humanoid = self.Character:WaitForChild("Humanoid")
	self.RootPart = self.Humanoid.RootPart

	self.PlayerGui = PlayerGui
	self.SenorMenu = SenorMenu.new(Player, self.PlayerGui.SenorMenu, self.DefaultActionKeys, self.MusicPlayer.SoundLibrary)
	self.SenorMenu:Deactivate()
	
	self.Player.CharacterAdded:Connect(function(Character)
		self.Character = Character
		self.Humanoid = Character:WaitForChild("Humanoid")
		self.RootPart = self.Humanoid.RootPart
	end)
	
	self.Player.CharacterRemoving:Connect(function()
		self.GuiKeys:UnbindAllKeys()
		self.DefaultActionKeys:UnbindAllKeys()
	end)

	---------------------------------------------------------------------------------
	-- Setting the GuiKeys Map --
	---------------------------------------------------------------------------------

	self.GuiKeys.Map["Menu"].Action = function(ActionName, InputState, InputObject)
		if InputState == Enum.UserInputState.Begin then
			if self.SenorMenuOpen == true then
				self.SenorMenu:Deactivate()
				self.SenorMenuOpen = false
			elseif self.SenorMenuOpen == false then
				self.SenorMenu:Activate()
				self.SenorMenuOpen = true
			end
		end
	end

	self.GuiKeys:BindAllKeys()

	---------------------------------------------------------------------------------
	-- Setting the ActionKeys Map --
	---------------------------------------------------------------------------------

	Snackbar:CreateSnackbar("[System]: Client is currently playing on a "..Platform(), "Dark", 5)

	return self
end

function CharacterHandler:IsAlive()
	if not self.Humanoid then return false end
	return self.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead
end

function CharacterHandler:HasGuiOpen()
	return self.SenorMenuOpen
end

return CharacterHandler