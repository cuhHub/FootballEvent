--------------------------------------------------------
-- Services - Assets
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
    A service for finding assets made in addon editor.
]]
---@class Assets: NoirService
Addon.Assets = Noir.Services:CreateService(
    "Assets",
    false,
    "A service for finding assets made in addon editor.",
    "A service for finding assets made in addon editor.",
    {"Cuh4"}
)

--[[
    Called when this service is initialized.
]]
function Addon.Assets:ServiceInit()
    --[[
        The locations within this and other addons.
    ]]
    ---@type table<integer, SWLocation>
    self.Locations = {}
    self:_SearchLocations()

    --[[
        A table of all assets found.
    ]]
    ---@type table<integer, Asset>
    self.Assets = {}
    self:_SearchAssets()
end

--[[
    Finds all used locations.
]]
function Addon.Assets:_SearchLocations()
    for addonIndex = 0, server.getAddonCount() - 1 do
        for locationIndex = 0, server.getAddonData(addonIndex).location_count - 1 do
            local data = server.getLocationData(addonIndex, locationIndex)

            if not data then
                goto continue
            end

            local location = Addon.Classes.SWLocation:New(data, addonIndex, locationIndex)
            table.insert(self.Locations, location)

            Addon.Logger:Info("Assets: Found location: %s", location:Format())

            ::continue::
        end
    end
end

--[[
    Finds all assets.
]]
function Addon.Assets:_SearchAssets()
    for _, location in pairs(self:GetLocations()) do
        for componentIndex = 0, location.Data.component_count - 1 do
            local component = server.getLocationComponentData(location.AddonIndex, location.LocationIndex, componentIndex)

            if not component then
                goto continue
            end

            local asset = Addon.Classes.Asset:New(
                location,
                component,
                componentIndex
            )

            table.insert(self.Assets, asset)

            Addon.Logger:Info("Assets: Found asset: %s", asset:Format())

            ::continue::
        end
    end

    self:OnAllLoaded()
end

--[[
    Tells all assets that all assest have been loaded.
]]
function Addon.Assets:OnAllLoaded()
    for _, asset in pairs(self:GetAssets()) do
        asset:OnAllLoaded()
    end
end

--[[
    Returns an asset from custom asset ID.
]]
---@param assetID string The custom asset ID
---@return Asset|nil
function Addon.Assets:GetAssetByCustomID(assetID)
    for _, asset in pairs(self:GetAssets()) do
        if asset:GetCustomAssetID() == assetID then
            return asset
        end
    end
end

--[[
    Returns all locations.
]]
---@return table<integer, SWLocation>
function Addon.Assets:GetLocations()
    return self.Locations
end

--[[
    Returns all assets.
]]
---@return table<integer, Asset>
function Addon.Assets:GetAssets()
    return self.Assets
end

--[[
    Searches for assets by tags.
]]
---@param tags table<integer, string>|nil The tags to search for
---@param properties table<string, any>|nil The properties to search for
---@return table<integer, Asset>
function Addon.Assets:Find(tags, properties)
    if not tags and not properties then
        return self:GetAssets()
    end

    ---@type table<integer, Asset>
    local found = {}

    for _, asset in pairs(self:GetAssets()) do
        if tags and #tags > 0 and not asset:MatchTags(tags) then
            goto continue
        end

        if properties and Noir.Libraries.Table:Length(properties) > 0 and not asset:MatchProperties(properties) then
            goto continue
        end

        table.insert(found, asset)

        ::continue::
    end

    return found
end