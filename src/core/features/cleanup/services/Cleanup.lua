--------------------------------------------------------
-- Services - Cleanup
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
    A service for cleaning up objects, radiation, etc.
]]
---@class Cleanup: NoirService
Addon.Cleanup = Noir.Services:CreateService(
    "Cleanup",
    false,
    "A service for cleaning up objects, radiation, etc.",
    "A service for cleaning up objects, radiation, etc. Supports adding object exceptions, etc.",
    {"Cuh4"}
)

--[[
    Called when this service is initialized.
]]
function Addon.Cleanup:ServiceInit()
    --[[
        How many IDs to iterate through per cleanup cycle.
    ]]
    ---@type integer
    self.ID_BATCH_SIZE = Config.Cleanup.ObjectCleanupBatchSize or 50

    --[[
        The tick interval for object cleanup updates.
    ]]
    ---@type integer
    self._ObjectCleanupUpdateIntervalTicks = 10

    --[[
        The last cleaned up object ID.
    ]]
    ---@type integer
    self._LastCleanupObjectID = 0

    --[[
        Cached maximum object ID from FindCurrentObjectID().
    ]]
    ---@type integer|nil
    self._CachedMaxObjectID = nil

    --[[
        Whether initial cleanup has completed.
    ]]
    ---@type boolean
    self._InitialCleanupComplete = false

    --[[
        Object exceptions indexed by object ID.
    ]]
    ---@type table<integer, ObjectCleanupException>
    self.ObjectCleanupExceptions = {}

    --[[
        Objects we have already recognized, indexed by object ID.<br>
        Used for object type exceptions. There's probably a better way to do this, but I am going
        to go insane and would rather go with this utter horseshit for now.
    ]]
    ---@type table<integer, boolean>
    self._ObjectTypeExceptionsRecognizedObjects = {}
end

--[[
    Called when this service is started.
]]
function Addon.Cleanup:ServiceStart()
    --[[
        A repeated task for cleaning radiation.
    ]]
    self.RadiationCleanupTask = Noir.Services.TaskService:AddTimeTask(function()
        server.clearRadiation()
    end, Config.Cleanup.RadiationCleanupInterval, nil, true)

    --[[
        A repeated task for cleaning oil spills.
    ]]
    self.OilSpillCleanupTask = Noir.Services.TaskService:AddTimeTask(function()
        server.clearOilSpill()
    end, Config.Cleanup.OilSpillCleanupInterval, nil, true)

    --[[
        A task for checking exception expiry (less frequent - every 10 seconds).
    ]]
    self.ExceptionExpiryTask = Noir.Services.TaskService:AddTimeTask(function()
        self:CheckExceptionsExpiry()
    end, 10, nil, true)

    self:ScheduleInitialCleanup()

    Noir.Services.HoarderService:AddCheckpoint(
        self,
        Addon.Classes.ObjectCleanupException,

        ---@param instance ObjectCleanupException
        function(instance)
            Addon.Logger:Info("Cleanup: Loading object cleanup exception for obj %d", instance.Object.ID)
            return true
        end
    )

    Noir.Services.HoarderService:LoadAll(
        self,
        "ObjectCleanupExceptions",
        self.ObjectCleanupExceptions,
        Addon.Classes.ObjectCleanupException,
        {
            Noir.Classes.Object
        }
    )
end

--[[
    Finds the current object ID.
]]
---@return integer
function Addon.Cleanup:FindCurrentObjectID()
    local temporaryObject = Noir.Services.ObjectService:SpawnObject(0, matrix.translation(0, 0, 0))
    temporaryObject:Despawn()

    return temporaryObject.ID
end

--[[
    Exempts an object from being cleaned up.
]]
---@param object NoirObject The object to exempt from cleanup
---@param lifetime integer The lifetime of this object cleanup exception in seconds. Use 0 for permanent
function Addon.Cleanup:ExemptObjectFromCleanup(object, lifetime)
    if self:IsObjectExemptFromCleanup(object) then
        Addon.Logger:Info(
            "Cleanup: Object ID %d is already exempt from cleanup, ignoring",
            object.ID
        )

        return
    end

    local exception = Addon.Classes.ObjectCleanupException:New(object, lifetime)
    exception:Save()

    self.ObjectCleanupExceptions[object.ID] = exception

    Addon.Logger:Info(
        "Cleanup: Exempted object ID %d from cleanup for %d second(s)",
        object.ID,
        lifetime
    )
end

--[[
    Returns if an object is exempt from being cleaned up.
]]
---@param object NoirObject The object to check
---@return boolean
function Addon.Cleanup:IsObjectExemptFromCleanup(object)
    local exception = self.ObjectCleanupExceptions[object.ID]

    if not exception then
        return false
    end

    if exception:HasExpired() then
        self:RemoveObjectCleanupException(object)
        return false
    end

    return true
end

--[[
    Removes an object's exemption from being cleaned up.
]]
---@param object NoirObject The object to remove the exemption for
function Addon.Cleanup:RemoveObjectCleanupException(object)
    local exception = self.ObjectCleanupExceptions[object.ID]

    if not exception then
        Addon.Logger("Cleanup: Attempted to remove cleanup exception for object ID %d but it is not exempt from cleanup", object.ID)
        return
    end

    exception:Unsave()
    self.ObjectCleanupExceptions[object.ID] = nil
    self._ObjectTypeExceptionsRecognizedObjects[object.ID] = nil

    Addon.Logger:Info("Cleanup: Removed cleanup exception for object ID %d", object.ID)
end

--[[
    Checks for object type exception.<br>
    Use before checking if object is exempt from cleanup.
]]
---@param object NoirObject The object to check
function Addon.Cleanup:_HandleObjectTypeException(object)
    if self._ObjectTypeExceptionsRecognizedObjects[object.ID] then
        return
    end

    local data = object:GetData()

    if not data then
        return
    end

    local exceptionConfig = Config.Cleanup.ObjectTypeExceptions[data.object_type]

    if not exceptionConfig then
        return
    end

    local lifetime = exceptionConfig.lifetime
    self:ExemptObjectFromCleanup(object, lifetime)

    self._ObjectTypeExceptionsRecognizedObjects[object.ID] = true

    Addon.Logger:Info(
        "Cleanup: Exempted object ID %d of type %d from cleanup for %d second(s) due to object type exception",
        object.ID,
        data.object_type,
        lifetime
    )
end

--[[
    Cleans up an object by its ID.
]]
---@param objectID integer The ID of the object to clean up.
---@param noSetID boolean|nil Whether to not set the last cleaned up object ID. Defaults to false.
---@return boolean
function Addon.Cleanup:CleanupObjectByID(objectID, noSetID)
    local object = Noir.Services.ObjectService:GetObject(objectID)

    if not object:Exists() then
        return false
    end

    return self:CleanupObject(object, noSetID)
end

--[[
    Cleans up an object.
]]
---@param object NoirObject The object to clean up.
---@param noSetID boolean|nil Whether to not set the last cleaned up object ID. Defaults to false.
---@return boolean
function Addon.Cleanup:CleanupObject(object, noSetID)
    if self:IsObjectExemptFromCleanup(object) then
        return false
    end

    self:_HandleObjectTypeException(object)

    if self:IsObjectExemptFromCleanup(object) then
        return false
    end

    object:Despawn()
    Addon.Logger:Info("Cleanup: Cleaned up object ID %d", object.ID)

    if not noSetID then
        self._LastCleanupObjectID = object.ID
    end

    return true
end

--[[
    Performs initial cleanup over multiple ticks to avoid blocking.
]]
function Addon.Cleanup:PerformInitialCleanup()
    Addon.Logger:Info("Cleanup: Performing initial cleanup (deferred)")
end

--[[
    Schedules the initial cleanup using IterateOverTicks.
]]
function Addon.Cleanup:ScheduleInitialCleanup()
    if self._InitialCleanupComplete then
        return
    end

    local currentMaxID = self:FindCurrentObjectID()
    local objectIDs = {}

    for i = 0, currentMaxID do
        table.insert(objectIDs, i)
    end

    Noir.Services.TaskService:IterateOverTicks(objectIDs, self.ID_BATCH_SIZE or 50, function(_, objectID, _, completed)
        if completed then
            self._InitialCleanupComplete = true
            Addon.Logger:Info("Cleanup: Initial cleanup completed")

            self._CachedMaxObjectID = currentMaxID
            self._LastCleanupObjectID = currentMaxID
            self:ScheduleObjectCleanup()
        else
            self:CleanupObjectByID(objectID, true)
        end
    end)
end

--[[
    Cleans up objects over multiple ticks to avoid stuttering.
]]
function Addon.Cleanup:PromptObjectCleanup()
    local currentMaxID = self._CachedMaxObjectID or 0

    local batchSize = self.ID_BATCH_SIZE or 50
    local startID = self._LastCleanupObjectID + 1
    local endID = startID + batchSize - 1

    if endID > currentMaxID then
        endID = currentMaxID
    end

    for objectID = startID, endID do
        self:CleanupObjectByID(objectID)
    end

    self._LastCleanupObjectID = endID

    if endID >= currentMaxID then
        self._CachedMaxObjectID = self:FindCurrentObjectID()
        self._LastCleanupObjectID = 0
    end
end

--[[
    Schedules the object cleanup for the next tick.
]]
function Addon.Cleanup:ScheduleObjectCleanup()
    Noir.Services.TaskService:AddTickTask(function()
        self:PromptObjectCleanup()
        self:ScheduleObjectCleanup()
    end, self._ObjectCleanupUpdateIntervalTicks or 10)
end

--[[
    Checks for expired object cleanup exceptions.
]]
function Addon.Cleanup:CheckExceptionsExpiry()
    for objectID, exception in pairs(self.ObjectCleanupExceptions) do
        if exception:HasExpired() then
            self:CleanupObject(exception.Object, true) -- this will remove the exception too
        elseif not exception.Object:Exists() then
            self:RemoveObjectCleanupException(exception.Object)
        end
    end
end