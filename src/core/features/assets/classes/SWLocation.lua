--------------------------------------------------------
-- Classes - SWLocation
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
    A class representing a Stormworks location, but with more information.
]]
---@class SWLocation: NoirClass
---@field New fun(self: SWLocation, location: SWLocationData, addonIndex: integer, locationIndex: integer): SWLocation
Addon.Classes.SWLocation = Noir.Class("SWLocation")

--[[
    Initializes `SWLocation` class instances.
]]
---@param location SWLocationData The location of the asset
---@param addonIndex integer The index of the addon the location is in
---@param locationIndex integer The index of the location
function Addon.Classes.SWLocation:Init(location, addonIndex, locationIndex)
    --[[
        The location data.
    ]]
    self.Data = location

    --[[
        The index of the addon the location is in.
    ]]
    self.AddonIndex = addonIndex

    --[[
        The index of the location.
    ]]
    self.LocationIndex = locationIndex
end

--[[
    Formats the location to a string.
]]
---@return string
function Addon.Classes.SWLocation:Format()
    return ("Location #%d of addon #%d @ %s (%s)"):format(self.LocationIndex, self.AddonIndex, self.Data.name, self.Data.tile)
end