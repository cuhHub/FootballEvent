--------------------------------------------------------
-- Enums - API Service Route
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
    Routes for all backend services.
]]
Addon.Enums.APIServiceRoute = {
    Conversion = "conversion/",
    Tokens = "tokens/",
    Servers = "servers/",
    Players = "players/",
    Messages = "messages/",
    PersistentData = "persistent-data/",
    FaultReports = "fault-reports/"
}

--[[
    A route for a backend service.
]]
---@alias APIServiceRouteEnum
---| "conversion/" # Conversion Service
---| "tokens/" # Token Service
---| "servers/" # Server Service
---| "players/" # Player Service
---| "messages/" # Message Service
---| "persistent-data/" # Persistent Data Service
---| "fault-reports/" # Fault Reporting Service