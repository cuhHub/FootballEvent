--------------------------------------------------------
-- Classes - API Message Punishment
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
    A class representing a punishment for a message if it was flagged.
]]
---@class APIMessagePunishment: NoirDataclass
---@field New fun(self: APIMessagePunishment, punishmentType: APIMessagePunishmentTypeEnum, punishmentDuration: number|nil): APIMessagePunishment
---@field PunishmentType APIMessagePunishmentTypeEnum The type of punishment
---@field PunishmentDuration number|nil The duration of the punishment in days
Addon.Classes.APIMessagePunishment = Noir.Libraries.Dataclasses:New("APIMessagePunishment", {
    Noir.Libraries.Dataclasses:Field("PunishmentType", "number"),
    Noir.Libraries.Dataclasses:Field("PunishmentDuration", "number", "nil")
})

--[[
    Returns an APIMessagePunishment instance from a response to a backend request.
    *classmethod*
]]
---@param response table The decoded response
---@return APIMessagePunishment
function Addon.Classes.APIMessagePunishment:FromBackendResponse(response)
    return self:New(
        response.punishment_type,
        response.punishment_duration
    )
end