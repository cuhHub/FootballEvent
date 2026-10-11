--------------------------------------------------------
-- Classes - Object Cleanup Exception
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
    A class representing a object cleanup exception.
]]
---@class ObjectCleanupException: NoirHoardable
---@field New fun(self: ObjectCleanupException, object: NoirObject, lifetime: integer): ObjectCleanupException
Addon.Classes.ObjectCleanupException = Noir.Class("ObjectCleanupException", Noir.Classes.Hoardable)

--[[
    Initializes `ObjectCleanupException` class instances.
]]
---@param object NoirObject The object to exempt from cleanup
---@param lifetime integer The lifetime of this object cleanup exception in seconds. Use 0 for permanent
function Addon.Classes.ObjectCleanupException:Init(object, lifetime)
    self:InitFrom(Noir.Classes.Hoardable, object.ID)

    --[[
        The ID of the object.
    ]]
    self.ID = object.ID

    --[[
        The lifetime of this object cleanup exception.
    ]]
    self.Lifetime = lifetime

    --[[
        Whether or not the exception is permanent.
    ]]
    self.Permanent = lifetime == 0

    --[[
        The object this cleanup exception is for.
    ]]
    self.Object = object

    --[[
        The time this object cleanup exception was created.
    ]]
    self.CreationTime = Noir.Services.TaskService:GetTimeSeconds()
end

--[[
    Called after serialization via HoarderService.
]]
function Addon.Classes.ObjectCleanupException:OnPreSerialize()
    ---@type NoirObject
    self.Object = self.Object.ID
end

--[[
    Called after deserialization via HoarderService.
]]
---@param serialized table The serialized version of this class instance
---@param lookupClasses table<string, NoirClass> The lookup classes used
function Addon.Classes.ObjectCleanupException:OnPostDeserialize(serialized, lookupClasses)
    ---@diagnostic disable-next-line: param-type-mismatch
    self.Object = Noir.Services.ObjectService:GetObject(self.Object)
end

--[[
    Saves this ObjectCleanupException via HoarderService.
]]
function Addon.Classes.ObjectCleanupException:Save()
    self:Hoard(Addon.Cleanup, "ObjectCleanupExceptions")
end

--[[
    Unsaves this ObjectCleanupException via HoarderService.
]]
function Addon.Classes.ObjectCleanupException:Unsave()
    self:Unhoard(Addon.Cleanup, "ObjectCleanupExceptions")
end

--[[
    Returns if this exception has expired.
]]
---@return boolean
function Addon.Classes.ObjectCleanupException:HasExpired()
    if self.Permanent then
        return false
    end

    local currentTime = Noir.Services.TaskService:GetTimeSeconds()
    return currentTime - self.CreationTime >= self.Lifetime
end