local TagService = require(ReplicatedStorage.TagService)

local Objectifier = require(script.Parent.Parent.Classes.Objectifier)
	
local ObjectService = {}
--Private Properties

--Public Properties MIGHT WANNA MOVE TO SETTINGS AT SOME POINT BUT NOT NOW
ObjectService.ObjectTag = "Object"
ObjectService.IDAttribute = "ID"
ObjectService.ClassAttribute = "Class"

--Private Methods
local function isA(instance: Instance, classNames: {}): boolean
	for _, className: string in classNames do
		if instance:IsA(className) then
			return true
		end
	end
	return false
end

--Public Methods
function ObjectService:GetInstanceByID(id: string, ancestor: Instance): Instance
	local instances = TagService:GetTaggedOfPredicate(ObjectService.ObjectTag, function(instance)
		return instance:IsDescendantOf(ancestor) and instance:GetAttribute(ObjectService.IDAttribute) == id
	end)
	assert(#instances <= 1, "Multiple instances of ID " .. id .. " under " .. tostring(ancestor))
	return instances[1]
end

function ObjectService:GetInstancesOfClassName(className: string, ancestor: Instance): {instance: Instance}
	return TagService:GetTaggedOfPredicate(ObjectService.ObjectTag, function(instance)
		return instance:IsDescendantOf(ancestor) and instance:GetAttribute(ObjectService.ClassAttribute) == className
	end)
end

function ObjectService:ApplyPropertiesToDescendants(ancestor: Instance, properties: {}, classNames: {className: string}?)
	for _, instance: Instance in ancestor:GetDescendants() do
		if classNames ~= nil and not isA(instance, classNames) then continue end
		for property: string, value: any in properties do
			pcall(function() instance[property] = value end)
		end
	end
end

function ObjectService:FindFirstObjectAncestorOfClassName(className: string, instance: Instance)
	local current = instance
	repeat current = current.Parent until current == nil or current:GetAttribute(ObjectService.ClassAttribute) == className
	return current
end

function ObjectService:CreateObjectifier(className: string, f: (instance: Instance) -> any): any
	return Objectifier.new(className, f)
end

return ObjectService