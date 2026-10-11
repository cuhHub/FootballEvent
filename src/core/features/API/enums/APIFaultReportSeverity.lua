--------------------------------------------------------
-- Enums - API Fault Report Severity
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
    Represents the severity of a fault report.
]]
Addon.Enums.APIFaultReportSeverity = {
    Warning = 0,
    Critical = 1,
    Error = 2
}

--[[
    Represents the severity of a fault report.
]]
---@alias APIFaultReportSeverity
---| 0 # Warning
---| 1 # Critical
---| 2 # Error