--------------------------------------------------------
-- Classes - Asset
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
    A class representing an asset in the addon.
]]
---@class Asset: NoirClass
---@field New fun(self: Asset, location: SWLocation, component: SWAddonComponentData, componentIndex: integer): Asset
Addon.Classes.Asset = Noir.Class("Asset")

--[[
    Initializes `Asset` class instances.
]]
---@param location SWLocation The location of the asset
---@param component SWAddonComponentData The actual component in the location
---@param componentIndex integer The index of the component
function Addon.Classes.Asset:Init(location, component, componentIndex)
    local tags, properties = Addon.Libs.AssetParser:ParseAssetText(component.tags_full)

    --[[
        The tags of the asset.
    ]]
    self.Tags = tags

    --[[
        The properties of the asset.
    ]]
    self.Properties = properties

    --[[
        The location of the asset.
    ]]
    self.Location = location

    --[[
        The component of the asset.
    ]]
    self.Component = component

    --[[
        The index of the component.
    ]]
    self.ComponentIndex = componentIndex

    --[[
        The custom ID for this asset. Can be nil, and is dicated by `_AssetID` property
    ]]
    ---@type string|nil
    self._AssetID = self:GetProperty("_AssetID")

    --[[
        The ID of the asset to use for spawning. Can be nil, and is dicated by `_UseAssetForSpawn` property
    ]]
    ---@type string|nil
    self._AssetIDForSpawnOverride = self:GetProperty("_UseAssetForSpawn")

    --[[
        The asset to use for spawning, can be nil.
    ]]
    self._AssetForSpawnOverride = nil
end

--[[
    Called when all assets have loaded.
]]
function Addon.Classes.Asset:OnAllLoaded()
    if self._AssetIDForSpawnOverride then
        local asset = Addon.Assets:GetAssetByCustomID(self._AssetIDForSpawnOverride)

        if not asset then
            error("Addon.Classes.Asset:Init()", "Failed to find asset with custom ID '%s' to override spawning for %s.", self._AssetIDForSpawnOverride, self:Format())
        end

        self._AssetForSpawnOverride = asset
    end
end

--[[
    Formats the asset to a string.
]]
function Addon.Classes.Asset:Format()
    return ("Asset #%d @ %s"):format(self.Component.id, self.Location:Format())
end

--[[
    Returns the custom asset ID for this asset. Can be nil.
]]
---@return string|nil
function Addon.Classes.Asset:GetCustomAssetID()
    return self._AssetID
end

--[[
    Returns the specified property in this asset, providing the default value if it doesn't exist.
]]
---@param key string The key of the property
---@param defaultValue any|nil The default value to return if the property doesn't exist
---@return any
function Addon.Classes.Asset:GetProperty(key, defaultValue)
    local value = self.Properties[key]

    if value == nil then
        return defaultValue
    end

    return value
end

--[[
    Returns if this asset's tags match those provided.
]]
---@param tags table<integer, string> The tags to match
---@return boolean
function Addon.Classes.Asset:MatchTags(tags)
    local matches = 0

    for _, tag in pairs(tags) do
        if Noir.Libraries.Table:Find(self.Tags, tag) ~= nil then
            matches = matches + 1
        else
            return false
        end
    end

    return matches == #tags
end

--[[
    Returns if this asset's properties match those provided.
]]
---@param properties table<string, any> The properties to match
---@return boolean
function Addon.Classes.Asset:MatchProperties(properties)
    for key, value in pairs(properties) do
        if self.Properties[key] ~= value then
            return false
        end
    end

    return true
end

--[[
    Returns the location index for this asset.
]]
---@return integer
function Addon.Classes.Asset:GetLocationIndex()
    return server.getLocationIndex((server.getAddonIndex()), self.Location.Data.name)
end

--[[
    Returns all global positions in the world for the asset.
]]
---@return SWMatrix[]
function Addon.Classes.Asset:GetPositions()
    return Noir.Services.RelPosService:CreateRelPos(
        self.Location.Data.tile,
        self.Component.transform
    ):GetGlobalPositions()
end

--[[
    Returns the global position in the world for the asset.
]]
---@param noOffset boolean|nil If true, spawn offset from reference asset (if any) will not be applied to the position
---@return SWMatrix
function Addon.Classes.Asset:GetPosition(noOffset)
    local position = self:GetPositions()[1]

    if not position then
        Addon.Logger:Warning("Addon.Classes.Asset:GetPosition(): No position in the world for the asset (ocean tile issue? tile: %s).", self.Location.Data.tile)
        return matrix.identity()
    end

    if noOffset then
        return position
    end

    return self:_ApplySpawnOffset(position)
end

--[[
    Returns the addon index for this asset.
]]
---@return integer
function Addon.Classes.Asset:GetAddonIndex()
    return self.Location.AddonIndex
end

--[[
    Returns if this asset uses a reference asset.
]]
---@return boolean
function Addon.Classes.Asset:UsesReferenceAsset()
    return self:GetReferenceAsset() ~= nil
end

--[[
    Returns the reference asset if any.
]]
---@return Asset|nil
function Addon.Classes.Asset:GetReferenceAsset()
    return self._AssetForSpawnOverride
end

--[[
    Returns the addon index for spawning this asset.
]]
---@return integer
function Addon.Classes.Asset:_GetSpawnAddonIndex()
    return self:UsesReferenceAsset() and self:GetReferenceAsset():GetAddonIndex() or self:GetAddonIndex()
end

--[[
    Returns the location index for spawning this asset.
]]
---@return integer
function Addon.Classes.Asset:_GetSpawnLocationIndex()
    return self:UsesReferenceAsset() and self:GetReferenceAsset():GetLocationIndex() or self:GetLocationIndex()
end

--[[
    Returns the component index for spawning this asset.
]]
---@return integer
function Addon.Classes.Asset:_GetSpawnComponentIndex()
    return self:UsesReferenceAsset() and self:GetReferenceAsset().ComponentIndex or self.ComponentIndex
end

--[[
    Returns the component ID for spawning this asset.
]]
---@return integer
function Addon.Classes.Asset:_GetSpawnComponentID()
    return self:UsesReferenceAsset() and self:GetReferenceAsset().Component.id or self.Component.id
end

--[[
    Returns the spawn offset from the reference asset (asset reference feature).
]]
---@return SWMatrix
function Addon.Classes.Asset:_GetSpawnOffsetFromReference()
    if not self:UsesReferenceAsset() then
        return matrix.translation(0, 0, 0)
    end

    local usesOffset = self:GetReferenceAsset():GetProperty("_UsesOffset", false)
    local acceptsOffset = self:GetProperty("_AcceptsOffset", true)

    if not usesOffset or not acceptsOffset then
        return matrix.translation(0, 0, 0)
    end

    return matrix.translation(
        self:GetReferenceAsset():GetProperty("_OffsetX", 0),
        self:GetReferenceAsset():GetProperty("_OffsetY", 0),
        self:GetReferenceAsset():GetProperty("_OffsetZ", 0)
    )
end

--[[
    Applies the spawn offset to the position, if there is a spawn offset.
]]
---@param position SWMatrix The position to apply the spawn offset to
---@return SWMatrix
function Addon.Classes.Asset:_ApplySpawnOffset(position)
    return matrix.multiply(position, self:_GetSpawnOffsetFromReference())
end

--[[
    Spawns a vehicle from this asset.
]]
---@param position SWMatrix|nil The position to spawn the vehicle at, or nil to use the asset's position
---@return NoirVehicle
function Addon.Classes.Asset:SpawnVehicle(position)
    return Noir.Services.VehicleService:SpawnVehicle(
        self:_GetSpawnComponentID(),
        self:_ApplySpawnOffset(position or self:GetPosition(true)),
        self:_GetSpawnAddonIndex()
    )
end

--[[
    Spawns an object from this asset.
]]
---@param position SWMatrix|nil The position to spawn the object at, or nil to use the asset's position
---@return NoirObject
function Addon.Classes.Asset:SpawnObject(position)
    local component, success = server.spawnAddonComponent(
        self:_ApplySpawnOffset(position or self:GetPosition(true)),
        self:_GetSpawnAddonIndex(),
        self:_GetSpawnLocationIndex(),
        self:_GetSpawnComponentIndex()
    )

    if not success then
        error(
            "Asset:SpawnObject()",
            "Failed to spawn object (server.spawnAddonComponent() failed) for asset %s",
            self:Format()
        )
    end

    local object = Noir.Services.ObjectService:GetObject(component.object_id)

    if not object:Exists() then
        error("Asset:SpawnObject()", "Object does not exist after spawning. Asset: %s", self:Format())
    end

    return object
end