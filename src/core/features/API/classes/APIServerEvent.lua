--------------------------------------------------------
-- Classes - API Server Event
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
    A class representing a server event from the backend.
]]
---@class APIServerEvent: NoirDataclass
---@field New fun(self: APIServerEvent, identifier: string, type: APIServerEventTypeEnum, payload: table): APIServerEvent
---@field Identifier string The identifier of the event
---@field Type APIServerEventTypeEnum The type of the event
---@field Payload table The payload the event carries
Addon.Classes.APIServerEvent = Noir.Libraries.Dataclasses:New("APIServerEvent", {
    Noir.Libraries.Dataclasses:Field("Identifier", "string"),
    Noir.Libraries.Dataclasses:Field("Type", "string"),
    Noir.Libraries.Dataclasses:Field("Payload", "table")
})

--[[
    Returns an APIServerEvent instance from a response to a backend request.
    *classmethod*
]]
---@param response table The decoded response
---@return APIServerEvent
function Addon.Classes.APIServerEvent:FromBackendResponse(response)
    return self:New(
        response.identifier,
        response.type,
        response.payload
    )
end