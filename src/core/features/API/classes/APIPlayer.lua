--------------------------------------------------------
-- Classes - API Player
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
    A class representing a player from the backend.
]]
---@class APIPlayer: NoirDataclass
---@field New fun(
---     self: APIPlayer,
---     steamId: string,
---     steamUsername: string,
---     steamIconUrl: string|nil,
---     discordId: string|nil,
---     isDiscordLinked: boolean,
---     linkedAt: number|nil,
---     playtime: number,
---     sessionPlaytime: number,
---     online: boolean,
---     serverId: integer|nil,
---     joinedServerAt: number,
---     leftServerAt: number|nil,
---     firstPlayed: number,
---     deaths: integer,
---     totalVehiclesSpawned: integer,
---     isStaff: boolean,
---     isDeveloper: boolean,
---     language: APIPlayerLanguageEnum,
---     supporterTier: APISupporterTierEnum,
---     banned: boolean,
---     banReason: string|nil,
---     banDuration: integer|nil,
---     steamProfileUrl: string): APIPlayer
---@field SteamID string The Steam ID of this player 
---@field SteamUsername string The Steam username of this player 
---@field SteamIconURL string|nil The Steam icon URL of this player 
---
---@field DiscordID string|nil The Discord ID of this player 
---@field IsDiscordLinked boolean Whether the player has linked their Discord account 
---@field LinkedAt number|nil The time when the player linked their Discord account 
---
---@field Playtime number The total amount of time the player has been online 
---@field SessionPlaytime number The amount of time the player has been online in the current session 
---@field Online boolean Whether the player is currently online 
---@field ServerID integer|nil The server ID where the player is currently connected 
---@field JoinedServerAt number The time when the player joined the current server 
---@field LeftServerAt number|nil The time when the player left the current server 
---
---@field FirstPlayed number The time when the player first joined 
---@field Deaths integer The amount of times the player has died 
---@field TotalVehiclesSpawned integer The total amount of vehicles spawned by the player 
---@field IsStaff boolean Whether the player is a staff member 
---@field IsDeveloper boolean Whether the player is a developer 
---@field Language APIPlayerLanguageEnum The language the player has set 
---@field SupporterTier APISupporterTierEnum The supporter tier the player has 
---
---@field Banned boolean Whether the player has been banned 
---@field BanReason string|nil The reason the player was banned 
---@field BanDuration integer|nil The duration of the player's ban in days 
---
---@field SteamProfileURL string The Steam profile URL of the player
Addon.Classes.APIPlayer = Noir.Libraries.Dataclasses:New("APIPlayer", {
    Noir.Libraries.Dataclasses:Field("SteamID", "string"),
    Noir.Libraries.Dataclasses:Field("SteamUsername", "string"),
    Noir.Libraries.Dataclasses:Field("SteamIconURL", "string", "nil"),

    Noir.Libraries.Dataclasses:Field("DiscordID", "string", "nil"),
    Noir.Libraries.Dataclasses:Field("IsDiscordLinked", "boolean"),
    Noir.Libraries.Dataclasses:Field("LinkedAt", "number", "nil"),

    Noir.Libraries.Dataclasses:Field("Playtime", "number"),
    Noir.Libraries.Dataclasses:Field("SessionPlaytime", "number"),
    Noir.Libraries.Dataclasses:Field("Online", "boolean"),
    Noir.Libraries.Dataclasses:Field("ServerID", "number", "nil"),
    Noir.Libraries.Dataclasses:Field("JoinedServerAt", "number"),
    Noir.Libraries.Dataclasses:Field("LeftServerAt", "number", "nil"),

    Noir.Libraries.Dataclasses:Field("FirstPlayed", "number"),
    Noir.Libraries.Dataclasses:Field("Deaths", "number"),
    Noir.Libraries.Dataclasses:Field("TotalVehiclesSpawned", "number"),
    Noir.Libraries.Dataclasses:Field("IsStaff", "boolean"),
    Noir.Libraries.Dataclasses:Field("IsDeveloper", "boolean"),
    Noir.Libraries.Dataclasses:Field("Language", "string"),
    Noir.Libraries.Dataclasses:Field("SupporterTier", "number"),

    Noir.Libraries.Dataclasses:Field("Banned", "boolean"),
    Noir.Libraries.Dataclasses:Field("BanReason", "string", "nil"),
    Noir.Libraries.Dataclasses:Field("BanDuration", "number", "nil"),

    Noir.Libraries.Dataclasses:Field("SteamProfileURL", "string")
})

--[[
    Returns an APIPlayer instance from a response to a backend request.
    *classmethod*
]]
---@param response table The decoded response
---@return APIPlayer
function Addon.Classes.APIPlayer:FromBackendResponse(response)
    return self:New(
        response.steam_id,
        response.steam_username,
        response.steam_icon_url,
        response.discord_id,
        response.is_discord_linked,
        response.linked_at,
        response.playtime,
        response.session_playtime,
        response.online,
        response.server_id,
        response.joined_server_at,
        response.left_server_at,
        response.first_played,
        response.deaths,
        response.total_vehicles_spawned,
        response.is_staff,
        response.is_developer,
        response.language,
        response.supporter_tier,
        response.banned,
        response.ban_reason,
        response.ban_duration,
        response.steam_profile_url
    )
end