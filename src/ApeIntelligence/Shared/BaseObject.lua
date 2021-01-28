--/* Basic object/class creation */--
--/* Equipped with a maid and Destroy function

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("ApeIntelligence"))
local Maid = require("Maid")

local BaseObject = {}
BaseObject.__index = BaseObject
BaseObject.ClassName = "BaseObject"

function BaseObject.new(obj)
	local self = setmetatable({}, BaseObject)

	self.Maid = Maid.new()
	self.Obj = obj

	return self
end

function BaseObject:Destroy()
	self.Maid:DoCleaning()

	setmetatable(self, nil)
end

return BaseObject