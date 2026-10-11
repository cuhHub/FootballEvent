--------------------------------------------------------
-- Libraries - Player
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
    A library for player related functions (eg: name formatting)
]]
---@class PlayerLib: NoirLibrary
Addon.Libs.Player = Noir.Libraries:Create(
    "Player",
    "A library for player related functions (eg: name formatting)",
    "A library for player related functions (eg: name formatting)",
    {"Cuh4"}
)

--[[
    Formats the name of a player.
]]
---@param player NoirPlayer The player to format
---@return string
function Addon.Libs.Player:FormatPlayerName(player)
    return ("%s (#%d)"):format(player.Name, player.ID)
end

--[[
    Calls the callback with the player's character (instant if character exists, or may take a bit if character hasn't loaded yet).
]]
---@param player NoirPlayer The player to get the character of
---@param callback fun(character: NoirObject) The callback to call with the character
function Addon.Libs.Player:GetCharacterDefinite(player, callback)
    local character = player:GetCharacter()

    if character then
        callback(character)
    else
        player.OnCharacterLoad:Once(callback)
    end
end

--[[
    Returns all players apart from those in the exceptions argument.
]]
---@param exceptions table<integer, NoirPlayer> A table of players to exclude
---@return table<integer, NoirPlayer>
function Addon.Libs.Player:GetPlayersApartFrom(exceptions)
    local exceptionsPeerIDs = {} ---@type table<integer, boolean>

    for _, player in pairs(exceptions) do
        exceptionsPeerIDs[player.ID] = true
    end

    local players = {} ---@type table<integer, NoirPlayer>

    for _, player in pairs(Noir.Services.PlayerService:GetPlayers(true)) do
        if exceptionsPeerIDs[player.ID] then
            goto continue
        end

        table.insert(players, player)

        ::continue::
    end

    return players
end

--[[
    Returns if the server is empty.
]]
---@return boolean
function Addon.Libs.Player:IsServerEmpty()
    return #Noir.Services.PlayerService:GetPlayers(false) <= 0
end

--[[
    Returns the formatted names of all players in a table.
]]
---@param players table<any, NoirPlayer> The players to get the formatted names of
---@return table<integer, string>
function Addon.Libs.Player:FormatPlayerNames(players)
    ---@type table<integer, string>
    local names = {}

    for _, player in pairs(players) do
        table.insert(names, self:FormatPlayerName(player))
    end

    return names
end

--[[
    Returns a player by name search or ID.
]]
---@param query string|nil The player name (can be partial/case-insensitive) or ID, or nil to get nil
---@return NoirPlayer|nil
function Addon.Libs.Player:SearchPlayer(query)
    if not query then
        return
    end

    local ID = tonumber(query)

    return ID and
        Noir.Services.PlayerService:GetPlayer(ID) or
        Noir.Services.PlayerService:SearchPlayerByName(query)
end

--[[
    Returns a random player in the server, or nil if none are in the server.
]]
---@return NoirPlayer|nil
function Addon.Libs.Player:GetRandomPlayer()
    return Noir.Libraries.Table:Random(Noir.Services.PlayerService:GetPlayers(false))
end

--[[
    Returns if the position is within x meters of any player.
]]
---@param position SWMatrix The position to check
---@param distance number The distance in meters to check
---@return boolean
function Addon.Libs.Player:IsPositionNearAnyPlayer(position, distance)
    local squaredDistance = distance * distance

    for _, player in pairs(Noir.Services.PlayerService:GetPlayers(false)) do
        if Addon.Libs.Matrix:GetSquaredDistance(position, player:GetPosition()) <= squaredDistance then
            return true
        end
    end

    return false
end

--[[
    Heals the player.
]]
---@param player NoirPlayer
function Addon.Libs.Player:HealPlayer(player)
    local character = player:GetCharacter()

    if not character then
        return
    end

    character:Revive()
    character:Heal(100)
end

--[[
    Clears a player's items.
]]
---@param player NoirPlayer The player to clear
function Addon.Libs.Player:ClearPlayerItems(player)
    local character = player:GetCharacter()

    if not character then
        return
    end

    for slot = 1, 10 do
        character:GiveItem(slot, 0)
    end
end