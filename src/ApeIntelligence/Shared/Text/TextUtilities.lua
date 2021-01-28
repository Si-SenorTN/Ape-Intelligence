--!nonstrict
local RunService = game:GetService("RunService")

local TextUtilities = {}

function TextUtilities:TypeWrite(TextLabel: TextLabel, Text: string): ()
	local UniText = "a\u{2022}b\u{2022}c\u{2022}d"
	local Length = utf8.len(UniText)
	local ToTake = Length/30
	local Accumulated = 0
	local UPos = 1
	local UChar = 0
	while Accumulated < ToTake do
		Accumulated += RunService.Heartbeat:Wait()
		local Char = math.min(math.floor((Accumulated/ToTake) * Length), Length)
		if Char ~= UChar then
			UPos = utf8.offset(Text,Char-UChar+1,UPos)
			TextLabel.Text = string.sub(Text,1,UPos-1)
			UChar = Char
		end
	end
end

return TextUtilities