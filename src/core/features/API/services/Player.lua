--------------------------------------------------------
-- Services - API - Player
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
    Handles requests to cuhHub's Player Service.
]]
---@class API.Player: NoirService
Addon.API.Player = Noir.Services:CreateService("API.Player")

--[[
    Called when this service is initialized.
]]
function Addon.API.Player:ServiceInit()
    --[[
        A player data cache indexed by peer ID.
    ]]
    ---@type table<integer, APIPlayer>
    self.PlayerDataCache = {}
end

--[[
    Called when this service is started.
]]
function Addon.API.Player:ServiceStart()
    --[[
        A connection to `PlayerService`'s `OnLeave` event.
    ]]
    self.OnLeaveConnection = Noir.Services.PlayerService.OnLeave:Connect(function(player)
        self:UncachePlayerData(player)
    end)
end

--[[
    Returns the cached player data for the provided player.
]]
---@param player NoirPlayer The player to get data for
---@return APIPlayer|nil
function Addon.API.Player:GetCachedPlayerData(player)
    return self.PlayerDataCache[player.ID]
end

--[[
    Caches player data.
]]
---@param player NoirPlayer The player to cache data for
---@param data APIPlayer The data to cache
function Addon.API.Player:CachePlayerData(player, data)
    self.PlayerDataCache[player.ID] = data
end

--[[
    Clears a player's cached data.
]]
---@param player NoirPlayer The player to clear data for
function Addon.API.Player:UncachePlayerData(player)
    self.PlayerDataCache[player.ID] = nil
end

--[[
    Closure for player API responses.
]]
---@param player NoirPlayer The player
---@param callback fun(player: APIPlayer)|nil The callback returning the player's new data. Optional
---@return fun(response: APIConversionRequestResponse)
function Addon.API.Player:_PlayerResponseCallback(player, callback)
    return function(response)
        if not callback then
            return
        end

        local decoded = Noir.Libraries.JSON:Decode(response.Text)

        if not decoded then
            Addon.Logger:Warning("API.Player:_PlayerResponseCallback(): Failed to decode player data: "..response.Text)
            return
        end

        local playerData = Addon.Classes.APIPlayer:FromBackendResponse(decoded)
        self:CachePlayerData(player, playerData)

        callback(playerData)
    end
end

--[[
    Begin a player's session by "joining them into the server."
]]
---@param player NoirPlayer The player to "join"
---@param callback fun(player: APIPlayer)|nil The callback returning the player's new data. Optional
---@param errorCallback fun(response: APIConversionRequestResponse)|nil The callback called when this operation goes wrong
function Addon.API.Player:PlayerJoin(player, callback, errorCallback)
    Addon.API.Conversion:HTTPPOST(
        Config.API.URL..Addon.Enums.APIServiceRoute.Servers..Addon.API.Server.ServerData.ID.."/join",
        self:_PlayerResponseCallback(player, callback),
        function(response)
            Addon.Logger:Warning("API.Player:PlayerJoin(): Failed to join player, got response: "..response.Text)

            if errorCallback then
                errorCallback(response)
            end
        end,
        nil,
        {
            steam_username = player.Name,
            steam_id = player.Steam
        }
    )
end

--[[
    End a player's session.
]]
---@param player NoirPlayer The player to "leave"
---@param callback fun(player: APIPlayer)|nil The callback returning the player's new data. Optional
function Addon.API.Player:PlayerLeave(player, callback)
    Addon.API.Conversion:HTTPPOST(Config.API.URL..Addon.Enums.APIServiceRoute.Players..player.Steam.."/leave", self:_PlayerResponseCallback(player, callback), function(response)
        Addon.Logger:Warning("API.Player:PlayerLeave(): Failed to leave player, got response: "..response.Text)
    end)
end

--[[
    Bans a player.
]]
---@param player NoirPlayer The player to ban
---@param reason string The reason for the ban
---@param duration integer The duration of the ban in days. Use 0 for permanent
function Addon.API.Player:PlayerBan(player, reason, duration)
    Addon.API.Conversion:HTTPPOST(Config.API.URL..Addon.Enums.APIServiceRoute.Players..player.Steam.."/ban", nil, function(response)
        Addon.Logger:Warning("API.Player:PlayerBan(): Failed to ban player, got response: "..response.Text)
    end, nil, {
        reason = reason,
        days = duration
    })
end

--[[
    Kicks a player.
]]
---@param player NoirPlayer The player to kick
---@param reason string The reason for the kick
function Addon.API.Player:PlayerKick(player, reason)
    Addon.API.Conversion:HTTPPOST(Config.API.URL..Addon.Enums.APIServiceRoute.Players..player.Steam.."/kick", nil, function(response)
        Addon.Logger:Warning("API.Player:PlayerKick(): Failed to kick player, got response: "..response.Text)
    end, nil, {
        reason = reason
    })
end

--[[
    Warns a player.
]]
---@param player NoirPlayer The player to warn
---@param reason string The reason for the warning (warn message)
function Addon.API.Player:PlayerWarn(player, reason)
    Addon.API.Conversion:HTTPPOST(Config.API.URL..Addon.Enums.APIServiceRoute.Players..player.Steam.."/warn", nil, function(response)
        Addon.Logger:Warning("API.Player:PlayerWarn(): Failed to warn player, got response: "..response.Text)
    end, nil, {
        reason = reason
    })
end

--[[
    Begin linking a player to their Discord account.
    This will only give the linking code.
]]
---@param player NoirPlayer The player to begin a linking process for
---@param callback fun(linking_code: string, expires_in_mins: number) The callback called when a linking code is given
---@param errorCallback fun()|nil The callback called when this operation goes wrong
function Addon.API.Player:BeginLinking(player, callback, errorCallback)
    Addon.API.Conversion:HTTPPOST(Config.API.URL..Addon.Enums.APIServiceRoute.Players..player.Steam.."/link/begin", function(response)
        local decoded = Noir.Libraries.JSON:Decode(response.Text)

        if not decoded then
            Addon.Logger:Warning("API.Player:BeginLinking(): Failed to decode linking response: "..response.Text)
            return
        end

        callback(decoded.linking_code, decoded.expires_in / 60)
    end, function(response)
        Addon.Logger:Warning("API.Player:BeginLinking(): Failed to link player: "..response.Text)

        if errorCallback then
            errorCallback()
        end
    end)
end

--[[
    Cancels a linking process for a player.
]]
---@param player NoirPlayer The player to cancel a linking process for
function Addon.API.Player:CancelLinking(player)
    Addon.API.Conversion:HTTPPOST(Config.API.URL..Addon.Enums.APIServiceRoute.Players..player.Steam.."/link/cancel")
end

--[[
    Returns data on the player (or nil if no data).
]]
---@param player NoirPlayer The player to get data of
---@param callback fun(data: APIPlayer) The callback to get data from
---@param ignoreCache boolean|nil Whether to ignore the cache
---@param errorCallback fun()|nil The callback called when this operation goes wrong (e.g. no data for player)
function Addon.API.Player:GetPlayerData(player, callback, ignoreCache, errorCallback)
    local cached = self:GetCachedPlayerData(player)

    if cached and not ignoreCache then
        callback(cached)
        return
    end

    Addon.API.Conversion:HTTPGET(Config.API.URL..Addon.Enums.APIServiceRoute.Players..player.Steam, self:_PlayerResponseCallback(player, callback), function(response)
        Addon.Logger:Warning("API.Player:GetPlayerData(): Failed to get player data: "..response.Text)

        if errorCallback then
            errorCallback()
        end
    end)
end

--[[
    Increments the player's total deaths.
]]
---@param player NoirPlayer The player to affect
function Addon.API.Player:IncrementPlayerDeaths(player)
    Addon.API.Conversion:HTTPPATCH(Config.API.URL..Addon.Enums.APIServiceRoute.Players..player.Steam.."/deaths", nil, nil, nil, {
        steam_id = player.Steam
    })
end

--[[
    Increments the player's total vehicle spawns.
]]
---@param player NoirPlayer The player to affect
function Addon.API.Player:IncrementPlayerVehicleSpawns(player)
    Addon.API.Conversion:HTTPPATCH(Config.API.URL..Addon.Enums.APIServiceRoute.Players..player.Steam.."/total-vehicles-spawned", nil, nil, nil, {
        steam_id = player.Steam
    })
end