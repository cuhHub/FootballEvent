--------------------------------------------------------
-- Services - Message
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
    A service that provides methods to send a message and a notification to a player.
]]
---@class Message: NoirService
Addon.Message = Noir.Services:CreateService(
    "Message",
    false,
    "A service that provides methods to send a message and a notification to a player.",
    "A barebones service that provides methods to send a message and a notification to a player.",
    {"Cuh4"}
)

--[[
    Send a message to a player/everyone via chat and notification.
]]
---@param player NoirPlayer|nil The player, or nil for everyone
---@param title string The title of the message
---@param content string The contents of the message
---@param notificationType SWNotificationTypeEnum The type of notification to send
---@param ... any Arguments to pass to content format
function Addon.Message:Send(player, title, content, notificationType, ...)
    self:SendMessage(player, title, content, ...)
    self:SendNotification(player, title, content, notificationType, ...)
end

--[[
    Sends a message to a player/everyone via chat.
]]
---@param player NoirPlayer|nil The player, or nil for everyone
---@param title string The title of the message
---@param content string The contents of the message
---@param ... any Arguments to pass to content format
function Addon.Message:SendMessage(player, title, content, ...)
    Noir.Services.MessageService:SendMessage(player, ("[%s]"):format(title), content, ...)
end

--[[
    Sends a notification to a player/everyone.
]]
---@param player NoirPlayer|nil The player, or nil for everyone
---@param title string The title of the notification
---@param content string The contents of the notification
---@param notificationType SWNotificationTypeEnum The type of notification to send
---@param ... any Arguments to pass to content format
function Addon.Message:SendNotification(player, title, content, notificationType, ...)
    Noir.Services.NotificationService:Notify(title, content, notificationType, player, ...)
end