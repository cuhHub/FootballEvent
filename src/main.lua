--------------------------------------------------------
-- Main
--------------------------------------------------------

--[[
    Copyright (C) 2026 cuhHub - All Rights Reserved
    - Unauthorized copying of this file, via any medium is strictly prohibited
    - Proprietary and confidential
]]

-------------------------------
-- // Main
-------------------------------

--[[
    The logger for this addon.
]]
Addon.Logger = Noir.Libraries.Logging:CreateLogger("Football Event v"..Config.Version)
Addon.Logger:AttachMiddleware(Noir.Classes.DebugLogLoggerMiddleware:New())
Addon.Logger:AttachMiddleware(Addon.Classes.APIFaultReportLoggerMiddleware:New())

---@param source string
---@param message string
Noir.Debugging.OnError:Connect(function(source, message)
    Addon.Logger:Error("%s: %s", source, message)
end)

Addon.Logger:SetFormatter(function(record)
    local start = ("[Server #%s] [%s] [%s] [%sms] (%s): "):format(
        Addon.API.Server.Initialized and Addon.API.Server.ServerData.ID or "N/A",
        Noir.AddonName,
        Noir.Classes.Logger:GetLevelName(record.Level),
        record.Time,
        record.Logger.Name
    )

    return start..record.Message:gsub("\n", "\n"..start)
end)

if SSSW_DBG then
    if SSSW_DBG.level == "full" then
        SSSW_DBG.expected_stack_onTick = {"_ENV[name]", "`existing(...)`"}
    else
        SSSW_DBG.expected_stack_onTick = {"_ENV[name]"}
    end

    SSSW_DBG.expected_stack_httpReply = SSSW_DBG.expected_stack_onTick
    SSSW_DBG.expected_stack_onCustomCommand  = SSSW_DBG.expected_stack_onTick

    Noir.Callbacks:_InstantiateCallback("onTick", true)
    Noir.Callbacks:_InstantiateCallback("httpReply", true)
    Noir.Callbacks:_InstantiateCallback("onCustomCommand", true)

    SSSW_DBG.error_handler = function(info)
        Addon.Logger:Error("Error detected by ssswtool: %s @ line %d (column %d)\n%s", info.name, info.line, info.column, table.concat(SSSW_DBG.stacktrace(), "\n"))
    end
end

Noir.Started:Once(function()
    Addon.Logger:Info("Version: %s", Config.Version)
end)

-- Start Noir
Noir:Start()