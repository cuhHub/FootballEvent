--------------------------------------------------------
-- Services - API
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
    A service for interacting with cuhHub's backend API.
]]
---@class API: NoirService
Addon.API = Noir.Services:CreateService(
    "API",
    false,
    "A service that provides methods to interact with the cuhHub backend.",
    "A service that provides methods to interact with the cuhHub backend. This makes working with the backend easier as requests don't have to be manually sent.",
    {"Cuh4"}
)

Addon.API.InitPriority = 0
Addon.API.StartPriority = 0

--[[
    Called when the service is initialized.
]]
function Addon.API:ServiceInit()
    --[[
        The API token for this addon.
    ]]
    ---@type string
    self.API_TOKEN = nil

    --[[
        Whether or not this service is read.y
    ]]
    self.IsReady = false

    --[[
        An event fired when the API service is ready (API token retrieved).
    ]]
    self.OnReady = Noir.Libraries.Events:Create()

    --[[
        Data relating to cuhHub itself (e.g: Discord invite).
    ]]
    self.cuhHubData = {
        --[[
            The invite URL for cuhHub's Discord
        ]]
        ---@type string
        ---@diagnostic disable-next-line
        DiscordInviteURL = cuhHub and cuhHub.DiscordInviteURL or "NO INVITE"
    }
end

--[[
    Called when the service is started.
]]
function Addon.API:ServiceStart()
    self:_GetAPIToken()
end

--[[
    Runs the function if this service is ready, otherwise when it becomes ready. 
]]
---@param callback fun() The callback to call when/if ready
function Addon.API:RunWhenReady(callback)
    if self.IsReady then
        callback()
    else
        self.OnReady:Once(callback)
    end
end

--[[
    Retrieves the API token for this addon.
]]
function Addon.API:_GetAPIToken()
    Noir.Services.HTTPService:GET("/"..Addon.Enums.APIServiceRoute.Tokens.."addon", Config.API.Port, function(response)
        if not response:IsOk() then
            Addon.Logger:Warning("API:_GetAPIToken(): Failed to get API token, trying again")
            self:_GetAPIToken()
            return
        end

        local token = Noir.Libraries.JSON:Decode(response.Text)

        if not token then
            error("API:_GetAPIToken()", "Failed to decode API token response")
        end

        self.API_TOKEN = token.token
        self.OnReady:Fire()
        self.IsReady = true

        Addon.Logger:Info("API: Got API token "..self.API_TOKEN)
    end)
end