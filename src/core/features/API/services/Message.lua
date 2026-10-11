--------------------------------------------------------
-- Services - API - Message
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
    Handles requests to cuhHub's Message Service.
]]
---@class API.Message: NoirService
Addon.API.Message = Noir.Services:CreateService("API.Message")

--[[
    Saves a message sent by a player to the backend for it to also process.
    Should be used when a player sends a message.
]]
---@param message NoirMessage The message sent by a player
---@param callback fun(message: APIMessage)
function Addon.API.Message:SendMessage(message, callback)
    if message.IsAddon then
        return
    end

    Addon.API.Conversion:HTTPPOST(Config.API.URL..Addon.Enums.APIServiceRoute.Messages, function(response)
        if not callback then
            return
        end

        local decoded = Noir.Libraries.JSON:Decode(response.Text)

        if not decoded then
            Addon.Logger:Warning("API.Message:SendMessage(): Failed to decode message data: "..response.Text)
            return
        end

        local messageData = Addon.Classes.APIMessage:FromBackendResponse(decoded)
        callback(messageData)
    end, function(response)
        Addon.Logger:Warning("API.Message:SendMessage(): Failed to send message to backend, got response: "..response.Text)
    end, nil, {
        content = message.Content,
        player_steam_id = message.Author.Steam,
        server_id = Addon.API.Server.ServerData.ID
    })
end