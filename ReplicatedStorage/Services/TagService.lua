local CollectionService = game:GetService("CollectionService")

local extender = require(script.Parent.Parent.Modules.extender)
local table = require(script.Parent.Parent.Libraries.table)
local Signal = require(script.Parent.Parent.Classes.Signal)

local TagService = {}
extender(TagService, CollectionService)

function TagService:FindFirstAncestorOfTag(instance: Instance, tag: string)
	local current = instance
	repeat current = current.Parent until current == nil or current:HasTag(tag)
	return current
end

function TagService:GetTaggedOfPredicate(tag: string, f: (instance: Instance) -> boolean)
	return table.filter(CollectionService:GetTagged(tag), f)
end

function TagService:GetTaggedOfAncestor(ancestor: Instance, tag: string)
	return TagService:GetTaggedOfPredicate(tag, function(instance: Instance)
		return instance:IsDescendantOf(ancestor)
	end)
end

return TagService