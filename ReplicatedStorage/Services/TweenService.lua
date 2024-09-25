local _TweenService = game:GetService("TweenService")

local extender = require(script.Parent.Parent.Modules.extender)

local DataTypes = {
    number = "NumberValue",
    CFrame = "CFrameValue"
}

local TweenService = {}

function TweenService:CreateMethodTween(instance: Instance, tweenInfo: TweenInfo, methodName: string, initial: number | CFrame, final: number | CFrame): Tween
    local success, value: ValueBase = pcall(function()
        return Instance.new(DataTypes[typeof(final)])
    end)
    assert(success, "Data type " .. typeof(final) .. " is not supported in this function.")
    value.Value = initial
    local tween = _TweenService:Create(
        value,
        tweenInfo,
        {
            Value = final
        }
    )
    local changed = value:GetPropertyChangedSignal("Value"):Connect(function()
        instance[methodName](instance, value.Value)
    end)
    tween.Destroying:Once(function()
        changed:Disconnect()
        changed = nil
    end)
    return tween
end

extender(TweenService, _TweenService)

local module: typeof(_TweenService) & typeof(TweenService) = TweenService
return module