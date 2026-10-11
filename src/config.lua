--------------------------------------------------------
-- Config
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
    A table storing configuration values for use throughout the addon.
]]
Config = {}
Config.Version = "1.0.0"

--[[
    API service config.
]]
Config.API = {}
Config.API.URL = "http://localhost:1500/"
Config.API.Port = 1500
Config.API.ConversionResponsesFetchInterval = 2.5 -- in seconds
Config.API.ServerEventFetchInterval = 5 -- in seconds
Config.API.ShouldFetchServerEvents = false
Config.API.ShouldFetchConversionRequestResponses = true
Config.API.ConversionRequestTimeout = 15 -- in seconds

--[[
    UI service related config.
]]
Config.UI = {}
Config.UI.UpdateInterval = 0.01 -- seconds

--[[
    Cleanup service related config.
]]
Config.Cleanup = {}
Config.Cleanup.OilSpillCleanupInterval = 1 -- seconds
Config.Cleanup.RadiationCleanupInterval = 1 -- seconds
Config.Cleanup.ObjectCleanupInterval = 1 -- seconds (for exception expiry check)
Config.Cleanup.ObjectCleanupBatchSize = 50 -- objects processed per tick

Config.Cleanup.ObjectTypeExceptions = {
    [66] = {lifetime = 1200}, -- c4
    [67] = {lifetime = 10}, -- grenade
    [72] = {lifetime = 0}, -- creatures
    [59] = {lifetime = 0}, -- animals
    [1] = {lifetime = 0}, -- characters
    [74] = {lifetime = 0}, -- fishing lure
    [68] = {lifetime = 0}, -- chaff flares
    [64] = {lifetime = 5}, -- ammo shell
    [71] = {lifetime = 300}, -- glowstick
    [73] = {lifetime = 0}, -- drill rod
    [57] = {lifetime = 120}, -- flare (handheld)
    [62] = {lifetime = 120}, -- flare (flare gun projectile)
    [63] = {lifetime = 120} -- flare (vehicle flare projectile),
}

--[[
    Football Event related config.
]]
Config.Football = {}
Config.Football.NeededGoalsToWin = 5
Config.Football.MinimumPlayers = 2