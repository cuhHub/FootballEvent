--------------------------------------------------------
-- Classes - Effect
--------------------------------------------------------

--[[
    Copyright (C) 2026 cuhHub

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A base class for effects.
]]
---@class Effect: NoirClass
---@field New fun(self: Effect, name: string, position: SWMatrix): Effect
Addon.Classes.Effect = Noir.Class("Effect")

--[[
    Initializes `Effect` class instances.
]]
---@param name string The name of the effect
---@param position SWMatrix The position of the effect
function Addon.Classes.Effect:Init(name, position)
    --[[
        The name of the effect.
    ]]
    self.Name = name

    --[[
        The position of the effect.
    ]]
    self.Position = position

    --[[
        Whether or not the event has started.
    ]]
    self.Started = false

    --[[
        Cleanup closet.
    ]]
    self.Closet = Addon.Janitor:CreateCloset()

    --[[
        Fired upon starting.
    ]]
    self.OnStartEvent = Noir.Libraries.Events:Create()

    --[[
        Fired upon completion.
    ]]
    self.OnCompleteEvent = Noir.Libraries.Events:Create()
end

--[[
    Returns if the effect has started or not.
]]
---@return boolean
function Addon.Classes.Effect:HasStarted()
    return self.Started
end

--[[
    Retursn the position of the effect.
]]
---@return SWMatrix
function Addon.Classes.Effect:GetPosition()
    return self.Position
end

--[[
    Performs cleanup.
]]
function Addon.Classes.Effect:_Cleanup()
    self.Closet:Cleanup()
end

--[[
    Starts the effect.
]]
function Addon.Classes.Effect:Start()
    if self:HasStarted() then
        error("Addon.Classes.Effect:Start()", "Effect has already started.")
    end

    self.Started = true
    self:OnStart()
    self.OnStartEvent:Fire()

    Addon.Logger:Info("Effect: Started effect %s", self.Name)
end

--[[
    Called upon the effect starting.
    *abstractmethod*
]]
function Addon.Classes.Effect:OnStart()
    error("Addon.Classes.Effect:OnStart()", "Effect is not implemented.")
end

--[[
    Completes the effect.
]]
function Addon.Classes.Effect:Complete()
    if not self:HasStarted() then
        error("Addon.Classes.Effect:Complete()", "Effect has not started.")
    end

    self.Started = false
    self:OnComplete()
    self:_Cleanup()
    self.OnCompleteEvent:Fire()

    Addon.Logger:Info("Effect: Completed effect %s", self.Name)
end

--[[
    Called upon effect completion.
    *abstractmethod*
]]
function Addon.Classes.Effect:OnComplete()
    error("Addon.Classes.Effect:OnComplete()", "Effect is not implemented.")
end