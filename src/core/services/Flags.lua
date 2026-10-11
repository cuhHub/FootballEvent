--------------------------------------------------------
-- Services - Flags
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
    A service that add flags - a way to toggle features during runtime.
]]
---@class Flags: NoirService
Addon.Flags = Noir.Services:CreateService(
    "Flags",
    false,
    "A service that add flags - a way to toggle features during runtime.",
    "A service that add flags - a way to toggle features during runtime.",
    {"Cuh4"}
)

--[[
    Called when the service is initialized.
]]
function Addon.Flags:ServiceInit()
    --[[
        A table of all flags.
    ]]
    ---@type table<string, boolean>
    self.Flags = {}
end

--[[
    Called when the service is started.
]]
function Addon.Flags:ServiceStart()
    self:CreateCommands()
end

--[[
    Registers a flag.
]]
---@param name string The name of the flag
---@param value boolean The default value of the flag
function Addon.Flags:RegisterFlag(name, value)
    if self:HasFlag(name) then
        error("Addon.Flags:RegisterFlag()", "Flag %s already exists.", name)
    end

    self.Flags[name] = value
    Addon.Logger:Info("Flags: Registered flag %s with value %s", name, value)
end

--[[
    Sets a flag.
]]
---@param name string The name of the flag
---@param value boolean The vnew alue of the flag
function Addon.Flags:SetFlag(name, value)
    if not self:HasFlag(name) then
        error("Addon.Flags:SetFlag()", "Flag %s does not exist.", name)
    end

    self.Flags[name] = value
    Addon.Logger:Info("Flags: Set flag %s to %s", name, value)
end

--[[
    Toggles a flag.
]]
---@param name string The name of the flag
function Addon.Flags:ToggleFlag(name)
    if not self:HasFlag(name) then
        error("Addon.Flags:ToggleFlag()", "Flag %s does not exist.", name)
    end

    self:SetFlag(name, not self:IsEnabled(name))
end

--[[
    Gets a flag's current value.
]]
---@param name string The name of the flag
---@return boolean
function Addon.Flags:IsEnabled(name)
    if not self:HasFlag(name) then
        error("Addon.Flags:GetFlag()", "Flag %s does not exist.", name)
    end

    return self:GetFlags()[name]
end

--[[
    Returns if a flag exists.
]]
---@param name string The name of the flag
---@return boolean
function Addon.Flags:HasFlag(name)
    return self:GetFlags()[name] ~= nil
end

--[[
    Returns all flags.
]]
---@return table<string, boolean>
function Addon.Flags:GetFlags()
    return self.Flags
end

--[[
    Creates commands.
]]
function Addon.Flags:CreateCommands()
    Noir.Services.CommandService:CreateCommand(
        "aflags",
        {},
        false,
        true,
        false,
        "",

        function(context)
            local flags = self:GetFlags()

            ---@type table<integer, string>
            local formatted = {}

            for name, value in pairs(flags) do
                table.insert(formatted, ("%s: %s"):format(name, value and "Enabled" or "Disabled"))
            end

            Addon.Message:Send(
                context.Player,
                "Flags",
                Addon.Libs.String:BulletList(formatted, "-"),
                Addon.Enums.NotificationType.INFO
            )
        end
    )

    Noir.Services.CommandService:CreateCommand(
        "aflag",
        {},
        false,
        true,
        false,
        "",

        function(context)
            local flagName = context.Args[1]

            if not flagName then
                Addon.Message:Send(
                    context.Player,
                    "Flags",
                    "Missing flag name",
                    Addon.Enums.NotificationType.ERROR
                )

                return
            end

            if not self:HasFlag(flagName) then
                Addon.Message:Send(
                    context.Player,
                    "Flags",
                    "Flag does not exist",
                    Addon.Enums.NotificationType.ERROR
                )

                return
            end

            Addon.Message:Send(
                context.Player,
                "Flags",
                "%s: %s",
                Addon.Enums.NotificationType.INFO,
                flagName,
                self:IsEnabled(flagName) and "Enabled" or "Disabled"
            )
        end
    )

    Noir.Services.CommandService:CreateCommand(
        "atflag",
        {},
        false,
        true,
        false,
        "",

        function(context)
            local flagName = context.Args[1]

            if not flagName then
                Addon.Message:Send(
                    context.Player,
                    "Flags",
                    "Missing flag name",
                    Addon.Enums.NotificationType.ERROR
                )

                return
            end

            if not self:HasFlag(flagName) then
                Addon.Message:Send(
                    context.Player,
                    "Flags",
                    "Flag does not exist",
                    Addon.Enums.NotificationType.ERROR
                )

                return
            end

            self:ToggleFlag(flagName)

            Addon.Message:Send(
                context.Player,
                "Flags",
                "Toggled flag '%s' -> %s",
                Addon.Enums.NotificationType.INFO,
                flagName,
                self:IsEnabled(flagName) and "Enabled" or "Disabled"
            )
        end
    )
end