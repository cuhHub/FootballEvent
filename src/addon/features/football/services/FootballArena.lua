--------------------------------------------------------
-- Services - Football Arena
--------------------------------------------------------

--[[
    Copyright (C) 2026 cuhHub - All Rights Reserved
    - Unauthorized copying of this file, via any medium is strictly prohibited
    - Proprietary and confidential
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Handles the football arena.
]]
---@class FootballArena: NoirService
Addon.FootballArena = Noir.Services:CreateService(
    "FootballArena",
    false,
    "Handles the football arena.",
    "Handles the football arena.",
    {"Cuh4"}
)

--[[
    Called when the service is initialized.
]]
function Addon.FootballArena:ServiceInit()
    --[[
        The arena.
    ]]
    ---@type Arena
    self.Arena = nil

    --[[
        The arena asset tag.
    ]]
    self.ARENA_ASSET_TAG = "arena"
end

--[[
    Called when the service is started.
]]
function Addon.FootballArena:ServiceStart()
    --[[
        The arena spawn position.
    ]]
    self.SpawnPosition = Noir.Libraries.Matrix:Offset(Addon.Events.HUB_POSITION, 1000, 0, 0)
end

--[[
    Returns the arena spawn position.
]]
---@return SWMatrix
function Addon.FootballArena:GetSpawnPosition()
    return self.SpawnPosition
end

--[[
    Returns if the arena is spawned or not.
]]
---@return boolean
function Addon.FootballArena:IsArenaSpawned()
    return self.Arena ~= nil
end

--[[
    Returns the arena.
]]
---@return Arena
function Addon.FootballArena:GetArena()
    if not self:IsArenaSpawned() then
        error("Addon.FootballArena:GetArena()", "Arena is not spawned.")
    end

    return self.Arena
end

--[[
    Spawns the arena.
]]
---@param loadCallback function Called when arena initially loads
function Addon.FootballArena:SpawnArena(loadCallback)
    local asset = Addon.Assets:Find({self.ARENA_ASSET_TAG})[1]

    if not asset then
        error("Addon.FootballArena:SpawnArena()", "Failed to find arena asset with tag '%s'.", self.ARENA_ASSET_TAG)
    end

    self.Arena = Addon.Classes.Arena:New(asset, self.SpawnPosition)
    self.Arena:Setup()

    self.Arena.OnLoad:Once(loadCallback)
end

--[[
    Removes the arena.
]]
function Addon.FootballArena:RemoveArena()
    self.Arena:Cleanup()
    self.Arena = nil
end