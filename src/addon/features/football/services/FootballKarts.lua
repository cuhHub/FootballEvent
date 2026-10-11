--------------------------------------------------------
-- Services - Football Karts
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
    Handles player karts.
]]
---@class FootballKarts: NoirService
Addon.FootballKarts = Noir.Services:CreateService(
    "FootballKarts",
    false,
    "Handles player karts.",
    "Handles player karts.",
    {"Cuh4"}
)

--[[
    Called when the service is initialized.
]]
function Addon.FootballKarts:ServiceInit()
    --[[
        Karts, indexed by owner player ID.
    ]]
    ---@type table<integer, Kart>
    self.Karts = {}

    --[[
        The kart asset tag.
    ]]
    self.KART_ASSET_TAG = "kart"
end

--[[
    Called when the service is started.
]]
function Addon.FootballKarts:ServiceStart()
    self:CreateCommands()
end

--[[
    Resets all karts.
]]
function Addon.FootballKarts:ResetKarts()
    for _, kart in pairs(self:GetKarts()) do
        kart:Reset()
    end
end

--[[
    Returns the kart asset for the given team.
]]
---@param team Team The team to get the kart asset for
---@return Asset
function Addon.FootballKarts:GetKartAsset(team)
    local asset = Addon.Assets:Find({self.KART_ASSET_TAG}, {["Team"] = team.Name})[1]

    if not asset then
        error("Addon.FootballKarts:GetKartAsset()", "Failed to find kart asset for team '%s'.", team.Name)
    end

    return asset
end

--[[
    Spawns a kart for a player.
]]
---@param player NoirPlayer The player to spawn the kart for
---@param spawnPosition SWMatrix The position to spawn the kart at
---@return Kart
function Addon.FootballKarts:SpawnKart(player, spawnPosition)
    local team = Addon.Events:GetPlayerTeam(player)

    if not team then
        error("Addon.FootballKarts:SpawnKart()", "Player not in team.")
    end

    local asset = self:GetKartAsset(team)

    local kart = Addon.Classes.Kart:New(asset, spawnPosition, player)
    kart:Setup()

    self.Karts[player.ID] = kart

    Addon.Logger:Info("FootballKarts: Spawned kart for player '%s'.", Addon.Libs.Player:FormatPlayerName(player))

    return kart
end

--[[
    Returns all karts, indexed by player ID.
]]
---@return table<integer, Kart>
function Addon.FootballKarts:GetKarts()
    return self.Karts
end

--[[
    Returns a player's kart.
]]
---@param player NoirPlayer The player to get the kart for
---@return Kart|nil
function Addon.FootballKarts:GetKart(player)
    return self:GetKarts()[player.ID]
end

--[[
    Returns if a player has a kart.
]]
---@param player NoirPlayer The player to check
---@return boolean
function Addon.FootballKarts:HasKart(player)
    return self:GetKart(player) ~= nil
end

--[[
    Removes a player's kart.
]]
---@param player NoirPlayer The player to remove the kart for
function Addon.FootballKarts:RemoveKart(player)
    local kart = self:GetKart(player)

    if not kart then
        error("Addon.FootballKarts:RemoveKart()", "Player has no kart.")
    end

    kart:Cleanup()
    self.Karts[player.ID] = nil

    Addon.Logger:Info("FootballKarts: Removed kart for player '%s'.", Addon.Libs.Player:FormatPlayerName(player))
end

--[[
    Creates commands.
]]
function Addon.FootballKarts:CreateCommands()
    Noir.Services.CommandService:CreateCommand(
        "flip",
        {},
        false,
        false,
        false,
        "",

        function(context)
            if not context.HasPermission then
                return
            end

            local kart = Addon.FootballKarts:GetKart(context.Player)

            if not kart then
                return
            end

            kart:TryFlip()
        end
    )
end