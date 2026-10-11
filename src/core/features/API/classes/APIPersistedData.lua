--------------------------------------------------------
-- Classes - API Persisted Data
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
    A class representing persisted data.
]]
---@class APIPersistedData: NoirDataclass
---@field New fun(self: APIPersistedData, key: string, value: string, createdAt: number, lastUpdatedAt: number): APIPersistedData
---@field Key string The key the data is under (index)
---@field Value string The value of the data
---@field CreatedAt number The time the data was created
---@field LastUpdatedAt number The time the data was last updated
Addon.Classes.APIPersistedData = Noir.Libraries.Dataclasses:New("APIPersistedData", {
    Noir.Libraries.Dataclasses:Field("Key", "string"),
    Noir.Libraries.Dataclasses:Field("Value", "string"),
    Noir.Libraries.Dataclasses:Field("CreatedAt", "number"),
    Noir.Libraries.Dataclasses:Field("LastUpdatedAt", "number")
})

--[[
    Returns an APIPersistedData instance from a response to a backend request.
    *classmethod*
]]
---@param response table The decoded response
---@return APIPersistedData
function Addon.Classes.APIPersistedData:FromBackendResponse(response)
    return self:New(
        response.key,
        response.value,
        response.created_at,
        response.last_updated_at
    )
end