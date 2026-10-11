--------------------------------------------------------
-- Classes - Closet
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
    A Janitor closet. Stores values that need cleaning up later.
]]
---@class Closet: NoirClass
---@field New fun(self: Closet): Closet
Addon.Classes.Closet = Noir.Class("Closet")

--[[
    Initializes `Closet` class instances.
]]
function Addon.Classes.Closet:Init()
    --[[
        Values to be cleaned up.
    ]]
    self.Values = {}
end

--[[
    Cleans up a value.
]]
---@param value JanitorCapableValue The value to clean up
function Addon.Classes.Closet:_HandleCleanup(value)
    if type(value) == "function" then
        value()
    elseif Noir.IsClass(value) then
        if value:IsA(Noir.Classes.Widget) then
            value:Remove() ---@diagnostic disable-line
        elseif value:IsA(Noir.Classes.Vehicle) then
            value:Despawn() ---@diagnostic disable-line
        elseif value:IsA(Noir.Classes.Body) then
            value:Despawn() ---@diagnostic disable-line
        elseif value:IsA(Noir.Classes.Connection) then
            if value.Connected then
                value:Disconnect() ---@diagnostic disable-line
            end
        elseif value:IsA(Noir.Classes.Task) then
            value:Remove() ---@diagnostic disable-line
        elseif value:IsA(Noir.Classes.Object) then
            value:Despawn() ---@diagnostic disable-line
        end
    else
        error("Closet", ":_HandleCleanup(): Can't cleanup value due to invalid value type: %s", type(value))
    end

    self.Values[value] = nil
end

--[[
    Adds a value to the closet.
]]
---@param value JanitorCapableValue The value to add
function Addon.Classes.Closet:Add(value)
    self.Values[value] = true
end

--[[
    Removes a value from the closet.
]]
---@param value JanitorCapableValue The value to remove
function Addon.Classes.Closet:Remove(value)
    self.Values[value] = nil
end

--[[
    Cleans up all values in the closet.
]]
function Addon.Classes.Closet:Cleanup()
    for value, _ in pairs(self.Values) do
        self:_HandleCleanup(value)
    end
end

--[[
    Represents a value type that a Closet can clean up.
]]
---@alias JanitorCapableValue
---| function
---| NoirWidget
---| NoirVehicle
---| NoirBody
---| NoirConnection
---| NoirTask
---| NoirObject