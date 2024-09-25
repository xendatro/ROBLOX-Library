local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TagService = require(ReplicatedStorage.TagService)

local ObjectSettings = require(ReplicatedStorage.ObjectSettings)

--[[Objectifier]]
local Objectifier = {}
Objectifier.__index = Objectifier

--Private Methods
local function apply(self: typeof(Objectifier.new()), instance: Instance)	
	self.Objects[instance] = self.ApplyFunction(instance)
end

local function unapply(self: typeof(Objectifier.new()), instance: Instance)
	self.UnapplyFunction(instance, self.Objects[instance])
	self.Objects[instance] = nil
end

local function isClass(instance, className)
	return instance:GetAttribute(ObjectSettings.ClassAttribute) == className
end

local function setUpConnections(self: typeof(Objectifier.new()))
	self.Connections = {}
	self.InstanceAdded = TagService:GetInstanceAddedSignal(ObjectSettings.ObjectTag):Connect(function(instance: Instance)
		if not isClass(instance, self.ClassName) then return end
		apply(self, instance)
	end)
	self.InstanceRemoved = TagService:GetInstanceRemovedSignal(ObjectSettings.ObjectTag):Connect(function(instance: Instance)
		if not isClass(instance, self.ClassName) then return end
		unapply(self, instance)
	end)
end

local function initialize(self)
	for _, instance in TagService:GetTagged(ObjectSettings.ObjectTag) do
		if not isClass(instance, self.ClassName) then continue end
		apply(self, instance)
	end
end

function Objectifier.new(className: string, applyFunction: (instance: Instance) -> any, unapplyFunction: (instance: Instance, applyResult: any))
	local self = setmetatable({}, Objectifier)

	self.Objects = {}
	self.ClassName = className
	self.ApplyFunction = applyFunction
	self.UnapplyFunction = unapplyFunction

	setUpConnections(self)
	initialize(self)

	return self
end

function Objectifier:Get(instance: Instance)
	return self.Objects[instance]
end


return Objectifier