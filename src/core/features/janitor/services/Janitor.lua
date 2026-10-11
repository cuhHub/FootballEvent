--------------------------------------------------------
-- Services - Janitor
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
    A service that removes things like widgets when the addon starts.
]]
---@class Janitor: NoirService
Addon.Janitor = Noir.Services:CreateService(
    "Janitor",
    false,
    "A service that removes things like widgets when the addon starts.",
    "A service that removes things like widgets when the addon starts.",
    {"Cuh4"}
)

Addon.Janitor.StartPriority = 0

--[[
    Called when this service is initialized.
]]
function Addon.Janitor:ServiceInit()
    self:EnsuredLoad("Objects", {})
    self:EnsuredLoad("Widgets", {})
    self:EnsuredLoad("Vehicles", {})

    self._StartupCloset = self:CreateCloset()
end

--[[
    Called when this service is started.
]]
function Addon.Janitor:ServiceStart()
    for id, _ in pairs(self:GetSaveData().Objects) do
        local object = Noir.Services.ObjectService:GetObject(id)
        self:GetSaveData().Objects[id] = nil

        if not object then
            goto continue
        end

        self._StartupCloset:Add(object)

        ::continue::
    end

    for id, _ in pairs(self:GetSaveData().Widgets) do
        local widget = Noir.Services.UIService:GetWidget(id)
        self:GetSaveData().Widgets[id] = nil

        if not widget then
            goto continue
        end

        self._StartupCloset:Add(widget)

        ::continue::
    end

    for id, _ in pairs(self:GetSaveData().Vehicles) do
        local vehicle = Noir.Services.VehicleService:GetVehicle(id)
        self:GetSaveData().Vehicles[id] = nil

        if not vehicle then
            goto continue
        end

        self._StartupCloset:Add(vehicle)

        ::continue::
    end

    self._StartupCloset:Cleanup()
end

--[[
    Creates a Closet.
]]
---@return Closet
function Addon.Janitor:CreateCloset()
    return Addon.Classes.Closet:New()
end

--[[
    Marks an object for removal.
]]
---@param object NoirObject The object to remove
function Addon.Janitor:DisposeObject(object)
    self:GetSaveData().Objects[object.ID] = true
end

--[[
    Unmarks an object for removal.
]]
---@param object NoirObject The object to keep
function Addon.Janitor:KeepObject(object)
    self:GetSaveData().Objects[object.ID] = nil
end

--[[
    Marks a vehicle for removal.
]]
---@param vehicle NoirVehicle The vehicle to remove
function Addon.Janitor:DisposeVehicle(vehicle)
    self:GetSaveData().Vehicles[vehicle.ID] = true
end

--[[
    Unmarks a vehicle for removal.
]]
---@param vehicle NoirVehicle The vehicle to keep
function Addon.Janitor:KeepVehicle(vehicle)
    self:GetSaveData().Vehicles[vehicle.ID] = nil
end

--[[
    Marks a widget for removal.
]]
---@param widget NoirWidget The widget to remove
function Addon.Janitor:DisposeWidget(widget)
    self:GetSaveData().Widgets[widget.ID] = true
end

--[[
    Unmarks a widget for removal.
]]
---@param widget NoirWidget The widget to keep
function Addon.Janitor:KeepWidget(widget)
    self:GetSaveData().Widgets[widget.ID] = nil
end