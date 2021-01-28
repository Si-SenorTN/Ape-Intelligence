--\* used to determine the players current platform *\--
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

return function()
	if UserInputService.KeyboardEnabled then
		return "PC"
	elseif UserInputService.TouchEnabled then
		return "Mobile"
	elseif GuiService:IsTenFootInterface() then
		return "Console"
	else
		warn("Users Choosen platform is unknown")
		return nil
	end
end