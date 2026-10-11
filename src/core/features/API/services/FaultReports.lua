--------------------------------------------------------
-- Services - API - Fault Reports
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
    Handles requests to cuhHub's Fault Reporting Service.
]]
---@class API.FaultReports: NoirService
Addon.API.FaultReports = Noir.Services:CreateService("API.FaultReports")

--[[
    Reports a fault.
]]
---@param severity APIFaultReportSeverity The severity of the fault report
---@param message string The message to be used in the fault report
---@param stacktrace string|nil An optional stacktrace to attach to the fault report
---@param deeperName string|nil The deeper name to be used in the fault report (e.g. the name of a service)
function Addon.API.FaultReports:ReportFault(severity, message, stacktrace, deeperName)
    Addon.API.Conversion:HTTPPOST(Config.API.URL..Addon.Enums.APIServiceRoute.FaultReports, nil, function(response)
        Addon.Logger:Warning("API.FaultReports:ReportFault(): Failed to report fault")
    end, nil, {
        severity = severity,
        source = Addon.Enums.APIFaultReportSource.Addon,
        name = Noir.AddonName,
        deeper_name = deeperName,
        message = message,
        stacktrace = stacktrace
    })
end