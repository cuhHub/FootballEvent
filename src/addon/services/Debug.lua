--------------------------------------------------------
-- Services - Debug
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
    A service for general debugging.
]]
---@class Debug: NoirService
Addon.Debug = Noir.Services:CreateService(
    "Debug",
    false,
    "A service for general debugging.",
    "A service for general debugging, comes with commands, etc.",
    {"Cuh4"}
)

--[[
    Called when the service is initialized.
]]
function Addon.Debug:ServiceInit()
    --[[
        Whether or not function calls should be logged.
    ]]
    self.LogFunctionCalls = false
end

--[[
    Called when the service is started.
]]
function Addon.Debug:ServiceStart()
    self:CreateCommands()

    ---@param tracker NoirTracker
    Noir.Debugging.OnBeforeCall:Connect(function(tracker, ...)
        if not self.LogFunctionCalls then
            return
        end

        Addon.Logger:Info("%s (%.1f calls/tick) (%.6fms)", tracker.FunctionName, tracker:GetAverageCallsPerTick(), tracker:GetAverageExecutionTime())
    end)
end

--[[
    Creates debug commands.
]]
function Addon.Debug:CreateCommands()
    Noir.Services.CommandService:CreateCommand(
        "relpos",
        {"rp"},
        false,
        true,
        false,
        "",

        function(context)
            if not context.HasPermission then
                return
            end

            local pos = context.Player:GetPosition()
            local relPos = Noir.Services.RelPosService:GetRelPos(pos)
            local funcCallString = ([=[Noir.Services.RelPosService:CreateRelPos(
    "%s",
    matrix.translation(%.3f, %.3f, %.3f)
):GetGlobalPositions()[1]]=]):format(relPos.TileName, relPos.Offset[13], relPos.Offset[14], relPos.Offset[15])

            Addon.Message:Send(
                context.Player,
                "relpos",
                funcCallString,
                Addon.Enums.NotificationType.INFO,
                relPos.TileName,
                relPos.Offset[13],
                relPos.Offset[14],
                relPos.Offset[15]
            )

            Addon.API.PersistentData:SaveData("_debug_pos", funcCallString)
        end
    )

    Noir.Services.CommandService:CreateCommand(
        "position",
        {"pos"},
        false,
        true,
        false,
        "",

        function(context)
            if not context.HasPermission then
                return
            end

            local pos = context.Player:GetPosition()
            local formatted = ("matrix.translation(%.3f, %.3f, %.3f)"):format(pos[13], pos[14], pos[15])
            Addon.API.PersistentData:SaveData("_debug_pos", formatted)

            Addon.Message:Send(
                context.Player,
                "position",
                formatted.."\n(saved to db)",
                Addon.Enums.NotificationType.INFO
            )
        end
    )

    Noir.Services.CommandService:CreateCommand(
        "savedata",
        {"sd", "g_savedata"},
        false,
        true,
        false,
        "",

        function(context)
            if not context.HasPermission then
                return
            end

            Addon.Logger:Info(Noir.Libraries.Table:ToString(g_savedata))
            Noir.Services.NotificationService:Success("g_savedata", "Printed g_savedata, see logs.", context.Player)
        end
    )

    Noir.Services.CommandService:CreateCommand(
        "removewidgets",
        {},
        false,
        true,
        false,
        "",

        function(context)
            if not context.HasPermission then
                return
            end

            for _, widget in pairs(Noir.Services.UIService:GetWidgetsShownToPlayer(context.Player)) do
                widget:Remove()
            end
        end
    )

    Noir.Services.CommandService:CreateCommand(
        "raiseerror",
        {},
        false,
        true,
        false,
        "",

        function(context)
            if not context.HasPermission then
                return
            end

            error("debug", "test")
        end
    )

    Noir.Services.CommandService:CreateCommand(
        "clearservsd",
        {},
        false,
        true,
        false,
        "",

        function(context)
            if not context.HasPermission then
                return
            end

            g_savedata.Noir.Services = {}
        end
    )

    Noir.Services.CommandService:CreateCommand(
        "tile",
        {},
        false,
        true,
        false,
        "",

        function(context)
            if not context.HasPermission then
                return
            end

            local tile, success = server.getTile(context.Player:GetPosition())

            if not success then
                Addon.Message:Send(
                    context.Player,
                    "tile",
                    "failed to get tile",
                    Addon.Enums.NotificationType.ERROR
                )

                return
            end

            Addon.Message:Send(
                context.Player,
                "tile",
                tile.name,
                Addon.Enums.NotificationType.INFO
            )
        end
    )

    Noir.Services.CommandService:CreateCommand(
        "simleave",
        {"sle"},
        false,
        true,
        false,
        "",

        function(context)
            if not context.HasPermission then
                return
            end

            onPlayerLeave(
                tonumber(context.Player.Steam), ---@diagnostic disable-line: param-type-mismatch
                context.Player.Name,
                context.Player.ID,
                context.Player.Admin,
                context.Player.Auth
            )
        end
    )

    Noir.Services.CommandService:CreateCommand(
        "settps",
        {"stps"},
        false,
        true,
        false,
        "",

        function(context)
            if not context.HasPermission then
                return
            end

            Noir.Services.TPSService:SetTPS(tonumber(context.Args[1]) or 0)
        end
    )

    Noir.Services.CommandService:CreateCommand(
        "die",
        {},
        false,
        true,
        false,
        "",

        function(context)
            if not context.HasPermission then
                return
            end

            context.Player:GetCharacter():Kill()
        end
    )

    Noir.Services.CommandService:CreateCommand(
        "alocate",
        {},
        false,
        true,
        false,
        "",

        function(context)
            if not context.HasPermission then
                return
            end

            if not context.Args[1] then
                Addon.Message:Send(
                    context.Player,
                    "asset locate",
                    "missing tags argument (e.g. ?alocate tag1,tag2,tag3)",
                    Addon.Enums.NotificationType.ERROR
                )

                return
            end

            local tags = Noir.Libraries.String:Split(context.Args[1], ",")
            local assets = Addon.Assets:Find(tags)

            if #assets <= 0 then
                Addon.Message:Send(
                    context.Player,
                    "asset locate",
                    "no assets found",
                    Addon.Enums.NotificationType.ERROR
                )

                return
            end

            ---@param asset Asset
            local list = Noir.Libraries.Table:Map(assets, function(index, asset)
                return asset:Format() -- contains location too
            end)

            Addon.Message:Send(
                context.Player,
                "asset locate",
                "assets matching tags: '%s':\n%s",
                Addon.Enums.NotificationType.INFO,
                table.concat(tags, ", "),
                Addon.Libs.String:BulletList(list, "-")
            )
        end
    )

    Noir.Services.CommandService:CreateCommand(
        "debug",
        {"deb"},
        false,
        true,
        false,
        "",

        function(context)
            if not context.HasPermission then
                return
            end

            local command = context.Args[1]

            if not command then
                Addon.Message:Send(context.Player, "debug", "missing argument", Addon.Enums.NotificationType.INFO)
                return
            end

            if command:lower() == "track" then
                Noir.Debugging:TrackAll("Addon", Addon)
            elseif command:lower() == "track_specific" then
                local path = Noir.Libraries.String:Split(context.Args[2], ".")
                local target, parent, name = Addon, _ENV, "Addon"

                for _, index in pairs(path) do
                    parent = target
                    target = target[index]

                    if not target then
                        Addon.Message:Send(
                            context.Player,
                            "debug",
                            "could not find "..name.."."..index,
                            Addon.Enums.NotificationType.ERROR
                        )

                        return
                    end

                    name = name.."."..index
                end

                if type(target) == "function" then
                    local index = Noir.Libraries.Table:Find(parent, target)
                    parent[index] = Noir.Debugging:TrackFunction(name, target):Mount()
                elseif type(target) == "table" then
                    Noir.Debugging:TrackAll(name, target)
                else
                    Addon.Message:Send(
                        context.Player,
                        "debug",
                        "cant track value. bad type",
                        Addon.Enums.NotificationType.ERROR
                    )
                end
            elseif command:lower() == "tcall" then
                self.LogFunctionCalls = not self.LogFunctionCalls
            elseif command:lower() == "toggle" then
                Noir.Debugging.Enabled = not Noir.Debugging.Enabled

                if Noir.Debugging.Enabled then
                    Addon.Message:Send(context.Player, "debug", "enabled debug", Addon.Enums.NotificationType.INFO)
                else
                    Addon.Message:Send(context.Player, "debug", "disabled debug", Addon.Enums.NotificationType.INFO)
                end
            elseif command:lower() == "stats" then
                Noir.Debugging:ShowLastCalledTracked()
                Noir.Debugging:ShowLeastPerformantTracked()
                Noir.Debugging:ShowMostCalledTracked()
                Noir.Debugging:ShowMostCalledPerTickTracked()
            elseif command:lower() == "calls" then
                local trackers = Noir.Debugging:GetTrackedFunctions(true)

                table.sort(trackers, function(a, b)
                    return (a:GetCallCount() * a:GetAverageCallsPerTick()) > (b:GetCallCount() * b:GetAverageCallsPerTick())
                end)

                Noir.Debugging:_PresentTrackers("most called generally (calls/tick + calls)", trackers)
            elseif command:lower() == "track_server" then
                Noir.Debugging:TrackAll("server", server, {[server.getTimeMillisec] = true})
            elseif command:lower() == "sd" then
                Addon.Logger:Info(Noir.Libraries.Table:ToString(g_savedata))
            else
                Addon.Message:Send(context.Player, "debug", "unknown: ", Addon.Enums.NotificationType.INFO)
            end
        end
    )
end