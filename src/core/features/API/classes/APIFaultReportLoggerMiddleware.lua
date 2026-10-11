--------------------------------------------------------
-- Classes - API Fault Report Logger Middleware
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
    A logger middleware to create fault reports for errors.
]]
---@class APIFaultReportLoggerMiddleware: NoirLoggerMiddleware
---@field New fun(self: APIFaultReportLoggerMiddleware): APIFaultReportLoggerMiddleware
Addon.Classes.APIFaultReportLoggerMiddleware = Noir.Class("APIFaultReportLoggerMiddleware", Noir.Classes.LoggerMiddleware)

--[[
    Initializes `APIFaultReportLoggerMiddleware` class instances.
]]
function Addon.Classes.APIFaultReportLoggerMiddleware:Init()
    self:InitFrom(
        Noir.Classes.LoggerMiddleware,
        "APIFaultReportLoggerMiddleware"
    )

    self:SetFilter(Noir.Enums.LogLevel.ERROR)
end

--[[
    Called when a log is created.
]]
---@param logRecord NoirLogRecord The log record
function Addon.Classes.APIFaultReportLoggerMiddleware:OnLog(logRecord)
    Addon.API:RunWhenReady(function()
        Addon.API.FaultReports:ReportFault(
            Addon.Enums.APIFaultReportSeverity.Error,
            logRecord:Format(),
            SSSW_DBG and table.concat(SSSW_DBG.stacktrace(), "\n") or nil,
            logRecord.Logger.Name
        )
    end)
end