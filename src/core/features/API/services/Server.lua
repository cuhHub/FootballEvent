--------------------------------------------------------
-- Services - API - Server
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
    Handles requests to cuhHub's Server Service.
]]
---@class API.Server: NoirService
Addon.API.Server = Noir.Services:CreateService("API.Server")

--[[
    Called when this service is initialized.
]]
function Addon.API.Server:ServiceInit()
    --[[
        The data of the server this addon is running in.
    ]]
    self.ServerData = {
        --[[
            The ID of the server this addon is running in.
        ]]
        ---@type integer
        ---@diagnostic disable-next-line
        ID = Server and Server.ID or 0,

        --[[
            The name of the server this addon is running in.
        ]]
        ---@type string
        ---@diagnostic disable-next-line
        Name = Server and Server.Name or "NO NAME", -- The name of this server

        --[[
            The description of the server this addon is running in.
        ]]
        ---@type string
        ---@diagnostic disable-next-line
        Description = Server and Server.Description or "NO DESCRIPTION",

        --[[
            The port this server is using (note that port + 1 is also used).
        ]]
        ---@type integer
        ---@diagnostic disable-next-line
        Port = Server and Server.Port or 0,

        --[[
            The maximum amount of players this server can have.
        ]]
        ---@type integer
        ---@diagnostic disable-next-line
        MaxPlayers = Server and Server.MaxPlayers or 0,

        --[[
            The password for this server, or "" if no password.
        ]]
        ---@type string
        ---@diagnostic disable-next-line
        Password = Server and Server.Password or "",

        --[[
            The amount of mods in this server.
        ]]
        ---@type integer
        ---@diagnostic disable-next-line
        ModCount = Server and Server.Mods or 0,

        --[[
            The amount of addons in this server.
        ]]
        ---@type integer
        ---@diagnostic disable-next-line
        AddonCount = Server and Server.Addons or 0,

        --[[
            The version of this server (Stormworks depot version number).
        ]]
        ---@type string
        ---@diagnostic disable-next-line
        Version = Server and Server.Version or "NO VERSION",
    }
end

--[[
    Restarts this server.
]]
function Addon.API.Server:RestartServer()
    Addon.API.Conversion:HTTPPOST(Config.API.URL..Addon.Enums.APIServiceRoute.Servers..self.ServerData.ID.."/restart")
end

--[[
    Stops this server.
]]
function Addon.API.Server:StopServer()
    Addon.API.Conversion:HTTPPOST(Config.API.URL..Addon.Enums.APIServiceRoute.Servers..self.ServerData.ID.."/stop")
end

--[[
    Sends a server heartbeat. This is used to tell the backend this server is running and not frozen or anything.
]]
function Addon.API.Server:Heartbeat()
    Addon.API.Conversion:HTTPPOST(Config.API.URL..Addon.Enums.APIServiceRoute.Servers..self.ServerData.ID.."/heartbeat")
end

--[[
    Sends a server update (inform).
]]
function Addon.API.Server:InformServer()
    Addon.API.Conversion:HTTPPOST(Config.API.URL..Addon.Enums.APIServiceRoute.Servers..self.ServerData.ID.."/inform", nil, nil, nil, {
        tps = Noir.Services.TPSService:GetTPS(),
        average_tps = Noir.Services.TPSService:GetAverageTPS()
    })
end

--[[
    Sends a live chat message to the Discord channel for this server.
]]
---@param title string The title of the message
---@param message string The content of the message
---@param emoji string The emoji to use
---@param r number The red component of the color
---@param g number The green component of the color
---@param b number The blue component of the color
function Addon.API.Server:SendLiveChat(title, message, emoji, r, g, b)
    Addon.API.Conversion:HTTPPOST(Config.API.URL..Addon.Enums.APIServiceRoute.Servers..self.ServerData.ID.."/say", nil, nil, nil, {
        title = title,
        message = message,
        emoji = emoji,
        color = {r, g, b}
    })
end