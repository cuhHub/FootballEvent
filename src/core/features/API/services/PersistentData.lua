--------------------------------------------------------
-- Services - API - Persistent Data
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
    Provides an interface for saving and fetching data.
]]
---@class API.PersistentData: NoirService
Addon.API.PersistentData = Noir.Services:CreateService("API.PersistentData")

--[[
    Saves data under a key.
]]
---@param key string The key to save the value under
---@param value string The string to save (use JSON for non-string data)
function Addon.API.PersistentData:SaveData(key, value)
    Addon.API.Conversion:HTTPPOST(Config.API.URL..Addon.Enums.APIServiceRoute.PersistentData..key, nil, function(response)
        Addon.Logger:Warning("API.PersistentData:SaveData(): Failed to save data! Response: "..response.Text)
    end, nil, {
        value = value
    })
end

--[[
    Deletes data under a key.
]]
---@param key string The key to delete
function Addon.API.PersistentData:DeleteData(key)
    Addon.API.Conversion:HTTPDELETE(Config.API.URL..Addon.Enums.APIServiceRoute.PersistentData..key, nil, function(response)
        Addon.Logger:Warning("API.PersistentData:DeleteData(): Failed to delete data! Response: "..response.Text)
    end)
end

--[[
    Returns the data under a key.
]]
---@param key string The key to retrieve the data for
---@param callback fun(data: APIPersistedData|nil) The callback called when the data is retrieved
function Addon.API.PersistentData:GetData(key, callback)
    return Addon.API.Conversion:HTTPGET(Config.API.URL..Addon.Enums.APIServiceRoute.PersistentData..key, function(response)
        local decoded = Noir.Libraries.JSON:Decode(response.Text)

        if not decoded then
            Addon.Logger:Warning("API.PersistentData:GetData(): Failed to decode persisted data: "..response.Text)
            return
        end

        local data = Addon.Classes.APIPersistedData:FromBackendResponse(decoded)
        callback(data)
    end, function(response)
        local decoded = Noir.Libraries.JSON:Decode(response.Text)

        if not decoded then
            Addon.Logger:Warning("API.PersistentData:GetData(): Failed to decode persisted data error response: "..response.Text)
            return
        end

        if decoded.layer and decoded.layer == 0 then
            callback(nil)
        else
            Addon.Logger:Warning("API.PersistentData:GetData(): Got an unexpected error for fetching persisted data at key %s: "..response.Text, key)
        end
    end)
end