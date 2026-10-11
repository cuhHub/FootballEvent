--------------------------------------------------------
-- Enums - API Server Event Type
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
    The type of a server event from backend.
]]
Addon.Enums.APIServerEventType = {
    Announce = "announce",
    DiscordMessage = "discord_message",
    LinkCompletion = "link_completion",
    Warn = "warn",
    Kick = "kick",
    Ban = "ban"
}

--[[
    The type of a server event from backend.
]]
---@alias APIServerEventTypeEnum
---| "announce" # Announcement
---| "discord_message" # Discord message
---| "link_completion" # Link completion
---| "warn" # Warn
---| "kick" # Kick
---| "ban" # Ban