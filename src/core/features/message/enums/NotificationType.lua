--------------------------------------------------------
-- Enums - Notification Type
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
    Enum for notification types.<br>
    This enum is more of an alias. It does not contain all Stormworks notification types
    but rather only the ones that fit situations that go successfully, with errors, etc.
]]
Addon.Enums.NotificationType = {
    SUCCESS = 4,
    ERROR = 2,
    INFO = 7,
    ANNOUNCEMENT = 11
}