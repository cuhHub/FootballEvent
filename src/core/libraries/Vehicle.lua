--------------------------------------------------------
-- Libraries - Vehicle
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
    A library for vehicle/body related functions (eg: name formatting)
]]
---@class VehicleLib: NoirLibrary
Addon.Libs.Vehicle = Noir.Libraries:Create(
    "Vehicle",
    "A library for vehicle/body related functions (eg: name formatting)",
    "A library for vehicle/body related functions (eg: name formatting)",
    {"Cuh4"}
)

--[[
    Formats the name of a body.
]]
---@param body NoirBody The body to format
---@return string
function Addon.Libs.Vehicle:FormatBodyName(body)
    local name = body:GetName()

    if not name then
        return ("Body #%d"):format(body.ID)
    end

    return ("%s (Body #%d)"):format(name, body.ID)
end

--[[
    Formats the name of a vehicle.
]]
---@param vehicle NoirVehicle The vehicle to format
---@return string
function Addon.Libs.Vehicle:FormatVehicleName(vehicle)
    local name = vehicle.PrimaryBody and vehicle.PrimaryBody:GetName() or nil

    if not name then
        return ("Vehicle #%d"):format(vehicle.ID)
    end

    return ("%s (Vehicle #%d)"):format(name, vehicle.ID)
end

--[[
    Returns if a seat is occupied.
]]
---@param seat SWVehicleSeatData The seat to check
---@return boolean
function Addon.Libs.Vehicle:IsSeatOccupied(seat)
    if seat.seated_id == -1 then
        return false
    end

    if seat.seated_id == 4294967295 then
        return false
    end

    return true
end