--------------------------------------------------------
-- Classes - API Message
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
    A class representing a message sent by a player.
]]
---@class APIMessage: NoirDataclass
---@field New fun(self: APIMessage, sentAt: number, content: string, sender: APIPlayer, isFlagged: boolean, punishment: APIMessagePunishment): APIMessage
---@field SentAt number The time the message was sent
---@field Content string The content of the message
---@field Sender APIPlayer The player who sent the message
---@field IsFlagged boolean If the message was flagged as inappropriate
---@field Punishment APIMessagePunishment The punishment to be given to the player if the message was flagged
Addon.Classes.APIMessage = Noir.Libraries.Dataclasses:New("APIMessage", {
    Noir.Libraries.Dataclasses:Field("SentAt", "number"),
    Noir.Libraries.Dataclasses:Field("Content", "string"),
    Noir.Libraries.Dataclasses:Field("Sender", "class"), -- APIPlayer
    Noir.Libraries.Dataclasses:Field("IsFlagged", "boolean"),
    Noir.Libraries.Dataclasses:Field("Punishment", "class") -- APIMessagePunishment
})

--[[
    Returns an APIMessage instance from a response to a backend request.
    *classmethod*
]]
---@param response table The decoded response
---@return APIMessage
function Addon.Classes.APIMessage:FromBackendResponse(response)
    return self:New(
        response.sent_at,
        response.content,
        Addon.Classes.APIPlayer:FromBackendResponse(response.sender),
        response.is_flagged,
        Addon.Classes.APIMessagePunishment:FromBackendResponse(response.punishment)
    )
end