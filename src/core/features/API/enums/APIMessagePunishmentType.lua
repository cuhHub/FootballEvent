--------------------------------------------------------
-- Enums - API Message Punishment Type
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
    The type of a punishment for a message from the backend.
]]
Addon.Enums.APIMessagePunishmentType = {
    NoPunishment = 0,
    RequiresWarn = 1,
    RequiresKick = 2,
    RequiresBan = 3
}

--[[
    The type of a server event from backend.
]]
---@alias APIMessagePunishmentTypeEnum
---| 0 # No punishment
---| 1 # Warn
---| 2 # Kick
---| 3 # Ban